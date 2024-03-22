[toc]

# 上传pem文件(废弃)

```
mv /root/.ssh/shilintan-bigdata.pem /root/.ssh/id_rsa.pem
chmod 600 /root/.ssh/id_rsa.pem
```

# 导出离线文件

```
sealos_4.3.3_linux_amd64.tar.gz

kubernetes-v1.28.7.tar
helm-v3.8.2.tar
calico-v3.24.1.tar
```

### 上传离线文件到专有环境镜像仓库

暂时省略

思路: push

## sealos导出离线文件

```
sealos pull registry.cn-shanghai.aliyuncs.com/labring/kubernetes:v1.27.12
sealos pull registry.cn-shanghai.aliyuncs.com/labring/helm:v3.9.4

sealos save -o kubernetes-v1.27.12.tar  registry.cn-shanghai.aliyuncs.com/labring/kubernetes:v1.27.12
sealos save -o helm-v3.9.4.tar          registry.cn-shanghai.aliyuncs.com/labring/helm:v3.9.4
```

## ctr导出离线镜像

```
ctr -n k8s.io i ls
```

思路: ctr -n k8s.io i export --all-platform xxx.tar xxx:xxx

# 主机初始化

修改镜像仓库

```
sed -i 's#deb.debian.org#mirrors.163.com#g' /etc/apt/sources.list && sed -i 's#security.debian.org#mirrors.163.com#g' /etc/apt/sources.list && apt -y update
```

# 安装sealos

## 通过scp拷贝文件

```
# 从集群拷贝文件
scp root@172.30.0.109:/root/kubernetes-v1.27.12.tar   /root/kubernetes-v1.27.12.tar
```

```
tar -zxvf sealos_4.3.7_linux_amd64.tar.gz sealos &&  chmod +x sealos && mv sealos /usr/bin
sealos version
rm -rf sealos_4.3.7_linux_amd64.tar.gz
```



```
tar -zxvf sealos_4.3.5_linux_amd64.tar.gz sealos &&  chmod +x sealos && mv sealos /usr/bin
sealos version
rm -rf sealos_4.3.5_linux_amd64.tar.gz
```



# 安装k8S

## 磁盘挂载

```
fdisk -l
wipefs --all /dev/vdb
mkfs.ext4 /dev/vdb

mkdir -p        /data
mount 			/dev/vdb 			/data
mkdir -p 		/data/kubelet 		/data/containers 	/data/containerd     /data/etcd
mkdir -p 		/var/lib/kubelet 	/var/lib/containers /var/lib/containerd /var/lib/etcd
mount --bind 	/data/kubelet   	/var/lib/kubelet
mount --bind 	/data/containers   	/var/lib/containers
mount --bind 	/data/containerd   	/var/lib/containerd
mount --bind 	/data/etcd   	    /var/lib/etcd

df -h /var/lib/kubelet  /var/lib/containers  /var/lib/containerd    /var/lib/etcd

cat >> /etc/fstab <<EOF
/dev/vdb          /data ext4          defaults 0 0
/data/kubelet     /var/lib/kubelet    none defaults,bind 0 0
/data/containers  /var/lib/containers none defaults,bind 0 0
/data/containerd  /var/lib/containerd none defaults,bind 0 0
/data/etcd        /var/lib/etcd       none defaults,bind 0 0
EOF
systemctl daemon-reload
```

## sealos导入离线文件

```shell
sealos load -i kubernetes-v1.27.11.tar
sealos load -i helm-v3.14.1.tar
sealos images
rm -rf kubernetes-v1.27.11.tar helm-v3.14.1.tar
```



```
sealos load -i kubernetes-v1.25.0.tar
sealos images
```



## ctr导入离线文件

暂时省略

思路: ctr i import/load

```
ctr -n k8s.io i import coredns.tar


ctr -n k8s.io i ls|grep coredns

rm -rf coredns.tar
```



## 修改主机名(可选)

