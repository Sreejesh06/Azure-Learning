# 01 - Introduction

## Visual Flow

<Mermaid chart={`
architecture-beta
    group containerapps(cloud)[Azure Container Apps]
    service orderapi(server)[Order Processing API] in containerapps
    service worker(server)[Background Worker] in containerapps
    
    group external(cloud)[External]
    service users(server)[HTTP Traffic] in external
    service servicebus(database)[Azure Service Bus] in external
    
    users:R -- L:orderapi
    servicebus:R -- L:worker
`} />

The flow above shows a typical e-commerce order processing architecture. We have synchronous HTTP traffic hitting the Order Processing API from the outside world, and an asynchronous background worker pulling messages from an Azure Service Bus queue. Both of these components live inside Azure Container Apps and need distinct scaling behaviors to handle unpredictable traffic bursts while scaling all the way down to zero during idle times to save costs.

## What's the Problem?

Imagine you are building this order processing service for an e-commerce platform. Your application sees predictable traffic spikes during big sales, and totally unpredictable bursts when marketing campaigns drop. 

If your current deployment uses fixed resources, you run into two major issues:
1. **Poor response times:** During peak periods, your fixed resources get overwhelmed. Customer complaints start rolling in about slow checkout times during flash sales.
2. **Wasted money:** During quiet hours, your app just sits there doing nothing, but operations is reporting massive bills because the application runs at full capacity around the clock.

## The Solution: Automatic Scaling

By implementing automatic scaling in Azure Container Apps, we can solve both problems. We need the application to:
- Scale out rapidly when HTTP requests increase.
- Process messages efficiently from Azure Service Bus queues during order fulfillment.
- Scale back down to zero during idle periods to minimize costs.

The platform needs to handle both synchronous API traffic and asynchronous background processing, each requiring different scaling behaviors. Leadership expects this solution to reduce infrastructure costs by at least 40% while keeping response times under 200 milliseconds during peak load.

## What We Are Going to Build and Learn

In this lab, we are going to dive deep into configuring automatic horizontal scaling to build a responsive, cost-efficient container deployment. By the end, you will know how to:

- Configure HTTP, TCP, CPU, and memory scale rules for your container apps.
- Implement event-driven scaling using KEDA scalers for Azure services (like Service Bus).
- Select the right compute resources to optimize both performance and cost.
- Apply revision modes to control scaling behavior and manage traffic distribution.


---
title: 02 - Configure Scale Rules
description: Learn how to configure HTTP, TCP, CPU, and Memory scaling in Azure Container Apps
---

## Visual Flow

<Mermaid chart={`
architecture-beta
    group traffic(cloud)[Traffic / Load]
    service http(server)[HTTP Requests] in traffic
    service tcp(server)[TCP Connections] in traffic
    service cpu(server)[CPU / Memory load] in traffic

    group aca(cloud)[Azure Container Apps]
    service keda(server)[KEDA Scaler] in aca
    service replica1(server)[Replica 1] in aca
    service replica2(server)[Replica 2] in aca
    service replica3(server)[Replica 3] in aca
    
    keda:T -- B:http
    keda:T -- B:tcp
    keda:T -- B:cpu
    
    keda:R -- L:replica1
    keda:R -- L:replica2
    keda:R -- L:replica3
`} />

The flow above shows how KEDA (Kubernetes Event-driven Autoscaling) sits inside Azure Container Apps. It constantly polls your defined triggers (HTTP, TCP, or CPU/Memory) and automatically provisions or terminates replicas based on the thresholds you define. 

## Understand Scale Definitions

Scale definitions in Azure Container Apps consist of three main components:
1. **Limits:** The minimum and maximum number of replicas allowed.
2. **Rules:** The triggers that determine when scaling occurs (e.g., 50 concurrent HTTP requests).
3. **Behavior:** The polling intervals and cool-down periods used to make scaling decisions.

If ingress is disabled and you do not specify a minimum replica count or custom rule, your app scales to zero and cannot restart because there is no trigger. Billing is strictly based on the replica count. When scaled to zero, you incur zero compute charges.

## HTTP Scale Rules

HTTP scaling adjusts replicas based on concurrent HTTP requests. The platform calculates this by counting the requests received over the past 15 seconds and dividing by 15. The default threshold is 10 requests per replica. 

