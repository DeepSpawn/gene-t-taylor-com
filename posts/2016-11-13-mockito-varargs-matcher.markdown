---
layout: post
title: Matching on Varargs with Mockito
description: Implimenting a custom Mockito 1.X Varargs Matcher
tags: [Java, Mockito, Testing]
comments: true
published: true
---

I recently had the need for a Mockito matcher, like [eq()](http://site.mockito.org/mockito/docs/1.10.19/org/mockito/Matchers.html#eq(boolean)) , to match on varargs.
There is `anyVararg()` provided by the library but nothing for actually matching on the
contents of the array. After some digging I found that you need to impliment a custom matcher as described on Stackoverflow 
[here](http://stackoverflow.com/questions/24295197/is-there-mockito-eq-matcher-for-varargs-array/24295695#24295695).

The solution is to impliment a custom matcher that impliments the VarargMatcher interface 
 
<script src="https://gist.github.com/DeepSpawn/42e5e0d56cf87562e1d65e2ea66419cc.js"></script>

This can then be wrapped in a static factory method if you want something that looks more like `eq`  

<script src="https://gist.github.com/DeepSpawn/e1f89cf820ac55a48fa4e3caece52066.js"></script>

For those interested there is an [open issue you can watch](https://github.com/mockito/mockito/issues/356) for adding this to the library proper. 
