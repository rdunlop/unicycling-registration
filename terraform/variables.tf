variable "environment" {
  type        = string
  description = "Environment name (prod or staging)"

  validation {
    condition     = contains(["prod", "staging"], var.environment)
    error_message = "environment must be prod or staging"
  }
}

variable "domain" {
  type        = string
  description = "Primary domain for the ACM certificate and Route53 A record (e.g. registration.unicycling-software.com)"
}

variable "subject_alt_names" {
  type        = list(string)
  default     = []
  description = "Additional SANs for the ACM certificate."
}

variable "zone_id" {
  type        = string
  description = "Route53 hosted zone ID for unicycling-software.com"
}

variable "ec2_instance_id" {
  type        = string
  description = "ID of the existing EC2 instance to register in the ALB target group"
}

variable "ec2_security_group_id" {
  type        = string
  description = "ID of the existing EC2 security group; an ingress rule will be added allowing port 80 from the ALB"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the ALB will be created"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs (minimum 2, in different AZs) for the ALB"
}

variable "wildcard_domain" {
  type        = string
  default     = null
  description = "What is the wildcard domain (*.regtest.unicycling-software.com) pointing to the ALB. Enable to route all tenant subdomains through the ALB."
}

variable "iam_user_name" {
  type        = string
  description = "Name of the existing IAM user the app runs as (uniregtest for staging, uniregistration for prod)"
}

variable "rails_env" {
  type        = string
  description = "RAILS_ENV value inside the container (stage for staging, production for prod)"
}

variable "elasticache_security_group_id" {
  type        = string
  description = "Security group ID attached to the ElastiCache instance; ECS tasks will be granted port 6379 ingress"
}

variable "rds_security_group_id" {
  type        = string
  description = "Security group ID attached to the shared RDS instance; ECS tasks will be granted port 5432 ingress"
}

variable "ecr_repository_url" {
  type        = string
  description = "ECR repository URL without tag — from terraform/global output ecr_repository_url"
}

variable "image_tag" {
  type        = string
  description = "Image tag to deploy (git SHA from CircleCI, or 'latest' for initial apply)"
}

variable "ecs_traffic_weight" {
  type        = number
  default     = 0
  description = "Percentage of ALB traffic sent to ECS (0–100). EC2 receives the remainder. Start at 0, raise gradually during cutover."

  validation {
    condition     = var.ecs_traffic_weight >= 0 && var.ecs_traffic_weight <= 100
    error_message = "ecs_traffic_weight must be between 0 and 100."
  }
}
