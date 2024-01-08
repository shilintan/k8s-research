apt install -y buildah
buildah login -u "$(cat container_username)" --password-stdin < container_password "https://registry.cn-shanghai.aliyuncs.com"

buildah pull registry.cn-hangzhou.aliyuncs.com/google_containers/csi-node-driver-registrar:v2.8.0
buildah tag registry.cn-hangzhou.aliyuncs.com/google_containers/csi-node-driver-registrar:v2.8.0 registry.cn-shanghai.aliyuncs.com/shilintan-public/google_containers_csi-node-driver-registrar:v2.8.0
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/google_containers_csi-node-driver-registrar:v2.8.0
buildah rmi registry.cn-hangzhou.aliyuncs.com/google_containers/csi-node-driver-registrar:v2.8.0 registry.cn-shanghai.aliyuncs.com/shilintan-public/google_containers_csi-node-driver-registrar:v2.8.0

buildah pull openebs/lvm-driver:1.2.0
buildah tag openebs/lvm-driver:1.2.0 registry.cn-shanghai.aliyuncs.com/shilintan-public/openebs_lvm-driver:1.2.0
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/openebs_lvm-driver:1.2.0
buildah rmi openebs/lvm-driver:1.2.0 registry.cn-shanghai.aliyuncs.com/shilintan-public/openebs_lvm-driver:1.2.0

buildah pull registry.cn-hangzhou.aliyuncs.com/google_containers/csi-resizer:v1.8.0
buildah tag registry.cn-hangzhou.aliyuncs.com/google_containers/csi-resizer:v1.8.0 registry.cn-shanghai.aliyuncs.com/shilintan-public/google_containers_csi-resizer:v1.8.0
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/google_containers_csi-resizer:v1.8.0
buildah rmi registry.cn-hangzhou.aliyuncs.com/google_containers/csi-resizer:v1.8.0 registry.cn-shanghai.aliyuncs.com/shilintan-public/google_containers_csi-resizer:v1.8.0

buildah pull registry.cn-hangzhou.aliyuncs.com/google_containers/csi-snapshotter:v6.2.2
buildah tag registry.cn-hangzhou.aliyuncs.com/google_containers/csi-snapshotter:v6.2.2 registry.cn-shanghai.aliyuncs.com/shilintan-public/google_containers_csi-snapshotter:v6.2.2
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/google_containers_csi-snapshotter:v6.2.2
buildah rmi registry.cn-hangzhou.aliyuncs.com/google_containers/csi-snapshotter:v6.2.2 registry.cn-shanghai.aliyuncs.com/shilintan-public/google_containers_csi-snapshotter:v6.2.2

buildah pull registry.cn-hangzhou.aliyuncs.com/google_containers/snapshot-controller:v6.2.2
buildah tag registry.cn-hangzhou.aliyuncs.com/google_containers/snapshot-controller:v6.2.2 registry.cn-shanghai.aliyuncs.com/shilintan-public/google_containers_snapshot-controller:v6.2.2
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/google_containers_snapshot-controller:v6.2.2
buildah rmi registry.cn-hangzhou.aliyuncs.com/google_containers/snapshot-controller:v6.2.2 registry.cn-shanghai.aliyuncs.com/shilintan-public/google_containers_snapshot-controller:v6.2.2

buildah pull registry.cn-hangzhou.aliyuncs.com/google_containers/csi-provisioner:v3.5.0
buildah tag registry.cn-hangzhou.aliyuncs.com/google_containers/csi-provisioner:v3.5.0 registry.cn-shanghai.aliyuncs.com/shilintan-public/google_containers_csi-provisioner:v3.5.0
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/google_containers_csi-provisioner:v3.5.0
buildah rmi registry.cn-hangzhou.aliyuncs.com/google_containers/csi-provisioner:v3.5.0 registry.cn-shanghai.aliyuncs.com/shilintan-public/google_containers_csi-provisioner:v3.5.0

buildah pull bitnami/nginx-ingress-controller:1.9.3-debian-11-r0
buildah tag bitnami/nginx-ingress-controller:1.9.3-debian-11-r0 registry.cn-shanghai.aliyuncs.com/shilintan-public/bitnami_nginx-ingress-controller:1.9.3-debian-11-r0
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/bitnami_nginx-ingress-controller:1.9.3-debian-11-r0
buildah rmi bitnami/nginx-ingress-controller:1.9.3-debian-11-r0 registry.cn-shanghai.aliyuncs.com/shilintan-public/bitnami_nginx-ingress-controller:1.9.3-debian-11-r0

buildah pull grafana/promtail:2.8.3-amd64
buildah tag grafana/promtail:2.8.3-amd64 registry.cn-shanghai.aliyuncs.com/shilintan-public/grafana_promtail:2.8.3-amd64
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/grafana_promtail:2.8.3-amd64
buildah rmi grafana/promtail:2.8.3-amd64 registry.cn-shanghai.aliyuncs.com/shilintan-public/grafana_promtail:2.8.3-amd64

