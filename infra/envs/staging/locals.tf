
locals {
  iam_name = "${var.environment}-iam"
  sg_name  = "${var.environment}-sg"
  private_subnet_map = {
    for idx, id in tolist(module.vpc.private_subnet_ids) :
    tostring(idx) => id
  }

}
