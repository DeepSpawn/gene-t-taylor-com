---
layout: post
title: Java Pattern Matching in Practice
description: Implementing Scala style Structural Pattern Matching in Java
tags: Java, Java8, FP
comments: true
feature: "coding-924920_1280.jpg"
published: true
---

When switching from Scala back to Java one of the language features I find myself missing is pattern matching.
Luckily I stumbled across a gem of a [blog post](http://blog.higher-order.com/blog/2009/08/21/structural-pattern-matching-in-java/) that explains how you can emulate structural pattern matching in Java. 
(If pattern matching is new for you then there is a good primer over on [stack overflow](http://stackoverflow.com/a/2502787/4673214)).

After reading that post I was curious as to how this looks in practice when using something a little more complicated than a tree.
To see how it looked I thought I would implement Json as an Algebraic Data Type as this is a commonly used example so would provide an easy comparison
between Scala and Java pattern matching.

Here is a Java implementation of Json as an ADT. A the top level we declare Json as an abstract class with a match method that accepts a function taking each possible case to T.

<script src="https://gist.github.com/DeepSpawn/4b423262e34880b2fe0b7ec9e7220f27.js"></script>

Then we subclass Json for each case with the subclass implementation of Match being to call the relevant function with itself as the argument.

<script src="https://gist.github.com/DeepSpawn/d050a43f2eebc3e9c6a1914a6ffd7ffd.js"></script>

Once we have defined our ADT we can pattern match away. Here is an example of using match to recursively build up a String representation
of a Json Object.

<script src="https://gist.github.com/DeepSpawn/46d0f07123a227d9daa7392a2b471b2a.js"></script>

This comes out looking pretty good, Lambdas allow match statments to look pretty natural and we have the compiler ensuring our matches are 
complete.

Admittedly there is quite a bit of upfront boilerplant when defining your ADT as you can see when you look at the 
[full implementation](https://gist.github.com/DeepSpawn/eac6651d336f620405907607c509741f). 
Using an IDE like like Intellij IDEA mitigates this somewhat as it can do most of the heavy lifting.
Alternatively you could look [derive4j](https://github.com/derive4j/derive4j) which will generate the code for you.
(I was recommended it on Twitter but have not yet had a chance to use it yet)


