

````markdown
# Terraform DevOps Assignment – Naj Pathan

## GitHub Repository

https://github.com/NajPathan-Devops/Terraform_Naj

---

## 1. Project Overview

This project demonstrates Infrastructure as Code (IaC) and AWS DevOps deployment using Terraform.

The assignment is divided into three parts:

1. **Part 1 – Flask and Express applications on a single EC2 instance**
2. **Part 2 – Flask and Express applications on separate EC2 instances with VPC networking**
3. **Part 3 – Dockerized applications deployed using Amazon ECR, ECS Fargate, and Application Load Balancer**

All infrastructure was created using Terraform and tested on AWS.

After validation, the AWS resources created for the assignment were destroyed to avoid unnecessary ongoing costs.

---

# 2. Technologies Used

| Technology | Purpose |
|---|---|
| Terraform | Infrastructure as Code |
| AWS EC2 | Virtual machine deployment |
| AWS VPC | Network infrastructure |
| AWS Security Groups | Network access control |
| AWS Internet Gateway | Internet connectivity |
| Amazon ECR | Docker image storage |
| Amazon ECS | Container orchestration |
| AWS Fargate | Serverless container execution |
| Application Load Balancer | Application routing |
| Docker | Application containerization |
| Python / Flask | Backend application |
| Node.js / Express | Frontend application |
| Amazon S3 | Terraform remote state |
| Git / GitHub | Source code management |

---

# 3. Environment

- **AWS Region:** `ap-south-1`
- **Terraform Version:** `1.16.4`
- **AWS CLI:** `2.36.49`
- **Docker:** `29.1.3`
- **Operating Environment:** Ubuntu on WSL2

---

# 4. Project Structure

```text
Terraform_Naj/
│
├── Part1_Single_EC2/
│   ├── backend.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── user_data.sh
│   ├── variables.tf
│   └── .terraform.lock.hcl
│
├── Part2_Separate_EC2/
│   ├── backend.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── user_data_flask.sh
│   ├── user_data_express.sh
│   ├── variables.tf
│   └── .terraform.lock.hcl
│
├── Part3_ECS_Docker/
│   ├── backend.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── variables.tf
│   │
│   ├── flask-app/
│   │   ├── Dockerfile
│   │   ├── app.py
│   │   └── requirements.txt
│   │
│   └── express-app/
│       ├── Dockerfile
│       ├── app.js
│       └── package.json
│
├── screenshots/
├── .gitignore
└── README.md
````

---

# 5. Part 1 – Flask and Express on a Single EC2

## Objective

Deploy a Flask backend and an Express frontend on a single AWS EC2 instance using Terraform.

## Architecture

```text
Internet
   |
   v
EC2 Instance
   |
   +---- Flask Application :5000
   |
   +---- Express Application :3000
```

## Infrastructure Created

* One Ubuntu EC2 instance
* Instance type: `t3.micro`
* Security Group
* SSH access on port `22`
* Flask access on port `5000`
* Express access on port `3000`
* Public IP address
* User-data configuration
* Flask systemd service
* Express systemd service

## Application Configuration

The Terraform user-data script automatically installs and configures:

* Python
* Flask
* Node.js
* npm
* Express
* Required application services

Both applications are configured to start automatically.

## Validation

The applications were tested using:

```bash
curl http://<PUBLIC_IP>:5000
curl http://<PUBLIC_IP>:5000/health

curl http://<PUBLIC_IP>:3000
curl http://<PUBLIC_IP>:3000/health
```

The Flask application returned a running response and a healthy health-check response.

The Express application also returned a running response and a healthy health-check response.

## Result

Part 1 was successfully deployed and tested using Terraform.

After validation, the EC2 instance and associated security group were destroyed using:

```bash
terraform destroy -auto-approve
```

---

# 6. Part 2 – Separate EC2 Instances and VPC Networking

## Objective

Deploy the Flask and Express applications on separate EC2 instances and configure communication between them using AWS VPC networking and security groups.

## Network Architecture

```text
                    Internet
                       |
                Internet Gateway
                       |
                  Custom VPC
                10.20.0.0/16
                       |
          +------------+------------+
          |                         |
          v                         v
   Flask Subnet               Express Subnet
   10.20.1.0/24               10.20.2.0/24
          |                         |
          v                         v
    Flask EC2                  Express EC2
       :5000                      :3000
          ^                         |
          |_________________________|
             Private communication
