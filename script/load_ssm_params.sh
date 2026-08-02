#!/bin/bash
# Loads a .env file into SSM Parameter Store under /unicycling-registration/{environment}/
#
# Usage:
#   script/load_ssm_params.sh staging path/to/.env.staging
#   script/load_ssm_params.sh prod    path/to/.env.production
#
# All values are stored as SecureString (KMS-encrypted).
# Re-running is safe — existing parameters are overwritten.

set -euo pipefail

ENVIRONMENT=${1:?"Usage: $0 <staging|prod> <path/to/.env>"}
ENV_FILE=${2:?"Usage: $0 <staging|prod> <path/to/.env>"}
REGION="us-west-2"
PREFIX="/unicycling-registration/${ENVIRONMENT}"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Error: $ENV_FILE not found" >&2
  exit 1
fi

echo "Loading $ENV_FILE → SSM ${PREFIX}/"
echo ""

while IFS= read -r line || [[ -n "$line" ]]; do
  # Skip blank lines and comments
  [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue

  # Must contain an = sign
  [[ "$line" != *=* ]] && continue

  KEY="${line%%=*}"
  VALUE="${line#*=}"

  # Strip surrounding single or double quotes from value
  if [[ "$VALUE" =~ ^\'(.*)\'$ ]]; then
    VALUE="${BASH_REMATCH[1]}"
  elif [[ "$VALUE" =~ ^\"(.*)\"$ ]]; then
    VALUE="${BASH_REMATCH[1]}"
  fi

  # Skip keys with spaces or that look invalid
  [[ "$KEY" =~ [[:space:]] ]] && continue
  [[ -z "$KEY" ]] && continue

  echo "  ${PREFIX}/${KEY}"
  aws ssm put-parameter \
    --region "$REGION" \
    --name "${PREFIX}/${KEY}" \
    --value "$VALUE" \
    --type SecureString \
    --overwrite \
    --no-cli-pager \
    > /dev/null

done < "$ENV_FILE"

echo ""
echo "Done. Verify with:"
echo "  aws ssm get-parameters-by-path --path ${PREFIX}/ --region ${REGION} --query 'Parameters[*].Name'"
