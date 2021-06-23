resource "aws_athena_database" "pp_data_base" {
    name   = "pp_data_base"
    bucket = aws_s3_bucket.clean_pp_ass_ex.bucket
}
  
resource "aws_glue_catalog_table" "aws_glue_catalog_table" {
    name          = "cleaned_table"
    database_name = "${aws_athena_database.pp_data_base.name}"

    table_type = "EXTERNAL_TABLE"

    parameters = {
    EXTERNAL              = "TRUE"
    }

    storage_descriptor {
    location      = "s3://${aws_s3_bucket.clean_pp_ass_ex.bucket}/2021/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
    ser_de_info {
        name    = "SerDeCsv"
        serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"
        parameters = {
        "field.delim" = ","
        }
    }

    columns {
        name = "id"
        type = "string"
    }

    columns {
        name = "name"
        type = "string"
    }

    columns {
        name    = "abv"
        type    = "string"
    }

    columns {
        name    = "ibu"
        type    = "string"
    }

    columns {
        name    = "target_fg"
        type    = "string"
    }
    columns {
        name = "target_og"
        type = "string"
    }
    columns {
        name = "ebc"
        type = "string"
    }
    columns {
        name = "srm"
        type = "string"
    }
    columns {
        name = "ph"
        type = "string"
    }
    }
}

resource "aws_kms_key" "kms10" {
  description             = "KMS key 1"
  deletion_window_in_days = 10
}

resource "aws_athena_workgroup" "output_athena" {
  name = "output_athena"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${aws_s3_bucket.clean_pp_ass_ex.bucket}/"

      encryption_configuration {
        encryption_option = "SSE_KMS"
        kms_key_arn       = aws_kms_key.kms10.arn
      }
    }
  }
}