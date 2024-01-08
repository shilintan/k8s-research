[toc]

# 架构

https://docs.ceph.com/en/latest/start/intro/

https://docs.ceph.com/en/latest/architecture



硬件要求: https://docs.ceph.com/en/latest/start/hardware-recommendations/

配置文件: https://access.redhat.com/documentation/zh-cn/red_hat_ceph_storage/2/html/configuration_guide/index

# 优化

## 禁用磁盘缓存

​	参考文档: https://docs.ceph.com/en/latest/start/hardware-recommendations/#write-caches

```
apt install hdparm -y
apt install sdparm -y
apt install smartmontools -y

hdparm -W0 /dev/sdb
sdparm --clear WCE /dev/sdb
smartctl -s wcache,off /dev/sdb
```

## 文件条带化

参考文档:

​	https://docs.ceph.com/en/quincy/dev/file-striping/

​	rook	https://github.com/rook/rook/issues/1960

stripe_unit(条带单元)、stripe_count(条带数)、object_size

​	单位byte

`ceph.conf`

```
[client]
rbd default stripe_unit = 16777216
rbd default stripe_count = 16
rbd default features = 12
rbd default format = 2
rbd default order = 23
```

检查

```
# 查看默认配置
ceph --show-config
```

测试

```
$ ceph config set global rbd_default_stripe_unit 16777216
$ ceph config set global rbd_default_stripe_count 16
$ rbd create --size 1G img
$ rbd info img
rbd image 'img':
        size 1 GiB in 256 objects
        order 22 (4 MiB objects)
        snapshot_count: 0
        id: 109b78c030ef
        block_name_prefix: rbd_data.109b78c030ef
        format: 2
        features: layering, striping, exclusive-lock, object-map, fast-diff, deep-flatten
        op_features: 
        flags: 
        create_timestamp: Tue May 17 04:43:48 2022
        access_timestamp: Tue May 17 04:43:48 2022
        modify_timestamp: Tue May 17 04:43:48 2022
        stripe unit: 4 KiB
        stripe count: 4
```

元数据使用ssd

ceph bluestore使用ssd

radosgw 多加节点资源、副本数量

osd建议不基于已有ceph块

osd 给更多内存作为缓存

# 兼容本地存储(openebs)

先初始化本地存储, 关闭后台自动发现设备



# 资源计算

ceph:

​	mon:	1c3g+50g-ssd

​	mgr:	1c3g

​	mds:	1c3g

​	rgw:	 1c2g

​	osd:	  1c5g, 50c250g

system:	   1c1g

log:		  1c1g

nginx:		1c1g



计算公式: 7c15g + 磁盘数量 x 1c5g

# 部署

1 sdd, 3 hdd

aliyun 挂载的磁盘无法识别为ssd

osd的盘的大小一致



## 磁盘挂载

```shell
mkdir -p 		/data/rook
mkdir -p 		/var/lib/rook
mount --bind 	/data/rook   		/var/lib/rook
df -h /var/lib/rook
cat >> /etc/fstab <<EOF
/data/rook       /var/lib/rook        none defaults,bind 0 0
EOF
systemctl daemon-reload
```



查看磁盘类型(hdd或者ssd)

```
apt install util-linux -y
lsblk -d -o name,rota
# 结果为1则为hdd, 结果为0则为ssd
```

需要提前部署prometheus

```
kubectl create -f	rook/deploy/examples/crds.yaml -f rook/deploy/examples/common.yaml
kubectl apply -f	rook/deploy/examples/monitoring/rbac.yaml
kubectl apply -f     rook/deploy/examples/monitoring/csi-metrics-service-monitor.yaml -f rook/deploy/examples/monitoring/exporter-service-monitor.yaml -f rook/deploy/examples/monitoring/service-monitor.yaml
kubectl apply -f	csi-ceph-conf-override.yaml
kubectl apply -f	operator.yaml
kubectl apply -f	prepare-image.yaml
kubectl -n rook-ceph wait pods -l app=rook-ceph-operator --for=condition=Ready=true --timeout=180s
kubectl -n rook-ceph wait pods -l app=prepare-image --for=condition=Ready=true --timeout=180s


kubectl apply -f	cluster.yaml
kubectl apply -f	toolbox.yaml
kubectl -n rook-ceph wait pods -l mon=a --for=condition=Ready=true --timeout=180s
kubectl -n rook-ceph wait pods -l mon=b --for=condition=Ready=true --timeout=180s
kubectl -n rook-ceph wait pods -l mon=c --for=condition=Ready=true --timeout=180s
kubectl -n rook-ceph wait pods -l mgr=a --for=condition=Ready=true --timeout=180s
kubectl -n rook-ceph wait pods -l mgr=b --for=condition=Ready=true --timeout=180s
kubectl -n rook-ceph wait pods -l mon=a --for=condition=Ready=true --timeout=180s
kubectl -n rook-ceph wait pods -l app=rook-ceph-tools --for=condition=Ready=true --timeout=180s
```

