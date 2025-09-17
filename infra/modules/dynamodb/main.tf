resource "aws_dynamodb_table" "ShortenedUrl" {
  name         = var.name
  billing_mode = var.billing_mode

  hash_key = var.hash_key_name


  attribute {
    name = var.hash_key_name
    type = var.hash_key_type
  }

  ttl {

    enabled        = var.ttl.enabled
    attribute_name = var.ttl.attribute_name
  }


  point_in_time_recovery {
    enabled = var.point_in_time_recovery
  }


  server_side_encryption {
    enabled = var.sse_enabled
  }



}