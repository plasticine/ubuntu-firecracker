#! /bin/bash
set -ex

dpkg -i /mnt/root/linux*.deb

echo 'ubuntu-bionic' > /etc/hostname

passwd -d root

mkdir /etc/systemd/system/serial-getty@ttyS0.service.d/
cat <<EOF > /etc/systemd/system/serial-getty@ttyS0.service.d/autologin.conf
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin root -o '-p -- \\u' --keep-baud 115200,38400,9600 %I $TERM
EOF

cat <<EOF > /etc/netplan/99_config.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: true
EOF
netplan generate

echo "UseDNS no" >> /etc/ssh/sshd_config

sh -c 'echo deb https://apt.buildkite.com/buildkite-agent stable main > /etc/apt/sources.list.d/buildkite-agent.list'
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 32A37959C2FA5C3C99EFBC32A79206696452D198

apt-get update
apt-get install -y --no-install-recommends buildkite-agent
systemctl enable buildkite-agent
systemctl start buildkite-agent
