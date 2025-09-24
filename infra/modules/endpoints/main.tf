resource "aws_vpc_endpoint" "s3" {
  vpc_id            = var.vpc_id
  vpc_endpoint_type = "Gateway"
  service_name      = "com.amazonaws.${var.region}.s3"
 route_table_ids = [aws_route_table.private.id]

}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id            = var.vpc_id
  vpc_endpoint_type = "Gateway"
  service_name      = "com.amazonaws.${var.region}.dynamodb"
  route_table_ids = [aws_route_table.private.id]

}


resource "aws_route_table" "public" {
  vpc_id = var.vpc_id
  tags   = { Name = "public-rt" }
}
resource "aws_route" "public_default_inet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.internet_gateway_id
}
resource "aws_route_table_association" "public_assoc" {
   count         = length(var.public_subnet_ids)
  subnet_id     = var.public_subnet_ids[count.index]
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = var.vpc_id
  tags   = { Name = "private-rt" }
}
resource "aws_route_table_association" "private_assoc" {
   count         = length(var.private_subnet_ids)
  subnet_id     = var.private_subnet_ids[count.index]
  route_table_id = aws_route_table.private.id
}