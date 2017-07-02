---
layout: post
title: Sequential Paging with RxJava
description: Wrapping DynamoDB query paging into an RxJava Observable 
tags: Reviews
feature: "coding-924920_1280.jpg"
comments: true
published: true
---

I recently found myself needing to get the first N results from a dynamoDB table that matched a predicate, 
but the predicate was too complicated to express in the dynamoDB qeury language so I had to filter results in memory and go back for subsequent pages until enough results were found. This is straight forward enought to do, you get returned a lastEvalutedKey which you can supply as part of you next query to get the next set of results from the table. 

Where this gets interesting is if you want to expose this sequence of paging as an RxJava Observable. You have to do the request to get the first page of results and extact a value from that before you can generate a subsequent page. To accomplish this we need something we can both push values to and allow clients to pull values from. 

RxJava offers such a construct, a [Subject](http://reactivex.io/RxJava/javadoc/rx/subjects/Subject.html). The documentation on the class may seems a little opaque 'Represents an object that is both an Observable and an Observer', but if you break it down it is really no so bad. If you are using RxJava you should be pretty comfortable with an [Observable](http://reactivex.io/RxJava/javadoc/rx/Observable.html). An [Observer](http://reactivex.io/RxJava/javadoc/rx/Observer.html) is a construct for push based notifications, ie you can pass it values via [onNext](http://reactivex.io/RxJava/javadoc/rx/Observer.html#onNext(T)) and terminate it by calling [onCompleted](http://reactivex.io/RxJava/javadoc/rx/Observer.html#onCompleted()) or [onError](http://reactivex.io/RxJava/javadoc/rx/Observer.html#onError(java.lang.Throwable)) if you want to propogate an error.

In this instance we want to push each lastEvaluatedKey to the Subject so that it can be used in creating the next page of commits. We also want to turn a lastEvaluatedKey into a page of results, and offer this page of results as an Observable for others to consume.

~~~~ {.java}
private Observable<QueryResult> blockingPaging(
    final Function<AttributeValue, QueryResult> fetchPage) {
    final SerializedSubject<AttributeValue, AttributeValue> mySubject = 
        UnicastSubject.<AttributeValue>create()
        .toSerialized();

    mySubject.onNext(new AttributeValue("Inital value"));

    return mySubject.observeOn(Schedulers.trampoline(), 1)
            .map(currentKey -> {
                final QueryResult qr = fetchPage.apply(currentKey);
                if (qr.getLastEvaluatedKey() != null) {
                    mySubject.onNext(qr.getLastEvaluatedKey().get(MY_KEY));
                } else {
                    mySubject.onCompleted();
                }
                return qr;
            });
 }
~~~~~

There is one more details that it is worth mentioning. I am specifing that we want the subject to be observed on the [trampoline](http://reactivex.io/RxJava/javadoc/rx/schedulers/Schedulers.html#trampoline())  scheduler, this is necessary if we dont want to accumulate stack frames as we go through the pages. 

This was adapted from the following stackoverflow [answer](https://stackoverflow.com/a/42892287/4673214) which presents how to accomplish this using RxJava 2