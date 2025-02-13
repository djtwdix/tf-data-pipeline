# AWS Data Pipeline with Terraform

## Overview

This project sets up an AWS data pipeline using Terraform. It includes:

- **S3 Buckets** for storing data and Athena query results.
- **AWS Lambda** for processing files when uploaded to S3.
- **IAM Roles and Policies** to manage permissions.
- **AWS Glue** for cataloging data.
- **Amazon Athena** for querying the processed data.

## Infrastructure Breakdown

### Terraform Configuration

- Defines AWS as the required provider.
- Sets the region to `us-east-1` and uses the default AWS profile.

### IAM Roles and Permissions

- **Lambda Execution Role**: Allows the Lambda function to run and access necessary AWS services.
- **S3 Bucket Policy**: Grants Lambda permission to read and write objects in the data bucket.
- **Lambda Invocation Permission**: Allows S3 to trigger the Lambda function upon file upload.

### S3 Buckets

- **dt-data-pipeline**: Main bucket where raw data is uploaded.
- **dt-athena-query-results**: Stores results of Athena queries.
- **Bucket Notifications**: Triggers the Lambda function when a new object is added to `dt-data-pipeline`.

### Lambda Function

- Retrieves the uploaded file from S3.
- Parses the file content (assumed to be JSON).
- Adds a `processed: true` flag to the JSON object.
- Writes the updated file back to S3.

### AWS Glue

- **Glue Database**: Organizes the metadata for the data pipeline.
- **Glue Table**: Defines the schema for files in the S3 bucket, specifying JSON format and column structure.

### Amazon Athena

- **Workgroup Configuration**: Specifies that Athena should store query results in the designated S3 bucket.
- **Query Execution**: Allows analysts to query processed data efficiently.

## How It Works

1. A file is uploaded to the `dt-data-pipeline` S3 bucket.
2. S3 triggers the Lambda function.
3. Lambda processes the file, modifying its contents.
4. The updated file is saved back to S3.
5. AWS Glue makes the data available for querying in Athena.
6. Athena queries can be executed, with results stored in `dt-athena-query-results`.

## Deployment

1. Ensure you have AWS credentials configured.
2. Run `npm install` to install aws-sdk/client-s3
3. Run `terraform init` to initialize Terraform.
4. Run `terraform apply` to deploy the resources.

## Cleanup

To remove all resources, run:

```
terraform destroy
```
