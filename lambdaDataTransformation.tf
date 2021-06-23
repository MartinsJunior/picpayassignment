resource "aws_lambda_function" "data_cleaned_transformation"{
  role          = "${aws_iam_role.iam_for_lambda_data_transformation.arn}"
  filename      = "${var.lambda_data_cleaned_transformation_path}"
  function_name = "${var.lambda_data_cleaned_transformation_name}"
  description   = "${var.lambda_data_cleaned_transformation_description}"
  handler       = "${var.lambda_data_cleaned_transformation_handler}"
  runtime       = "${var.python_default_version}"

  source_code_hash = base64sha256("${var.lambda_data_cleaned_transformation_path}")

}



resource "aws_iam_role" "iam_for_lambda_data_transformation" {
  name = "iam_for_lambda_data_transformation"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "amazonS3FullAccess" {
  name = "amazonS3FullAccess"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": "*"
        }
    ]
})
}


resource "aws_iam_role_policy_attachment" "lambda_s3Att" {
  role       = aws_iam_role.iam_for_lambda_data_transformation.name
  policy_arn = aws_iam_policy.amazonS3FullAccess.arn
}

resource "aws_iam_role_policy_attachment" "lambda_logs_transformation" {
  role       = aws_iam_role.iam_for_lambda_data_transformation.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

resource "aws_iam_role_policy_attachment" "lambda_kinesis_transformation_Att" {
  role       = aws_iam_role.iam_for_lambda_data_transformation.name
  policy_arn = aws_iam_policy.amazonKinesisFullAccess.arn
}