resource "aws_ecr_repository" "ecsv2" {
  name                 = "${var.name}"
  image_tag_mutability = "IMMUTABLE_WITH_EXCLUSION"
 
  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  image_tag_mutability_exclusion_filter {
    filter      = "latest*"
    filter_type = "WILDCARD"
  }

}