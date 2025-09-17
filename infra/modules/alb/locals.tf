locals {
  # Opinionated defaults every resource in this module should carry
  default_tags = {

    Module = "alb"
  }

  # Merge default tags with any caller-provided tags
  common_tags = merge(local.default_tags, var.tags)

  # Enforce a consistent SSL policy for HTTPS listeners
  ssl_policy = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}