## [译] K8S 六种存储解决方案的性能比较测试

#### 独家号 [K8sMeetup社区](https://toutiao.io/subjects/392908) 作者 小君君[原文链接](https://mp.weixin.qq.com/s/bV9_KBaqe4XqUbd32w8CEw)

![img](./[译] K8S 六种存储解决方案的性能比较测试 - 开发者头条.assets/302083d527d21ddc3c3c899b7d0a182b.jpeg)

> 翻译：小君君（才云）
>
> 技术校对：星空下的文仔（才云）、bot（才云）

大多数开发人员都认为在部署集群时选择合适的存储技术极为重要。但是，在 Kubernetes 这片市场上，人们对于存储技术的选择并没有一个标准的答案。本文将**介绍 Kubernetes 中常用的 6 种存储，分析它们的使用场景和优缺点，并对它们进行性能测试，找出哪种存储解决方案才是最理想的选择。**

存储技术的选择在很大程度上取决于工程师们要运行的工作负载类型。如果你正在使用 Kubernetes，你可能偏向于通过动态配置使用 volume 来进行块存储。对于裸机集群，你就需要为你的用例选择最为合适的技术，并将其集成到你的硬件上。

此外，例如 AKS、EKS 和 GKE 等公有云可以开箱即用并带有块存储，但这并不意味着它们是最好的选择。在许多情况下，默认公有云存储类的故障转移时间较长。例如，在 AWS EBS 中存在一个故障的 VM，附在此 VM Pod 上的 volume 需要 5 分钟以上的时间才能在另一个节点上重新联机。但是，像 Portworx 和 OpenEBS 此类云原生存储就可以很快解决这种问题。

本文的目的就是寻找在 Kubernetes 中最常用的存储解决方案，并进行基本性能比较。本次测试使用以下存储后端对 Azure AKS 执行所有测试：

- Azure 原生 StorageClass：Azure 高级版；
- 将 AWS cloud volume 映射到实例中：Azure hostPath，附带 Azure 托管磁盘；
- 由 Rook 管理的 Ceph；
- 由 Heketi 管理的 Gluster；
- 带有 cStor 后端的 OpenEBS；
- Portworx。

![img](./[译] K8S 六种存储解决方案的性能比较测试 - 开发者头条.assets/5b72e97e8e21c7b0ab402c2bcc6032c3.png)

**测试结果**

*注：请将结果作为存储选择期间的标准之一，但不要仅根据本文的数据做出最终判断。

**在描述过程之前，我们先总结一下最终结论。如果我们忽略本地 Azure pvc 或 hostPath，测试结果是：**

- Portworx 是 AKS 最快的容器存储；
- Ceph 是 HW 集群的最佳开源后端存储，但对于公有云，它的操作复杂性较高；
- OpenEBS 是一个很棒的概念，但需要更多的后端优化（这个项目正在优化中）。

那么这究竟是为什么呢？让我们从每个后端存储介绍安装说明开始，详述 AKS 测试的具体过程！

![img](./[译] K8S 六种存储解决方案的性能比较测试 - 开发者头条.assets/62dec63f7e8d1a293b75dadc864a3f4e.png)

**各存储解决方案的安装及优缺点**

*注：本节不含 Azure hostpath 的安装介绍。

***\*Azure 原生 Storage Class\****

本文将把 Azure 原生 Storage Class 作为所有测试的基线。Azure 会动态创建托管磁盘并将其映射到 VM 中，其中 Kubernetes 为 Pod 的 volume。

如果只是为了使用它，你没有必要再做其他事情。当你配置新的 AKS 集群时，它会自动预定义为“default”和“managed-premium”两种存储类。Premium 类将使用基于 SSD 的高性能和低延迟磁盘。

```
$ kubectl get storageclasses
NAME                PROVISIONER                AGE
default (default)   kubernetes.io/azure-disk   8m
managed-premium     kubernetes.io/azure-disk   8m

$ kubectl get pvc
NAME              STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS      AGE
dbench-pv-claim   Bound     pvc-e7bd34a4-1dbd-11e9-8726-ae508476e8ad   1000Gi     RWO            managed-premium   10s

$ kubectl get po
NAME           READY     STATUS              RESTARTS   AGE
dbench-w7nqf   0/1       ContainerCreating   0          29s
```

优点：

- AKS 上的默认值无需执行任何操作。

弊端：

- 故障转移方案非常慢：有时需要将近 10 分钟的时间才能将 volume 重新连接到不同节点上的 Pod。

