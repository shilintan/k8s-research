```shell
kubectl create ns nginx
kubectl -n nginx apply -f loki-promtail-middleware.yaml
helm upgrade --install nginx nginx-ingress-controller/ --namespace nginx --create-namespace -f values.yaml

helm uninstall nginx --namespace nginx
```

```shell
kubectl create ns nginx
kubectl -n nginx apply -f loki-promtail-middleware.yaml
helm upgrade --install nginx-oss nginx-ingress-controller/ --namespace nginx --create-namespace -f oss/values.yaml

helm uninstall nginx-oss --namespace nginx
```

```shell
kubectl create ns nginx
kubectl -n nginx apply -f loki-promtail-middleware.yaml
helm upgrade --install nginx-service nginx-ingress-controller/ --namespace nginx --create-namespace -f service/values.yaml

helm uninstall nginx-service --namespace nginx
```

```shell
kubectl -n nginx get daemonset

kubectl -n nginx get pod -o wide
kubectl -n nginx get deploy
kubectl -n nginx get configmap
kubectl -n nginx get svc

kubectl -n nginx describe daemonset nginx-nginx-ingress-controller
kubectl -n nginx describe pod -l app.kubernetes.io/name=nginx-ingress-controller
kubectl -n nginx describe pod nginx-service-nginx-ingress-controller-dc9tf
kubectl -n nginx delete   pod nginx-nginx-ingress-controller-v4ngf nginx-nginx-ingress-controller-vfcvd nginx-nginx-ingress-controller-vr7v6
kubectl -n nginx get pods | grep nginx-nginx-ingress-controlle |awk '{print $1}'|xargs kubectl -n nginx logs -f --tail 300
kubectl -n nginx logs -f --tail 300 nginx-nginx-ingress-controller-4w877

kubectl -n nginx exec -it nginx-nginx-ingress-controller-4w877 -- bash
```

访问:
http://localhost:30080
https://localhost:30443