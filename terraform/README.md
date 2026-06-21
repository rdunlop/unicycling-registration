# Terraform Infrastructure

Manages ALB, ACM certificates, and Route53 DNS for prod and staging.

- **Prod:** `registration.unicycling-software.com` + wildcard `*.unicycling-software.com` (all tenant subdomains)
- **Staging:** `registrationtest.unicycling-software.com`

State is stored in S3 (`unicycling-registration-terraform-state`), locked via `use_lockfile` (Terraform ≥ 1.10, no DynamoDB needed).

## Prerequisites

```bash
brew install terraform   # or brew upgrade terraform
terraform version        # must be >= 1.10
aws sts get-caller-identity  # confirm AWS credentials are active
```

---

## Step 1: Bootstrap (one-time only)

Creates the S3 bucket used to store Terraform state. Run once; never run again.

```bash
cd terraform/bootstrap
terraform init
terraform apply
cd -
```

---

## Step 2: Gather AWS resource IDs

Run these CLI commands to populate the `terraform.tfvars` files in `prod/` and `staging/`.

```bash
# Route53 hosted zone
aws route53 list-hosted-zones \
  --query "HostedZones[?contains(Name,'unicycling-software.com')].{Id:Id,Name:Name}" \
  --output table

# Prod EC2: instance ID, VPC ID, subnet, security group
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=*registration*prod*" \
  --query "Reservations[].Instances[].[InstanceId,VpcId,SubnetId,SecurityGroups[0].GroupId,PublicIpAddress]" \
  --output table

# Staging EC2
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=*registration*stage*" \
  --query "Reservations[].Instances[].[InstanceId,VpcId,SubnetId,SecurityGroups[0].GroupId,PublicIpAddress]" \
  --output table

# All subnets in the VPC — pick 2+ in different AZs for the ALB (use public subnets only)
aws ec2 describe-subnets \
  --filters "Name=vpc-id,Values=vpc-e113c084" \
  --query "Subnets[].[SubnetId,AvailabilityZone,MapPublicIpOnLaunch,Tags[?Key=='Name'].Value|[0]]" \
  --output table

# Existing Route53 A records (to confirm what will be overwritten)
aws route53 list-resource-record-sets \
  --hosted-zone-id /hostedzone/Z1NYSHL8JOE6MN \
  --query "ResourceRecordSets[?Type=='A']" --output json
```

Fill the results into `prod/terraform.tfvars` and `staging/terraform.tfvars`, replacing the `TODO` placeholders.

---

## Step 3: Apply (two-step, per environment)

No import needed — `dns.tf` uses `allow_overwrite = true` so Terraform replaces the existing direct-to-EC2 A record automatically.

The two-step approach is required because `aws_route53_record.acm_validation` uses `for_each` over the cert's domain validation options, which are only known after the cert is created.

### Staging first

```bash
cd terraform

terraform init -backend-config=staging/backend.tfvars -reconfigure

# Step 3a: create the ACM cert so its validation records become known
terraform apply -target=aws_acm_certificate.app -var-file=staging/terraform.tfvars

# Step 3b: apply everything (ALB, listeners, DNS validation records, DNS cutover)
terraform apply -var-file=staging/terraform.tfvars
```

### Prod (after staging is validated)

```bash
terraform init -backend-config=prod/backend.tfvars -reconfigure

terraform apply -target=aws_acm_certificate.app -var-file=prod/terraform.tfvars

terraform apply -var-file=prod/terraform.tfvars
```

---

## Day-to-day usage

### Apply to staging

```bash
cd terraform

terraform init -backend-config=staging/backend.tfvars -reconfigure
terraform plan  -var-file=staging/terraform.tfvars
terraform apply -var-file=staging/terraform.tfvars
```

### Apply to prod

```bash
cd terraform

terraform init -backend-config=prod/backend.tfvars -reconfigure
terraform plan  -var-file=prod/terraform.tfvars
terraform apply -var-file=prod/terraform.tfvars
```

> **Note:** `-reconfigure` is required when switching between environments because the S3 backend key changes. It does not destroy or migrate state.

---

## Verification after apply

```bash
# Check cert was issued
aws acm list-certificates --region us-west-2 --output table

# Check ALB target health (EC2 should show healthy)
aws elbv2 describe-target-health \
  --target-group-arn $(terraform output -raw target_group_arn)

# End-to-end HTTPS smoke test via ALB (before DNS cutover, test directly):
curl -I --resolve registrationtest.unicycling-software.com:443:<ALB-IP> \
  https://registrationtest.unicycling-software.com

# After DNS cutover:
curl -I https://registrationtest.unicycling-software.com
curl -I https://registration.unicycling-software.com
```

---

## Scheduled tasks (nightly cron)

`scheduled_tasks.tf` defines EventBridge rules that trigger one-off ECS Fargate tasks on a schedule (replacing the old `whenever`/cron setup on EC2).

| Task | Schedule | Command |
|------|----------|---------|
| `update_registration_period` | Daily at midnight UTC | `bundle exec rake update_registration_period` |

EventBridge launches a new ECS task using the latest active task definition; the task exits when the rake command finishes.

### Checking whether a scheduled task ran successfully

**1. Find the stopped ECS task** (EventBridge-launched tasks stop after the command finishes):

```bash
ENV=staging  # or: prod

aws ecs list-tasks \
  --cluster unicycling-registration-$ENV \
  --desired-status STOPPED \
  --region us-west-2
```

**2. Check the exit code and stop reason** (exit code `0` = success):

```bash
aws ecs describe-tasks \
  --cluster unicycling-registration-$ENV \
  --tasks <task-arn-from-above> \
  --region us-west-2 \
  --query "tasks[0].{stopCode:stopCode,stoppedReason:stoppedReason,exitCode:containers[0].exitCode,lastStatus:lastStatus}"
```

A `stopCode` of `EssentialContainerExited` with `exitCode: 0` is a clean run. Any other exit code or `TaskFailedToStart` indicates a failure.

**3. Read the container logs from CloudWatch:**

```bash
# List recent log streams (newest first; the task ID is the stream prefix)
aws logs describe-log-streams \
  --log-group-name /ecs/unicycling-registration-$ENV-web \
  --order-by LastEventTime \
  --descending \
  --limit 5 \
  --region us-west-2

# Fetch the log output for a specific stream
aws logs get-log-events \
  --log-group-name /ecs/unicycling-registration-$ENV-web \
  --log-stream-name "web/<task-id>" \
  --region us-west-2 \
  --output text --query "events[].message"
```

Logs are retained for 30 days (`retention_in_days = 30` in `ecs.tf`).

---

## After apply: set ALB_LISTENER_ARN in the app

The Rails app (`PollAcmCertificateJob`) uses `ALB_LISTENER_ARN` to attach per-tenant
ACM certificates to the HTTPS listener at runtime. Get the ARN and store it:

```bash
# Get the listener ARN from Terraform output
terraform output -raw https_listener_arn

# Set it as an SSM parameter (run once per environment after apply)
aws ssm put-parameter \
  --name "/unicycling-registration/staging/ALB_LISTENER_ARN" \
  --value "$(terraform output -raw https_listener_arn)" \
  --type "String" \
  --overwrite
```

---

## After successful cutover to ECS

Once all traffic has moved from EC2 to ECS (Phase 11 of the ECS migration plan),
update the target group to use ECS instead of the EC2 instance. At that point
`ec2_instance_id` and `ec2_security_group_id` become irrelevant and can be removed
from the Terraform config in favour of ECS-managed target group attachments.
