tar xvf containerd-1.6.23-linux-amd64.tar.gz -C /usr
ctr -v
mkdir -p /etc/containerd && containerd config default | tee /etc/containerd/config.toml
mkdir -p /etc/containerd/certs.d
tee /lib/systemd/system/containerd.service <<-'EOF'
[Unit]
Description=containerd container runtime
Documentation=https://containerd.io
After=network.target local-fs.target

[Service]
ExecStartPre=-/sbin/modprobe overlay
ExecStart=/usr/bin/containerd

Type=notify
Delegate=yes
KillMode=process
Restart=always
RestartSec=5
LimitNPROC=infinity
LimitCORE=infinity
LimitNOFILE=1048576
TasksMax=infinity
OOMScoreAdjust=-999

[Install]
WantedBy=multi-user.target
EOF

tee /etc/modules-load.d/containerd.conf <<-'EOF'
overlay
br_netfilter
EOF
modprobe overlay
modprobe br_netfilter

tee /etc/sysctl.d/99-kubernetes-cri.conf <<-'EOF'
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sysctl --system
systemctl daemon-reload
systemctl restart containerd
systemctl enable containerd
systemctl status containerd