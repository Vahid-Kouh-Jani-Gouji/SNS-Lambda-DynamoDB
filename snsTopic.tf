resource "aws_sns_topic_subscription" "lambda_subscription" {
  topic_arn = aws_sns_topic.user_updates.arn
  protocol  = "lambda"
  endpoint  = "arn:aws:lambda:eu-central-1:117995874887:function:putitem"
}
