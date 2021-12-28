data "aws_secretsmanager_secret_version" "notify_me" {
  secret_id = "tg-notify-me"
}

output "secret_id" {
  value = data.aws_secretsmanager_secret_version.notify_me.arn
}
