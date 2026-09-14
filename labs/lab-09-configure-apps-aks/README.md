# Lab 09 - Configure Apps on AKS

Welcome to Lab 09! In this module, you will learn how to decouple your application's code from its configuration and state.

## Learning Objectives

By completing this module, you will be able to:
- Explain how to externalize application configuration using core Kubernetes primitives.
- Implement **ConfigMaps** and safely inject non-sensitive settings (like feature flags or API URLs) into your Pods.
- Implement **Secrets** and consume sensitive values (like database passwords or API keys) securely.
- Attach persistent, stateful storage to a stateless application using **PersistentVolume** and **PersistentVolumeClaim** resources.

## Prerequisites

Before diving into the lab exercises, ensure you have:
- Programming experience with languages such as Python, JavaScript, or C#.
- A basic understanding of Azure services and cloud computing concepts.
- An active Azure Kubernetes Service (AKS) cluster from the previous lab.

Let's begin configuring our AKS workloads for production!
