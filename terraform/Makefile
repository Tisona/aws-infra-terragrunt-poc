help:     ## Show this help.
		@sed -ne '/@sed/!s/## //p' $(MAKEFILE_LIST)

cache-find:  ## Find all .terragrunt-cache folders
		find . -type d -name ".terragrunt-cache"

cache-delete: ## Delete all .terragrunt-cache folders
		find . -type d -name ".terragrunt-cache" -prune -exec rm -rf {} \;

create-all: ## Deploy infrastructure
		@terragrunt run-all apply --terragrunt-working-dir="./prod"

.PHONY destroy-all: ## Destroy all resources
destroy-all: delete-ecr-images destroy-terragrunt
delete-ecr-images:
		$(info Deleting ECR images..)
		@chmod +x ./scripts/delete-ecr-images.sh && ./scripts/delete-ecr-images.sh us-east-1 poc-app 
destroy-terragrunt:
		$(info Destroying terragrunt resources..)
		@terragrunt run-all destroy --terragrunt-working-dir="./prod"

.PHONY: show-creds ## Show deployer credentials
show-creds: show-key show-secret
show-key: 
		$(info AWS_ACCESS_KEY_ID:)
		@terragrunt output iam_access_key_id --terragrunt-working-dir="./prod/_global/prod/iam-user/deployer/"
show-secret:
		$(info AWS_SECRET_ACCESS_KEY:)
		@terragrunt output iam_access_key_secret --terragrunt-working-dir="./prod/_global/prod/iam-user/deployer/"

show-ip: ## Show global accelerator ip addresses
		@terragrunt output ip_sets --terragrunt-working-dir="./prod/_global/prod/global-accelerator/" 
