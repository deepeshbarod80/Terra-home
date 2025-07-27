# Printing the ec2 instance details

output "instance_id" {
  value = aws_instance.web.*.id
}

output "instance_type" {
  value = aws_instance.web.*.instance_type
}

output "instance_ami" {
  value = aws_instance.web.*.ami
}

output "instance_public_ip" {
  value = aws_instance.web.*.public_ip
}

output "instance_private_ip" {
  value = aws_instance.web.*.private_ip
}

output "instance_public_dns" {
  value = aws_instance.web.*.public_dns
}

output "instance_private_dns" {
  value = aws_instance.web.*.private_dns
}

output "instance_state" {
  value = aws_instance.web.*.state
}

output "instance_tags" {
  value = aws_instance.web.*.tags
}

output "instance_vpc_id" {
  value = aws_instance.web.*.vpc_id
}

output "instance_subnet_id" {
  value = aws_instance.web.*.subnet_id
}

output "instance_security_groups" {
  value = aws_instance.web.*.security_groups
}

output "instance_key_name" {
  value = aws_instance.web.*.key_name
}

output "instance_iam_instance_profile" {
  value = aws_instance.web.*.iam_instance_profile
}

output "instance_monitoring" {
  value = aws_instance.web.*.monitoring
}

output "instance_ebs_optimized" {
  value = aws_instance.web.*.ebs_optimized
}



# Root Block Device

output "instance_root_block_device" {
  value = aws_instance.web.*.root_block_device
}

output "instance_root_device_name" {
  value = aws_instance.web.*.root_device_name
}


# Root Volume

output "instance_root_volume_id" {
  value = aws_instance.web.*.root_volume_id
}

output "instance_root_volume_type" {
  value = aws_instance.web.*.root_volume_type
}

output "instance_root_volume_size" {
  value = aws_instance.web.*.root_volume_size
}

output "instance_root_volume_iops" {
  value = aws_instance.web.*.root_volume_iops
}

output "instance_root_volume_encrypted" {
  value = aws_instance.web.*.root_volume_encrypted
}

output "instance_root_volume_delete_on_termination" {
  value = aws_instance.web.*.root_volume_delete_on_termination
}

output "instance_root_volume_tags" {
  value = aws_instance.web.*.root_volume_tags
}

output "instance_root_volume_availability_zone" {
  value = aws_instance.web.*.root_volume_availability_zone
}

output "instance_root_volume_state" {
  value = aws_instance.web.*.root_volume_state
}

output "instance_root_volume_arn" {
  value = aws_instance.web.*.root_volume_arn
}

output "instance_root_volume_kms_key_id" {
  value = aws_instance.web.*.root_volume_kms_key_id
}

output "instance_root_volume_encryption_enabled" {
  value = aws_instance.web.*.root_volume_encryption_enabled
}

output "instance_root_volume_outpost_arn" {
  value = aws_instance.web.*.root_volume_outpost_arn
}

output "instance_root_volume_owner_id" {
  value = aws_instance.web.*.root_volume_owner_id
}

output "instance_root_volume_volume_id" {
  value = aws_instance.web.*.root_volume_volume_id
}

output "instance_root_volume_volume_type" {
  value = aws_instance.web.*.root_volume_volume_type
}

output "instance_root_volume_volume_size" {
  value = aws_instance.web.*.root_volume_volume_size
}

output "instance_root_volume_volume_iops" {
  value = aws_instance.web.*.root_volume_volume_iops
}

output "instance_root_volume_volume_encrypted" {
  value = aws_instance.web.*.root_volume_volume_encrypted
}

output "instance_root_volume_volume_delete_on_termination" {
  value = aws_instance.web.*.root_volume_volume_delete_on_termination
}

output "instance_root_volume_volume_tags" {
  value = aws_instance.web.*.root_volume_volume_tags
}

output "instance_root_volume_volume_availability_zone" {
  value = aws_instance.web.*.root_volume_volume_availability_zone
}

output "instance_root_volume_volume_state" {
  value = aws_instance.web.*.root_volume_volume_state
}

output "instance_root_volume_volume_arn" {
  value = aws_instance.web.*.root_volume_volume_arn
}

output "instance_root_volume_volume_kms_key_id" {
  value = aws_instance.web.*.root_volume_volume_kms_key_id
}