## rdb

```
kubectl apply -f	rbd-storageclass.yaml
```

## rgw

```
kubectl apply -f	object.yaml
kubectl -n rook-ceph wait pods -l rgw=my-store --for=condition=Ready=true --timeout=180s
kubectl apply -f	object-user.yaml
kubectl apply -f	object-ingress.yaml
kubectl apply -f	ceph-radosgw-ui.yaml
kubectl apply -f	svc-out.yaml
kubectl -n rook-ceph wait pods -l app=oss-ui --for=condition=Ready=true --timeout=180s
```

使用ssd作为hdd加速盘

查看用户名、密码

```
kubectl -n rook-ceph get secret rook-ceph-object-user-my-store-my-user -o jsonpath='{.data.AccessKey}' | base64 --decode

kubectl -n rook-ceph get secret rook-ceph-object-user-my-store-my-user -o jsonpath='{.data.SecretKey}' | base64 --decode
```



创建bucket

```
kubectl -n rook-ceph delete pod load-generator
kubectl -n rook-ceph run -it --tty --command load-generator --image=registry.cn-shanghai.aliyuncs.com/shilintan-public/minio_mc:RELEASE.2023-11-20T16-30-59Z.fips -- sh
kubectl -n rook-ceph describe pod load-generator
kubectl -n rook-ceph logs -f --tail 300 load-generator


mc alias set s3 http://rook-ceph-rgw-my-store:80 aa bb

BUCKET_NAME=bigdatacabinet
mc mb s3/${BUCKET_NAME}
mc anonymous set download s3/${BUCKET_NAME}
mc anonymous get-json s3/${BUCKET_NAME}
```

或者旧版本的cpu, 修改虚拟机的cpu虚拟化方式为host方式

```
kubectl -n rook-ceph delete pod load-generator
kubectl -n rook-ceph run -it --tty --command load-generator --image=minio/mc:RELEASE.2023-12-14T00-37-41Z-cpuv1 -- sh
```

直接为ceph-rgw设置cors(可选)

```
kubectl delete pod load-generator
kubectl run -it --tty load-generator --image=centos:centos7.9.2009 -- bash

cp -r /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup \
&& curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo \
&& yum clean all \
&& yum makecache

yum update -y
yum install -y python3
yum install epel-release
yum install python-pip -y
pip install s3cmd
s3cmd --version



s3cmd --configure
	EIKH91E57ZQ4H1HF4LSQ
	bBSzQu3FK3dWTDWXI0mZ25JhI0CGCXDK1WoxTEve
	rook-ceph-rgw-my-store.rook-ceph
	%(bucket).rook-ceph-rgw-my-store.rook-ceph




cat >> cors.xml <<EOF
<CORSConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
<CORSRule>
<AllowedMethod>PUT</AllowedMethod>
<AllowedMethod>DELETE</AllowedMethod>
<AllowedMethod>POST</AllowedMethod>
<AllowedMethod>GET</AllowedMethod>
<AllowedOrigin>*</AllowedOrigin>
<AllowedHeader>*</AllowedHeader>
<ExposeHeader>ETag</ExposeHeader>
</CORSRule>
</CORSConfiguration>
EOF

s3cmd setcors cors.xml s3://bigdatacenter
s3cmd setcors cors.xml s3://bigdatacloud
s3cmd setcors cors.xml s3://culturebox
s3cmd setcors cors.xml s3://culturecloud
```



# 调试

