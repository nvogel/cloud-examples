#!/bin/bash

echo "------------------------------------------------------------------------"
echo "                          Start at $(date)"
echo "------------------------------------------------------------------------"

# Set hostname
hostnamectl set-hostname ${name}

# disable Selinux dynamicaly and permanentaly
setenforce Permissive
echo SELINUX=disabled > /etc/sysconfig/selinux

# Wait for network
for i in 1 2 3 4 5; do ping -w 180 -c 1 8.8.8.8 && break || sleep 15; done

echo "------------------------------------------------------------------------"
echo "                          Start of update at $(date)"
echo "------------------------------------------------------------------------"

yum update -y

echo "------------------------------------------------------------------------"
echo "                          End of update at $(date)"
echo "------------------------------------------------------------------------"

# Install base package
yum install vim wget nc tcpdump htop iptables bind-utils -y

echo 'Install salt-minion'

mkdir -p /etc/salt/minion.d

cat > /etc/salt/minion.d/minion.conf <<EOF
log_file: file:///dev/log
log_level_logfile: warning
log_fmt_logfile: 'salt-minion[%(process)d] %(name)s: %(message)s'

log_level: warning

recon_default: 1000
recon_max: 10000
recon_randomize: True

random_reauth_delay: 60
acceptance_wait_time: 10
acceptance_wait_time_max: 360

master_tries: 10
auth_tries: 10
auth_timeout: 20

return_retry_timer: 20
return_retry_timer_max: 60
EOF

curl -o bootstrap-salt.sh -L https://bootstrap.saltstack.com
sh bootstrap-salt.sh -A admin.internal.k8s -i ${name} git v2019.2.0

cat > /etc/salt/grains <<EOF
role: ${role}
EOF

echo "------------------------------------------------------------------------"
echo "                          End at $(date)"
echo "------------------------------------------------------------------------"