buildah pull shilintan/proxy_registry_k8s_io:sig-storage-csi-node-driver-registrar-v2.9.1
buildah tag shilintan/proxy_registry_k8s_io:sig-storage-csi-node-driver-registrar-v2.9.1 registry.cn-shanghai.aliyuncs.com/shilintan-public/sig-storage-csi-node-driver-registrar:v2.9.1
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/sig-storage-csi-node-driver-registrar:v2.9.1
buildah rmi shilintan/proxy_registry_k8s_io:sig-storage-csi-node-driver-registrar-v2.9.1 registry.cn-shanghai.aliyuncs.com/shilintan-public/sig-storage-csi-node-driver-registrar:v2.9.1

buildah pull shilintan/proxy_registry_k8s_io:sig-storage-csi-resizer-v1.9.2
buildah tag shilintan/proxy_registry_k8s_io:sig-storage-csi-resizer-v1.9.2 registry.cn-shanghai.aliyuncs.com/shilintan-public/sig-storage-csi-resizer:v1.9.2
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/sig-storage-csi-resizer:v1.9.2
buildah rmi shilintan/proxy_registry_k8s_io:sig-storage-csi-resizer-v1.9.2 registry.cn-shanghai.aliyuncs.com/shilintan-public/sig-storage-csi-resizer:v1.9.2

buildah pull shilintan/proxy_registry_k8s_io:sig-storage-csi-provisioner-v3.6.2
buildah tag shilintan/proxy_registry_k8s_io:sig-storage-csi-provisioner-v3.6.2 registry.cn-shanghai.aliyuncs.com/shilintan-public/sig-storage-csi-provisioner:v3.6.2
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/sig-storage-csi-provisioner:v3.6.2
buildah rmi shilintan/proxy_registry_k8s_io:sig-storage-csi-provisioner-v3.6.2 registry.cn-shanghai.aliyuncs.com/shilintan-public/sig-storage-csi-provisioner:v3.6.2

buildah pull shilintan/proxy_registry_k8s_io:sig-storage-csi-snapshotter-v6.3.2
buildah tag shilintan/proxy_registry_k8s_io:sig-storage-csi-snapshotter-v6.3.2 registry.cn-shanghai.aliyuncs.com/shilintan-public/sig-storage-csi-snapshotter:v6.3.2
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/sig-storage-csi-snapshotter:v6.3.2
buildah rmi shilintan/proxy_registry_k8s_io:sig-storage-csi-snapshotter-v6.3.2 registry.cn-shanghai.aliyuncs.com/shilintan-public/sig-storage-csi-snapshotter:v6.3.2

buildah pull shilintan/proxy_registry_k8s_io:sig-storage-csi-attacher-v4.4.2
buildah tag shilintan/proxy_registry_k8s_io:sig-storage-csi-attacher-v4.4.2 registry.cn-shanghai.aliyuncs.com/shilintan-public/sig-storage-csi-attacher:v4.4.2
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/sig-storage-csi-attacher:v4.4.2
buildah rmi shilintan/proxy_registry_k8s_io:sig-storage-csi-attacher-v4.4.2 registry.cn-shanghai.aliyuncs.com/shilintan-public/sig-storage-csi-attacher:v4.4.2

buildah pull quay.io/ceph/ceph:v18.2.0
buildah tag quay.io/ceph/ceph:v18.2.0 registry.cn-shanghai.aliyuncs.com/shilintan-public/quay.io_ceph_ceph:v18.2.0
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/quay.io_ceph_ceph:v18.2.0
buildah rmi quay.io/ceph/ceph:v18.2.0 registry.cn-shanghai.aliyuncs.com/shilintan-public/quay.io_ceph_ceph:v18.2.0

buildah pull quay.io/cephcsi/cephcsi:v3.10.0
buildah tag quay.io/cephcsi/cephcsi:v3.10.0 registry.cn-shanghai.aliyuncs.com/shilintan-public/quay.io_cephcsi_cephcsi:v3.10.0
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/quay.io_cephcsi_cephcsi:v3.10.0
buildah rmi quay.io/cephcsi/cephcsi:v3.10.0 registry.cn-shanghai.aliyuncs.com/shilintan-public/quay.io_cephcsi_cephcsi:v3.10.0

buildah pull rook/ceph:v1.13.0
buildah tag rook/ceph:v1.13.0 registry.cn-shanghai.aliyuncs.com/shilintan-public/rook_ceph:v1.13.0
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/rook_ceph:v1.13.0
buildah rmi rook/ceph:v1.13.0 registry.cn-shanghai.aliyuncs.com/shilintan-public/rook_ceph:v1.13.0

