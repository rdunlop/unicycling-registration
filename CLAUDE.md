# CLAUDE.md

## Terraform

- Run Terraform only through `terraform/bin/tf <staging|prod> <command> [args]`. Do not run `terraform` directly, and do not run `terraform init` by hand in `terraform/`. The wrapper re-initializes the backend for the environment on every run, which stops a prod plan from using the staging state.
- Read the `bin/tf:` line it prints before reading a plan. It shows the environment, the backend, and the `image_tag` in use.
- Do not put `image_tag` in `terraform/*/terraform.tfvars`. The wrapper uses the image that is running in ECS. Only set `IMAGE_TAG=<sha>` for an intentional rollback.
- Normal deploys go through CI. Local `apply` is only for a break-glass fix, and the wrapper requires you to type the environment name first.
- Do not commit Terraform state or plan files.
