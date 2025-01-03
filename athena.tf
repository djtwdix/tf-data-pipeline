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