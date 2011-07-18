---
layout: default
author: sam
title: Managing Cassandra's Schema from Rails
synopsis: Our approach to managing our cassandra cluster's schema using rails, rake, and capistrano.
---

The other day I was tracking down a bug on one of our rails
projects that uses Cassandra as its primary data store.  I needed
to find a way to manage changes to the Cassandra schema across
all of our development, and production boxes.

Rails normally uses ActiveRecord Migrations to manage an
application's schema.  Obviously these don't work with Cassandra
since it is not a relational database.  Fortunately we were able
to quickly create a system for managing Cassandra's schema from
the rails app.  It's brand new so YMMV, but I thought the
approach might be useful to others trying to use Cassandra from
rails.


Declarative Schema
--

Column families and their attributes are defined in a YAML file.
Our project has a `schema.yml` file that looks like this:

{% highlight yaml %}
---
ReportHandles:
  comparator_type: 'UTF8Type'
Reports:
  column_type: Super
  comparator_type: 'UTF8Type'
Runs:
  column_type: Super
  default_validation_class: 'BytesType'
{% endhighlight %}

This file defines all of our column families and the properties
such as `comparator_type` which we care about.  This differs from
Rails' built-in approach to migrations.  Instead of defining a
series of migrations that are applied in order, we declare the
schema that we want, and the system brings Cassandra in line with
it.  This felt like a simpler approach for our use case, and made
sense since Cassandra (not being a relational db) has a simpler,
more flexible schema system, and less dependency between column
families than, say, MySQL tables.  You might look at
[active_column](http://blog.carbonfive.com/2011/01/06/database-migrations-for-cassandra-with-activecolumn/)
if you want Cassandra migrations that are closer in style to
ActiveRecord.

To accomplish the actual schema changes we have a `Schema` module
that looks like this:


{% highlight ruby %}
module Schema
  def self.migrate
    config.each do |(name, properties)|
      migrate_column_family(name, properties)
    end
    wait_for_schema_agreement
    schema
  end

  def self.schema_agreement?
    cassandra_client.schema_agreement?
  end

  def self.config
    @config ||=  config!
  end

  def self.config!
    YAML.load_file(File.join(Config.root, 'db', 'schema.yml'))
  end

  def self.wait_for_schema_agreement
    return if schema_agreement?
    secs = 90
    Timeout.timeout(secs) do
      puts "waiting up to #{secs} seconds for schema agreement"
      until schema_agreement?
        print '.'
      end
      puts
      puts "done"
    end
  end

  # Migrate a column family to a desired state.
  # NB. Only properties that are explicitly declared are set.
  # Removing a value
  # from properties will not reset it back to default, it will
  # leave it in its
  # current state.
  def self.migrate_column_family(column_family_name, properties = {})
    wait_for_schema_agreement
    cf_def = find_or_initialize_column_family(column_family_name)
    properties.each do |property, value|
      cf_def.send "#{property}=", value
    end

    if column_family_exists? cf_def.name
      cassandra_client.update_column_family cf_def
    else
      cassandra_client.add_column_family cf_def
    end
  end

  def self.find_or_initialize_column_family(name)
    cf_def = column_family(name.to_s) || (
      cf_def = CassandraThrift::CfDef.new
      cf_def.keyspace = cassandra_client.keyspace
      cf_def.name = name.to_s
      cf_def
    )
  end

  # SCHEMA INTROSPECTION
  def self.column_family_exists?(name)
    column_families.map(&:name).include? name.to_s
  end

  def self.schema
    cassandra_client.schema
  end

  def self.column_families
    schema.cf_defs
  end

  def self.column_family(name)
    column_families.detect{|cf| cf.name == name.to_s}
  end

end
{% endhighlight %}

It assumes that you have a `cassandra_client` method defined, and
that the Keyspace you're managing exists.  At some point I may
clean this up and release it as a gem but, like I said, for now
YMMV.  I've omitted the specs for brevity, but you can see them
on [gist](https://gist.github.com/1090146).

Cluster schema does not yet agree...
--

When I first ran this against a clustered Cassandra setup I
started getting *cluster schema does not yet agree* messages,
followed by a failure.  It turns out Cassandra has the concept of
_schema agreement_.  This makes perfect sense when you consider
that Cassandra is distributed, and fault tolerant.  Schema
changes have to be propagated through the cluster, until
eventually all nodes agree.  It seems that until there is
agreement, you can't make further schema changes.  To deal with
this the `Schema` manager waits for schema agreement before
making changes to the column family:

{% highlight ruby %}
def self.migrate_column_family(column_family_name, properties = {})
  wait_for_schema_agreement
  cf_def = find_or_initialize_column_family(column_family_name)
...
{% endhighlight %}

Waiting for the schema to propagate usually just takes a second
and is easy to do:

{% highlight ruby %}
def self.wait_for_schema_agreement
  return if schema_agreement?
  secs = 90
  Timeout.timeout(secs) do
    puts "waiting up to #{secs} seconds for schema agreement"
    until schema_agreement?
      print '.'
    end
    puts
    puts "done"
  end
end
{% endhighlight %}

Integrating with Rake and Capistrano
--

I wanted to keep the workflow around schema management as close
to the rails conventions as possible.  The schema can be brought
up to date locally by running `rake cassandra:migrate` which is
defined as:

{% highlight ruby %}
namespace :cassandra do
  desc "Migrate to the current cassandra schema"
  task :migrate do
    require File.expand_path(File.join(Config.root, 'lib', 'schema'))
    Schema.migrate
    puts "Migrated to this Schema:"
    puts *Schema.column_families.map(&:inspect)
  end
end
{% endhighlight %}

Hooking it up to our Capistrano deploy was also easy.  By
overriding the `deploy:migrate` task this gets hooked into our
deploy process in place of ActiveRecord Migrations.

{% highlight ruby %}
namespace :deploy do
  task :migrate do
    run "cd #{release_path} && RAILS_ENV=#{stage} rake cassandra:migrate"
  end
end
{% endhighlight %}

Now running the standard `cap deploy:migrations` task deploys the
codebase and brings the Cassandra schema up to date.
