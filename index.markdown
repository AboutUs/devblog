---
layout: default
title: AboutUs Dev Blog
---

<div class="posts">
{% for post in site.posts %}
  <div class='post'>
    <h2 class='short title'>
      <a href="{{ post.url }}">{{ post.title }}</a>
    </h2>
    <div class='short location'>{{ post.date | date_to_string }}</div>
    <div class='long description'>{{ post.content }}</div>
    <hr>
  </div>
{% endfor %}
</div>
