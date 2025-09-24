module "alb" {
  source            = "../../modules/alb"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  certificate_arn   = var.certificate_arn
  security_group_id = module.sg.alb_sg_id
}

module "vpc" {
  source               = "../../modules/vpc"
  cidr_block           = var.cidr_block
  name                 = "${var.environment}-vpc"
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs
  azs                  = var.azs

}


module "ecs" {

  source             = "../../modules/ecs"
  execution_role_arn = module.iam.execution_role_arn
  subnet_ids         = module.vpc.private_subnet_ids
  container_image    = var.container_image
  security_group_ids = [module.sg.ecs_tasks_sg_id]
  task_role_arn      = module.iam.task_role_arn
}

module "dynamodb" {
  source = "../../modules/dynamodb"
  name   = "${var.environment}-dynamodb"
}
module "iam" {
  source             = "../../modules/iam"
  dynamodb_table_arn = module.dynamodb.table_arn
  iam_name           = local.iam_name
}

module "sg" {
  source    = "../../modules/sg"
  vpc_id    = module.vpc.vpc_id
  sg_name   = local.sg_name
  alb_sg_id = var.alb_sg_id



}
# data "aws_route_table" "by_private_subnet" {
#   for_each  = toset(module.vpc.private_subnet_ids)
#   subnet_id = each.value
# }
 module "endpoints" {
  source = "../../modules/endpoints"
  vpc_id = module.vpc.vpc_id
  region = var.region
#route_table_ids = local.private_route_table_ids
internet_gateway_id = module.vpc.igw_id
public_subnet_ids = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnets         = module.vpc.public_subnet_ids

  endpoints = {
    s3 = {
       vpc_id=module.vpc.vpc_id
      service_name     = "com.amazonaws.${var.region}.s3"
      vpc_endpoint_type = "Gateway"
  
    }

    dynamodb = {
      vpc_id=module.vpc.vpc_id
      service_name     = "com.amazonaws.${var.region}.dynamodb"
      vpc_endpoint_type = "Gateway"
      
    }
  }
}