buildah pull minio/mc:RELEASE.2023-11-20T16-30-59Z.fips
buildah tag minio/mc:RELEASE.2023-11-20T16-30-59Z.fips registry.cn-shanghai.aliyuncs.com/shilintan-public/minio_mc:RELEASE.2023-11-20T16-30-59Z.fips
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/minio_mc:RELEASE.2023-11-20T16-30-59Z.fips
buildah rmi minio/mc:RELEASE.2023-11-20T16-30-59Z.fips registry.cn-shanghai.aliyuncs.com/shilintan-public/minio_mc:RELEASE.2023-11-20T16-30-59Z.fips

buildah pull machines/filestash:6b271d3
buildah tag machines/filestash:6b271d3 registry.cn-shanghai.aliyuncs.com/shilintan-public/machines_filestash:6b271d3
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/machines_filestash:6b271d3
buildah rmi machines/filestash:6b271d3 registry.cn-shanghai.aliyuncs.com/shilintan-public/machines_filestash:6b271d3

buildah pull quay.io/kata-containers/kata-deploy:3.2.0
buildah tag quay.io/kata-containers/kata-deploy:3.2.0 registry.cn-shanghai.aliyuncs.com/shilintan-public/quay.io_kata-containers_kata-deploy:3.2.0
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/quay.io_kata-containers_kata-deploy:3.2.0
buildah rmi quay.io/kata-containers/kata-deploy:3.2.0 registry.cn-shanghai.aliyuncs.com/shilintan-public/quay.io_kata-containers_kata-deploy:3.2.0

buildah pull quay.io/cilium/cilium:v1.14.3
buildah tag quay.io/cilium/cilium:v1.14.3 registry.cn-shanghai.aliyuncs.com/shilintan-public/quay.io_cilium_cilium:v1.14.3
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/quay.io_cilium_cilium:v1.14.3
buildah rmi quay.io/cilium/cilium:v1.14.3 registry.cn-shanghai.aliyuncs.com/shilintan-public/quay.io_cilium_cilium:v1.14.3

buildah pull quay.io/cilium/operator-generic:v1.14.3
buildah tag quay.io/cilium/operator-generic:v1.14.3 registry.cn-shanghai.aliyuncs.com/shilintan-public/quay.io_cilium_operator-generic:v1.14.3
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/quay.io_cilium_operator-generic:v1.14.3
buildah rmi quay.io/cilium/operator-generic:v1.14.3 registry.cn-shanghai.aliyuncs.com/shilintan-public/quay.io_cilium_operator-generic:v1.14.3

buildah pull mysql:8.2
buildah tag mysql:8.2 registry.cn-shanghai.aliyuncs.com/shilintan-public/mysql:8.2
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/mysql:8.2
buildah rmi mysql:8.2 registry.cn-shanghai.aliyuncs.com/shilintan-public/mysql:8.2

buildah pull mysql/mysql-router:8.0.32
buildah tag mysql/mysql-router:8.0.32 registry.cn-shanghai.aliyuncs.com/shilintan-public/mysql_mysql-router:8.0.32
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/mysql_mysql-router:8.0.32
buildah rmi mysql/mysql-router:8.0.32 registry.cn-shanghai.aliyuncs.com/shilintan-public/mysql_mysql-router:8.0.32

buildah pull mydumper/mydumper:v0.15.2-6
buildah tag mydumper/mydumper:v0.15.2-6 registry.cn-shanghai.aliyuncs.com/shilintan-public/mydumper_mydumper:v0.15.2-6
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/mydumper_mydumper:v0.15.2-6
buildah rmi mydumper/mydumper:v0.15.2-6 registry.cn-shanghai.aliyuncs.com/shilintan-public/mydumper_mydumper:v0.15.2-6

buildah pull prom/mysqld-exporter:v0.15.0
buildah tag prom/mysqld-exporter:v0.15.0 registry.cn-shanghai.aliyuncs.com/shilintan-public/prom_mysqld-exporter:v0.15.0
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/prom_mysqld-exporter:v0.15.0
buildah rmi prom/mysqld-exporter:v0.15.0 registry.cn-shanghai.aliyuncs.com/shilintan-public/prom_mysqld-exporter:v0.15.0

buildah pull phpmyadmin:5.2.1
buildah tag phpmyadmin:5.2.1 registry.cn-shanghai.aliyuncs.com/shilintan-public/phpmyadmin:5.2.1
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/phpmyadmin:5.2.1
buildah rmi phpmyadmin:5.2.1 registry.cn-shanghai.aliyuncs.com/shilintan-public/phpmyadmin:5.2.1

