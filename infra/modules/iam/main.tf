resource "aws_iam_role" "execution" {
  name = "${var.iam_name}-ecs-execution"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "ecs-tasks.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "execution_managed" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "task" {
  name = "${var.iam_name}-ecs-task"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "ecs-tasks.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

# Least-privilege DynamoDB access for your app
resource "aws_iam_role_policy" "task_dynamodb" {
  name = "${var.iam_name}-task-dynamodb"
  role = aws_iam_role.task.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "dynamodb:GetItem",
        "dynamodb:PutItem",

      ],
      Resource = var.dynamodb_table_arn
    }]
  })
}


resource "aws_iam_role_policy" "execution_logs" {
  name = "ecs-execution-logs"
  role = aws_iam_role.execution.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "logs:CreateLogGroup",
        "logs:DescribeLogGroups"
      ],
      Resource = "*"
    }]
  })
}

resource "aws_iam_role" "codedeploy" {
  name = "ecs-codedeploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "codedeploy.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "codedeploy_policy" {
  name = "ecs-codedeploy-policy"
  role = aws_iam_role.codedeploy.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecs:CreateTaskSet",
          "ecs:DeleteTaskSet",
          "ecs:UpdateServicePrimaryTaskSet",
          "ecs:DescribeServices",
          "ecs:DescribeTaskSets",
          "ecs:UpdateService"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeRules",
          "elasticloadbalancing:ModifyListener",
          "elasticloadbalancing:ModifyRule"
        ],
        Resource = "*"
      }
    ]
  })
}





# --- OIDC provider stays the same ---
resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b55a9f3b6d8e5eeb0e7"
  ]
}

# --- Trust policy (who can assume the role) ---
data "aws_iam_policy_document" "gha_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${var.github_owner}/${var.github_repo}:ref:refs/heads/*",
        "repo:${var.github_owner}/${var.github_repo}:ref:refs/tags/*",
        "repo:${var.github_owner}/${var.github_repo}:ref:refs/pull/*"
      ]
    }
  }
}

# --- The role to be assumed by GitHub OIDC ---
resource "aws_iam_role" "gha_oidc" {
  name                 = "gha-oidc-simple"
  description          = "Minimal role assumed by GitHub Actions via OIDC"
  assume_role_policy   = data.aws_iam_policy_document.gha_trust.json
  max_session_duration = 3600
}

# --- Define a customer-managed policy (replace with real perms later) ---
data "aws_iam_policy_document" "github_policy" {
  statement {
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
      "ecr:DescribeRepositories",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer"
    ]
    resources = [
      "arn:aws:ecr:${var.aws_region}:${var.account_id}:repository/${var.ecr_repository}"
    ]
  }
}

resource "aws_iam_policy" "github_managed" {
  name        = "gha-oidc-simple-policy"
  description = "Reusable managed policy for GitHub OIDC role"
  policy      = data.aws_iam_policy_document.github_policy.json
}

# --- Attach the managed policy to the role ---
resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.gha_oidc.name
  policy_arn = aws_iam_policy.github_managed.arn
}



