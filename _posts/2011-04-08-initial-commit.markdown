---
layout: default
author: sam
synopsis: This is the first post for AboutUs' programming blog.  I describe our hacker-centric blogger setup powered by git, jekyll, and nginx.
---

This is the first post for AboutUs' programming blog.  The blog's
powered by git, jekyll and nginx.  To create a post we create a
text file in the git repository in our favorite editor (i.e.
vim).  The posts go in a `_posts` directory and look like this:

    devblog [master*] $ ls _posts

    _posts:
    2011-04-08-initial-commit.markdown


[Jekyll](http://tom.preston-werner.com/2008/11/17/blogging-like-a-hacker.html)
is used to convert the content textile, markdown, and html
templates into a static html site.

    devblog [master*] $ jekyll
    Configuration from /www/aboutus/devblog/_config.yml
    Building site: . -> ./_site
    Successfully generated site: . -> ./_site

Jekyll's `--auto` option is pretty nice for development.  It
regenerates the site every time you save a file.

    devblog [master*] $ jekyll --auto
    Configuration from /www/aboutus/devblog/_config.yml
    Auto-regenerating enabled: . -> ./_site
    [2011-04-11 20:49:52] regeneration: 8 files changed
    [2011-04-11 20:50:22] regeneration: 1 files changed
    [2011-04-11 20:50:27] regeneration: 1 files changed

On the server jekyll generates static html files for nginx to
serve.

It barely has _any_ dependencies.

    devblog # gem install jekyll --no-rdoc --no-ri
    Building native extensions.  This could take a while...
    Successfully installed liquid-2.2.2
    Successfully installed fast-stemmer-1.0.0
    Successfully installed classifier-1.3.3
    Successfully installed directory_watcher-1.4.0
    Successfully installed syntax-1.0.0
    Successfully installed maruku-0.6.0
    Successfully installed jekyll-0.10.0
    7 gems installed

There's a git post-receive hook that regenerates the site whenever
someone pushes a change.

    devblog # vi .git/hooks/post-receive

{% highlight ruby %}
    #!/bin/sh
    #
    GIT_REPO=/www/aboutus/devblog.git
    TMP_GIT_CLONE=/tmp/devblog
    PUBLIC_WWW=/www/aboutus/devblog

    git clone $GIT_REPO $TMP_GIT_CLONE
    jekyll --no-auto $TMP_GIT_CLONE $PUBLIC_WWW
    rm -Rf $TMP_GIT_CLONE
    exit
{% endhighlight %}

Nginx serves the static files in `/www/aboutus/devblog`.

Deploying is just a `git push`.

    devblog [master] $ git push 
    Counting objects: 23, done.
    Delta compression using up to 2 threads.
    Compressing objects: 100% (9/9), done.
    Writing objects: 100% (12/12), 925 bytes, done.
    Total 12 (delta 6), reused 0 (delta 0)
    remote: Initialized empty Git repository in /tmp/devblog/.git/
    remote: Configuration from /tmp/devblog/_config.yml
    remote: Building site: /tmp/devblog -> /www/aboutus/devblog
    remote: Successfully generated site: /tmp/devblog -> /www/aboutus/devblog
    Killed by signal 1.
    To blog@devblog:/www/aboutus/devblog.git
       12aa781..ab54f06  master -> master

