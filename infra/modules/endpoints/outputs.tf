output "endpoints" {
  value = {
    s3       = aws_vpc_endpoint.s3.id
    dynamodb = aws_vpc_endpoint.dynamodb.id
  }
}

output "public_route_table_id" { value = aws_route_table.public.id }
output "private_route_table_id" { value = aws_route_table.private.id }
output "s3_endpoint_id" { value = aws_vpc_endpoint.s3.id }
output "dynamodb_endpoint_id" { value = aws_vpc_endpoint.dynamodb.id }