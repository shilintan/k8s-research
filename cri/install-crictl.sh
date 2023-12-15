tar xvf crictl-v1.28.0-linux-amd64.tar.gz -C /usr/bin
chmod +x /usr/bin/crictl
crictl --version

tee /etc/crictl.yaml <<-'EOF'
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 10
EOF