locals {
  ssh_config = <<SSHCONFIG
Host *
   StrictHostKeyChecking no
   UserKnownHostsFile=/dev/null
   ServerAliveInterval 10
   TCPKeepAlive no
   VerifyHostKeyDNS no
   User ec2-user
   IdentitiesOnly yes
   IdentityFile ${module.ssh_key_pair.private_key_filename}

Host bastion
    HostName ${aws_instance.bastion.public_ip}

Host admin
    HostName admin.internal.k8s
    ProxyJump bastion

Host etcd-0
    HostName etcd-0.internal.k8s
    ProxyJump bastion

Host etcd-1
    HostName etcd-1.internal.k8s
    ProxyJump bastion

Host etcd-2
    HostName etcd-2.internal.k8s
    ProxyJump bastion

Host master-0
    HostName master-0.internal.k8s
    ProxyJump bastion

Host master-1
    HostName master-1.internal.k8s
    ProxyJump bastion

Host master-2
    HostName master-2.internal.k8s
    ProxyJump bastion

Host worker-0
    HostName worker-0.internal.k8s
    ProxyJump bastion

Host worker-1
    HostName worker-1.internal.k8s
    ProxyJump bastion

Host worker-2
    HostName worker-2.internal.k8s
    ProxyJump bastion
SSHCONFIG
}

resource "local_file" "ssh_config" {
  depends_on = ["module.ssh_key_pair"]
  content    = "${local.ssh_config}"
  filename   = "var/ssh_config"
}
