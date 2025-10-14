
resource "aws_lambda_function" "trigger_deploy" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "ecr-trigger-codedeploy"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      APPLICATION_NAME   = "url-code-deploy"
      DEPLOYMENT_GROUP   = "urlshortener"
      TASKDEF_FAMILY     = var.taskdef_family
      TASK_ROLE_ARN      = var.task_role_arn
      EXECUTION_ROLE_ARN = var.execution_role_arn
      CONTAINER_REPO_URI = var.container_repo_uri
      CONTAINER_NAME     = var.container_name
      CONTAINER_PORT     = tostring(var.container_port)
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name = "ecr-trigger-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "ecr-trigger-codedeploy-perms"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # CodeDeploy + ECS (as you had)
      {
        Effect = "Allow",
        Action = [
          "codedeploy:CreateDeployment",
          "codedeploy:GetDeployment",
          "codedeploy:GetDeploymentConfig",
          "codedeploy:GetApplication",
          "codedeploy:GetDeploymentGroup",
          "codedeploy:RegisterApplicationRevision",
          "codedeploy:GetApplicationRevision",
          "codedeploy:ListApplicationRevisions",
          "ecs:DescribeTaskDefinition",
          "ecs:RegisterTaskDefinition"
        ],
        Resource = "*"
      },

      {
        Effect = "Allow",
        Action = "iam:PassRole",
        Resource = [
          var.task_role_arn,
          var.execution_role_arn
        ],
        Condition = {
          StringEquals = {
            "iam:PassedToService" = "ecs-tasks.amazonaws.com"
          }
        }
      },

      # Logs (unchanged)
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}


resource "aws_cloudwatch_event_rule" "ecr_push" {
  name        = "capture-ecr-push"
  description = "Capture ECR image pushes"

  event_pattern = jsonencode({
    source      = ["aws.ecr"]
    detail-type = ["ECR Image Action"]
    detail = {
      action-type     = ["PUSH"]
      repository-name = [var.ecr_repository_name]
      image-tag       = ["latest"]
    }
  })
}

# Target Lambda from EventBridge
resource "aws_cloudwatch_event_target" "lambda" {
  rule      = aws_cloudwatch_event_rule.ecr_push.name
  target_id = "TriggerCodeDeployLambda"
  arn       = aws_lambda_function.trigger_deploy.arn
}

# Allow EventBridge to invoke Lambda
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.trigger_deploy.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ecr_push.arn
}

# Create zip file for Lambda function
data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/lambda.zip"

  source {
    filename = "index.js"
    content  = <<-EOF
const { ECSClient, DescribeTaskDefinitionCommand, RegisterTaskDefinitionCommand } = require("@aws-sdk/client-ecs");
const { CodeDeployClient, CreateDeploymentCommand } = require("@aws-sdk/client-codedeploy");

const REGION = process.env.AWS_REGION || "eu-west-2";
const ecs = new ECSClient({ region: REGION });
const cd  = new CodeDeployClient({ region: REGION });

exports.handler = async (event) => {
  console.log("Received event:", JSON.stringify(event, null, 2));

  const d = event && event.detail ? event.detail : {};
  if (event["detail-type"] !== "ECR Image Action" ||
      d["action-type"] !== "PUSH" ||
      d.result !== "SUCCESS") {
    console.log("Ignoring non-successful or non-push event");
    return { ignored: true };
  }

  const imageTag = d["image-tag"] || "latest";
  const repository = d["repository-name"];
  if (!repository) throw new Error("Missing repository-name from event");

  const family           = process.env.TASKDEF_FAMILY;      // e.g. "staging-urlshortener"
  const containerName    = process.env.CONTAINER_NAME;      // e.g. "staging-urlshortener"
  const containerPort    = parseInt(process.env.CONTAINER_PORT, 10);
  const taskRoleArn      = process.env.TASK_ROLE_ARN;
  const executionRoleArn = process.env.EXECUTION_ROLE_ARN;
  const applicationName  = process.env.APPLICATION_NAME;
  const deploymentGroup  = process.env.DEPLOYMENT_GROUP;
  const containerRepoUri = process.env.CONTAINER_REPO_URI;  

  // 1) Describe current task def (by family) to clone settings
  const cur = await ecs.send(new DescribeTaskDefinitionCommand({ taskDefinition: family }));
  const td = cur.taskDefinition;

  // 2) Update image for target container
  const newContainerDefs = td.containerDefinitions.map((c) => {
    if (c.name === containerName) {
      return Object.assign({}, c, { image: containerRepoUri + ":" + imageTag });
    }
    return c;
  });

  // 3) Register new task definition revision
  const reg = await ecs.send(new RegisterTaskDefinitionCommand({
    family: family,
    networkMode: td.networkMode,
    requiresCompatibilities: td.requiresCompatibilities,
    cpu: td.cpu,
    memory: td.memory,
    executionRoleArn: executionRoleArn,
    taskRoleArn: taskRoleArn,
    volumes: td.volumes,
    placementConstraints: td.placementConstraints,
    proxyConfiguration: td.proxyConfiguration,
    ephemeralStorage: td.ephemeralStorage,
    containerDefinitions: newContainerDefs
  }));
  const taskDefArn = reg.taskDefinition.taskDefinitionArn;
  console.log("Registered task def:", taskDefArn);

  // 4) Trigger CodeDeploy deployment with inline AppSpec
  const appSpec = {
    version: 0.0,
    Resources: [{
      TargetService: {
        Type: "AWS::ECS::Service",
        Properties: {
          TaskDefinition: taskDefArn,
          LoadBalancerInfo: {
            ContainerName: containerName,
            ContainerPort: containerPort
          },
          PlatformVersion: "LATEST"
        }
      }
    }]
  };

  const res = await cd.send(new CreateDeploymentCommand({
    applicationName: applicationName,
    deploymentGroupName: deploymentGroup,
    revision: {
      revisionType: "AppSpecContent",
      appSpecContent: { content: JSON.stringify(appSpec) }
    },
    description: "ECR push " + repository + ":" + imageTag + " -> " + taskDefArn
  }));

  console.log("Deployment created:", res);
  return res;
};
EOF
  }
}



resource "aws_codedeploy_app" "this" {
  compute_platform = "ECS"
  name             = "url-code-deploy"
}


resource "aws_iam_role" "eventbridge_role" {
  name = "eventbridge-codedeploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "eventbridge_policy" {
  name = "eventbridge-codedeploy-policy"
  role = aws_iam_role.eventbridge_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "codedeploy:CreateDeployment",
          "codedeploy:GetDeployment",
          "codedeploy:GetDeploymentConfig",
          "codedeploy:GetApplication",
          "codedeploy:GetDeploymentGroup",
          "codedeploy:List*"
        ]
        Resource = "*"
      }
    ]
  })
}



resource "aws_codedeploy_deployment_group" "codedeploy" {
  app_name               = aws_codedeploy_app.this.name
  deployment_config_name = "CodeDeployDefault.ECSLinear10PercentEvery1Minutes"
  deployment_group_name  = "urlshortener"
  service_role_arn       = var.iam_role_arn

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout    = "CONTINUE_DEPLOYMENT"
      wait_time_in_minutes = 0 # Don't wait for manual approval
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = var.cluster
    service_name = var.ecs_svc
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [var.listener_arn]
      }

      target_group {
        name = var.blue_tg_name
      }

      target_group {
        name = var.green_tg_name
      }

    }
  }
}