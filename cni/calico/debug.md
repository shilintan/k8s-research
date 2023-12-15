```shell
kubectl -n calico-apiserver get pod 
kubectl -n calico-system get pod

kubectl -n calico-apiserver logs -f --tail 300 calico-apiserver-7cd669f565-8m28f
kubectl -n calico-apiserver logs -f --tail 300 calico-apiserver-7cd669f565-hvgs5

kubectl -n calico-system logs -f --tail 300 calico-kube-controllers-85666c5b94-nbbjs
kubectl -n calico-system logs -f --tail 300 calico-node-kmdcb
kubectl -n calico-system logs -f --tail 300 calico-typha-6864b595b-zsx6n
kubectl -n calico-system logs -f --tail 300 csi-node-driver-c8lbh csi-node-driver-registrar
```

coredns这块

```shell
kubectl -n kube-system get pod
kubectl -n kube-system logs -f --tail 300 coredns-565d847f94-wr724
kubectl -n kube-system logs -f --tail 300 coredns-565d847f94-zx2lx

kubectl -n kube-system delete pod coredns-565d847f94-66nqq coredns-565d847f94-d7vd2

kubectl -n kube-system logs -f --tail 300 kube-proxy-f674m
kubectl -n kube-system delete pod kube-proxy-vtsf5
```