#! /bin/bash
set -ex

dpkg -i /mnt/root/linux*.deb

# Set hostname
echo 'buildkite' > /etc/hostname

# Configure networking
cat <<EOF > /etc/netplan/99_config.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: true
      optional: false
      addresses:
      - 172.16.0.2/24
      nameservers:
        addresses: [1.1.1.1, 1.0.0.1]
      routes:
      - to: 0.0.0.0/0
        via: 172.16.0.1
        metric: 100
EOF
netplan generate

# Install system tools
apt-get update
apt-get install -y --no-install-recommends curl net-tools

# Install buildkite agent
sh -c 'echo deb https://apt.buildkite.com/buildkite-agent stable main > /etc/apt/sources.list.d/buildkite-agent.list'
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 32A37959C2FA5C3C99EFBC32A79206696452D198
apt-get update
apt-get install -y --no-install-recommends buildkite-agent
systemctl enable buildkite-agent

# Configure MOTD
rm -rf /etc/update-motd.d/*
cat <<'EOF' > /etc/update-motd.d/00-message
#!/bin/sh

cat <<'MESSAGE'

 _           _ _     _ _    _ _
| |         (_) |   | | |  (_) |
| |__  _   _ _| | __| | | ___| |_ ___
| '_ \| | | | | |/ _` | |/ / | __/ _ \
| |_) | |_| | | | (_| |   <| | ||  __/
|_.__/ \__,_|_|_|\__,_|_|\_\_|\__\___|

--

MESSAGE

printf "Welcome to %s (%s %s %s)", $(lsb_release -s -d), $(uname -o), $(uname -r), $(uname -m)
echo ""
EOF
chmod +x /etc/update-motd.d/00-message

# Configure auto login
passwd -d root
mkdir -p /etc/systemd/system/serial-getty@ttyS0.service.d/
cat <<EOF > /etc/systemd/system/serial-getty@ttyS0.service.d/autologin.conf
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin root -o '-p -- \\u' --keep-baud 115200,38400,9600 %I $TERM
EOF

# All done, let’s get outta here!
exit 0
