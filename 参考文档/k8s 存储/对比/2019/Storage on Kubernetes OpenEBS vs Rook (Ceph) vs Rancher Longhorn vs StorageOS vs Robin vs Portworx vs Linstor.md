[STORAGE](https://vitobotta.com/tags/storage/) • [KUBERNETES](https://vitobotta.com/tags/kubernetes/)

# [Storage on Kubernetes: OpenEBS vs Rook (Ceph) vs Rancher Longhorn vs StorageOS vs Robin vs Portworx vs Linstor](https://vitobotta.com/2019/08/06/kubernetes-storage-openebs-rook-longhorn-storageos-robin-portworx/)

![img](./Storage on Kubernetes OpenEBS vs Rook (Ceph) vs Rancher Longhorn vs StorageOS vs Robin vs Portworx vs Linstor.assets/calendar.png)

Published Tuesday, Aug 06 2019

[Jump to comments](https://vitobotta.com/2019/08/06/kubernetes-storage-openebs-rook-longhorn-storageos-robin-portworx/#commento-wrapper)



﻿﻿﻿﻿﻿**Update**! In the comments below a reader (perhaps from the company?) suggested I try [Linstor](https://www.linbit.com/en/linstor/), so I have tried it and added a section about it. I’ve also written a post on [how to install it](https://vitobotta.com/2019/08/07/linstor-storage-with-kubernetes/), since setup is quite different from that of the others.

Today I basically “gave up” on Kubernetes - at least for now - and will be using [Heroku](https://www.heroku.com/). The reason? Storage! I would never have guessed that I would spend much more time trying to sort out storage than actually learning Kubernetes. I use [Hetzner Cloud](https://hetzner.cloud/?ref=mqx6KKKwyook) (referral link, we both receive credits) as my provider since it’s very affordable and has very good performance, and have deployed my clusters with [Rancher](https://rancher.com/) since I started learning. So I haven’t tried any of the managed Kubernetes services from Google/Amazon/Microsoft/[DigitalOcean](https://m.do.co/c/775d55357dbf)﻿ (referral link, we both receive credits) or others, mainly because I wanted to learn to run K8s myself but also because of the cost.

So yeah, I’ve spent a ton of time trying to figure out which storage solution to use while defining a possible stack on top of Kubernetes. I prefer open source and not just for the price, but I also evaluated a few paid options out of curiosity because they also offer free versions of their software with some limitations. With my most recent tests I took note of some numbers I got while benchmarking the various options, so although I won’t be using Kubernetes for now, I thought these results might be of interest to others looking into storage for Kubernetes. I just wanted to mention that there is a [CSI driver](https://github.com/hetznercloud/csi-driver) that makes it possible to provision Hetzner Cloud volumes directly, but I haven’t tried it. The reason why I was looking into a cloud native software defined storage solution was that I wanted to have features like replication and the ability to quickly mount persistent volumes on any node, especially in case of node failures etc. Some of these solutions also offer point-in-time snapshots and off site backups, which is very handy.

The 7 storage solutions I have tested are:

## OpenEBS (https://openebs.io/)

Like I mentioned in a [previous post](https://vitobotta.com/2019/07/03/openebs-tips/), OpenEBS is the solution I kinda had settled with at first after testing most of the options on this list. OpenEBS is very easy to install and use, but I have to admit that I am very disappointed with performance after doing more tests with real data, under load. It’s open source, and the developers on their [Slack channel](https://openebs-community.slack.com/) have always been super helpful whenever I needed some help. Unfortunately, performance is very poor compared to that of the other options, so because of that I had started to test/evaluate again. OpenEBS offers three storage engines currently, but the benchmark results I am posting here are for cStor. I dont’t have numbers for Jiva and LocalPV in my notes at the moment.

Generally speaking, Jiva was a little faster for me while LocalPV was very fast, as fast as benchmarking the disk directly. The problem with LocalPV is a volume can only be accessible from the node it has been provisioned on, and there is no replication. I also had a few small issues when restoring a backup using [Velero](https://velero.io/) on a new cluster because the name of the nodes were different. Speaking of backups, cStor also has a [plugin for Velero](https://github.com/openebs/velero-plugin) that allows off site backups of point-in-time snapshots as opposed to file-level backups with the Velero-Restic integration. I also wrote a few [scripts](https://github.com/vitobotta/velero-openebs-backup) to manage backups and restores with this plugin more easily. Overall, I like OpenEBS a lot and I really wish the performance was better.

## Rook (https://rook.io/)

Rook is also open source and differs from the others on this list in that it’s a storage “orchestrator” which can do the heavy lifting managing storage with different backends, such as Ceph, EdgeFS and others, abstracting a lot of complexity. I had several issues with EfgeFS when I tried it several months ago so I have mostly tested with Ceph. Ceph offers more than just block storage; it offers also object storage compatible with S3/Swift and a distributed file system. What I love about Ceph is that it can spread data of a volume across multiple disks so you can have a volume actually use more disk space than the size of a single disk, which is handy. Another cool feature is that when you add more disks to the cluster, it automatically rebalances/redistributes the data across the disks.

Ceph also has snapshots but as far as I know they are not directly usable from within Rook/Kubernetes but I haven’t really investigated this. It doesn’t have off site backups though, so you need to use something with Velero/Restic which does file-level backups instead of backing up point-in-time snapshots. What is really cool about Rook is that it makes using Ceph incredibly easy hiding a lot of its complexity, while offering the tools to talk directly to Ceph for troubleshooting. Unfortunately, while stress-testing Ceph volumes I consistently ran into [this issue](https://github.com/rook/rook/issues/3132) which makes Ceph unstable. It is not clear yet whether it’s a bug in Ceph or a problem in how Rook manages Ceph. Tweaking some memory settings seems to help but does not eliminate the problem entirely. Ceph’s performance is decent, as shown in the benchmarks below. It also has a good dashboard.

## Rancher Longhorn (https://github.com/longhorn/longhorn)

I really like Longhorn and I think it’s promising. Unfortunately the developers themselves (Rancher Labs) admit that it is not production-ready, and it shows. It’s open source and performance is good (despite they haven’t yet looked into performance optimisations), but volumes often take a very long time to either attach to or mount in a pod, sometimes up to 15-16 minutes in the worst cases - especially after restoring from a big backup or upgrading a workload. It has snapshots and off site backups of those snapshots, although they only cover volumes so you still need to use something like Velero to back up the other resources. Both backups and restores are very reliable, but ridiculously slow. Really, unusable level of slow. CPU utilization/system load often gets very high when handling a moderate amount of data with Longhorn. There’s a handy dashboard that allows managing Longhorn very well. Like I said I like Longhorn a lot but it’s just not quite there yet.

## StorageOS (https://storageos.com/)

StorageOS is the first paid product on the list. It offers a developer edition that limits manageable storage to 500 GB but AFAIK doesn’t limit the number of nodes. I contacted sales, and was told that pricing starts fro $125/mo per TB if I remember correctly. It has a basic dashboard and a handy CLI, but I noticed something weird concerning performance: it seems decently fast according to some benchmarks, but then when I tried to stress-test volumes the speed didn’t look as good, so not sure about it. Because of that I didn’t spend much time with it. It doesn’t have off site backups unfortunately, so also in this case you need to use Velero with Restic to back up volumes. This is surprising for a paid product, in my opinion. I also want to add that the devs weren’t very helpful nor responsive on Slack.

## Robin (https://robin.io/)

I learnt about Robin’s existence on Reddit, when their CTO suggested I try it. Before that I hadn’t seen any mentions of it, perhaps because I was focussing my search on open source solutions, while Robin is a paid product. There’s a generous Community Edition which allows up to 10 TB of storage and 3 nodes. Overall it’s a very solid product, and I was pleased by its features. It has a very good CLI but its killer feature for me is that it can snapshot and back up entire applications (defined either as Helm releases or a “flex apps” through a selector of resources) including both volumes and other resources, so you don’t have to use Velero at all. It works great… apart from a “little” detail: if you restore (or “import” in Robin’s terms) an application in a new cluster - for example in a disaster recovery scenario - well, the restore works, but you cannot continue backing up the application. It just doesn’t work in the current release, and this was confirmed to me by the developers on Slack. I was kinda shocked by this to be honest… definitely something I wasn’t expecting considering how good the rest is (e.g. backups and restores are incredibly fast). They said they are working on fixing it for the next release. As for the performance, it’s overall very good but I noticed something very weird: if I run benchmarks directly on a volume mounted on the host, I get much better read speeds than on the same volume but from inside a pod. Every other benchmark result is identical, but in theory there shouldn’t be any difference at all. To be honest, although they are working on it I am kinda sad about the restore/backup issue, because I thought I had finally found a proper solution and was prepared to pay for it once I needed more storage or more servers.

## Portworx (https://portworx.com/)

I don’t have much to say about Portworx other than it’s a paid product and that it’s as brilliant as it is expensive. Performance is absolutely stellar! By far the best. On Slack I was told that pricing starts from $205/mo/node as seen on Google’s GKE marketplace - I don’t know if pricing is the same if purchased directly. In any case I couldn’t afford it at all for a long while, so I was very, very disappointed that the developer license (which allows up to 1 TB of storage and 3 nodes) is basically useless with Kubernetes unless you are happy with static provisioning. I was hoping the enterprise license would automatically downgrade to the developer license at the end of the trial but no, that’s not the case. You can only use the developer license with Docker directly and set up in Kubernetes is cumbersome and limited. Despite I love open source solutions, if I could afford it I would definitely use Portworx. As far as performance it’s just a world apart IMO.

## Linstor (https://www.linbit.com/en/linstor/)

I added this section after publishing the post, since a reader suggested I try Linstor as well. I did, and so far I like it! Though I need to play with it more. For now, I can say that performance looks good (I added the benchmark results below), it basically gives me identical performance to what I get from bechmarking the disk directly, showing no overhead at all (don’t ask me why Portworx can give numbers even higher than direct disk benchmarks because I have no idea - they must do some magic optimisations). So Linstor seems to be very efficient so far. Installation isn’t particularly “difficult”, but it’s not as straightforward as with the others. I had to first install Linstor (kernel module and tools/services) and configure LVM for thin provisioning/snapshots support outside of Kubernetes, directly on the host, and then create the resources required to use the storage from Kubernetes. I didn’t like that I couldn’t get it working on CentOS, so I had to use Ubuntu. Not a big deal, but a little annoying since the documentation (which otherwise is great, btw) mentions some packages that cannot be found from the suggested Epel repos. Linstor has snapshots, but not off site backups, so also in this case I would have to use Velero with Restic to back up volumes. I would prefer the ability to back up snapshots instead of file-level backups, but I can live with that if I can have performant and reliable storage. Linstor is also open source with the option of paid support, so unless I am missing something it can be used with no limits regardless of whether or not you have a support contract, but I need to check this better. I am wondering how mature Linstor is for Kubernetes but the actual storage layer lives outside Kubernetes and it seems this software has been around for a while already, so it should be battle tested. Have I found a solution that will make me change my mind about giving up on Kubernetes? LOL I don’t know, I need to play with it a little more, including replication, and see. But the first impressions are good. Sure thing is that I would really like to use my own Kubernetes clusters instead of Heroku both for freedom and for learning useful skills. Because installing Linstor is not as straightforward as with the others, I will write a post about it soon.

## The benchmarks

Unfortunately I haven’t kept much of my notes during benchmarking because it didn’t occur to me that I could write a post about it. So I only have results from basic fio benchmarks and only with single-node clusters, so I don’t have numbers for replicated setups at the moment. However the figures below can give you a rough idea of what to expect from each of the options as they were compared with exactly the same 4 cores / 16 GB of ram cloud server with an additional 100 GB disk for the volumes under test. I ran the benchmark 3 times for each solution and calculated the averages, plus I reset the server setup for each product. Again, while these tests are not “scientific” in any way, they can give you an idea of what to expect. Other tests I ran involved copying 38 GB of mixed photos/videos into and from a volume to test both reads and writes, but unfortunately I didn’t keep notes on the timings. In short: Portworkx was a lot faster.

To benchmark the volumes I used this manifest:

```yaml
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: dbench
spec:
  storageClassName: ...
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
---
apiVersion: batch/v1
kind: Job
metadata:
  name: dbench
spec:
  template:
    spec:
      containers:
      - name: dbench
        image: sotoaster/dbench:latest
        imagePullPolicy: IfNotPresent
        env:
          - name: DBENCH_MOUNTPOINT
            value: /data
          - name: FIO_SIZE
            value: 1G
        volumeMounts:
        - name: dbench-pv
          mountPath: /data
      restartPolicy: Never
      volumes:
      - name: dbench-pv
        persistentVolumeClaim:
          claimName: dbench
  backoffLimit: 4
```

So I first create a volume with the relevant storage class, then I run a job which uses fio under the hood. The 1GB setting was to get an idea of the performance with a benchmark that wouldn’t take too long to run. Here are the results:

| Product          | Random Read/Write IOPS              | Read/Write Bandwitdh               | Average Latency (usec) Read/Write | Sequential Read/Write                           | Mixed Random Read/Write IOPS       |
| ---------------- | ----------------------------------- | ---------------------------------- | --------------------------------- | ----------------------------------------------- | ---------------------------------- |
| OpenEBS (cStor)  | ***\**2475\**\***/***\**2893\*\**** | ***\**21.9MiB/s\*\**** / 52.2MiB/s | ***\**2137.88\*\****/1861.59      | ***\**6413KiB/s\*\**** / ***\**54.2MiB/s\*\**** | ***\**2786\*\****/***\**943\*\**** |
| Rook (Ceph)      | 4262/3523                           | 225MiB/s / 141MiB/s                | 1247.22/***\**2229.20\*\****      | 245MiB/s / 168MiB/s                             | 3047/1021                          |
| Rancher Longhorn | 7028/4032                           | 302MiB/s / 204MiB/s                | 1068.23/1303.46                   | 358MiB/s / 236MiB/s                             | 4826/1614                          |
| StorageOS        | 37.7k/7832                          | 443MiB/s / ***\**31.2MiB/s\*\****  | 209.55/559.49                     | 453MiB/s / 107MiB/s                             | **19.1k**/**6664**                 |
| Robin            | 7496/**32.7k**                      | 29.5MiB/s / **273MiB/s**           | 1119.50/786.46                    | 54.6MiB/s / 270MiB/s                            | 7458/2483                          |
| Portworx         | **58.1k**/18.1k                     | **1282MiB/s** / 257MiB/s           | **137.85**/**256.42**             | **1493MiB/s** / **281MiB/s**                    | 13.2k/4370                         |

I styled the best number for each metric in bold and the worst in italic.

## Conclusion

As you can see, in most cases Portworx performs better than the others. But it’s an expensive product, at least for me. I don’t know about Robin pricing but it has a generous community edition in comparison, so if you are looking for a paid product you may want to try it (hoping they fix the restore/backup issue soon). Out of the three open source options I’ve tried, OpenEBS is the one with which I have had the least issues, but performance is still very poor unfortunately. I wish I had kept more notes on more benchmark results, but I hope you find the results above and my comments on each product useful.