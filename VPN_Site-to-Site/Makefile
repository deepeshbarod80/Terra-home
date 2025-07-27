.PHONY: init plan apply destroy fmt validate clean

init:
	terraform init

plan:
	terraform plan -out=tfplan

apply:
	terraform apply tfplan

destroy:
	terraform destroy -auto-approve

fmt:
	terraform fmt -recursive

validate:
	terraform validate

clean:
	rm -rf .terraform/
	rm -f tfplan
	rm -f terraform.tfstate*
	rm -f .terraform.lock.hcl