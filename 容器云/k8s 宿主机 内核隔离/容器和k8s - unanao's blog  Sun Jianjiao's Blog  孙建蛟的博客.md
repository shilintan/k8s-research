# 1 容器基础

容器的核心功能，**容器的本质是进程**。就是通过为进程创建一个“边界”。对于大多数Linux而言，就是Cgroups和Namespace技术。

- Cgroups: Control Groups 的缩写，是 Linux 内核提供的一种可以限制和隔离进程组 (process groups) 所使用的物理资源 (如CPU, 内存，磁盘，网络带宽等等) 的机制。
- Namespace: 通过 namespace 可以让一些进程只能看到与自己相关的一部分资源，而另外一些进程也只能看到与它们自己相关的资源。

使用它的时候还是比较简单的，**Linux提供系统调用指定相应的参数后，就可以创建自己的命名空间了**。如PID进程空间:

```
1
int pid = clone(function, statck_size, CLONE_NEWPID | SIGCHLD, NULL)
```

在参数中指定CLONE_NEWPID参数，新创建的进程就会“看到”一个全新的进程空间，在这个进程空间里，它的PID是1。当然这只是障眼法，在宿主机里，进程的PID还是实际的数值。Linux提供了Mount, UTS, IPC, Network和User这些Namespace。

Docker容器听起来很玄幻，其实就是创建容器进程时，指定了这个进程需要启用的一组Namespace的参数。使得容器只能看到当前Namespace所限定的资源，文件，设备，状态或者配置。—— **容器只是一个特殊的进程而已**。

Docker文件系统的方式有所不一样，通过分层的方式通过结合使用Mount Namespace和rootfs，容器就能够为进程构建出一个完善的文件系统隔离环境。同时需要chroot和pivot_root这两个系统调用切换进程根目录。

一个“容器”，实际上就是一个**由Linux Namespace做隔离, Linux Cgroups做限制和rootfs作文件系统，三种技术构建出来的进程隔离环境**。

一分为二的看待：

- 一组联合挂在的/var/lib/docker/aufs/mnt上的rootfs，这部分是容器镜像。
- 一个由Namespace + Cgroups构成的隔离环境。

# 2 kubernetes

Kubernetes项目最主要的设计思想是，从更宏观的个角度，以统一的方式来定义任务之间的各种关系，并且为将来支持更多类的关系留有余地。**提供了一套基于容器构建分布式系统的基础依赖**。

# 3 Pod

Pod 是Kubernets项目的原子调度单位。 操作系统里面通过pstree可以看到，进程是以进程组的方式运行。

应用之间有着如果有着非常密切的协作关系，如果没有预先设定组的概念，运维关系就会非常难以处理。提前分组，就可以解决如果多个容器有亲密关系，需要部署在同一台服务器上的问题。如果只是设置亲和性，可能分配到第n个服务没资源了，处理起来比较麻烦。

Pod只是一个逻辑概念，Pod里的所有容器，共享的是同一个Network Namespace， 并且可以生命共享同一个Volume。并且通过创建中间容器Infra，然后其他容器Join的方式，与Infra关联在一起。

同一个Pod里面的两个容器，就可以直接通过localhost进行通信了。

容器设计模式：如果用户想在容器里面跑多个功能，并且不相关的应用时，应该**优先考虑是不是应该被描述成同一个pod里面的多个容器**。比如通过tomcat部署war包(现在都是包含tomcat的jar包了)：

- 传统的做法时将tomcat和war包打包在一起，如果要升级任何一个，都需重新打包镜像。
- 分别发布2个容器，一个tomcat容器，一个war包。放在同一个pod中。顶一个Init Container类型WAR包容器，将WAR包拷贝到/app目录下。

Pod实际上扮演的是传统基础设施里面虚拟机的角色；而容器则是虚拟机里面运行的用户程序。