**2.\**Ceph Rook\****

Ceph Rook 需要设计特定的硬件配置，根据数据类型生成 pg 组，配置日志 SSD 分区（在 bluestore 之前）并定义 crush 映射。**它****是一种处理整个存储集群安装的简洁方法。**

**在 AKS 上安装 Ceph Rook ：**

- 使用 Ceph Rook 快速入门指南[1]；
- 配置特定于 AKS 的 FLEXVOLUME_DIR_PATH，因为它们使用 /etc/kubernetes/volumeplugins/ 而不是默认的 Ubuntu /usr/libexec。没有这个改变，pvc 将无法通过 kubelet 安装。

```
diff --git a/cluster/examples/kubernetes/ceph/operator.yaml b/cluster/examples/kubernetes/ceph/operator.yaml
index 73cde2e..33f45c8 100755--- a/cluster/examples/kubernetes/ceph/operator.yaml
+++ b/cluster/examples/kubernetes/ceph/operator.yaml
@@ -431,8 +431,8 @@ spec:
         # - name: AGENT_MOUNT_SECURITY_MODE
         #   value: "Any"
         # Set the path where the Rook agent can find the flex volumes
-        # - name: FLEXVOLUME_DIR_PATH
-        #  value: "<PathToFlexVolumes>"+        - name: FLEXVOLUME_DIR_PATH
+          value: "/etc/kubernetes/volumeplugins"
         # Set the path where kernel modules can be found
         # - name: LIB_MODULES_DIR_PATH
         #  value: "<PathToLibModules>"
```

- 指定想在 deviceFilter 中使用的设备（附加磁盘始终在 /dev/sdc 上）；

```
diff --git a/cluster/examples/kubernetes/ceph/cluster.yaml b/cluster/examples/kubernetes/ceph/cluster.yaml
index 48cfeeb..0c91c48 100755--- a/cluster/examples/kubernetes/ceph/cluster.yaml
+++ b/cluster/examples/kubernetes/ceph/cluster.yaml
@@ -227,7 +227,7 @@ spec:
storage: # cluster level storage configuration and selection
useAllNodes: trueuseAllDevices: false-    deviceFilter:
+    deviceFilter: "^sdc"location:
Config:
```

- 安装完成后，使用以下配置创建 Ceph 块池和存储类：

```
apiVersion: ceph.rook.io/v1
kind: CephBlockPool
metadata:
name: replicapool
namespace: rook-ceph
spec:
failureDomain: host
replicated:
size: 3---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
name: rook-ceph-block
provisioner: ceph.rook.io/block
parameters:
blockPool: replicapool
clusterNamespace: rook-ceph
fstype: xfs
reclaimPolicy: Retain
```

- 通过以下部署工具箱检查状态：

```
ceph status
cluster:
id:     bee70a10-dce1-4725-9285-b9ec5d0c3a5e
health: HEALTH_OK

services:
mon: 3 daemons, quorum c,b,a
mgr: a(active)
osd: 3 osds: 3 up, 3 in

data:
pools:   0 pools, 0 pgs
objects: 0  objects, 0 B
usage:   3.0 GiB used, 3.0 TiB / 3.0 TiB avail
pgs:

[root@aks-agentpool-27654233-0 /]#
[root@aks-agentpool-27654233-0 /]#
[root@aks-agentpool-27654233-0 /]# ceph osd status
+----+--------------------------+-------+-------+--------+---------+--------+---------+-----------+
| id |           host           |  used | avail | wr ops | wr data | rd ops | rd data |   state   |
+----+--------------------------+-------+-------+--------+---------+--------+---------+-----------+
| 0  | aks-agentpool-27654233-0 | 1025M | 1021G |    0   |     0   |    0   |     0   | exists,up |
| 1  | aks-agentpool-27654233-1 | 1025M | 1021G |    0   |     0   |    0   |     0   | exists,up |
| 2  | aks-agentpool-27654233-2 | 1025M | 1021G |    0   |     0   |    0   |     0   | exists,up |
+----+--------------------------+-------+-------+--------+---------+--------+---------+-----------+
```

优点：

- 它是一个可以在大型生产环境中运行的 Robust 存储；
- Rook 使生命周期管理变得更加简单。

弊端：

- 复杂；它不太适合在公有云中运行，建议只在具有正确配置的 HW 集群上运行。

**3.\**GlusterFS Heketi\****

