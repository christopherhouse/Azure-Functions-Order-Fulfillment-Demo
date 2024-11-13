# Azure Functions Order Fulfillment Demo

## Overview
This project contains an Azure Function App that can be used to demonstrate the end-to-end tracing capabilities of Azure Application Insights.  The Function App models a simple order fulfillment scenario.  Orders are received via HTTP post using the Function [`CreateSalesOrder`](FunctionsOrderFulfillmentDemo/Functions/CreateSalesOrder.cs) and then processed asynchronsously by other Functions in the App.  The Function App implements a simple approval workflow for all orders with a total value greater than a specified threshold.  This threshold is defined via the Service Bus subscription filter defined in the parameter `ordersForApprovalSqlFilter` in the Bicep templat that deploys the infrastructure for this solution.  Orders over this threshold are run through Durable Functions workflow starting with the Function `StartApprovalWorkflow`.

## Deploying
This infrastructure and code contained in this repo can be deployed using the Azure Pipeline [`build-and-deploy-order-fulfillment.yaml`](.pipelins/build-and-deploy-order-fulfillment.yaml).  This section describes how to provision this pipeline so you can deploy the solution.

### Create a Varable Group
The pipeline depends on a variable gruop to provide resource group and service connection names.  Create a variable group in Azure DevOps named `order-fulfillment` with the following variables:

| Name | Value |
|------|-------|
|RESOURCE_GROUP_DEV|The name of the resource group to deploy the solution to in the dev environment|
|SERVICE_CONNECTION_DEV|The name of the service connection to use to deploy the solution to the dev environment|

Optionally, you may use the pipeline to deploy across multiple environmments.  If you do, you'll need to add additional variables to the variable group for each environment.  The pipeline is currently configured to deploy to a dev environment only.  If you want to deploy to multiple environments, you'll need to modify the pipeline, adding stages for additional environments via the tempalte [`deploy.yaml`](.pipelines/templates/deploy.yaml).  

### Configure the Pipeline
In Azure DevOps, create a new pipeline.  Choose the option to use existing YAML in a repository.  Point to your repository and select the pipeline [`build-and-deploy-order-fulfillment.yaml`](.pipelines/build-and-deploy-order-fulfillment.yaml).  The pipeline is configured to trigger on commits to any branch.  You may want to change this to trigger on a different branch.  The pipeline is also configured to deploy to a dev environment.  If you want to deploy to multiple environments, you'll need to modify the pipeline as described above.

### Run the Pipeline
Once the pipeline is created, run it to build the Function code, deploy the Azure resources, and deploy the Function code.

## Generating Traffic
This repo includes a simple JMeter test that will exercise the `CreateSalesOrder` Function.  It runs a thread for 40 users over 2 minutes.  The thread posts JSON to the `CreateSalesOrder` endpoint, using a random number for the total.  This ensures that some orders will be over the threshold and require approval via the Durable Functions workflow.  The JMeter test is located in the file [`OrderFulfillmentDemo.jmx`](tests/OrderFulfillmentDemo.jmx).  You can run this test locally using JMeter to generate traffic to the Function App or, alternatively you may upload the test to the Azure Load Testing resource deployed as part of this solution's infrastructure and run the test there.  Note that the Cosmos DB resource deployed with this solution is configured with just 1000 RU/s.  At 40 users, you should easily exceed this limit, resulting in throttling and exceptions in your App Insights telemetry.

The test assumes that the Function App is fronted by Azure API Management.  Before running the test, you'll need to update the following items in the JMeter test:
- Set the value of the user-defined variable `apimHostName` to the hostname of your Azure API Management instance.  Look for the text  `[ENTER YOUR APIM HOSTNAME HERE]` in the JMeter test.
- Set the value of the user-defined variable `apimSubscriptionKey` to the subscription key for your Azure API Management instance.  Look for the text `[ENTER YOUR APIM SUBSCRIPTION KEY HERE]` in the JMeter test.
- Set the value of the path for the HTTP POST.  Enter the correct path/suffix for the Order Fulfillment API on your APIM resource.  Look for the text `[ENTER APIM SUFFIX FOR ORDER FULFILLMENT API HERE]` in the JMeter test.

## Integrating the Function With Azure API Management
The Function App can easily be onboarded to Azure API Management using the OpenAPI specification for the Function App.  This spec can be accessed via the following URL on your Function App:
```
https://your-function-app-name.azurewebsites.net/api/swagger.json
```