buildah pull nacos/nacos-server:v2.2.3
buildah tag nacos/nacos-server:v2.2.3 registry.cn-shanghai.aliyuncs.com/shilintan-public/nacos_nacos-server:v2.2.3
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/nacos_nacos-server:v2.2.3
buildah rmi nacos/nacos-server:v2.2.3 registry.cn-shanghai.aliyuncs.com/shilintan-public/nacos_nacos-server:v2.2.3

buildah pull xuxueli/xxl-job-admin:2.4.0
buildah tag xuxueli/xxl-job-admin:2.4.0 registry.cn-shanghai.aliyuncs.com/shilintan-public/xuxueli_xxl-job-admin:2.4.0
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/xuxueli_xxl-job-admin:2.4.0
buildah rmi xuxueli/xxl-job-admin:2.4.0 registry.cn-shanghai.aliyuncs.com/shilintan-public/xuxueli_xxl-job-admin:2.4.0

buildah pull bitnami/zookeeper:3.9.1-debian-11-r1
buildah tag bitnami/zookeeper:3.9.1-debian-11-r1 registry.cn-shanghai.aliyuncs.com/shilintan-public/bitnami_zookeeper:3.9.1-debian-11-r1
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/bitnami_zookeeper:3.9.1-debian-11-r1
buildah rmi bitnami/zookeeper:3.9.1-debian-11-r1 registry.cn-shanghai.aliyuncs.com/shilintan-public/bitnami_zookeeper:3.9.1-debian-11-r1

buildah pull elkozmon/zoonavigator:1.1.2
buildah tag elkozmon/zoonavigator:1.1.2 registry.cn-shanghai.aliyuncs.com/shilintan-public/elkozmon_zoonavigator:1.1.2
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/elkozmon_zoonavigator:1.1.2
buildah rmi elkozmon/zoonavigator:1.1.2 registry.cn-shanghai.aliyuncs.com/shilintan-public/elkozmon_zoonavigator:1.1.2

buildah pull busybox:1.36
buildah tag busybox:1.36 registry.cn-shanghai.aliyuncs.com/shilintan-public/busybox:1.36
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/busybox:1.36
buildah rmi busybox:1.36 registry.cn-shanghai.aliyuncs.com/shilintan-public/busybox:1.36

buildah pull elasticsearch:7.17.7
buildah tag elasticsearch:7.17.7 registry.cn-shanghai.aliyuncs.com/shilintan-public/elasticsearch:7.17.7
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/elasticsearch:7.17.7
buildah rmi elasticsearch:7.17.7 registry.cn-shanghai.aliyuncs.com/shilintan-public/elasticsearch:7.17.7

buildah pull quay.io/prometheuscommunity/elasticsearch-exporter:v1.6.0
buildah tag quay.io/prometheuscommunity/elasticsearch-exporter:v1.6.0 registry.cn-shanghai.aliyuncs.com/shilintan-public/quay.io_prometheuscommunity_elasticsearch-exporter:v1.6.0
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/quay.io_prometheuscommunity_elasticsearch-exporter:v1.6.0
buildah rmi quay.io/prometheuscommunity/elasticsearch-exporter:v1.6.0 registry.cn-shanghai.aliyuncs.com/shilintan-public/quay.io_prometheuscommunity_elasticsearch-exporter:v1.6.0

buildah pull appbaseio/dejavu:3.6.0
buildah tag appbaseio/dejavu:3.6.0 registry.cn-shanghai.aliyuncs.com/shilintan-public/appbaseio_dejavu:3.6.0
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/appbaseio_dejavu:3.6.0
buildah rmi appbaseio/dejavu:3.6.0 registry.cn-shanghai.aliyuncs.com/shilintan-public/appbaseio_dejavu:3.6.0

buildah pull kibana:7.17.7
buildah tag kibana:7.17.7 registry.cn-shanghai.aliyuncs.com/shilintan-public/kibana:7.17.7
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/kibana:7.17.7
buildah rmi kibana:7.17.7 registry.cn-shanghai.aliyuncs.com/shilintan-public/kibana:7.17.7

buildah pull docker.io/bitnami/minio:2023.11.11-debian-11-r0
buildah tag docker.io/bitnami/minio:2023.11.11-debian-11-r0 registry.cn-shanghai.aliyuncs.com/shilintan-public/docker.io_bitnami_minio:2023.11.11-debian-11-r0
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/docker.io_bitnami_minio:2023.11.11-debian-11-r0
buildah rmi docker.io/bitnami/minio:2023.11.11-debian-11-r0 registry.cn-shanghai.aliyuncs.com/shilintan-public/docker.io_bitnami_minio:2023.11.11-debian-11-r0

