resource "aws_api_gateway_rest_api" "notify_me" {
  name = "notify-me"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "notify_me" {
  path_part   = "notify"
  rest_api_id = aws_api_gateway_rest_api.notify_me.id
  parent_id   = aws_api_gateway_rest_api.notify_me.root_resource_id
}

resource "aws_api_gateway_method" "notify_me" {
  rest_api_id      = aws_api_gateway_rest_api.notify_me.id
  resource_id      = aws_api_gateway_resource.notify_me.id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "notify_me" {
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.notify_me.invoke_arn

  http_method = aws_api_gateway_method.notify_me.http_method
  resource_id = aws_api_gateway_resource.notify_me.id
  rest_api_id = aws_api_gateway_rest_api.notify_me.id
}

resource "aws_api_gateway_deployment" "notify_me" {
  rest_api_id = aws_api_gateway_rest_api.notify_me.id

  triggers = {
    redeployment = filesha1("./api-gateway.tf")
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "notify_me" {
  deployment_id = aws_api_gateway_deployment.notify_me.id
  rest_api_id   = aws_api_gateway_rest_api.notify_me.id
  stage_name    = "prod"
}

resource "aws_api_gateway_usage_plan" "notify_me" {
  name = "notify-me"

  api_stages {
    api_id = aws_api_gateway_rest_api.notify_me.id
    stage  = aws_api_gateway_stage.notify_me.stage_name
  }
}

resource "aws_api_gateway_usage_plan_key" "notify_me" {
  key_type      = "API_KEY"
  key_id        = aws_api_gateway_api_key.notify_me.id
  usage_plan_id = aws_api_gateway_usage_plan.notify_me.id
}

resource "aws_api_gateway_api_key" "notify_me" {
  name = "tg-notify-me-key"
}

output "endpoint_url" {
  value = "${aws_api_gateway_stage.notify_me.invoke_url}${aws_api_gateway_resource.notify_me.path}"
}

output "api_key" {
  value     = aws_api_gateway_api_key.notify_me.value
  sensitive = true
}