**GlusterFS 是一个的开源存储解决方案。**Heketi 是 GlusterFS RESTful volume 的管理界面。它提供了一种便捷的方式让 GlusterFS 具有动态配置的能力。如果没有这种访问权限，用户就必须手动创建 GlusterFS volume 并将其映射到 Kubernetes pv 上。

*注：关于 GlusterFS 的更多信息，见：https://docs.gluster.org/en/latest/Install-Guide/Overview/

**这里使用了 Heketi 快速入门指南[2]进行安装：**

- 根据样本 1 创建了一个包含磁盘和主机名的拓扑文件；
- Heketi 主要是在基于 RHEL 的操作系统上开发和测试的。在 AKS 上测试时，测试人员曾遇到了 Ubuntu 主机内核模块路径不正确的问题；

以下是修复该问题的 PR：

```
+++ b/deploy/kube-templates/glusterfs-daemonset.yaml
@@ -67,7 +67,7 @@ spec:
mountPath: "/etc/ssl"readOnly: true- name: kernel-modules
-          mountPath: "/usr/lib/modules"+          mountPath: "/lib/modules"readOnly: truesecurityContext:
capabilities: {}
@@ -131,4 +131,4 @@ spec:
path: "/etc/ssl"- name: kernel-modules
hostPath:
-          path: "/usr/lib/modules"+          path: "/lib/modules"
```

- 测试人员在 AKS 上遇到的另一个问题是没有空磁盘，于是他们使用 wipefs 清理 glusterfs 的磁盘（这个磁盘以前没有用于其他用途）；

```
wipefs -a /dev/sdc
/dev/sdc: 8 bytes were erased at offset 0x00000218 (LVM2_member): 4c 56 4d 32 20 30 30 31
```

- 运行 gk-deploy -g -t topology.json 命令，它在由 Heketi 控制器控制的每个节点上部署了 glusterfs pod。

```
root@aks-agentpool-20273348-0:~# kubectl get po -o wide
NAME                     READY   STATUS    RESTARTS IP        NODE                       NOMINATED NODE
glusterfs-fgc8f          1/1     Running   0       10.0.1.35  aks-agentpool-20273348-1glusterfs-g8ht6          1/1     Running   0       10.0.1.4   aks-agentpool-20273348-0glusterfs-wpzzp          1/1     Running   0       10.0.1.66  aks-agentpool-20273348-2heketi-86f98754c-n8qfb   1/1     Running   0       10.0.1.69  aks-agentpool-20273348-2
```

同时，动态配置问题也会对测试造成一定影响。对于 Kubernetes 控制平面，Heketi restURL 是不可用的。测试人员尝试利用 kube dns record、Pod IP 和 svc IP 来解决这个问题，但是都没有奏效。为此，他们最后选择通过 Heketi CLI 手动创建 volume。

```
root@aks-agentpool-20273348-0:~# export HEKETI_CLI_SERVER=http://10.0.1.69:8080root@aks-agentpool-20273348-0:~# heketi-cli volume create --size=10 --persistent-volume --persistent-volume-endpoint=heketi-storage-endpoints | kubectl create -f -
persistentvolume/glusterfs-efb3b155 created

root@aks-agentpool-20273348-0:~# kubectl get pv
NAME                 CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM     STORAGECLASS   REASON    AGE
glusterfs-efb3b155   10Gi       RWX            Retain           Available                                      19s
```

- 将现有的 PV 映射到 dbench 工具的 PVC 上。

```
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
name: glusterfs-efb3b155
spec:
accessModes:
- ReadWriteMany
storageClassName: ""resources:
requests:
storage: 10Gi
volumeName: glusterfs-efb3b155

kubectl get pvc
NAME                 STATUS    VOLUME               CAPACITY   ACCESS MODES   STORAGECLASS   AGE
glusterfs-efb3b155   Bound     glusterfs-efb3b155   10Gi       RWX                           36m
```

以下是在 Kubernetes 上安装 Heketi Gluster 的更多内容：

