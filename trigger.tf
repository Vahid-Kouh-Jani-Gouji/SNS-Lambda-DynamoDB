# resource "aws_lambda_event_source_mapping" "event_source_mapping" {

#   event_source_arn  = aws_sns_topic.user_updates.arn
 
#   function_name     = aws_lambda_function.put_dynamodb.arn
# }