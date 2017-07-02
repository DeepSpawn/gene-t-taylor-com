---
layout: post
title: List of Futures -> Future of List
description: Implementing the sequence function for the Java 8 CompletableFuture 
tags: Java, Java8, FP
comments: true
feature: "coding-924920_1280.jpg"
published: true
--- 

When working with Java 8's [CompletableFuture](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html) 
you may find a yourself in a sitution where you want to start a collection of async operations and block until they have all completed. 
One way of framing this problem is by thinking in types, which means that we are after a function of type
`List<CompletableFuture<T>> -> CompletableFuture<List<T>>`.

 Despite CompletableFuture having over 50 methods this is not actually something they provide out of the box.
 Fortunately is does have all of the pieces required to write such a function without much effort.
 The method [allOf](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html#allOf-java.util.concurrent.CompletableFuture...-)
accepts any number of CompletableFutures and returns a `CompletableFutures<Void>` that completes when all of the provided futures complete.
 Once this future completes all that is left is to go back the original futures and gather up the results, giving us the following 

<script src="https://gist.github.com/DeepSpawn/f3f33ffb4e51580666b0985a4d8a7781.js"></script>

(Credit to Misha over on [StackOverflow](http://stackoverflow.com/a/30026710/4673214) for providing this in an answer)