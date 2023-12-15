```shell
kubectl delete -f kata-deploy-stable.yaml
kubectl apply -f kata-deploy-stable.yaml
kubectl -n kube-system get pod
kubectl -n kube-system logs -f --tail 300 -l name=kata-deploy
kubectl -n kube-system describe pod -l name=kata-deploy
kubectl get RUNTIMECLASS -A
kubectl edit RUNTIMECLASS kata-clh
```

```shell
systemctl status  containerd
systemctl restart containerd
journalctl -xefu  containerd


journalctl -ft kata
```

```shell
kubectl apply -f test-kata.yaml

kubectl get pod
kubectl logs deploy/nginx-deployment-clh
kubectl exec -it nginx-deployment-clh-7f5c75c7cd-d69fv -- bash


ctr -n k8s.io c ls|wc -l && ctr -n k8s.io t ls|wc -l



kubectl delete -f test-kata.yaml
```
