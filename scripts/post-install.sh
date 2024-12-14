#!/bin/bash

echo "Updating the system..."
sudo dnf config-manager --set-enabled crb
sudo dnf -y -q install \
  https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm \
  https://dl.fedoraproject.org/pub/epel/epel-next-release-latest-9.noarch.rpm &> /dev/null

sudo dnf -y -q update &> /dev/null
sudo dnf -y -q upgrade --security &> /dev/null

echo "Installing packages..."
sudo dnf -y -q install dnf-plugins-core open-vm-tools htop mlocate net-tools unzip wget \
    chrony dnf-automatic ca-certificates \
    bash-completion wget curl git bpftool \
    perf strace tcpdump sysstat lsof mtr \
    nmap-ncat iperf3 htop &> /dev/null

# Configure automatic security updates
sudo systemctl enable --now dnf-automatic-notifyonly.timer

# Ensure NTP
sudo chronyc add server pt.pool.ntp.org &> /dev/null
sudo systemctl enable --now chronyd.service

# Modify SSH configuration
sudo sed -i 's/#MaxAuthTries 6/MaxAuthTries 3/' /etc/ssh/sshd_config
sudo sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords no/' /etc/ssh/sshd_config

sudo systemctl restart sshd
sudo systemctl enable --now sshd

# Add additional security hardening
sudo chmod 600 /etc/shadow
sudo chmod 600 /etc/gshadow

# Kernel and system optimization
echo "# Kernel optimization"
{
  echo "vm.swappiness=10"
  echo "fs.file-max=2097152"
} | sudo tee -a /etc/sysctl.conf > /dev/null 2>&1

sudo sysctl -p > /dev/null 2>&1

# Limit system logs
sudo sed -i 's/#SystemMaxUse=/SystemMaxUse=1G/' /etc/systemd/journald.conf


echo "Cleaning up system..."
sudo dnf -y -q clean all &> /dev/null
sudo rm -f /root/anaconda-ks.cfg /root/original-ks.cfg &> /dev/null

if [ -f /etc/udev/rules.d/70-persistent-net.rules ]; then
    sudo rm -f /etc/udev/rules.d/70-persistent-net.rules &> /dev/null
fi

sudo rm -f /etc/sysconfig/network-scripts/*
sudo rm -rf /tmp/*
sudo rm -rf /var/tmp/*
sudo rm -rf /var/cache/dnf/*
sudo truncate -s 0 /etc/machine-id
sudo rm -f /etc/ssh/ssh_host_*

# Audit logs
if [ -f /var/log/audit/audit.log ]; then
    sudo cat /dev/null | sudo tee /var/log/audit/audit.log
fi
if [ -f /var/log/wtmp ]; then
    sudo cat /dev/null | sudo tee /var/log/wtmp
fi
if [ -f /var/log/lastlog ]; then
    sudo cat /dev/null | sudo tee /var/log/lastlog
fi
sudo rm -f /var/log/*.log

history -cw
echo > ~/.bash_history
sudo rm -fr /root/.bash_history

# Finished
echo 'Configuration complete'
