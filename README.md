# k8s-research
作用

部署

生命周期管理(暂略)

存储

网络

监控

​	稳定性

​	性能

​	成本

cicd

​	私有化启动器

中间件

大数据

研发环境



# 存储

有哪些, 是什么, 哪些可用, 对比

https://kubernetes.io/zh-cn/docs/concepts/storage/storage-classes/#portworx-volume

https://landscape.cncf.io/card-mode?category=cloud-native-storage,runtime&grouping=category



OpenEBS、Ceph、Longhorn、GlusterFS、Portworx

## 特点

### 最快

原理: 无网络

本地

​	openebs

## 对比

### 性能对比

#### 2019

https://toutiao.io/posts/nmflsd/preview

https://blog.fleeto.us/post/kubernetes-storage-performance-comparison/

#### 2020

https://zhuanlan.zhihu.com/p/337076325

## 单机

### openebs

v3

https://openebs.io/docs

mayastor

​	不结合ssd能使用吗

主节点出现故障时, 是否影响使用, 是否是同步写副本

最大磁盘大小为单机最大磁盘大小

无法远程使用

## 分布式

### ceph

​	v17

​	ceph 优化

​		rdb块大小和数据库大小尽可能保持一致

​		内存缓存

​		分片数据尽可能聚集在容器所在主机上, 副本分布在另外的主机上, 先异步写副本再同步写当前主机节点再等待副本

​		hdd和ssd磁盘池分离

# 提问

k8s最新版本 1.27

k8s 从 1.23 到 1.27的新特性

​	k8s 1.23 新特性

​	k8s 1.24 新特性

​		dockershim移除

​	k8s 1.25 新特性

​	k8s 1.26 新特性

​		pod调度

​			动态申请资源

​		监控

​			kube组件自动提供/metrics端点

​			cAdvisor-less, CRI-full

​	k8s 1.27 新特性

​		镜像

​			k8s.gcr.io > registry.gcr.io

​		网络

​			优化性能: kube-proxy 大型集群

​		监控

​			kube-apiserver/kubelet tracing

​		资源限制

​			动态调整容器资源大小而不重启







# 发现问题

cncf landscape 没有更加详细的过滤、具体业务分类



# 方向思路

找到问题

找到通用问题

解决具体问题(poc), 形成文档/工具

解决通用问题, 形成产品



优化

## 具体表现

不同方案的测试对比报告

## 推动方式

量化对比数据