buildah pull bitnami/mongodb:5.0.19-debian-11-r19
buildah tag bitnami/mongodb:5.0.19-debian-11-r19 registry.cn-shanghai.aliyuncs.com/shilintan-public/bitnami_mongodb:5.0.19-debian-11-r19
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/bitnami_mongodb:5.0.19-debian-11-r19
buildah rmi bitnami/mongodb:5.0.19-debian-11-r19 registry.cn-shanghai.aliyuncs.com/shilintan-public/bitnami_mongodb:5.0.19-debian-11-r19

buildah pull bitnami/mongodb-exporter:0.39.0-debian-11-r53
buildah tag bitnami/mongodb-exporter:0.39.0-debian-11-r53 registry.cn-shanghai.aliyuncs.com/shilintan-public/bitnami_mongodb-exporter:0.39.0-debian-11-r53
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/bitnami_mongodb-exporter:0.39.0-debian-11-r53
buildah rmi bitnami/mongodb-exporter:0.39.0-debian-11-r53 registry.cn-shanghai.aliyuncs.com/shilintan-public/bitnami_mongodb-exporter:0.39.0-debian-11-r53

buildah pull mongo-express:1.0.0-20
buildah tag mongo-express:1.0.0-20 registry.cn-shanghai.aliyuncs.com/shilintan-public/mongo-express:1.0.0-20
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/mongo-express:1.0.0-20
buildah rmi mongo-express:1.0.0-20 registry.cn-shanghai.aliyuncs.com/shilintan-public/mongo-express:1.0.0-20

buildah pull bitnami/redis:7.2.2-debian-11-r0
buildah tag bitnami/redis:7.2.2-debian-11-r0 registry.cn-shanghai.aliyuncs.com/shilintan-public/bitnami_redis:7.2.2-debian-11-r0
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/bitnami_redis:7.2.2-debian-11-r0
buildah rmi bitnami/redis:7.2.2-debian-11-r0 registry.cn-shanghai.aliyuncs.com/shilintan-public/bitnami_redis:7.2.2-debian-11-r0

buildah pull bitnami/redis-sentinel:7.2.2-debian-11-r0
buildah tag bitnami/redis-sentinel:7.2.2-debian-11-r0 registry.cn-shanghai.aliyuncs.com/shilintan-public/bitnami_redis-sentinel:7.2.2-debian-11-r0
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/bitnami_redis-sentinel:7.2.2-debian-11-r0
buildah rmi bitnami/redis-sentinel:7.2.2-debian-11-r0 registry.cn-shanghai.aliyuncs.com/shilintan-public/bitnami_redis-sentinel:7.2.2-debian-11-r0

buildah pull bitnami/redis-exporter:1.55.0-debian-11-r0
buildah tag bitnami/redis-exporter:1.55.0-debian-11-r0 registry.cn-shanghai.aliyuncs.com/shilintan-public/bitnami_redis-exporter:1.55.0-debian-11-r0
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/bitnami_redis-exporter:1.55.0-debian-11-r0
buildah rmi bitnami/redis-exporter:1.55.0-debian-11-r0 registry.cn-shanghai.aliyuncs.com/shilintan-public/bitnami_redis-exporter:1.55.0-debian-11-r0

buildah pull ghcr.io/joeferner/redis-commander:0.8.1
buildah tag ghcr.io/joeferner/redis-commander:0.8.1 registry.cn-shanghai.aliyuncs.com/shilintan-public/ghcr.io_joeferner_redis-commander:0.8.1
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/ghcr.io_joeferner_redis-commander:0.8.1
buildah rmi ghcr.io/joeferner/redis-commander:0.8.1 registry.cn-shanghai.aliyuncs.com/shilintan-public/ghcr.io_joeferner_redis-commander:0.8.1

buildah pull gitlab/gitlab-ce:16.6.0-ce.0
buildah tag gitlab/gitlab-ce:16.6.0-ce.0 registry.cn-shanghai.aliyuncs.com/shilintan-public/gitlab_gitlab-ce:16.6.0-ce.0
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/gitlab_gitlab-ce:16.6.0-ce.0
buildah rmi gitlab/gitlab-ce:16.6.0-ce.0 registry.cn-shanghai.aliyuncs.com/shilintan-public/gitlab_gitlab-ce:16.6.0-ce.0

buildah pull gitlab/gitlab-runner:v16.6.0
buildah tag gitlab/gitlab-runner:v16.6.0 registry.cn-shanghai.aliyuncs.com/shilintan-public/gitlab_gitlab-runner:v16.6.0
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/gitlab_gitlab-runner:v16.6.0
buildah rmi gitlab/gitlab-runner:v16.6.0 registry.cn-shanghai.aliyuncs.com/shilintan-public/gitlab_gitlab-runner:v16.6.0

buildah pull debian:bookworm
buildah tag debian:bookworm registry.cn-shanghai.aliyuncs.com/shilintan-public/debian:bookworm
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/debian:bookworm
buildah rmi debian:bookworm registry.cn-shanghai.aliyuncs.com/shilintan-public/debian:bookworm

