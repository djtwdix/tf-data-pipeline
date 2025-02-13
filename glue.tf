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
    //plain text input format, works with json
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    //plain text output format
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
    compressed    = false
    columns {
      name = "name"
      type = "string"
    }

    columns {
      name = "processed"
      type = "boolean"
    }

    //add json serialization library
    ser_de_info {
      serialization_library = "org.openx.data.jsonserde.JsonSerDe"
    }
  }
}
