# [Migrating a Monolithic Website to Microservices on Google Kubernetes Engine](https://www.qwiklabs.com/focuses/11953?parent=catalog)

## Introduction

Why migrate from a monolithic application to a microservices architecture? Breaking down an application into microservices has the following advantages, most of these stem from the fact that microservices are loosely coupled:

* The microservices can be independently tested and deployed. The smaller the unit of deployment, the easier the deployment.
* They can be implemented in different languages and frameworks. For each microservice, you're free to choose the best technology for its particular use case.
* They can be managed by different teams. The boundary between microservices makes it easier to dedicate a team to one or several microservices.
* By moving to microservices, you loosen the dependencies between the teams. Each team has to care only about the APIs of the microservices they are dependent on. The team doesn't need to think about how those microservices are implemented, about their release cycles, and so on.
* You can more easily design for failure. By having clear boundaries between services, it's easier to determine what to do if a service is down.

Some of the disadvantages when compared to monoliths are:

* Because a microservice-based app is a network of different services that often interact in ways that are not obvious, the overall complexity of the system tends to grow.
* Unlike the internals of a monolith, microservices communicate over a network. In some circumstances, this can be seen as a security concern. Istio solves this problem by automatically encrypting the traffic between microservices.
* It can be hard to achieve the same level of performance as with a monolithic approach because of latencies between services.
* The behavior of your system isn't caused by a single service, but by many of them and by their interactions. Because of this, understanding how your system behaves in production (its observability) is harder. Istio is a solution to this problem as well.

In this lab you will deploy an existing monolithic application to a Google Kubernetes Engine cluster, then break it down into microservices. Kubernetes is a platform to manage, host, scale, and deploy containers. Containers are a portable way of packaging and running code. They are well suited to the microservices pattern, where each microservice can run in its own container. 