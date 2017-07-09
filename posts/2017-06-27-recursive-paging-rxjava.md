---
layout: post
title: Sequential Paging with RxJava
description: Wrapping DynamoDB paging in an RxJava Observable 
tags: Reviews
feature: "coding-924920_1280.jpg"
comments: true
published: true
---

So you want to do a table scan on a dynamoDB table to try and find the first N items that match some complicated predicate. This is likely to involve grabbing a page of results, filtering in memory and then going back to dynamoDB for another page of items until enough have been found.

The paging is straight forward to do, you get returned a lastEvalutedKey with the query results that you can supply with the next request to continue scanning form the correct localtion. Where this gets interesting if when you want to expose each page in the sequence as an element in a RxJava Observable. 

Each page requires the preious page to have been retrieved before you can generate it, so  we need to use some sort of Rx structure that allows us to both push and pull values from it.

RxJava offers such a construct as a [Subject](http://reactivex.io/RxJava/javadoc/rx/subjects/Subject.html). At first glance the documentation of the class may seem a little opaque

> 'Represents an object that is both an Observable and an Observer' 

but breaking it down into the two building blocks it is not so bad. 

- [Observable](http://reactivex.io/RxJava/javadoc/rx/Observable.html) is one of the core construct in the library so I wont cover that here. 

- An [Observer](http://reactivex.io/RxJava/javadoc/rx/Observer.html) is a construct you can use for push based notifications. You explicitly pass vaules to it by calling [onNext](http://reactivex.io/RxJava/javadoc/rx/Observer.html#onNext(T)) and terminate it by calling [onCompleted](http://reactivex.io/RxJava/javadoc/rx/Observer.html#onCompleted()) or [onError](http://reactivex.io/RxJava/javadoc/rx/Observer.html#onError(java.lang.Throwable)).

So making use of a Subject in out Dynamodb example we can put together something that looks like

~~~~ {.java}
private Observable<QueryResult> blockingPaging(
Function<AttributeValue, QueryResult> fetchPage) {

    SerializedSubject<AttributeValue, AttributeValue> mySubject = 
        UnicastSubject.create()
        .toSerialized();

    mySubject.onNext(new AttributeValue("Inital value"));

    return mySubject.observeOn(Schedulers.trampoline(), 1)
            .map(currentKey -> {
                QueryResult qr = fetchPage.apply(currentKey);
                if (qr.getLastEvaluatedKey() != null) {
                    mySubject.onNext(qr.getLastEvaluatedKey().get(MY_KEY));
                } else {
                    mySubject.onCompleted();
                }
                return qr;
            });
 }
~~~~~
- After fetching a page we push the lastEvaluatedKey to the subject so that it is availiable to be pulled when we want to fetch the next page from dynamoDB. 
- We need to handle the starting case and push some inital value, possibly a dummy value, so we are able to fetch the first page. 
- We also terminating the Observeable when there is nothing more for us to fetch from the table.

Once we have the Subject constructed we can just expose it as an Observeable for clients to consume.

The last detail worth mentioning is that we need to explicitly control how this subject is going to be observed by a client. It would very easy to impliment this in a way where we accumulate a stack frame for each page we fetch, in a similar manner way you would with a recursive loop.

Specifying that it should be observed on [Schedulers.trampoline()](http://reactivex.io/RxJava/javadoc/rx/schedulers/Schedulers.html#trampoline()) ensures that the work will get done on the current thread, but only after the currently executing work is finished. This ensures that are not going to accumulate stack frames as we page through the table.

This was adapted from the following stackoverflow [answer](https://stackoverflow.com/a/42892287/4673214) which presents this pattern using RxJava 2