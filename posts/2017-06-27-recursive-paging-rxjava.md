---
layout: post
title: Sequential Paging with RxJava
description: Wrapping DynamoDB query paging into an RxJava Observable 
tags: Reviews
feature: "coding-924920_1280.jpg"
comments: true
published: true
---

I recently needed to find the first N items in a dynamoDB table that matched a predicate. I had futher filtering that I need to apply in memory which could result in having to back to dynamoDB for a subsequent page until had been found.
The paging itself is straight forward enough to do using the lastEvalutedKey returned with the query results. Where this gets interesting if when you want to expose each page in the sequence as an item in an RxJava Observable.

This is interesting as each new page depends on a value from the previous page, the last Evaluted Key, before it can be generated. So we need to use some sort of Rx structure that allows us to both push and pull values from it. Luckily  RxJava offers such a construct in a [Subject](http://reactivex.io/RxJava/javadoc/rx/subjects/Subject.html).

If you are unfamiliar with RxJava the documentation on the class may seems a little opaque, it 'Represents an object that is both an Observable and an Observer' but if we break it down into its two components it is not so bad. If you have used RxJava at all you should hopefully already be familiar with an [Observable](http://reactivex.io/RxJava/javadoc/rx/Observable.html) so I wont cover that here. The other half of the Subject in an [Observer](http://reactivex.io/RxJava/javadoc/rx/Observer.html), a construct you can use for push based notifications. You explicitly pass vaules to it by calling [onNext](http://reactivex.io/RxJava/javadoc/rx/Observer.html#onNext(T)) and terminate it by calling [onCompleted](http://reactivex.io/RxJava/javadoc/rx/Observer.html#onCompleted()) or [onError](http://reactivex.io/RxJava/javadoc/rx/Observer.html#onError(java.lang.Throwable)).

Making use of a Subject we can put together something that looks like

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
So after fetching a page we want to push the lastEvaluatedKey to the subject so that it is availiable when we want to fetch the next page from dynamoDB. We need to push an inital value to the Subject so that we are able to fetch the first page, and we need to signal to the Subject that we are finished once there are no more records for us to query in the table. We can simply return the Subject from our method as an observeable for others to consume with the details of the paging hidden from callers.

The last detail worth mentioning is that we need to explicitly control how this subject is going to be observed by a client, it would very easy to impliment this in a way where we accumulate a stack frame for each page we fetch in a similar way you would with a recursive calls. Specifying that it should be observedOn [Schedulers.trampoline()](http://reactivex.io/RxJava/javadoc/rx/schedulers/Schedulers.html#trampoline()) ensure that the work will get done on the current thread, but only after the currently executing work is finished so that the stack size does not grow. 

This was adapted from the following stackoverflow [answer](https://stackoverflow.com/a/42892287/4673214) which presents this pattern using RxJava 2