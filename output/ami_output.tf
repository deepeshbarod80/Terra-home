
# AMI Output Example

output "ami_id" {
  value = "${data.aws_ami.ubuntu.id}"
}

output "ami_name" {
  value = "${data.aws_ami.ubuntu.name}"
}

output "ami_description" {
  value = "${data.aws_ami.ubuntu.description}"
}

output "ami_state" {
  value = "${data.aws_ami.ubuntu.state}"
}

output "ami_public" {
  value = "${data.aws_ami.ubuntu.public}"
}

output "ami_root_device_type" {
  value = "${data.aws_ami.ubuntu.root_device_type}"
}

output "ami_virtualization_type" {
  value = "${data.aws_ami.ubuntu.virtualization_type}"
}

output "ami_architecture" {
  value = "${data.aws_ami.ubuntu.architecture}"
}

output "ami_hypervisor" {
  value = "${data.aws_ami.ubuntu.hypervisor}"
}

output "ami_root_device_name" {
  value = "${data.aws_ami.ubuntu.root_device_name}"
}