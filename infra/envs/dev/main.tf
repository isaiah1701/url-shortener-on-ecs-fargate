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
  execution_role_arn = var.execution_role_arn
  subnet_ids         = var.subnet_ids
  container_image    = var.container_image
  security_group_ids = [module.sg.ecs_tasks_sg_id]
  task_role_arn      = var.task_role_arn
}

module "dynamodb" {
  source = "../../modules/dynamodb"
  name   = "${var.environment}-dynamodb"
}
module "iam" {
  source             = "../../modules/iam"
  dynamodb_table_arn = var.dynamodb_table_arn
  iam_name           = local.iam_name
}

module "sg" {
  source    = "../../modules/sg"
  vpc_id    = module.vpc.vpc_id
  sg_name   = local.sg_name
  alb_sg_id = var.alb_sg_id



}