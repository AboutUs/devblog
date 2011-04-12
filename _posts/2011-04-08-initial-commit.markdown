---
layout: default
title: Initial Commit
---

This is the first post for AboutUs' programming blog.  The blog's
powered by git, jekyll, nginx.  To create a post we just create a
text file in the git repository in our favorite editor (i.e.
vim).  The posts go in a `_posts` directory and look like this:

    devblog [master*] $ ls _{posts,layouts}/
    _layouts/:
    default.html

    _posts/:
    2011-04-08-initial-commit.markdown

Jekyll is used to convert the content textile, markdown, and html
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