```
kubectl -n rook-ceph get all
kubectl -n rook-ceph get pvc
kubectl -n rook-ceph get pod -o wide
kubectl -n rook-ceph get endpoints
kubectl -n rook-ceph get svc
kubectl -n rook-ceph get secret
kubectl -n rook-ceph get CephObjectStore

kubectl -n rook-ceph edit CephObjectStore my-store

kubectl -n rook-ceph describe pvc data-oss-ui-0

kubectl -n rook-ceph describe pod -l app=rook-ceph-operator
kubectl -n rook-ceph describe pod -l app=prepare-image
kubectl -n rook-ceph describe pod rook-ceph-csi-detect-version-vpm4n
kubectl -n rook-ceph describe pod rook-ceph-detect-version-kcqsv
kubectl -n rook-ceph describe pod mgr=a
kubectl -n rook-ceph describe pod mgr=b
kubectl -n rook-ceph describe pod rook-ceph-mon-a-86b79bb78f-kq8km
kubectl -n rook-ceph describe CephObjectStore my-store
kubectl -n rook-ceph describe pod -l app=rook-ceph-csi-detect-version
kubectl -n rook-ceph describe pod rook-ceph-tools-0
kubectl -n rook-ceph describe pod -l app=prepare-image
kubectl -n rook-ceph describe pod -l app=oss-ui

kubectl -n rook-ceph logs -f --tail 300 -l app=rook-ceph-operator
kubectl -n rook-ceph logs -f --tail 300 rook-discover-295ct
kubectl -n rook-ceph logs -f --tail 300 -l mon=a
kubectl -n rook-ceph logs -f --tail 300 -l mon=b
kubectl -n rook-ceph logs -f --tail 300 -l mon=c
kubectl -n rook-ceph logs -f --tail 300 -l mon=d
kubectl -n rook-ceph logs -f --tail 300 -l mgr=a
kubectl -n rook-ceph logs -f --tail 300 -l mgr=b
kubectl -n rook-ceph logs -f --tail 300 -l ceph-osd-id=1
kubectl -n rook-ceph logs -f --tail 300 -l ceph-osd-id=4
kubectl -n rook-ceph logs -f --tail 300 rook-ceph-mgr-a-c9bfcbff9-7dzxk
kubectl -n rook-ceph logs -f --tail 300 rook-ceph-mgr-b-6f47cd9574-c9zpl
kubectl -n rook-ceph logs -f --tail 300 rook-ceph-osd-0-56966895fc-nhglj
kubectl -n rook-ceph logs -f --tail 300 rook-ceph-osd-1-6868686568-zgpxt
kubectl -n rook-ceph logs -f --tail 300 rook-ceph-rgw-my-store-a-594fd5578b-mgf56
kubectl -n rook-ceph logs -f --tail 300 rook-ceph-rgw-my-store-a-594fd5578b-rpp9b
kubectl -n rook-ceph logs -f --tail 300 oss-ui-0
kubectl -n rook-ceph logs -f --tail 300 -l app=csi-rbdplugin-provisioner

kubectl -n rook-ceph delete pod -l app=rook-ceph-operator
kubectl -n rook-ceph delete pod -l app=prepare-image
kubectl -n rook-ceph delete pod -l mon=a
kubectl -n rook-ceph delete pod -l mon=b
kubectl -n rook-ceph delete pod -l mon=c
kubectl -n rook-ceph delete pod -l app=oss-ui

kubectl -n rook-ceph edit pod rook-ceph-mgr-a-c9bfcbff9-7dzxk
kubectl -n rook-ceph edit pod rook-ceph-mgr-b-6f47cd9574-c9zp
kubectl -n rook-ceph edit pod rook-ceph-mon-a-56db4b4444-b7zw4
kubectl -n rook-ceph edit pod rook-ceph-osd-0-6d44776b46-r59j4
kubectl -n rook-ceph edit pod csi-cephfsplugin-4txkq
```

rbd

```
kubectl -n rook-ceph get CephCluster
kubectl -n rook-ceph get CephBlockPool
kubectl get storageclass

kubectl -n rook-ceph describe CephCluster   rook-ceph
kubectl -n rook-ceph describe CephBlockPool replicapool
```

调试ceph

```
kubectl -n rook-ceph exec -it rook-ceph-tools-0 -- bash

ceph versions
ceph status
ceph health
ceph osd status
ceph osd df
ceph osd utilization
ceph osd pool stats
ceph osd tree
ceph pg stat



# 删除磁盘
ceph osd tree
ceph osd out osd.0
ceph osd purge 3 --yes-i-really-mean-it
ceph osd crush remove osd.0
ceph auth rm osd.0
ceph osd  rm osd.0
# 观察数据迁移过程
ceph -w
```

oss-object-ui

