
//create main s3 bucket

resource "aws_s3_bucket" "dt-data-pipeline" {
  bucket        = "dt-data-pipeline"
  force_destroy = true
}

//create s3 bucket for athena query results

resource "aws_s3_bucket" "dt-athena-query-results" {
  bucket        = "dt-athena-query-results"
  force_destroy = true
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

