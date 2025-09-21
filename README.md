# url-shortener-on-ecs-fargate

## Project Overview

This project is an upcoming cloud-native application designed for deployment on AWS ECS Fargate. It leverages Docker for containerization, Python for backend logic, and Terraform for infrastructure as code. The structure supports scalable deployment, modular infrastructure, and streamlined local development.

### Directory Structure & Details

- **app/**  
	Contains the main application code and dependencies.
	- `Dockerfile`: Container image definition.
	- `requirements.txt`: Python dependencies.
	- `src/`: Python source code (`main.py`, `ddb.py`).
	- `tests/`: Unit tests.

- **infra/**  
	Infrastructure as code using Terraform.
	- `envs/`: Environment-specific configs (dev, prod, staging).
	- `global/`: Shared infrastructure (e.g., backend state).
	- `modules/`: Reusable Terraform modules for AWS resources (VPC, ECS, ALB, IAM, DynamoDB, etc.).

- **local/**  
	Local development resources.
	- `docker-compose.yml`: Local multi-container setup.
	- `makefile`: Automation scripts.
	- `volume/`: Caches, logs, temporary files.

- **README.md**  
	Project documentation and instructions.

---

## Upcoming Status

This project is currently in development and is an upcoming solution. It is being structured for robust cloud deployment, modular infrastructure management, and easy local development/testing. Stay tuned for more updates as features and documentation are finalized.

