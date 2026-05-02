---
title: "Implementing an ImmutableMap collector"
description: "Creating an ImmutableMap Collector for a Java8 Stream"
pubDate: 2016-03-26
tags: ["Java", "Java8", "Guava", "Streams"]
feature: "coding-924920_1280.jpg"
---
Implementing a new Stream [collector](https://docs.oracle.com/javase/8/docs/api/java/util/stream/Collector.html) can seem a little daunting,
 the interface feature mutliple type parameters and the javadoc is a wall of text.
Nevertheless it is required if you want to collect your stream into a collection not found in the standard library, like Guava 
[immutable collections](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/ImmutableCollection.html).

Fortunately implementing a new collector is not as much work as it might seem. There is a static factory method that keeps the boilerplate to a minimum,
 so it is largely a matter of getting your head around the type signitures and required behaviour of the functions requried to contstruct a new collector.

## Type Parameters

* T - The type of input elements for the new collector
* A - The intermediate accumulation type of the new collector
* R - The final result type of the new collector

## Required Functions

* A **Supplier** (() -> A) that returns a new mutable result container
* A **Accumulator** ((A,T) -> void) that accepts a reuslt container and a stream element and adds the element to the container. This returns void as it is intended to operate via mutation
* A **Combiner** ((A,A) -> A) that combines two result containers into a single container 
* A **Finisher** (A -> R) that optionally applies a final transformation to the result container producing the final return type of the collector

## implementing toImmutableMap 

As a concrete example lets implement an immutable counterpart to [Collectors#toMap](https://docs.oracle.com/javase/8/docs/api/java/util/stream/Collectors.html#toMap-java.util.function.Function-java.util.function.Function-).
This method takes two functions,

* **keyMapper** *(T -> K)*
* **valueMapper** *(T -> V)*

 and outputs a collector that will collects a stream into a *Map<K,V>* of the output of applying the functions to each element in the stream.
 

The first thing we need to our immutableMap implementation is a supplier, in this instance we want to use a builder as our intermediate result container

```ImmutableMap::Builder```

For our accumulator we need to apply our keyMapper and valueMapper for element and then put the results into our builder

```(builder, element) -> builder.put(keyMapper.apply(element), valueMapper.apply(element))```

For the combiner we can just use a naive implementation as I primarily have serial streams in mind for this collector. 
We can build on of the builders into a Map and then use putAll to the contents to the other builder.

```(builderOne, builderTwo) -> builderOne.putAll(builderTwo.build())```

Our finisher is simply a call to build to produce the desired output type, ImmutableMap

```Builder::build```

Putting all of the pieces together we get the following method

<script src="https://gist.github.com/DeepSpawn/21b7a591fccfc6cad6bd.js"></script>
