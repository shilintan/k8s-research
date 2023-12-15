[toc]

# 要求

检查硬件虚拟化支持

```
cat /sys/module/kvm_intel/parameters/nested
```

内核要求:

​	4.8+

​	加载或内置vhost_vsock模块, CONFIG_VHOST_VSOCK=y

```
modprobe -i vhost_vsock
```

只能运行在物理机或者支持嵌套虚拟化

# vmware上的兼容操作

修改虚拟机设置, `处理器`, 勾选 `虚拟化 Intel VT-x/EPT 或 AMD-V/RVI(V)`



或者 修改虚拟机的配置文件(.vmx), 添加行

```
vhv.enable = "TRUE"
```



## 删除hyper-v功能

WIN+R打开`运行`, 输入 appwiz.cpl

单击“打开或关闭Windows功能”，取消勾选Hyper-V，确定禁用Hyper-V服务。



## 禁用HV主机服务

按下WIN+R组合键打开“运行”，然后输入services.msc回车。

禁用"HV主机服务"



## 关闭hypervisorlaunchtype

权限打开Windows PowerShell

运行命令:

```
bcdedit /set hypervisorlaunchtype off
```



重启电脑



在vmware虚拟机中, 停止`vmware-tools`服务并卸载 VMWare Linux 内核模块

```
lsmod | grep vsock

echo -e "blacklist vmw_vsock_virtio_transport_common\n" | tee -a /etc/modprobe.d/blacklist-shilintan.conf
echo -e "blacklist vsock_loopback\n" | tee -a /etc/modprobe.d/blacklist-shilintan.conf
echo -e "blacklist vmw_vsock_vmci_transport\n" | tee -a /etc/modprobe.d/blacklist-shilintan.conf
cat /etc/modprobe.d/blacklist-shilintan.conf
modprobe -i vhost_vsock
```





# k8s集成kata-containers

安装kata-containers



containerd集成kata-containers

https://github.com/kata-containers/kata-containers/blob/main/docs/install/README.md

k8s使用kata-containers

https://github.com/kata-containers/kata-containers/blob/main/docs/how-to/containerd-kata.md







# 二进制安装kata-containers

## 安装

```
上传或者下载kata-static-3.2.0-amd64.tar.xz
```



```
tar -xvf ~/kata-static-3.2.0-amd64.tar.xz -C /
rm -rf   ~/kata-static-3.2.0-amd64.tar.xz
chmod +x /opt/kata/bin/containerd-shim-kata-v2   /opt/kata/bin/kata-collect-data.sh  /opt/kata/bin/kata-runtime /opt/kata/bin/kata-monitor
ln -sf  /opt/kata/bin/containerd-shim-kata-v2    /usr/bin/containerd-shim-kata-v2
ln -sf  /opt/kata/bin/kata-collect-data.sh       /usr/bin/kata-collect-data.sh
ln -sf  /opt/kata/bin/kata-runtime               /usr/bin/kata-runtime
ln -sf  /opt/kata/bin/kata-monitor               /usr/bin/kata-monitor
```



```
/etc/kata-containers/configuration.toml
/opt/kata/share/defaults/kata-containers/configuration.toml
```



## 检查硬件是否满足要求

​	https://github.com/kata-containers/kata-containers?tab=readme-ov-file#hardware-requirements

```
kata-runtime check
```



## 清理

```
rm -rf /usr/bin/containerd-shim-kata-v2 /usr/bin/kata-collect-data.sh /usr/bin/kata-runtime
```

# containerd层集成

参考文档: https://github.com/kata-containers/kata-containers/blob/main/docs/install/container-manager/containerd/containerd-install.md

## containerd

`/etc/containerd/config.toml`

```
[plugins]
  [plugins."io.containerd.grpc.v1.cri"]
    [plugins."io.containerd.grpc.v1.cri".containerd]
      default_runtime_name = "kata"
      [plugins."io.containerd.grpc.v1.cri".containerd.runtimes]
        [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.kata]
          runtime_type = "io.containerd.kata.v2"
```



```
systemctl restart containerd
```



```
image="docker.io/library/busybox:latest"
ctr image pull "$image"
ctr run --runtime "io.containerd.kata.v2" --rm -t "$image" test-kata uname -r
```



```
journalctl -xefu containerd
```



# 测试

核心测试中间件能否运行

核心测试mysql能否运行



# 问题

部分容器无法使用kata

阿里云ecs无法使用kata

那么虚拟机中的内核参数如何设置
