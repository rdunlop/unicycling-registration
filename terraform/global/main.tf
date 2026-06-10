terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {}
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_ecr_repository" "app" {
  name                 = "unicycling-registration"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 20 images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 20
      }
      action = { type = "expire" }
    }]
  })
}

output "ecr_repository_url" {
  value = aws_ecr_repository.app.repository_url
}

# ---- CI IAM user (CircleCI) ----

resource "aws_iam_user" "circleci" {
  name = "circleci-unicycling-registration"
}

resource "aws_iam_access_key" "circleci" {
  user = aws_iam_user.circleci.name
}

resource "aws_iam_user_policy" "circleci_ecr" {
  name = "ecr-push"
  user = aws_iam_user.circleci.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ECRAuth"
        Effect   = "Allow"
        Action   = "ecr:GetAuthorizationToken"
        Resource = "*"
      },
      {
        Sid    = "ECRPush"
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage",
        ]
        Resource = aws_ecr_repository.app.arn
      },
    ]
  })
}

output "circleci_access_key_id" {
  value = aws_iam_access_key.circleci.id
}

output "circleci_secret_access_key" {
  value     = aws_iam_access_key.circleci.secret
  sensitive = true
}