```
my_or_hostname="k8s-$(hostname -I|awk '{print $1}')" && my_cus_hostname=${my_or_hostname//./-} && hostnamectl set-hostname ${my_cus_hostname}
my_or_hostname="k8s-$(hostname -I|awk '{print $1}')" && my_cus_hostname=${my_or_hostname//./-} && echo ${my_cus_hostname} > /etc/hostname
my_or_hostname="k8s-$(hostname -I|awk '{print $1}')" && my_cus_hostname=${my_or_hostname//./-} && echo "127.0.0.1 ${my_cus_hostname} " >> /etc/hosts


hostnamectl hostname
cat /etc/hostname
cat /etc/hosts
```

## 安装依赖包

```
apt update -y
apt install -y iptables
apt install -y vim
```

## 安装k8s(集群)

```
echo "shilintan666_" > password
sealos run registry.cn-shanghai.aliyuncs.com/labring/kubernetes:v1.27.12 registry.cn-shanghai.aliyuncs.com/labring/helm:v3.9.4 --masters 172.30.0.109,172.30.0.110,172.30.0.111 -f -p "$(cat password)"
```

或者通过密钥认证(废弃)

```
-i /root/.ssh/id_rsa.pem
```

去除主节点的污点

```shell
kubectl taint nodes --all node-role.kubernetes.io/control-plane:NoSchedule-
```

## 安装k8s(单机)

```
sealos run labring/kubernetes:v1.25.0 helm-v3.9.4.tar

kubectl taint node --all node-role.kubernetes.io/control-plane-
kubectl taint nodes --all node-role.kubernetes.io/master:NoSchedule-
kubectl taint nodes --all node.kubernetes.io/unreachable:NoSchedule-
```

## 修改cri配置文件

使用镜像代理仓库

```
mkdir -p /run/systemd/resolve
cp /etc/resolv.conf /run/systemd/resolve/resolv.conf
cat /run/systemd/resolve/resolv.conf


scp -i /root/.ssh/id_rsa.pem /var/lib/kubelet/config.yaml root@192.168.10.74:/var/lib/kubelet/config.yaml
scp -i /root/.ssh/id_rsa.pem /var/lib/kubelet/config.yaml root@192.168.10.76:/var/lib/kubelet/config.yaml
```

将文件`cri/config.toml`	替换到-> `/etc/containerd/config.toml`

```
systemctl daemon-reload
systemctl restart containerd
systemctl status containerd
journalctl -xefu containerd
```

将文件`cri/kubelet-config.yaml`  替换到-> `/var/lib/kubelet/config.yaml`

```
mkdir -p /var/lib/kubelet
vi /var/lib/kubelet/config.yaml

systemctl daemon-reload
systemctl restart kubelet
systemctl status  kubelet
journalctl -xefu  kubelet
```

验证

```
crictl rmi openebs/lvm-driver:1.2.0
crictl img
crictl pull openebs/lvm-driver:1.2.0
```

## 内核优化

`服务器-调优-内核参数.md`

` 服务器.md ` - `关闭交换空间` 

` 服务器.md ` - `时间` 

## 修改hosts

`本地镜像仓库配置.md`

```
cat >> /etc/hosts <<EOF
100.103.7.56	registry.cn-shanghai.aliyuncs.com
EOF
```





## 修改节点池

`节点池-local.md`


# 后续添加节点

添加之前记得对服务器做初始化

```
sealos add --nodes 10.88.201.106,10.88.201.107,10.88.201.108,10.88.201.109,10.88.201.110,10.88.201.111,10.88.201.112,10.88.201.113,10.88.201.114 -p $(cat password)
```

# 安装k8s组件

## cni-cillium

参考文档: `cni/cillium/部署.md`

## csi-openebs

参考文档: `csi/openebs/lvm-localpv/部署.md`

# 外部维护

查看kubeconfig文件: `cat ${HOME}/.kube/config`

## 本地连接

下载kubeconfig文件

下载`kubectl.exe`, 配置到`PAHT` 环境变量

配置 `KUBECONFIG` 环境变量指向kubeconfig文件

# 清理集群

```
sealos reset --masters 192.168.10.81,192.168.10.82,192.168.10.83 -p $(cat password)
```

# 删除节点

先逻辑删除, 再重装系统

## 通过sealos指令删除

```
sealos delete --nodes 192.168.0.101
```

也许可以不用重装系统

## 通过k8s指令删除

```
kubectl delete node 192.168.0.101
```

# 问题

一个ecs集群只能创建一个?

偶发性的创建失败
