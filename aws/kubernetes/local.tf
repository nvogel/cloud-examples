locals {
  ssh_config = <<SSHCONFIG
Host bastion
    HostName ${aws_instance.bastion.public_ip}
    User ec2-user
    IdentitiesOnly yes
    IdentityFile ${module.ssh_key_pair.private_key_filename}


Host admin
    HostName admin.internal.k8s
    User ec2-user
    IdentitiesOnly yes
    IdentityFile ${module.ssh_key_pair.private_key_filename}
    ProxyJump bastion
SSHCONFIG
}

resource "local_file" "ssh_config" {
  depends_on = ["module.ssh_key_pair"]
  content    = "${local.ssh_config}"
  filename   = "var/ssh_config"
}
