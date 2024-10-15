### This repo holds the Terraform project content

It contains multiple root modules and only one child module.
It must be run one by one according to the list bellow.
It assumes that you already have access to AWS and proper credentials are set on your machine.

#### Steps to run per folder in this strict order:

    terraform init && terraform apply

 1. **vpc** - create the VPC, subnets and SG
 2. **ecr** - create image repo
 3. **alb** - create ALB, target group and listener on port 80
 4. **ecs** - create Fargate cluster and a service that will run the image from the ECR repo

**NOTE:** all these root modules use tags child module that define global tags for all these resources.

