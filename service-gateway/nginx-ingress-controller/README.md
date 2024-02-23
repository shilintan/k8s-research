



# 日志拓展

```
kubectl create ns nginx
kubectl -n nginx apply -f loki-promtail-middleware.yaml
```

# 部署 all

```shell
helm upgrade --install nginx nginx-ingress-controller/ --namespace nginx --create-namespace -f values.yaml

helm uninstall nginx --namespace nginx
```

# 部署 public-network

```
helm upgrade --install nginx-public-network nginx-ingress-controller/ --namespace nginx --create-namespace -f public-network/values.yaml

helm uninstall nginx-public-network --namespace nginx
```

# 部署 oss

```shell
helm upgrade --install nginx-oss nginx-ingress-controller/ --namespace nginx --create-namespace -f oss/values.yaml

helm uninstall nginx-oss --namespace nginx
```

# 部署 service

```shell
helm upgrade --install nginx-service nginx-ingress-controller/ --namespace nginx --create-namespace -f service/values.yaml

helm uninstall nginx-service --namespace nginx
```

# 调试

```
kubectl -n nginx get daemonset
kubectl -n nginx edit daemonset nginx-nginx-ingress-controller

kubectl -n nginx get pod -o wide
kubectl -n nginx get deploy
kubectl -n nginx get configmap
kubectl -n nginx get svc

kubectl -n nginx describe daemonset nginx-nginx-ingress-controller
kubectl -n nginx describe pod -l app.kubernetes.io/name=nginx-ingress-controller
kubectl -n nginx describe pod nginx-nginx-ingress-controller-g6shz
kubectl -n nginx describe pod nginx-service-nginx-ingress-controller-dc9tf
kubectl -n nginx delete   pod nginx-nginx-ingress-controller-v4ngf nginx-nginx-ingress-controller-vfcvd nginx-nginx-ingress-controller-vr7v6
kubectl -n nginx get pods | grep nginx-nginx-ingress-controlle |awk '{print $1}'|xargs kubectl -n nginx logs -f --tail 300
kubectl -n nginx logs -f --tail 300 nginx-nginx-ingress-controller-9f95r promtail
kubectl -n nginx logs -f --tail 300 nginx-service-nginx-ingress-controller-66j49 promtail
kubectl -n nginx logs -f --tail 300 nginx-service-nginx-ingress-controller-8n9wr promtail
kubectl -n nginx logs -f --tail 300 nginx-service-nginx-ingress-controller-gqm5j promtail

kubectl -n nginx exec -it nginx-nginx-ingress-controller-4w877 -- bash
```

# 访问

http://localhost:30080
https://localhost:30443





# 端口统计

all				32080	32443

oss				32081	32444

public-network	32083	32446

service			32082	32445