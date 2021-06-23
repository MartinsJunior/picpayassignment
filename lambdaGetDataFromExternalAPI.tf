resource "aws_lambda_function" "get_data_from_external_api"{
  role          = "${aws_iam_role.iam_for_lambda.arn}"
  filename      = "${var.lambda_get_from_api_path}"
  function_name = "${var.lambda_get_from_api_name}"
  description   = "${var.lambda_get_from_api_description}"
  handler       = "${var.lambda_get_from_api_handler}"
  runtime       = "${var.python_default_version}"

  source_code_hash = base64sha256("${var.lambda_get_from_api_path}")

}

resource "aws_cloudwatch_event_rule" "every_five_minutes" {
    name = "every-five-minutes"
    description = "Fires every five minutes"
    schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "cloudwatch_event_target_every_five_minutes" {
    rule = "${aws_cloudwatch_event_rule.every_five_minutes.name}"
    arn = "${aws_lambda_function.get_data_from_external_api.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_cloudwatch_event" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.get_data_from_external_api.function_name}"
    principal = "events.amazonaws.com"
    source_arn = "${aws_cloudwatch_event_rule.every_five_minutes.arn}"
}


resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

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

resource "aws_iam_policy" "amazonKinesisFullAccess" {
  name = "amazonKinesisFullAccess"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "kinesis:*",
            "Resource": "*"
        }
    ]
})
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_kinesisAtt" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.amazonKinesisFullAccess.arn
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}