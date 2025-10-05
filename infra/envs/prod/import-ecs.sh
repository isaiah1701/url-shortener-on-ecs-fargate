#!/bin/bash

# Load vars manually
ENV="prod"
ACCOUNT_ID="044941685411"
REGION="eu-west-2"
CLUSTER="prod-urlshortener-cluster"
SERVICE="prod-urlshortener-service"

# Build ARN
ARN="arn:aws:ecs:${REGION}:${ACCOUNT_ID}:service/${CLUSTER}/${SERVICE}"

# Import
terraform import module.ecs.aws_ecs_service.this "$ARN"
