```
kubectl -n kube-system edit deploy coredns
修改
	replicas: 2
	->
	replicas: 1

新增:
	hostPort: 53
```



```
kubectl -n kube-system edit configmap coredns


        hosts {
                192.168.31.107 web.shilintan.com
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



安卓端

```
ip: 192.168.31.10
子网掩码: 255.255.255.0
网关: 192.168.31.1
dns: 192.168.31.107
dns2: 223.5.5.5
```

