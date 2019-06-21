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

yum --disableplugin=fastestmirror update -y

echo "------------------------------------------------------------------------"
echo "                          End of update at $(date)"
echo "------------------------------------------------------------------------"

# Install base package
yum install vim wget nc tcpdump htop iptables tmux bind-utils git -y

echo 'Install salt-master'

mkdir -p /etc/salt/master.d

cat > /etc/salt/master.d/99-master.conf <<EOF
auto_accept: True
worker_threads: 4
log_file: file:///dev/log
log_level_logfile: info
log_fmt_logfile: 'salt-master[%(process)d] %(name)s: %(message)s'
log_level: info
gather_job_timeout: 15
timeout: 30
EOF

curl -o bootstrap-salt.sh -L https://bootstrap.saltstack.com
sh bootstrap-salt.sh -M -A admin.internal.k8s -i ${name} git v2019.2.0

cat > /etc/salt/grains <<EOF
role: ${role}
EOF


echo "------------------------------------------------------------------------"
echo "                          End at $(date)"
echo "------------------------------------------------------------------------"
