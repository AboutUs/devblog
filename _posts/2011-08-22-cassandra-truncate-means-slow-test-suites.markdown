---
layout: default
author: sam
synopsis: How using Cassandra's truncate (or clear_keyspace) command made our tests super slow, and how we sped them up.
---

We've been using Cassandra as the primary data store on several applications for
a while.  Of course this means that it's integrated into our test, and ci
environments.  A couple days ago Brad and I noticed that one of our test suites,
which had been running in about 1 minute was now taking 10 minutes.  It was
painful.

We tracked the slowness down to this line in our Rspec spec_helper.rb file:

{% highlight ruby %}
config.before(:each) { $cassandra.clear_keyspace! }
{% endhighlight %}

The intention here was to clear the database before each test ran, to ensure
that tests were isolated from each other.  Great, except as we added more Column
Families this got slower and slower, until the call was taking ~1 second per
test case.  About 90% of the time in the test suite was being spent deleting
data from cassandra.  Oh the pain...

Luckily we got a tip from **thobbs** in the #cassandra irc channel.  He said:

> doing a get_range() while deleting everything is faster
> that's what I do for most of the pycassa test cases

He pointed me to
[an example in pycassa](https://github.com/pycassa/pycassa/blob/master/tests/test_columnfamily.py#L37).

Translated into ruby it looks like this:


{% highlight ruby %}
config.before(:each) do
  $cassandra.schema.cf_defs.each do |cf|
    $cassandra.get_range(cf.name, :key_count => 10000).each do |(row_key, _)|
      $cassandra.remove(cf.name, row_key)
    end
  end
end
{% endhighlight %}

With this change the test suite was back down to ~1 minute run time.  And the
people rejoice.
