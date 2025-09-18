resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = data.aws_vpc_endpoint_service.s3.service_name
}


resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id       = aws_vpc.main.id
  service_name =  data.aws_vpc_endpoint_service.dynamodb.service_name

}