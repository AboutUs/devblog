---
layout: default
title: AboutUs.org Developer Blog
---

<div class="index">
<h1 class='tagline'>Experiences in Software Development at AboutUs</h1>
<ul class="posts">
{% for post in site.posts %}
  <li>
    <div class="list-meta meta">
    <div class="author">
    {% include author_short.html %}
    </div>
    <div class="when">
    {{ post.date | date_to_string }}
    </div>
    </div>
    <div class="content">
    <h3><a href="{{ post.url }}">{{ post.title }}</a></h3>
    <div class="synopsis">{{ post.synopsis }}</div>
    </div>
    <div class="clearall"></div>
  </li>
{% endfor %}
</ul>
</div>
