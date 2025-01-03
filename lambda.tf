//archive lambda function file

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir = "./lambda-function"
  output_path = "./lambda_function.zip"
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

// allow dt-data-pipeline bucket to trigger lambda function

resource "aws_lambda_permission" "allow_s3_to_invoke_lambda" {
  statement_id  = "AllowS3InvokeLambda"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.dt-data-processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.dt-data-pipeline.arn
}