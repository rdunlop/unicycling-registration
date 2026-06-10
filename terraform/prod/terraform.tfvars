environment         = "prod"
iam_user_name       = "uniregistration"
domain              = "reg.unicycling-software.com"
subject_alt_names   = ["*.reg.unicycling-software.com"]
wildcard_domain     = "*.reg.unicycling-software.com"

# Run the CLI commands in the README Step 2 section to get these values.
ec2_instance_id       = "i-0329bb3d406c09fee"
ec2_security_group_id = "sg-e4640f81"
vpc_id                = "vpc-e113c084"
subnet_ids            = ["subnet-39963f5c", "subnet-16e82761", "subnet-1f6f8346", "subnet-ba154f92"]
zone_id               = "Z1NYSHL8JOE6MN"