buildah pull maven:3.9-eclipse-temurin-8-alpine
buildah tag maven:3.9-eclipse-temurin-8-alpine registry.cn-shanghai.aliyuncs.com/shilintan-public/maven:3.9-eclipse-temurin-8-alpine
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/maven:3.9-eclipse-temurin-8-alpine
buildah rmi maven:3.9-eclipse-temurin-8-alpine registry.cn-shanghai.aliyuncs.com/shilintan-public/maven:3.9-eclipse-temurin-8-alpine

buildah pull quay.io/buildah/stable:v1.31
buildah tag quay.io/buildah/stable:v1.31 registry.cn-shanghai.aliyuncs.com/shilintan-public/quay.io_buildah_stable:v1.31
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/quay.io_buildah_stable:v1.31
buildah rmi quay.io/buildah/stable:v1.31 registry.cn-shanghai.aliyuncs.com/shilintan-public/quay.io_buildah_stable:v1.31

buildah pull bitnami/kubectl:1.25
buildah tag bitnami/kubectl:1.25 registry.cn-shanghai.aliyuncs.com/shilintan-public/bitnami_kubectl:1.25
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/bitnami_kubectl:1.25
buildah rmi bitnami/kubectl:1.25 registry.cn-shanghai.aliyuncs.com/shilintan-public/bitnami_kubectl:1.25

buildah pull node:16.20.2
buildah tag node:16.20.2 registry.cn-shanghai.aliyuncs.com/shilintan-public/node:16.20.2
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/node:16.20.2
buildah rmi node:16.20.2 registry.cn-shanghai.aliyuncs.com/shilintan-public/node:16.20.2

buildah pull docker.io/shilintan/custom-apache_skywalking-java-agent:9.0.0-java17
buildah tag docker.io/shilintan/custom-apache_skywalking-java-agent:9.0.0-java17 registry.cn-shanghai.aliyuncs.com/shilintan-public/shilintan_custom-apache_skywalking-java-agent:9.0.0-java17
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/shilintan_custom-apache_skywalking-java-agent:9.0.0-java17
buildah rmi docker.io/shilintan/custom-apache_skywalking-java-agent:9.0.0-java17 registry.cn-shanghai.aliyuncs.com/shilintan-public/shilintan_custom-apache_skywalking-java-agent:9.0.0-java17

buildah pull alpine/curl:8.4.0
buildah tag alpine/curl:8.4.0 registry.cn-shanghai.aliyuncs.com/shilintan-public/alpine/curl:8.4.0
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/alpine/curl:8.4.0
buildah rmi alpine/curl:8.4.0 registry.cn-shanghai.aliyuncs.com/shilintan-public/alpine/curl:8.4.0

buildah pull swr.cn-east-2.myhuaweicloud.com/kuboard/etcd:v3.4.14
buildah tag swr.cn-east-2.myhuaweicloud.com/kuboard/etcd:v3.4.14 registry.cn-shanghai.aliyuncs.com/shilintan-public/swr.cn-east-2.myhuaweicloud.com_kuboard_etcd:v3.4.14
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/swr.cn-east-2.myhuaweicloud.com_kuboard_etcd:v3.4.14
buildah rmi swr.cn-east-2.myhuaweicloud.com/kuboard/etcd:v3.4.14 registry.cn-shanghai.aliyuncs.com/shilintan-public/swr.cn-east-2.myhuaweicloud.com_kuboard_etcd:v3.4.14

buildah pull swr.cn-east-2.myhuaweicloud.com/kuboard/kuboard:v3
buildah tag swr.cn-east-2.myhuaweicloud.com/kuboard/kuboard:v3 registry.cn-shanghai.aliyuncs.com/shilintan-public/swr.cn-east-2.myhuaweicloud.com_kuboard_kuboard:v3
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/swr.cn-east-2.myhuaweicloud.com_kuboard_kuboard:v3
buildah rmi swr.cn-east-2.myhuaweicloud.com/kuboard/kuboard:v3 registry.cn-shanghai.aliyuncs.com/shilintan-public/swr.cn-east-2.myhuaweicloud.com_kuboard_kuboard:v3

buildah pull grafana/grafana:9.3.2
buildah tag grafana/grafana:9.3.2 registry.cn-shanghai.aliyuncs.com/shilintan-public/grafana_grafana:9.3.2
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/grafana_grafana:9.3.2
buildah rmi grafana/grafana:9.3.2 registry.cn-shanghai.aliyuncs.com/shilintan-public/grafana_grafana:9.3.2

