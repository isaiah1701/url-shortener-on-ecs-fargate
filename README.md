# 🚀 URL Shortener on ECS Fargate — Production-Grade Deployment (ECS v2)

This project is a **production-ready AWS architecture** for deploying a containerized Python URL shortener using **ECS Fargate**, **Terraform**, and **CI/CD with GitHub OIDC → CodeDeploy**.

It builds upon the original CoderCo ECS challenge and extends it into a **secure, automated, multi-environment stack** with **blue/green deployments**, **WAF protection**, and **CloudWatch monitoring**.

---

## 🏗️ Architecture Overview

**Stack highlights**
- **ECS Fargate** – serverless compute for containerized workloads  
- **ALB + Blue/Green Target Groups** – safe deployment switching via CodeDeploy  
- **WAF (Web ACL)** – filters malicious traffic before reaching the ALB  
- **Route 53 + ACM** – custom domain with automatic TLS  
- **ECR** – Docker image registry  
- **Terraform Modules** – reusable IaC for VPC, ALB, ECS, IAM, WAF, CloudWatch  
- **GitHub OIDC → CodeDeploy** – secure CI/CD pipeline (no long-lived AWS keys)  
- **Multi-Environment Setup** – `dev`, `staging`, and `prod` folders using a shared S3 + DynamoDB backend  

---

## 🖼️ Key Components

### 🔹 Home Screen
![Home Screen](images/homescreen.png)

Simple FastAPI UI that accepts a URL, shortens it, and stores the mapping in DynamoDB.

---

### 🔹 OIDC Pipeline Integration
![OIDC](images/oidc.png)

GitHub Actions authenticates directly with AWS via OIDC — no static credentials.  
This ensures **secure, short-lived tokens** for Terraform plan/apply and image deployment.

---

### 🔹 CodeDeploy Blue/Green
![CodeDeploy](images/codeDeploy.png)

Traffic between blue and green target groups is shifted automatically after successful health checks, ensuring **zero-downtime deployments**.

---

### 🔹 WAF Configuration
![WAF](images/waf.png)
![WAF Firewall](images/wafFirewall.png)

AWS WAF protects the ALB from malicious patterns (SQL i, XSS, bad bots).  
Custom rules and rate limiting policies are defined through Terraform.

---

### 🔹 Private Endpoints
![Endpoints](images/endpoints.png)

VPC Interface Endpoints for CloudWatch, ECR, and Logs keep all ECS traffic internal to AWS.  
No data leaves the VPC, improving security and latency.

---
## 🚀 Deployment Flow Overview

The entire deployment flow from **commit → production** is fully automated through **GitHub Actions**, **ECR**, **EventBridge**, **Lambda**, and **CodeDeploy** — with secure authentication using **OIDC** (no stored AWS keys).

---

### 🧩 Step 1 — Developer Commit → GitHub Actions Trigger
- Developer commits code to any branch (`dev`, `staging`, or `main`).
- GitHub Actions triggers the **Build Workflow** automatically.
- Workflow loads environment variables, runs security and format checks, builds the Docker image, and authenticates to AWS via OIDC.

**Key checks and actions:**
- Load `.env` variables  
- Derive deploy environment from branch  
- Run **Checkov**, **TFLint**, and **Terraform validate**  
- Build and scan Docker image with **Trivy**  
- Authenticate securely to AWS via **OIDC**  

---

### 🐳 Step 2 — Build & Push to ECR
After validation:
- Docker builds the application image locally on the runner.
- The image is pushed to **Amazon ECR**, tagged as `latest`.

```bash
docker build -t $IMAGE_NAME:latest -f app/Dockerfile app
docker push $ECR_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$IMAGE_NAME:latest
⚡ Step 3 — EventBridge → Lambda Trigger

An EventBridge rule monitors the ECR repository for image push events (action-type: PUSH).

When a new image is pushed:

EventBridge triggers a Lambda function (ecr-trigger-codedeploy)

The Lambda automates the deployment lifecycle.

Lambda responsibilities:

Fetch current ECS task definition

Replace the image with the new ECR tag

Register a new ECS task definition revision

Trigger CodeDeploy with the new revision and AppSpec content

This ensures that every successful image push automatically triggers a new ECS deployment — no manual steps required.

🚀 Step 4 — CodeDeploy → Blue/Green Rollout

CodeDeploy coordinates a blue/green deployment using the ECS service and ALB listener.

The blue target group serves live production traffic.

The green target group runs the new revision in parallel.

Traffic shifts 10% every minute, verifying health checks through ALB.

If the green environment passes all checks, it becomes the new production.

If a failure occurs:

CodeDeploy automatically rolls back to the previous stable revision.

🌐 Step 5 — Traffic Shift & Health Validation

Once CodeDeploy confirms the green target group is healthy:

Traffic fully switches from blue → green

Blue tasks are terminated 5 minutes later

Logs and metrics are streamed to CloudWatch

Health checks:

HTTP path /healthz

Status codes 200–399

2 consecutive successes mark the target as healthy
| Stage                  | Trigger      | Service        | Action                 |
| ---------------------- | ------------ | -------------- | ---------------------- |
| 🧑‍💻 Developer commit | Git push     | GitHub Actions | Build + validate       |
| 🐳 Build image         | Workflow job | Docker + ECR   | Build & push image     |
| ⚡ ECR push event       | EventBridge  | Lambda         | Register new ECS task  |
| 🚀 Deployment          | Lambda       | CodeDeploy     | Blue/Green rollout     |
| ✅ Validation           | CodeDeploy   | ECS Fargate    | Health check + cutover |

---

## 🧠 Key Learnings

- Implementing **secure CI/CD without AWS keys**
- Managing **multi-env Terraform state** (S3 + DynamoDB)
- Designing **rollback-ready deployments** via CodeDeploy
- Integrating **AWS WAF + CloudWatch dashboards** for visibility
- Troubleshooting ECS Fargate target health and listener routing

---

## 📂 Repository Structure

app/ # FastAPI app
infra/
├── modules/ # Reusable Terraform modules (vpc, ecs, alb, waf, etc.)
├── envs/ # dev / staging / prod configurations
└── global/ # Backend (S3+DynamoDB) state setup
.github/workflows/ # CI/CD pipelines (Build + Deploy)


---

## 🧩 Tech Stack

| Category | Tools |
|-----------|-------|
| Cloud | AWS (ECS Fargate, ECR, ALB, WAF, Route 53, ACM, CloudWatch) |
| IaC | Terraform v1.9+ |
| CI/CD | GitHub Actions + OIDC → CodeDeploy |
| Language | Python (FastAPI) |
| Security | AWS WAF + Private VPC Endpoints |
| Monitoring | CloudWatch Logs + Dashboards |

---

## 🧭 Next Steps

- Add **CloudWatch Alarms → SNS notifications**
- Introduce **Checkov / Tfsec** for IaC security
- Automate **rollback on 5xx error threshold**
- Publish as a **Terraform module template**

---

### 🏁 Outcome

A fully automated, production-grade **ECS Fargate deployment** demonstrating:
- Infrastructure as Code discipline  
- Secure OIDC CI/CD integration  
- Blue/green release management  
- Layer-7 security via WAF  
- Cloud-native observability and resilience  

---

