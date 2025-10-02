resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "basic-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        "type": "metric",
        "x": 0, "y": 0, "width": 12, "height": 6,
        "properties": {
          "title": "ALB Requests",
          "view": "timeSeries",
          "region": var.region,
          "stat": "Sum",
          "metrics": [
            [ "AWS/ApplicationELB", "RequestCount", "LoadBalancer", var.alb_load_balancer_name ]
          ]
        }
      },
      {
        "type": "metric",
        "x": 0, "y": 6, "width": 12, "height": 6,
        "properties": {
          "title": "ECS CPU / Memory",
          "view": "timeSeries",
          "region": var.region,
          "metrics": [
            [ "AWS/ECS", "CPUUtilization", "ClusterName", var.ecs_cluster_name, "ServiceName", var.ecs_service_name ],
            [ ".", "MemoryUtilization", "ClusterName", var.ecs_cluster_name, "ServiceName", var.ecs_service_name ]
          ]
        }
      }
    ]
  })
}
