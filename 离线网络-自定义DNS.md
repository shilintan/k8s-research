```
kubectl -n kube-system edit deploy coredns
修改
	replicas: 2
	->
	replicas: 1

新增:
	hostPort: 53


kubectl -n kube-system logs -f --tail 300 deploy/coredns
kubectl -n kube-system delete pod coredns-5fc5c49558-zghrc
kubectl -n kube-system get pod|grep coredns
kubectl -n kube-system delete pod coredns-5fc5c49558-6x9sv
```



```
kubectl -n kube-system edit configmap coredns


        hosts {
                192.168.31.107 web.shilintan.com
                192.168.31.107 gateway.shilintan.com
                192.168.31.107 minio.shilintan.com
                fallthrough
        }
```



测试

```
nslookup web-ctbigdatacenter.shilintan.com 192.168.31.107
nslookup web-ctbigdatacenter.shilintan.com 192.168.31.1
nslookup web-ctbigdatacenter.cabinet.shilintan.com 192.168.0.29
ipconfig /flushdns
```

```shell

```


安卓端

```
ip: 192.168.31.10
子网掩码: 255.255.255.0
网关: 192.168.31.1
dns: 192.168.31.107
dns2: 223.5.5.5
```