```

## VPC Configuration

* VPC CIDR: `10.20.0.0/16`
* Flask subnet: `10.20.1.0/24`
* Express subnet: `10.20.2.0/24`
* Two Availability Zones
* Internet Gateway
* Public route table
* Subnet associations

## EC2 Configuration

### Flask EC2

* Private IP: `10.20.1.9`
* Public IP: `35.154.48.64`
* Application port: `5000`

### Express EC2

* Private IP: `10.20.2.210`
* Public IP: `13.201.225.132`
* Application port: `3000`

## Security Groups

Separate security groups were configured for the applications.

The Flask security group allows communication on port `5000` from the Express security group.

This allows the Express EC2 instance to communicate with the Flask EC2 instance.

## Validation

The following tests were performed:

```bash
curl http://<FLASK_PUBLIC_IP>:5000
curl http://<FLASK_PUBLIC_IP>:5000/health

curl http://<EXPRESS_PUBLIC_IP>:3000
curl http://<EXPRESS_PUBLIC_IP>:3000/health

curl http://<EXPRESS_PUBLIC_IP>:3000/flask-health
```

The Express-to-Flask test successfully confirmed communication between the two EC2 instances.

Example result:

```text
Express EC2 successfully reached Flask EC2
```

## Result

Part 2 was successfully deployed, tested, and validated.

After testing, all Part 2 resources were destroyed using:

```bash
terraform destroy -auto-approve
```

---

# 7. Part 3 – Docker, ECR, ECS Fargate and ALB

## Objective

Containerize the Flask and Express applications and deploy them using:

* Docker
* Amazon ECR
* Amazon ECS
* AWS Fargate
* Application Load Balancer
* Terraform

## Architecture

```text
                         Internet
                            |
                            v
                Application Load Balancer
                            |
             +--------------+--------------+
             |                             |
             | /                           | /api/*
             v                             v
       Express Target                Flask Target
             |                             |
             v                             v
      ECS Fargate Task              ECS Fargate Task
          :3000                         :5000
             |                             |
             v                             v
       Amazon ECR                   Amazon ECR
    Express Docker Image          Flask Docker Image
```

## VPC

* VPC CIDR: `10.30.0.0/16`
* Two public subnets
* Internet Gateway
* Public route table
* Application Load Balancer

## Amazon ECR

Two ECR repositories were created:

```text
terraform-naj-flask
terraform-naj-express
```

The Docker images were stored in ECR using the `latest` tag.

## Dockerized Flask Application

The Flask application is packaged using:

```text
flask-app/
├── Dockerfile
├── app.py
└── requirements.txt
```

The container listens on:

```text
Port 5000
```

## Dockerized Express Application

The Express application is packaged using:

```text
express-app/
├── Dockerfile
├── app.js
└── package.json
```

The container listens on:

```text
Port 3000
```

## ECS Fargate

An ECS cluster was created for the deployment.

Separate ECS services were created for:

* Flask
* Express

Each service runs one Fargate task.

The ECS security group allows application traffic from the Application Load Balancer security group.

## Application Load Balancer

The ALB provides public access to the applications.

Routing configuration:

```text
/        → Express ECS Service

/api     → Flask ECS Service

/api/*   → Flask ECS Service
```

## Health Checks

The target groups use application health-check endpoints:

```text
Flask:
 /health

Express:
 /health
```

Both target groups successfully reported healthy targets.

## Validation

The following endpoints were tested:

```bash
curl http://<ALB_DNS>/
curl http://<ALB_DNS>/health

curl http://<ALB_DNS>/api/
curl http://<ALB_DNS>/api/health
```

The tests confirmed:

* Express application was running
* Express health check was healthy
* Flask application was running
* Flask health check was healthy
* ALB routing was working
* ECS target groups were healthy

## ECS Service Validation

The ECS services reached the following state:

```text
Desired Count: 1
Running Count: 1
Pending Count: 0
```

## Terraform Result

Terraform successfully created the complete Part 3 infrastructure.

The deployment plan contained:

```text
21 resources to add
```

The deployment completed successfully.

After validation, the complete Part 3 infrastructure was destroyed to prevent unnecessary AWS charges.

---

# 8. Terraform Remote State

Terraform remote state was configured using Amazon S3.

## S3 Bucket

```text
terraform-naj-tfstate-493628259216
```

## State Files

```text
terraform-naj/part1/terraform.tfstate
terraform-naj/part2/terraform.tfstate
terraform-naj/part3/terraform.tfstate
```

The Terraform state files are intentionally excluded from GitHub.

The `.terraform` directories and state files are also excluded using `.gitignore`.

---

# 9. Terraform Workflow

The following workflow was used for each assignment part.

## Initialize

```bash
terraform init
```

## Format

```bash
terraform fmt
```

## Validate

```bash
terraform validate
```

## Plan

```bash
terraform plan
```

## Apply

```bash
terraform apply -auto-approve
```

## Test

Application endpoints and AWS resources were tested after deployment.

## Destroy

```bash
terraform destroy -auto-approve
```

---

# 10. Verification and Testing

The deployments were verified at multiple levels.

### Infrastructure Verification

* Terraform plan
* Terraform apply
* Terraform outputs
* AWS resource status

### Application Verification

* Flask application endpoint
* Express application endpoint
* Flask health endpoint
* Express health endpoint

### Networking Verification

* EC2-to-EC2 communication
* Security group rules
* Private IP communication

### Container Verification

* Docker images
* Amazon ECR repositories
* ECS task status
* ECS service status

### Load Balancer Verification

* ALB routing
* Flask target health
* Express target health
* `/api/*` routing

---

# 11. AWS Resource Cleanup

After completing the testing for all three parts, the deployed resources were destroyed.

Final cleanup checks confirmed that the assignment deployments had no remaining:

* EC2 instances
* ECS clusters
* Load balancers
* ECR repositories
* NAT gateways
* Elastic IP addresses

The S3 Terraform state bucket was retained for remote-state storage.

---

# 12. Security Considerations

Sensitive AWS credentials and private keys were not included in the repository.

The following are excluded from Git:

```text
.terraform/
*.tfstate
*.tfstate.*
*.pem
*.key
```

Terraform provider lock files are included to help maintain consistent provider versions.

---

# 13. Screenshots and Evidence

The project documentation includes screenshots showing:

1. Terraform initialization and validation
2. Terraform plan
3. Terraform apply
4. Flask and Express application testing
5. Part 2 VPC and EC2 deployment
6. Express-to-Flask communication
7. Part 3 ECS and ECR deployment
8. Application Load Balancer routing
9. Health-check results
10. AWS resource cleanup

The screenshots provide evidence of the Terraform deployment and application validation performed during the assignment.

---

# 14. Final Result

All three Terraform assignment parts were successfully implemented and tested:

| Part   | Implementation                   | Status    |
| ------ | -------------------------------- | --------- |
| Part 1 | Flask + Express on single EC2    | Completed |
| Part 2 | Separate EC2 + VPC networking    | Completed |
| Part 3 | Docker + ECR + ECS Fargate + ALB | Completed |

The complete source code is available on GitHub.

## GitHub Repository

[https://github.com/NajPathan-Devops/Terraform_Naj](https://github.com/NajPathan-Devops/Terraform_Naj)

---

## Author

**Naj Pathan**


