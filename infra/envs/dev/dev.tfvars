environment          = "dev"
cidr_block           = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24"]
private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
azs                  = ["eu-west-2a", "eu-west-2b"]


container_image = "isaiah4748/urlshortener:latest"


dynamodb_table_arn = "arn:aws:dynamodb:eu-west-2:000000000000:table/urlshortener"
alb_sg_id          = "sg-00000000000000000"
region             = "eu-west-2"

domain_name  = "5hort.site"
github_owner = "isaiah1701"
github_repo  = "url-shortener-on-ecs-fargate"
allowed_ref  = "refs/heads/main"   