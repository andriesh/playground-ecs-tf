## 1. Private ECR repo
## 2. ALB 
## 3. Build image
## 4. Push image to ECR

terraform {
  required_providers {
    docker = {
        source = "kreuzwerker/docker"
        version = "3.0.2"
        configuration_aliases = [ docker ]
    }
  }
}




# docker build . -t latest -t 1.0
docker build -t randomquotes:latest -t randomquotes:1.0 .
aws ecr get-login-password --region us-east-1 --profile endava | docker login --username AWS --password-stdin 315727832121.dkr.ecr.us-east-1.amazonaws.com

docker tag randomquotes:latest 315727832121.dkr.ecr.us-east-1.amazonaws.com/randomquotes:latest
docker tag randomquotes:1.0 315727832121.dkr.ecr.us-east-1.amazonaws.com/randomquotes:1.0

docker tag 1.0:latest 315727832121.dkr.ecr.us-east-1.amazonaws.com/andrei-rusnac-ecr:latest
docker push 315727832121.dkr.ecr.us-east-1.amazonaws.com/andrei-rusnac-ecr:1.0
docker push 315727832121.dkr.ecr.us-east-1.amazonaws.com/andrei-rusnac-ecr:latest



