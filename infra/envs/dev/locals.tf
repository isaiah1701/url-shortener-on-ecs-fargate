
locals {
  iam_name = "${var.environment}-iam"
  sg_name  = "${var.environment}-sg"
  private_subnet_map = {
    for idx, id in tolist(module.vpc.private_subnet_ids) :
    tostring(idx) => id
  }
   #private_route_table_ids = [module.vpc.private_rt_id]
   

 # private_route_table_ids = [for rt in data.aws_route_table.by_private_subnet : rt.id]
}