This type supports scale-to-zero. 

**Why:** You want to deploy an order API that scales up when concurrent HTTP requests exceed 50 per replica, and can scale to zero when no traffic exists.

```bash
az containerapp create \
  --name order-api \
  --resource-group rg-ecommerce \
  --environment my-environment \
  --image myregistry.azurecr.io/order-api:v1 \
  --min-replicas 0 \
  --max-replicas 10 \
  --scale-rule-name http-scaling \
  --scale-rule-type http \
  --scale-rule-http-concurrency 50
```

## TCP Scale Rules

TCP scaling is for persistent connections, not short-lived HTTP cycles. Think WebSocket servers, database connection pools, or gRPC services. It uses the same 15-second averaging window and also supports scale-to-zero.

## CPU and Memory Scale Rules

Resource-based scaling triggers when the average CPU or Memory utilization exceeds a percentage threshold. 

**Critical Limitation:** CPU and Memory rules CANNOT scale to zero. The platform requires at least one running replica to actually measure the utilization. If you need scale-to-zero, you must combine resource scaling with HTTP or event-driven rules.

**Why:** You want to configure scaling directly via YAML to combine HTTP and CPU rules, ensuring that the app scales if HTTP concurrency hits 100 OR CPU hits 70%.

```yaml
scale:
  minReplicas: 1
  maxReplicas: 20
  rules:
    - name: http-scaling
      http:
        metadata:
          concurrentRequests: "100"
    - name: cpu-scaling
      custom:
        type: cpu
        metadata:
          type: Utilization
          value: "70"
```

## Understand Scale Behavior (Timing Parameters)

The algorithm uses specific timing parameters to prevent thrashing:
- **Polling interval:** 30 seconds for custom scalers (CPU/Memory), 15 seconds for HTTP/TCP.
- **Cool-down period:** The platform waits a default of 300 seconds (5 minutes) after the last scaling event before it scales down to zero. 
- **Scale-up stabilization:** Zero seconds. It scales up immediately in steps of 1, 4, 8, 16, 32.
- **Scale-down stabilization:** 300 seconds. When it finally scales down, all unneeded replicas shut down at once.

## Best Practices
- **Production Minimums:** Set `min-replicas` to at least 1 for production to avoid cold start latency. Only scale to zero for dev environments or truly intermittent workloads.
- **API Workloads:** Default to HTTP scaling for web APIs because it is the most responsive and supports scaling to zero.
- **Combine Rules:** Use multiple rules (e.g., HTTP + CPU) to handle different traffic patterns effectively.
- **Beware the Cool-down:** The 5-minute cool-down means brief traffic spikes will leave replicas running (and costing money) for at least 5 minutes after traffic drops.


---
title: 03 - Implement event-driven scaling with KEDA
description: Learn how to scale Azure Container Apps using event-driven triggers like Azure Service Bus, Storage Queues, and Event Hubs via KEDA.
---

## Visual Flow

<Mermaid chart={`
architecture-beta
    group external(cloud)[External Event Sources]
    service servicebus(database)[Azure Service Bus] in external
    service storagequeue(database)[Storage Queue] in external
    service eventhub(database)[Event Hub] in external

    group aca(cloud)[Azure Container Apps]
    service keda(server)[KEDA Scaler] in aca
    service worker1(server)[Worker Replica 1] in aca
    service worker2(server)[Worker Replica 2] in aca
    
    keda:T -- B:servicebus
    keda:T -- B:storagequeue
    keda:T -- B:eventhub
    
    keda:R -- L:worker1
    keda:R -- L:worker2
`} />

This diagram shows how the KEDA scaler inside Azure Container Apps constantly polls external event sources (like message queues or event streams). When messages pile up in the queue, KEDA automatically spins up worker replicas to process the backlog, and scales them back to zero when the queue is empty.

## Understand KEDA Integration

Event-driven scaling is built for background processing. If you have an app that just sits in the background processing messages from a queue, scaling based on HTTP requests won't work (because it doesn't receive HTTP traffic). 

Instead, Azure Container Apps uses KEDA (Kubernetes Event-driven Autoscaling). KEDA monitors external sources (like a Service Bus queue), looks at metrics like queue depth, and adjusts your replicas. 
- **Polling:** KEDA polls the event source every 30 seconds.
- **Scale-to-zero:** Yes, it fully supports scaling down to zero when the queue is completely empty.

