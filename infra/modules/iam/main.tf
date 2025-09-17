resource "aws_iam_role" "this" {
  name = var.role_name

  assume_role_policy = jsondecode(
    {

      Version = "2012-10-17"

      Statement = [{

        Effect = "Allow"
        Principal = {
          Service = var.principal_service
        },
        Action = "sts:AssumeRole"
      }]

    }

  )


}



resource "aws_iam_policy" "inline" {

  count = length(var.policy_statements) > 0 ? 1 : 0
  name  = "${var.role_name}-inline"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      for s in var.policy_statements : {
        Effect   = s.effect,
        Action   = s.actions,
        Resource = s.resources
      }
    ]
  })

}


resource "aws_iam_role_policy_attachment" "inline_attach" {
  count      = length(var.policy_statements) > 0 ? 1 : 0
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.inline[0].arn
}