```
gluster volume info vol_efb3b15529aa9aba889d7900f0ce9849

Volume Name: vol_efb3b15529aa9aba889d7900f0ce9849
Type: Replicate
Volume ID: 96fde36b-e389-4dbe-887b-baae32789436
Status: Started
Snapshot Count: 0Number of Bricks: 1 x 3 = 3Transport-type: tcp
Bricks:
Brick1: 10.0.1.66:/var/lib/heketi/mounts/vg_5413895eade683e1ca035760c1e0ffd0/brick_cd7c419bc4f4ff38bbc100c6d7b93605/brick
Brick2: 10.0.1.35:/var/lib/heketi/mounts/vg_3277c6764dbce56b5a01426088901f6d/brick_6cbd74e9bed4758110c67cfe4d4edb53/brick
Brick3: 10.0.1.4:/var/lib/heketi/mounts/vg_29d6152eeafc57a707bef56f091afe44/brick_4856d63b721d794e7a4cbb4a6f048d96/brick
Options Reconfigured:
transport.address-family: inet
nfs.disable: on
performance.client-io-threads: off

kubectl get svc
NAME                       TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
heketi                     ClusterIP   192.168.101.75   <none>        8080/TCP   5h
heketi-storage-endpoints   ClusterIP   192.168.103.66   <none>        1/TCP      5h

root@aks-agentpool-20273348-0:~# kubectl get endpoints
NAME                       ENDPOINTS                            AGE
heketi                     10.0.1.69:8080                       5h
heketi-storage-endpoints   10.0.1.35:1,10.0.1.4:1,10.0.1.66:1   5h
kubernetes                 172.31.22.152:443                    1d
root@aks-agentpool-20273348-0:~# kubectl get endpoints heketi-storage-endpoints -o yaml
apiVersion: v1
kind: Endpoints
metadata:
creationTimestamp: 2019-01-29T15:14:28Z
name: heketi-storage-endpoints
namespace: defaultresourceVersion: "142212"
selfLink: /api/v1/namespaces/default/endpoints/heketi-storage-endpoints
uid: 91f802eb-23d8-11e9-bfcb-a23b1ec87092
subsets:
- addresses:
- ip: 10.0.1.35
- ip: 10.0.1.4
- ip: 10.0.1.66
ports:
- port: 1
protocol: TCP
```

优点：

- 有实践经验的存储解决方案；
- 比 Ceph 轻量。

弊端：

- Heketi 不是为 Kubernetes 专属设计的，它更适用于硬件集群；
- 它不是为“结构化数据”专属设计的（如 SQL 数据库）。但是，用户可以使用 Gluster 的备份和还原数据库。

**4.\**OpenEBS\****

OpenEBS **代表了一种新的 CAS（Container Attached Storage）概念，属于云原生存储类别。**它是基于单个微服务的存储控制器和基于多个微服务的存储复制品。

作为开源项目，目前它提供 2 个后端：Jiva 和 cStor。cStor 作为控制器，它的副本部署在一个 namespace（安装 openebs 的 namespace）中，也可以说它采用的是原始磁盘而不是格式化分区。每个 Kubernetes volume 都有自己的存储控制器，它可以在节点可用存储容量范围内进行扩展。

在 AKS 上安装它非常简单：

- 必须连接所有 Kubernetes 节点的控制台并安装 iSCSI，因为它使用 iSCSI 协议连接带 pod 的 Kubernetes 节点和存储控制器；

```
apt-get update
apt install -y open-iscsi
```

- 将单个 YAML 定义应用于 Kubernetes 集群；

```
kubectl apply -f https://openebs.github.io/charts/openebs-operator-0.8.0.yaml
```

- 下一步，OpenEBS 控制器会在底层节点上发现用户的所有磁盘。但你必须手动识别并将它附加到 AWS 托管磁盘上；

```
kubectl get disk
NAME                                      AGE
disk-184d99015253054c48c4aa3f17d137b1     5m
disk-2f6bced7ba9b2be230ca5138fd0b07f1     5m
disk-806d3e77dd2e38f188fdaf9c46020bdc     5m
```

- 将这些磁盘添加到自定义 Kubernetes 资源 StoragePoolClaim 中，该资源将被标准 StorageClass 引用。

```
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
name: openebs-custom
annotations:
openebs.io/cas-type: cstor
cas.openebs.io/config: |
- name: StoragePoolClaim
value: "cstor-disk"provisioner: openebs.io/provisioner-iscsi
---
apiVersion: openebs.io/v1alpha1
kind: StoragePoolClaim
metadata:
name: cstor-disk
spec:
name: cstor-disk
type: disk
maxPools: 3poolSpec:
poolType: striped
disks:
diskList:
- disk-2f6bced7ba9b2be230ca5138fd0b07f1
- disk-806d3e77dd2e38f188fdaf9c46020bdc
- disk-184d99015253054c48c4aa3f17d137b1
```

**优点：**

- 开源；
- Maya 在资源使用可视化方面做得很好。用户可以在 Kubernetes 集群中轻松部署多个服务，并轻松设置监视和日志记录，以收集集群中所有重要信息；
- OpenEBS 背后的社区：Slack 团队非常乐于助人，如果你主动询问，他们可能会帮你解决很多问题。

