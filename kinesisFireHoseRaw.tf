resource "aws_s3_bucket" "raw_pp_ass_ex" {
  bucket = "raw-pp-as"
  acl    = "public-read"
}

resource "aws_s3_bucket_public_access_block" "publicaccess3" {
  bucket = aws_s3_bucket.raw_pp_ass_ex.id
  
  block_public_acls   = false
  block_public_policy = false
}


resource "aws_kinesis_firehose_delivery_stream" "raw_kinesis_firehose" {
    name        = "raw_kinesis_firehose"
    destination = "s3"
    s3_configuration {
        role_arn   = aws_iam_role.amazon_kinesis_firehose_role.arn
        bucket_arn = aws_s3_bucket.raw_pp_ass_ex.arn
    }
    kinesis_source_configuration {
        kinesis_stream_arn = "${aws_kinesis_stream.stream_data_from_lambda.arn}"
        role_arn           = "${aws_iam_role.amazon_kinesis_firehose_role.arn}"
    }

}


resource "aws_iam_role" "amazon_kinesis_firehose_role" {
  name = "amazon_kinesis_firehose_role"

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

resource "aws_iam_policy" "amazon_kinesis_firehose_policy" {
  name = "amazon_kinesis_firehose_policy"

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
            "Resource": "arn:aws:lambda:us-east-2:365698824478:function:%FIREHOSE_POLICY_TEMPLATE_PLACEHOLDER%"
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


resource "aws_iam_role_policy_attachment" "fire_hose_att" {
  role       = aws_iam_role.amazon_kinesis_firehose_role.name
  policy_arn = aws_iam_policy.amazon_kinesis_firehose_policy.arn
}