resource "aws_s3_bucket" "clean_pp_ass_ex" {
  bucket = "clean-pp-as"
  acl    = "public-read"
}

resource "aws_s3_bucket_public_access_block" "publicaccesss3" {
  bucket = aws_s3_bucket.clean_pp_ass_ex.id

  block_public_acls   = false
  block_public_policy = false
}

resource "aws_kinesis_firehose_delivery_stream" "cleaned_transform_data" {
    name        = "cleaned_transform_data"
    destination = "extended_s3"
    kinesis_source_configuration {
        kinesis_stream_arn = "${aws_kinesis_stream.stream_data_from_lambda.arn}"
        role_arn           = "${aws_iam_role.amazon_kinesis_firehose_data_transformation_role.arn}"
    }   
    extended_s3_configuration {
        role_arn   = aws_iam_role.amazon_kinesis_firehose_data_transformation_role.arn
        bucket_arn = aws_s3_bucket.clean_pp_ass_ex.arn

        processing_configuration {
        enabled = "true"

        processors {
            type = "Lambda"

            parameters {
            parameter_name  = "LambdaArn"
            parameter_value = "${aws_lambda_function.data_cleaned_transformation.arn}:$LATEST"
            }
        }
        }
    }
  
}

resource "aws_iam_role" "amazon_kinesis_firehose_data_transformation_role" {
  name = "amazon_kinesis_firehose_data_transformation_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "amazon_kinesis_firehose_data_transformation_policy" {
  name = "amazon_kinesis_firehose_data_transformation_policy"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": "*"
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "lambda:InvokeFunction",
                "lambda:GetFunctionConfiguration"
            ],
            "Resource": "${aws_lambda_function.data_cleaned_transformation.arn}:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "kms:GenerateDataKey",
                "kms:Decrypt"
            ],
            "Resource": [
                "arn:aws:kms:us-east-2:365698824478:key/%FIREHOSE_POLICY_TEMPLATE_PLACEHOLDER%"
            ],
            "Condition": {
                "StringEquals": {
                    "kms:ViaService": "s3.us-east-2.amazonaws.com"
                },
                "StringLike": {
                    "kms:EncryptionContext:aws:s3:arn": [
                        "arn:aws:s3:::%FIREHOSE_POLICY_TEMPLATE_PLACEHOLDER%/*"
                    ]
                }
            }
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "kinesis:DescribeStream",
                "kinesis:GetShardIterator",
                "kinesis:GetRecords",
                "kinesis:ListShards"
            ],
            "Resource": "${aws_kinesis_stream.stream_data_from_lambda.arn}"
        },
        {
            "Effect": "Allow",
            "Action": [
                "kms:Decrypt"
            ],
            "Resource": [
                "arn:aws:kms:us-east-2:365698824478:key/%FIREHOSE_POLICY_TEMPLATE_PLACEHOLDER%"
            ],
            "Condition": {
                "StringEquals": {
                    "kms:ViaService": "kinesis.us-east-2.amazonaws.com"
                },
                "StringLike": {
                    "kms:EncryptionContext:aws:kinesis:arn": "${aws_kinesis_stream.stream_data_from_lambda.arn}"
                }
            }
        }
    ]
})
}


resource "aws_iam_role_policy_attachment" "lambda_firehose_Att" {
  role       = aws_iam_role.amazon_kinesis_firehose_data_transformation_role.name
  policy_arn = aws_iam_policy.amazon_kinesis_firehose_data_transformation_policy.arn
}