**弊端：**

- 不成熟：OpenEBS 是一个相当新的项目，尚未达到稳定版本。核心团队仍在进行后端优化；
- Kubelet 和存储控制器之间的 iSCSI 连接由 Kubernetes 服务实现，这种连接方式在 CNI 插件中可能会出现一些问题（如 Tungsten Fabric）；
- 需要在 Kubernetes 节点上安装其他软件（iSCSI），这使得它在托管 Kubernetes 集群的情况下变得不切实际。

*注：OpenEBS 团队帮忙修改的测试用例场景，见：https://github.com/kmova/openebs/tree/fio-perf-tests/k8s/demo/dbench

**5.\**Portworx\****

最后为大家介绍一种比较新颖的解决方案。

Portworx 是另一个专为 Kubernetes 设计的云原生存储，专注于高度分散的环境。它是一个主机可寻址存储，每个 volume 都直接映射到它所连接的主机上。它根据应用程序 I/O 的类型提供自动调整。**不幸的是，它不是开源的存储方案。然而，它免费提供了 3 个节点可进行试用。**

*注：关于 Portworx 更多信息，见：https://portworx.com/makes-portworx-unique/

在 AKS 上安装 Portworx 很容易，可以使用 Kubernetes 规格生成器：

- Kubernetes v1.11.4 中的 etcd 选择了 Portworx 托管的方式来简化安装；
- 如果你使用的是 Azure CNI，你就必须将数据网络接口修改为 azure0。否则 Portworx 将使用 docker bridge 而不是 VM 接口的 IP 地址；
- 网站生成器为集群提供了渲染的 Kubernetes YAML 清单；
- 在 bootstrap 之后，按照 Kubernetes 节点运行 Portworx pod;

```
root@aks-agentpool-20273348-0:~# kubectl get pods -o wide -n kube-system -l name=portworx
NAME             READY     STATUS    RESTARTS   AGE       IP          NODE                       NOMINATED NODE
portworx-g9csq   1/1       Running   0          14m       10.0.1.66   aks-agentpool-20273348-2   <none>
portworx-nt2lq   1/1       Running   0          14m       10.0.1.4    aks-agentpool-20273348-0   <none>
portworx-wcjnx   1/1       Running   0          14m       10.0.1.35   aks-agentpool-20273348-1   <none>
```

- 创建具有高优先级和 3 个副本的存储类，而后准备 Kubernetes pvc 。

```
root@aks-agentpool-20273348-0:~# kubectl get storageclass -o yaml portworx-sc
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
creationTimestamp: 2019-01-28T21:10:28Z
name: portworx-sc
resourceVersion: "55332"selfLink: /apis/storage.k8s.io/v1/storageclasses/portworx-sc
uid: 23455e40-2341-11e9-bfcb-a23b1ec87092
parameters:
priority_io: high
repl: "3"provisioner: kubernetes.io/portworx-volume
reclaimPolicy: Delete
volumeBindingMode: Immediate
```

**优点：**

- 易于部署：具有详细配置的 ebsite 配置器；
- AKS 集群的配置程序，无需任何额外步骤来充当 Ceph 或 GlusterFS；
- 云原生存储：它可以在 HW 集群和公有云上运行；
- 存储感知服务类（COS）和应用程序感知 I/O 调优。

**弊端：**

- 封闭源：专有供应商解决方案。

![img](./[译] K8S 六种存储解决方案的性能比较测试 - 开发者头条.assets/7fdc5b05ed357923555ed22f60d4b734.png)

**AKS 测试环境**

在本次测试中，测试人员配置了具有 3 个 VM 的基本 Azure AKS 集群。为了能够连接托管的 Premium SSD，测试人员必须使用 E 类型大小的 VM。因此他们选择了 Standard_E2s_v3，只有 2 个 vCPU 和 16GB RAM。

![img](./[译] K8S 六种存储解决方案的性能比较测试 - 开发者头条.assets/30406df766a9801e6ecf9f00bac81ed6.jpeg)

每个 AKS 集群都会自动配置第二个资源组（RG）MC_ <name>，你可以在其中找到所有 VM、NIC 。在 RG 内部，测试人员创建了 3 个 1TB 高级 SSD 托管磁盘并手动将它们连接到每个 VM 中。