buildah pull quay.io/prometheus/blackbox-exporter:v0.23.0
buildah tag quay.io/prometheus/blackbox-exporter:v0.23.0 registry.cn-shanghai.aliyuncs.com/shilintan-public/quay.io_prometheus_blackbox-exporter:v0.23.0
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/quay.io_prometheus_blackbox-exporter:v0.23.0
buildah rmi quay.io/prometheus/blackbox-exporter:v0.23.0 registry.cn-shanghai.aliyuncs.com/shilintan-public/quay.io_prometheus_blackbox-exporter:v0.23.0

buildah pull jimmidyson/configmap-reload:v0.5.0
buildah tag jimmidyson/configmap-reload:v0.5.0 registry.cn-shanghai.aliyuncs.com/shilintan-public/jimmidyson_configmap-reload:v0.5.0
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/jimmidyson_configmap-reload:v0.5.0
buildah rmi jimmidyson/configmap-reload:v0.5.0 registry.cn-shanghai.aliyuncs.com/shilintan-public/jimmidyson_configmap-reload:v0.5.0

buildah pull quay.io/brancz/kube-rbac-proxy:v0.14.0
buildah tag quay.io/brancz/kube-rbac-proxy:v0.14.0 registry.cn-shanghai.aliyuncs.com/shilintan-public/quay.io_brancz_kube-rbac-proxy:v0.14.0
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/quay.io_brancz_kube-rbac-proxy:v0.14.0
buildah rmi quay.io/brancz/kube-rbac-proxy:v0.14.0 registry.cn-shanghai.aliyuncs.com/shilintan-public/quay.io_brancz_kube-rbac-proxy:v0.14.0

buildah pull quay.io/prometheus/node-exporter:v1.5.0
buildah tag quay.io/prometheus/node-exporter:v1.5.0 registry.cn-shanghai.aliyuncs.com/shilintan-public/quay.io_prometheus_node-exporter:v1.5.0
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/quay.io_prometheus_node-exporter:v1.5.0
buildah rmi quay.io/prometheus/node-exporter:v1.5.0 registry.cn-shanghai.aliyuncs.com/shilintan-public/quay.io_prometheus_node-exporter:v1.5.0

buildah pull quay.io/prometheus/prometheus:v2.41.0
buildah tag quay.io/prometheus/prometheus:v2.41.0 registry.cn-shanghai.aliyuncs.com/shilintan-public/quay.io_prometheus_prometheus:v2.41.0
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/quay.io_prometheus_prometheus:v2.41.0
buildah rmi quay.io/prometheus/prometheus:v2.41.0 registry.cn-shanghai.aliyuncs.com/shilintan-public/quay.io_prometheus_prometheus:v2.41.0

buildah pull quay.io/prometheus/alertmanager:v0.25.0
buildah tag quay.io/prometheus/alertmanager:v0.25.0 registry.cn-shanghai.aliyuncs.com/shilintan-public/quay.io_prometheus_alertmanager:v0.25.0
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/quay.io_prometheus_alertmanager:v0.25.0
buildah rmi quay.io/prometheus/alertmanager:v0.25.0 registry.cn-shanghai.aliyuncs.com/shilintan-public/quay.io_prometheus_alertmanager:v0.25.0

buildah pull docker.io/shilintan/proxy_registry_k8s_io:kube-state-metrics--kube-state-metrics--v2.7.0
buildah tag docker.io/shilintan/proxy_registry_k8s_io:kube-state-metrics--kube-state-metrics--v2.7.0 registry.cn-shanghai.aliyuncs.com/shilintan-public/docker.io_shilintan_proxy_registry_k8s_io:kube-state-metrics--kube-state-metrics--v2.7.0
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/docker.io_shilintan_proxy_registry_k8s_io:kube-state-metrics--kube-state-metrics--v2.7.0
buildah rmi docker.io/shilintan/proxy_registry_k8s_io:kube-state-metrics--kube-state-metrics--v2.7.0 registry.cn-shanghai.aliyuncs.com/shilintan-public/docker.io_shilintan_proxy_registry_k8s_io:kube-state-metrics--kube-state-metrics--v2.7.0

buildah pull docker.io/shilintan/proxy_registry_k8s_io:prometheus-adapter--prometheus-adapter--v0.10.0
buildah tag docker.io/shilintan/proxy_registry_k8s_io:prometheus-adapter--prometheus-adapter--v0.10.0 registry.cn-shanghai.aliyuncs.com/shilintan-public/docker.io_shilintan_proxy_registry_k8s_io:prometheus-adapter--prometheus-adapter--v0.10.0
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/docker.io_shilintan_proxy_registry_k8s_io:prometheus-adapter--prometheus-adapter--v0.10.0
buildah rmi docker.io/shilintan/proxy_registry_k8s_io:prometheus-adapter--prometheus-adapter--v0.10.0 registry.cn-shanghai.aliyuncs.com/shilintan-public/docker.io_shilintan_proxy_registry_k8s_io:prometheus-adapter--prometheus-adapter--v0.10.0