## 1. Configure Azure Service Bus Scaling

This triggers scaling based on the number of messages in a Service Bus queue or topic subscription. 

**How the math works:** You configure a `messageCount` threshold. If you set `messageCount` to 5, and there are 50 messages sitting in the queue, KEDA will request 10 replicas (50 / 5) to handle the load.

**Why:** You want a background worker to scale up to a maximum of 30 replicas to process orders from a Service Bus queue, using a connection string stored securely as a secret.

```bash
az containerapp create \
  --name order-processor \
  --resource-group rg-ecommerce \
  --environment my-environment \
  --image myregistry.azurecr.io/order-processor:v1 \
  --min-replicas 0 \
  --max-replicas 30 \
  --secrets "sb-connection=<SERVICE_BUS_CONNECTION_STRING>" \
  --scale-rule-name servicebus-scaling \
  --scale-rule-type azure-servicebus \
  --scale-rule-metadata "queueName=orders" "namespace=sb-ecommerce" "messageCount=5" \
  --scale-rule-auth "connection=sb-connection"
```
*(If using topics instead of queues, you just swap `queueName` for `topicName` and add `subscriptionName`.)*

## 2. Configure Azure Storage Queue Scaling

Storage Queues are the simpler, cheaper alternative to Service Bus. You don't get advanced features (like sessions or dead-letter queues), but the scaling concept is exactly the same. 

You set a `queueLength` parameter (identical in concept to `messageCount`), and KEDA monitors the queue to spin up replicas.

**Why:** You want to scale a simple inventory-updates processor using an Azure Storage Queue, and you want to authenticate securely using Managed Identity instead of connection strings.

```bash
az containerapp create \
  --name queue-processor \
  --resource-group rg-ecommerce \
  --environment my-environment \
  --image myregistry.azurecr.io/queue-processor:v1 \
  --user-assigned <MANAGED_IDENTITY_RESOURCE_ID> \
  --min-replicas 0 \
  --max-replicas 20 \
  --scale-rule-name storage-queue-scaling \
  --scale-rule-type azure-queue \
  --scale-rule-metadata "accountName=stecommerce" "queueName=inventory-updates" "queueLength=10" \
  --scale-rule-identity <MANAGED_IDENTITY_RESOURCE_ID>
```

## 3. Configure Azure Event Hubs Scaling

Event Hubs is for massive, high-throughput streaming. Instead of counting individual messages in a queue, the Event Hubs scaler monitors the **"lag"** (unprocessed events) between the latest event and your consumer group's checkpoint.

**The Major Gotcha (Partitions):** Your maximum effective replicas are tied directly to the number of partitions in your Event Hub. If your Event Hub only has 32 partitions, setting your `maxReplicas` to 100 will do absolutely nothing. You can only have one consumer per partition.

Here is how you'd define it in YAML:
```yaml
scale:
  minReplicas: 0
  maxReplicas: 32
  rules:
    - name: eventhubs-scaling
      custom:
        type: azure-eventhub
        metadata:
          consumerGroup: "$Default"
          unprocessedEventThreshold: "64"
          checkpointStrategy: "blobMetadata"
      auth:
        - secretRef: eh-connection
          triggerParameter: connection
```

## Authentication for Scale Rules

KEDA needs to authenticate against the event source to read the metrics. You have two options:
1. **Secrets-based:** You store a connection string as a secret in the Container App, and map it to the scale rule (like we did in the Service Bus example). This works, but rotating secrets is a headache.
2. **Managed Identity (The Best Practice):** You assign an identity to your app, grant it RBAC permissions (like 'Azure Service Bus Data Receiver'), and the scaler uses that identity directly (like we did in the Storage Queue example). No passwords required!

## Best Practices
- **Use Managed Identity:** Always prefer this for production. It kills the risk of leaked connection strings.
- **Do the Math on Thresholds:** If 1 message takes 10 seconds to process, and you want 100 messages processed per minute, you need exactly 10 replicas running concurrently. Set your `messageCount` threshold to achieve that specific math so you don't over-provision and waste money.
- **Always Scale Background Workers to Zero:** This is where you save the most money. If the queue is empty, pay for absolutely nothing.