![img](./[译] K8S 六种存储解决方案的性能比较测试 - 开发者头条.assets/0ea2d8098da8360c9ff3e048b2277264.jpeg)

它允许我在每个专用于测试的实例中获得 1TB 的空磁盘。据 Azure 称，它的性能可以在 5000 IOPS 和 200 MB/s 吞吐量之间，具体取决于 VM 和磁盘大小。

![img](./[译] K8S 六种存储解决方案的性能比较测试 - 开发者头条.assets/8ec7c4b178550710b759746b4e473c65.jpeg)

**性能结果**

**重要说明：单个存储性能测试的结果是无法单独评估的，它们必须相互比较才能显示出差距。测试的方法有很多种，下面是其中较为简单的一种方法。**

为了进行测试，测试人员决定使用名为 Dbench 的负载测试器。**它是 Pod 的 Kubernetes 部署清单 , 同时它也是运行 FIO 的地方，并且带有 Flexible IO Tester 等 8 个测试用例。**

**测试在 Docker 镜像的入口点指定:**

- 随机读/写带宽；
- 随机读/写 IOPS；
- 读/写延迟；
- 顺序读/写；
- 混合读/写 IOPS。

注：所有测试的完整测试输出，见：

https://gist.github.com/pupapaik/76c5b7f124dbb69080840f01bf71f924

**随机读/写带宽**

随机读取测试表明，GlusterFS、Ceph 和 Portworx 在读取时的性能比 AWS 本地磁盘上的主机路径快好几倍，因为它们读取的是缓存。GlusterFS 写入速度最快，它与本地磁盘几乎达到了相同的值。

![img](./[译] K8S 六种存储解决方案的性能比较测试 - 开发者头条.assets/735e2c3a2e94751f83f2d501f291e7e7.jpeg)

![img](./[译] K8S 六种存储解决方案的性能比较测试 - 开发者头条.assets/0ceebab7da2278122bbb71f3db7d6fec.jpeg)

**随机读/写 IOPS**

随机 IOPS 显示 Portworx 和 Ceph 效果最佳。Portworx 在写入时的 IOPS 与本机 Azure pvc 几乎相同，这非常好。

![img](./[译] K8S 六种存储解决方案的性能比较测试 - 开发者头条.assets/600e0dee063f08c57359d86f5044020a.jpeg)

![img](./[译] K8S 六种存储解决方案的性能比较测试 - 开发者头条.assets/73058b1f002249f1d85943cc2775cc7d.jpeg)

**读/写延迟**

延迟测试返回了有趣的结果，因为本机 Azure pvc 比大多数其他测试存储都慢。Portworx 和 Ceph 实现了最佳读取速度。但是对于写入，GlusterFS 比 Ceph 更好。与其他存储相比，OpenEBS 延迟非常高。

![img](./[译] K8S 六种存储解决方案的性能比较测试 - 开发者头条.assets/535fadc1ae5d27cd1d74d38e17ccb6aa.jpeg)

![img](./[译] K8S 六种存储解决方案的性能比较测试 - 开发者头条.assets/4ed427d26a3e6c154fd42f0d92474c9f.jpeg)

**顺序读/写**

顺序读/写测试显示与随机测试类似的结果，但 Ceph 的读取是 GlusterFS 的 2 倍多。除了表现非常差的 OpenEBS 之外，写入结果几乎都在同一级别上。

![img](./[译] K8S 六种存储解决方案的性能比较测试 - 开发者头条.assets/8b4b2dea00b4c5e777d16735466b3678.jpeg)

![img](./[译] K8S 六种存储解决方案的性能比较测试 - 开发者头条.assets/ce6ae0da86145f6ca64113a8bc2eaee7.jpeg)**混合读/写 IOPS**

最后一个测试用例验证了混合读/写 IOPS，即使在 mixed write 上，Portworx 和 Ceph 也提供了比原生 Azure pvc 更好的 IOPS。

![img](./[译] K8S 六种存储解决方案的性能比较测试 - 开发者头条.assets/fedc310ee385940bd65c5ca3274aa854.jpeg)

![img](./[译] K8S 六种存储解决方案的性能比较测试 - 开发者头条.assets/72543debfc079b83eb5d2ca3a7dfc77f.jpeg)

以上就是所有测试结果，希望这篇文章对你有所帮助。

\--

参考文献：

[1]https://github.com/rook/rook/blob/master/Documentation/ceph-quickstart.md#ceph-storage-quickstart

[2]https://github.com/gluster/gluster-kubernetes/blob/master/docs/setup-guide.md#deployment