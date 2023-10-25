resource "aws_lambda_function" "put_dynamodb" {
 
 filename = "${path.module}/python/putitem.zip"
 function_name = "putitem"
  runtime = "python3.11"
  handler = "putitem.lambda_handler"
  role = aws_iam_role.lambda_exec.arn
}

resource "aws_cloudwatch_log_group" "lambda_put_dynamodb" {
  name = "/aws/lambda/${aws_lambda_function.put_dynamodb.function_name}"

  retention_in_days = 30
}

resource "aws_iam_role" "lambda_exec" {
  name = "serverless_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  
}

resource "aws_iam_policy" "iam_policy_for_lambda_dynamodb" {

  name         = "aws_iam_policy_for_terraform_aws_lambda_dynamodb"
  path         = "/"
  description  = "AWS IAM Policy for managing aws lambda role"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1698074550649",
      "Action": [
        "dynamodb:PutItem"
      ],
      "Effect": "Allow",
      "Resource": "${"aws_dynamodb_table.delivery.arn"}"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_lambda_dynamodb" {
  role        = aws_iam_role.lambda_exec.name
  policy_arn  = aws_iam_policy.iam_policy_for_lambda_dynamodb.arn
}


resource "aws_iam_policy" "iam_policy_for_lambda_sns" {

  name         = "aws_iam_policy_for_terraform_aws_lambda_sns"
  path         = "/"
  description  = "AWS IAM Policy for managing aws lambda role"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1698242525286",
      "Action": [
        "SNS:Subscribe",
        "SNS:SetTopicAttributes",
        "SNS:RemovePermission",
        "SNS:Publish",
        "SNS:ListSubscriptionsByTopic",
        "SNS:GetTopicAttributes",
        "SNS:DeleteTopic",
        "SNS:AddPermission"],
      "Effect": "Allow",
      "Resource": "${"aws_sns_topic.user_updates.arn"}"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_lambda_sns" {
  role        = aws_iam_role.lambda_exec.name
  policy_arn  = aws_iam_policy.iam_policy_for_lambda_sns.arn
}

resource "aws_lambda_permission" "with_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.put_dynamodb.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.user_updates.arn
}