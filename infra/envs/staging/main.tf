module "alb" {
  source            = "../../modules/alb"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  certificate_arn   = module.acm.validated_certificate_arn
  security_group_id = module.sg.alb_sg_id

}
module "ecr" {
  source = "../../modules/ecr"
  name   = "${var.environment}-urlshortener"


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
  ecs_name           = "${var.environment}-urlshortener" # This sets the container name
  execution_role_arn = module.iam.execution_role_arn
  subnet_ids         = module.vpc.private_subnet_ids
  container_image    = module.ecr.repository_url
  security_group_ids = [module.sg.ecs_tasks_sg_id]
  task_role_arn      = module.iam.task_role_arn
  table_name         = module.dynamodb.table_name
  vpc_id             = module.vpc.vpc_id
  blue_tg_name       = module.alb.blue_tg_name
  aws_region         = var.region



}

module "dynamodb" {
  source = "../../modules/dynamodb"
  name   = "${var.environment}-dynamodb"
}
module "iam" {
  source             = "../../modules/iam"
  dynamodb_table_arn = module.dynamodb.table_arn
  iam_name           = local.iam_name
  account_id = "044941685411"
  github_owner = "isaiah1701"
  github_repo = "https://github.com/isaiah1701/url-shortener-on-ecs-fargate"
  aws_region = var.region
  ecr_repository = "${var.environment}-urlshortener"
}

module "sg" {
  source    = "../../modules/sg"
  vpc_id    = module.vpc.vpc_id
  sg_name   = local.sg_name
  alb_sg_id = var.alb_sg_id



}

module "endpoints" {
  source = "../../modules/endpoints"
  vpc_id = module.vpc.vpc_id
  region = var.region

  internet_gateway_id = module.vpc.igw_id
  public_subnet_ids   = module.vpc.public_subnet_ids
  private_subnet_ids  = module.vpc.private_subnet_ids
  public_subnets      = module.vpc.public_subnet_ids
  ecr_sg_id           = module.sg.ecr_sg_id

  InterfaceEndpoints = {
    ecr_api = {
      service_name        = "com.amazonaws.${var.region}.ecr.api"
      subnet_ids          = module.vpc.private_subnet_ids
      security_group_ids  = [module.sg.ecr_sg_id] # ← make it a list
      private_dns_enabled = true
    }
    ecr_dkr = {
      service_name        = "com.amazonaws.${var.region}.ecr.dkr"
      subnet_ids          = module.vpc.private_subnet_ids
      security_group_ids  = [module.sg.ecr_sg_id] # ← make it a list
      private_dns_enabled = true
    }
  }



  GatewayEndpoints = {
    s3 = {
      vpc_id            = module.vpc.vpc_id
      service_name      = "com.amazonaws.${var.region}.s3"
      vpc_endpoint_type = "Gateway"

    }

    dynamodb = {
      vpc_id            = module.vpc.vpc_id
      service_name      = "com.amazonaws.${var.region}.dynamodb"
      vpc_endpoint_type = "Gateway"

    }








  }

  aws_region = var.region
}



module "acm" {

  source      = "../../modules/acm"
  domain_name = var.domain_name

  zone = module.route53.zone_id




}

module "route53" {
  source = "../../modules/route53"
  domain = var.domain_name

}

resource "aws_route53_record" "root_alias" {
  zone_id = module.route53.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = module.alb.alb_dns_name
    zone_id                = module.alb.alb_zone_id
    evaluate_target_health = true
  }
}

module "codedeploy" {
  source              = "../../modules/codedeploy"
  iam_role_arn        = module.iam.codedeploy_role_arn
  cluster             = module.ecs.cluster_name
  ecs_svc             = module.ecs.service_name
  listener_arn        = module.alb.https_listener_arn
  blue_tg_name        = module.alb.blue_tg_name
  green_tg_name       = module.alb.green_tg_name
  task_definition_arn = module.ecs.task_definition_arn
  ecr_repository_name = module.ecr.repository_name
  container_name      = "${var.environment}-urlshortener"
  task_role_arn       = module.iam.task_role_arn
  execution_role_arn  = module.iam.execution_role_arn
  container_repo_uri  = module.ecr.repository_url
  taskdef_family      = "${var.environment}-urlshortener-task"

}

module "waf" {
  source  = "../../modules/waf"
  alb_arn = module.alb.alb_arn
  region  = var.region
}

module "cloudwatch" {
  source                 = "../../modules/cloudwatch"
  ecs_service_name       = module.ecs.service_name
  ecs_cluster_name       = module.ecs.cluster_name
  region                 = var.region
  alb_load_balancer_name = module.alb.alb_arn
}