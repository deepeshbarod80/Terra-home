Basic Terraform Commands -
Terraform lets you build cloud infrastructure with code. Instead of clicking buttons in
AWS/GCP/Azure consoles, you define servers and services in configuration files.

```bash
terraform --help
# Displays general help for Terraform CLI commands.

terraform init
# Initializes the working directory containing Terraform configuration files. It downloads the necessary provider plugins.

terraform validate
# Validates the Terraform configuration files for syntax errors or issues.


// Terraform Plan
*
terraform plan
# Creates an execution plan, showing what actions Terraform will perform to make the infrastructure match the desired configuration.

terraform plan -destroy            
# Select the "destroy" planning mode, which creates a plan to destroy all objects currently managed by this Terraform configuration instead of the usual behavior.

terraform plan -refresh-only
# Select the "refresh only" planning mode, which checks whether remote objects still match the outcome of the most recent Terraform apply

terraform plan -refresh=false
# This can potentially make planning faster, but at the expense of possibly planning against a stale record of the remote system state.

terraform plan -replace=resource
# Force replacement of a particular resource instance using its resource address. If the plan would've normally produced an update or no-op action for this instance, Terraform will plan to replace it instead. You can use this option multiple times to replace more than one object.

terraform plan -target=resource
# Limit the planning operation to only the given module, resource, or resource instance and all of its dependencies. You can use this option multiple times to include more than one object. This is for exceptional use only.

terraform plan -var 'foo=bar'
# Set a value for one of the input variables in the root module of the configuration. Use this option more than once to set more than one variable.

terraform plan -var-file=filename
# Load variable values from the given file, in addition to the default files terraform.tfvars and *.auto.tfvars. Use this option more than once to include more than one

------------------------------------------------------------------------------->



// Terraform Apply
*

terraform apply
# Applies the changes required to reach the desired state of the configuration. It will prompt for approval before making changes.


Options:

terraform apply -auto-approve
# Skip interactive approval of plan before applying.

terraform apply -backup=path
# Path to backup the existing state file before modifying. Defaults to the "-state-out" path with ".backup" extension. Set to "-" to disable backup.

terraform apply -destroy 
# Destroy Terraform-managed infrastructure. The command "terraform destroy" is a convenience alias for this option.

terraform apply -lock=false
# Don't hold a state lock during the operation. This is dangerous if others might concurrently run commands against the same workspace.

terraform apply -lock-timeout=0s
# Duration to retry a state lock.

terraform apply -no-color
# If specified, output won't contain any color.

terraform apply -input=true
# Ask for input for variables if not directly set.

terraform apply -parallelism=n
# Limit the number of parallel resource operations. Defaults to 10.

terraform apply -state=path
# Path to read and save state (unless state-out is specified). Defaults to "terraform.tfstate".

terraform apply -state-out=path
# Path to write state to that is different than "-state". This can be used to preserve the old state.

terraform apply -var 'foo=bar'
# Set a value for one of the input variables in the root module of the configuration. Use this option more than once to set more than one variable.

terraform apply -var-file=filename
# Load variable values from the given file, in addition to the default files terraform.tfvars and *.auto.tfvars. Use this option more than once to include more than one variables file.






terraform show
# Displays the Terraform state or a plan in a human-readable format.


terraform output
# Displays the output values defined in the Terraform configuration after an apply.

terraform destroy
# Destroys the infrastructure defined in the Terraform configuration. It prompts for confirmation before destroying resources.

terraform refresh
# Updates the state file with the real infrastructure's current state without applying changes.

terraform replace
# Marks a resource for recreation on the next apply. Useful for forcing a resource to be recreated even if it hasn't been changed.

terraform untaint
# Removes the "tainted" status from a resource.




# Terraform Import Commands
*
terraform import
# Imports existing infrastructure into Terraform management.

terraform import <resource_type>.<resource_name> <resource_id>

// Example:
terraform import aws_instance.my_instance i-0123456789abcdef0
resource_type = aws_instance
resource_name = my_instance
resource_id = i-0123456789abcdef0

terraform import -replace 
# Force replacement of a particular resource instance

terraform graph
# Generates a graphical representation of Terraform's resources and their relationships.

terraform providers
# Lists the providers available for the current Terraform configuration.

terraform backend
# Configures the backend for storing Terraform state remotely (e.g., in `S3`, `Azure Blob Storage`, etc.).




# Terraform State Commands
*
terraform state
# Manages Terraform state files, such as moving resources between modules or manually

terraform state list
# Lists all resources tracked in the Terraform state file.

terraform state mv
# Moves an item in the state from one location to another.

terraform state rm
# Removes an item from the Terraform state file.


# Terraform Workspace Commands
*
terraform workspace
# Manages Terraform workspaces, which allow for creating separate environments within a single configuration.

terraform workspace new
# Creates a new workspace.


terraform modules
# Manages and updates Terraform modules, which are reusable configurations.

terraform init -get-plugins=true
# Ensures that required plugins are fetched and available for modules.

TF_LOG
# Sets the logging level for Terraform debug output (e.g., 'TRACE', 'DEBUG', 'INFO', 'WARN', 'ERROR').

TF_LOG_PATH
# Directs Terraform logs to a specified file.

TF_LOG_LEVEL
# Sets the 

terraform login
# Logs into Terraform Cloud or Terraform Enterprise for managing remote backends and workspaces.



console       Try Terraform expressions at an interactive command prompt
  terraform fmt
  # Reformat your configuration in the standard style
  
  terraform force-unlock  
  # Release a stuck lock on the current workspace
  
  terraform get           
  # Install or upgrade remote Terraform modules
  graph         Generate a Graphviz graph of the steps in an operation
  import        Associate existing infrastructure with a Terraform resource
  login         Obtain and save credentials for a remote host
  logout        Remove locally-stored credentials for a remote host
  metadata      Metadata related commands
  modules       Show all declared modules in a working directory
  output        Show output values from your root module
  providers     Show the providers required for this configuration
  refresh       Update the state to match remote systems
  show          Show the current state or a saved plan
  state         Advanced state management
  taint         Mark a resource instance as not fully functional
  test          Execute integration tests for Terraform modules
  untaint       Remove the 'tainted' state from a resource instance
  version       Show the current Terraform version
  workspace     Workspace management



```