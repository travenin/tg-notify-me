resource "aws_iam_role" "notify_me" {
  name = "notify-me-role"

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "notify_me" {
  function_name = "tg-notify-me"
  role          = aws_iam_role.notify_me.arn
  runtime       = "python3.8"

  handler          = "handler.handler"
  filename         = "../dist/lambda.zip"
  source_code_hash = filebase64sha256("../dist/lambda.zip")
}

resource "aws_lambda_permission" "lambda_permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.notify_me.id
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.notify_me.execution_arn}/*/*/*"
}
