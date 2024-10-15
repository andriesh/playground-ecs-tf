resource "aws_codebuild_project" "random-quotes-arusnac" {
  name          = "random-quotes"
  description   = "random-quotes_project"
  build_timeout = 5
  service_role  = aws_iam_role.image_builder_arusnac.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    type     = "S3"
    location = aws_s3_bucket.image_builder_arusnac.bucket
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    # environment_variable {
    #   name  = "SOME_KEY1"
    #   value = "SOME_VALUE1"
    # }

    # environment_variable {
    #   name  = "SOME_KEY2"
    #   value = "SOME_VALUE2"
    #   type  = "PARAMETER_STORE"
    # }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "log-group"
      stream_name = "log-stream"
    }

    s3_logs {
      status   = "ENABLED"
      location = "${aws_s3_bucket.image_builder_arusnac.id}/build-log"
    }
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/OctopusSamples/RandomQuotes.git"
    git_clone_depth = 1

    git_submodules_config {
      fetch_submodules = true
    }
  }

  source_version = "master"

  vpc_config {
    vpc_id = "vpc-d694d4ac" # Default VPC

    subnets = [
        subnet-0227c4ce3befe079e,
        subnet-047a6414a1103a78e,
    ]

    security_group_ids = [
        sg-0cafb87ec9df4b633,
    ]
  }

  tags = {
    tags = module.common_tags.tags
  }
}