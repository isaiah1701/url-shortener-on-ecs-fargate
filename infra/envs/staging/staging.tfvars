environment          = "staging"
cidr_block           = "10.1.0.0/20"
public_subnet_cidrs  = ["10.1.1.0/24", "10.1.2.0/24"]
private_subnet_cidrs = ["10.1.3.0/24", "10.1.4.0/24"]

azs = ["eu-west-2a", "eu-west-2b"]


container_image = "isaiah4748/urlshortener:latest"



alb_sg_id = "sg-0abc1234def567890"
region    = "eu-west-2"

domain_name = "5hort.site"

account_id   = "044941685411"
github_owner = "isaiah1701"
github_repo  = "url-shortener-on-ecs-fargate"
allowed_ref  = "refs/heads/main"   