```shell
kubectl apply -f object-storage-ui.yaml

kubectl delete -f object-storage-ui.yaml
kubectl -n rook-ceph delete pvc data-oss-ui-0

kubectl -n rook-ceph get pvc
kubectl -n rook-ceph get statefulset
kubectl -n rook-ceph describe statefulset oss-ui
kubectl -n rook-ceph get pod oss-ui-0
kubectl -n rook-ceph get svc oss-ui
kubectl -n rook-ceph delete pod oss-ui-0
kubectl -n rook-ceph describe pod oss-ui-0
kubectl -n rook-ceph logs -f --tail 300 oss-ui-0
kubectl -n rook-ceph exec -it oss-ui-0 -- bash
```

# 集成测试

## rbd

```
kubectl apply -f test-rdb.yaml


kubectl get pvc
kubectl get pod
kubectl describe pvc csi-rbd-demo-ephemeral-pod-mypvc
kubectl describe pod csi-rbd-demo-ephemeral-pod


kubectl delete -f test-rdb.yaml
```





# 清理

```
kubectl delete -f	toolbox.yaml
kubectl delete -f	object-ingress.yaml
kubectl delete -f 	object-user.yaml
kubectl delete -f 	object.yaml
for CRD in $(kubectl get crd -n rook-ceph | awk '/ceph.rook.io/ {print $1}'); do
    kubectl get -n rook-ceph "$CRD" -o name | \
    xargs -I {} kubectl patch -n rook-ceph {} --type merge -p '{"metadata":{"finalizers": []}}'
done
kubectl delete -f 	cluster.yaml
kubectl delete -f 	operator.yaml
kubectl delete -f 	rook/deploy/examples/crds.yaml
kubectl delete -f 	rook/deploy/examples/common.yaml

kubectl -n rook-ceph delete pvc data-oss-ui-0
```

在mon的主机上

```
rm -rf /var/lib/rook/*

lsblk

wipefs --all /dev/vdb
wipefs --all /dev/vdc
wipefs --all /dev/vdd
wipefs --all /dev/vde



DISK="/dev/vdb"
sgdisk --zap-all $DISK
dd if=/dev/zero of="$DISK" bs=1M count=100 oflag=direct,dsync
blkdiscard $DISK
partprobe $DISK

DISK="/dev/vdc"
sgdisk --zap-all $DISK
dd if=/dev/zero of="$DISK" bs=1M count=100 oflag=direct,dsync
blkdiscard $DISK
partprobe $DISK

DISK="/dev/vdd"
sgdisk --zap-all $DISK
dd if=/dev/zero of="$DISK" bs=1M count=100 oflag=direct,dsync
blkdiscard $DISK
partprobe $DISK

DISK="/dev/vde"
sgdisk --zap-all $DISK
dd if=/dev/zero of="$DISK" bs=1M count=100 oflag=direct,dsync
blkdiscard $DISK
partprobe $DISK


rm -rf /dev/ceph-*
rm -rf /dev/mapper/ceph--*
```



# 配置

## 配置oss防盗链

在ingress上

```
    nginx.ingress.kubernetes.io/server-snippet: |
      valid_referers none blocked server_names *.shilintan.com localhost;
      if ($invalid_referer) {
          return 403;
      }
```

## 配置oss-ui

注意: 

​	配置S3需要浏览器能访问到api端点

​	通过拖拽文件上传到oss



创建密码

Backend

​	删除其他, 只保留S3

​	Authentication Middleware

​		ADMIN

​			Related Backend: 	S3

​			Access Key Id: 		ZBQRIA1U32UNRA272KN0

​			Secret access key:	KFPIO6AXaHs8VfkbHZDZsz2fHgsTvHEWmgAJOjUo

​			Endpoint:			http://172.30.0.100:31483



# 扩容

## 扩容osd

```
删除operator
```



# 问题

服务参数DefaultLimitNOFILE不能超过1073741820

ceph 与ssd的兼容性有问题, 貌似无法使用ssd





# 程序集成使用

https://mvnrepository.com/artifact/com.amazonaws/aws-java-sdk-s3/1.12.594



# 多环境文件迁移

下载客户端

​	https://dl.min.io/client/mc/release/windows-amd64/mc.exe



下载源端文件夹

```
mc alias set ss3 http://oss.shilintan.com x x
SOURCE_BUCKET_NAME=bigdatacenter
mc cp --recursive ss3/${SOURCE_BUCKET_NAME}/ ${SOURCE_BUCKET_NAME}
```

上传文件夹

```
mc alias set ts3 http://oss.shilintan.com x x
TARGET_BUCKET_NAME=bigdatacenter
mc cp --recursive ${TARGET_BUCKET_NAME}/* ts3/${TARGET_BUCKET_NAME}/
```

