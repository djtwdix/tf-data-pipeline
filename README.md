# AWS Data Pipeline with Terraform

## Overview

This project sets up an AWS data pipeline using Terraform. The infrastructure includes:

S3 buckets for data storage and Athena query results

An AWS Lambda function triggered by S3 object uploads

AWS Glue for data cataloging

AWS Athena for querying stored data

## Infrastructure Components

### 1. Amazon S3 Buckets

dt-data-pipeline: Stores incoming data files

dt-athena-query-results: Stores Athena query results

### 2. AWS Lambda

Function: dt-data-processor

Triggered when an object is uploaded to dt-data-pipeline

Uses IAM role dt-lambda-execution-role

### 3. IAM Roles & Policies

dt-lambda-execution-role: Grants permissions for Lambda execution

Attached AWS-managed policy: AWSLambdaBasicExecutionRole

### 4. AWS Glue

Database: dt-data-pipeline-db

Table: dt-data-table

Stores metadata for data stored in dt-data-pipeline S3 bucket

### 5. AWS Athena

Workgroup: dt-data-pipeline-workgroup

Stores query results in dt-athena-query-results bucket

## Deployment Instructions

### Prerequisites

AWS CLI installed and configured

Terraform installed

IAM credentials with necessary permissions

### Steps

Clone this repository:

```
git clone <repository-url>
cd <repository-folder>
```

Initialize Terraform:

```
terraform init
```

Plan the deployment:

```
terraform plan
```

Apply the Terraform configuration:

```
terraform apply
```

Confirm the deployment when prompted.

## Cleanup

To remove all deployed resources:

```
terraform destroy
```

## Notes

The Lambda function code should be placed in the ./lambda-function directory.

Ensure profile = "default" in provider matches your AWS credentials profile.

Modify the Glue table schema as per your data structure.
