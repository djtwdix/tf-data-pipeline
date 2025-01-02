terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

//create main s3 bucket

resource "aws_s3_bucket" "dt-data-pipeline" {
  bucket = "dt-data-pipeline"
  force_destroy = true
}

//archive lambda function file

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir = "./lambda-function"
  output_path = "./lambda_function.zip"
}

//create iam role for lambda function

resource "aws_iam_role" "lambda_role" {
  name               = "dt-lambda-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

//attach iam policy to lambda role

resource "aws_iam_policy_attachment" "lambda_basic_execution" {
  name       = "lambda-basic-execution"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

//create lambda function

resource "aws_lambda_function" "dt-data-processor" {
  function_name = "dt-data-processor"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

}

//trigger lambda function when object is uploaded to s3 bucket

resource "aws_s3_bucket_notification" "s3_trigger_lambda" {
  bucket = aws_s3_bucket.dt-data-pipeline.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.dt-data-processor.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3_to_invoke_lambda]
}

// allow dt-data-pipeline bucket to trigger lambda function

resource "aws_lambda_permission" "allow_s3_to_invoke_lambda" {
  statement_id  = "AllowS3InvokeLambda"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.dt-data-processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.dt-data-pipeline.arn
}

//create s3 bucket for athena query results

resource "aws_s3_bucket" "dt-athena-query-results" {
  bucket = "dt-athena-query-results"
  force_destroy = true
} 

//create database for dt-data-pipeline s3 bucket

resource "aws_glue_catalog_database" "dt-data-pipeline-db" {
  name = "dt-data-pipeline-db"
}

//create table for dt-data-pipeline s3 bucket

resource "aws_glue_catalog_table" "dt-data-table" {
  database_name = aws_glue_catalog_database.dt-data-pipeline-db.name
  name          = "dt-data-table"

  table_type = "EXTERNAL_TABLE"
  parameters = {
    "classification" = "json" 
    "external"       = "TRUE"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.dt-data-pipeline.bucket}/" 
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
    compressed    = false
    columns { 
      name = "name" 
      type = "string"
      }
    
    ser_de_info {
     serialization_library = "org.openx.data.jsonserde.JsonSerDe"
    }
  }
}

//send query results to dt-athena-query-results s3 bucket

resource "aws_athena_workgroup" "dt-data-pipeline-workgroup" {
  name = "dt-data-pipeline-workgroup"

  configuration {
    enforce_workgroup_configuration = true
    result_configuration {
      output_location = "s3://${aws_s3_bucket.dt-athena-query-results.bucket}/"
    }
  }
}