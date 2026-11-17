environment         = "staging"
iam_user_name       = "uniregtest"
rails_env           = "stage"
ecs_traffic_weight  = 100

ecr_repository_url = "197931692346.dkr.ecr.us-west-2.amazonaws.com/unicycling-registration"
elasticache_security_group_id = "sg-e4640f81"
rds_security_group_id = "sg-d51560b0"

domain              = "regtest.unicycling-software.com"
registration_domain = "registrationtest.unicycling-software.com"
subject_alt_names   = ["*.regtest.unicycling-software.com"]
wildcard_domain     = "*.regtest.unicycling-software.com"

# Run the CLI commands in the README Step 2 section to get these values.
vpc_id                = "vpc-e113c084"
subnet_ids            = ["subnet-16e82761", "subnet-ba154f92"]
zone_id               = "Z1NYSHL8JOE6MN"