buildah pull quay.io/prometheus-operator/prometheus-operator:v0.62.0
buildah tag quay.io/prometheus-operator/prometheus-operator:v0.62.0 registry.cn-shanghai.aliyuncs.com/shilintan-public/quay.io_prometheus-operator_prometheus-operator:v0.62.0
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/quay.io_prometheus-operator_prometheus-operator:v0.62.0
buildah rmi quay.io/prometheus-operator/prometheus-operator:v0.62.0 registry.cn-shanghai.aliyuncs.com/shilintan-public/quay.io_prometheus-operator_prometheus-operator:v0.62.0

buildah pull timonwong/prometheus-webhook-dingtalk:v2.1.0
buildah tag timonwong/prometheus-webhook-dingtalk:v2.1.0 registry.cn-shanghai.aliyuncs.com/shilintan-public/timonwong_prometheus-webhook-dingtalk:v2.1.0
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/timonwong_prometheus-webhook-dingtalk:v2.1.0
buildah rmi timonwong/prometheus-webhook-dingtalk:v2.1.0 registry.cn-shanghai.aliyuncs.com/shilintan-public/timonwong_prometheus-webhook-dingtalk:v2.1.0

buildah pull docker.io/nginxinc/nginx-unprivileged:1.25.2
buildah tag docker.io/nginxinc/nginx-unprivileged:1.25.2 registry.cn-shanghai.aliyuncs.com/shilintan-public/docker.io_nginxinc_nginx-unprivileged:1.25.2
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/docker.io_nginxinc_nginx-unprivileged:1.25.2
buildah rmi docker.io/nginxinc/nginx-unprivileged:1.25.2 registry.cn-shanghai.aliyuncs.com/shilintan-public/docker.io_nginxinc_nginx-unprivileged:1.25.2

buildah pull docker.io/grafana/loki:2.9.3-amd64
buildah tag docker.io/grafana/loki:2.9.3-amd64 registry.cn-shanghai.aliyuncs.com/shilintan-public/docker.io_grafana_loki:2.9.3-amd64
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/docker.io_grafana_loki:2.9.3-amd64
buildah rmi docker.io/grafana/loki:2.9.3-amd64 registry.cn-shanghai.aliyuncs.com/shilintan-public/docker.io_grafana_loki:2.9.3-amd64

buildah pull docker.io/grafana/promtail:2.9.3-amd64
buildah tag docker.io/grafana/promtail:2.9.3-amd64 registry.cn-shanghai.aliyuncs.com/shilintan-public/docker.io_grafana_promtail:2.9.3-amd64
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/docker.io_grafana_promtail:2.9.3-amd64
buildah rmi docker.io/grafana/promtail:2.9.3-amd64 registry.cn-shanghai.aliyuncs.com/shilintan-public/docker.io_grafana_promtail:2.9.3-amd64

buildah pull busybox:1.36
buildah tag busybox:1.36 registry.cn-shanghai.aliyuncs.com/shilintan-public/busybox:1.36
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/busybox:1.36
buildah rmi busybox:1.36 registry.cn-shanghai.aliyuncs.com/shilintan-public/busybox:1.36

buildah pull skywalking.docker.scarf.sh/apache/skywalking-ui:9.6.0-java17
buildah tag skywalking.docker.scarf.sh/apache/skywalking-ui:9.6.0-java17 registry.cn-shanghai.aliyuncs.com/shilintan-public/skywalking.docker.scarf.sh_apache_skywalking-ui:9.6.0-java17
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/skywalking.docker.scarf.sh_apache_skywalking-ui:9.6.0-java17
buildah rmi skywalking.docker.scarf.sh/apache/skywalking-ui:9.6.0-java17 registry.cn-shanghai.aliyuncs.com/shilintan-public/skywalking.docker.scarf.sh_apache_skywalking-ui:9.6.0-java17

buildah pull skywalking.docker.scarf.sh/apache/skywalking-oap-server:9.6.0-java17
buildah tag skywalking.docker.scarf.sh/apache/skywalking-oap-server:9.6.0-java17 registry.cn-shanghai.aliyuncs.com/shilintan-public/skywalking.docker.scarf.sh_apache_skywalking-oap-server:9.6.0-java17
buildah push registry.cn-shanghai.aliyuncs.com/shilintan-public/skywalking.docker.scarf.sh_apache_skywalking-oap-server:9.6.0-java17
buildah rmi skywalking.docker.scarf.sh/apache/skywalking-oap-server:9.6.0-java17 registry.cn-shanghai.aliyuncs.com/shilintan-public/skywalking.docker.scarf.sh_apache_skywalking-oap-server:9.6.0-java17

