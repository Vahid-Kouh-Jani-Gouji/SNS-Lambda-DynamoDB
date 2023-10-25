data "archive_file" "lambda_dynamodb_put" {
  type = "zip"

  source_dir  = "${path.module}/python/"
  output_path = "${path.module}/python/putitem.zip"
}