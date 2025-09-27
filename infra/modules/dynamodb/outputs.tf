output "table_name" {
  description = "DynamoDB table name"
  value       = "ShortenedURL"
}

output "table_arn" {
  description = "DynamoDB table ARN"
  value       = aws_dynamodb_table.ShortenedUrl.arn
}
