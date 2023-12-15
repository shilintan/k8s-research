## 比较 Kubernetes 容器网络接口 (CNI) 提供商

Kubernetes 是一个高度模块化的开源项目，在网络实施方面提供了很大的灵活性。Kubernetes 生态系统中涌现出许多项目，使容器之间的通信变得简单、一致和安全。

CNI 代表容器网络接口，是支持基于插件的功能以简化 Kubernetes 中的网络的项目之一。CNI 背后的主要目的是为管理员提供足够的控制来监控通信，同时减少手动生成网络配置的开销。

借助 CNI，通信通过集成插件进行，该插件旨在通过允许 Kubernetes 供应商实施自定义网络模型，在所有 Pod 之间提供一致且可靠的网络。

CNI 插件分配名称空间隔离、流量和 IP 过滤等功能，默认情况下 Kubernetes Kube-Net 插件不提供这些功能。假设开发人员想要实现这些高级网络功能。在这种情况下，他们必须使用带有容器网络接口 (CNI) 的 CNI 插件，以使网络的创建和管理变得更容易。

市场上有各种 CNI 插件。但在本博客中，我们将讨论最流行的开源软件，例如 Flannel、Calico、WeaveNet、Cilium 和 Canal。在我们开始列出不同的 CNI 插件之前，让我们快速概述一下 CNI。

## 什么是容器网络接口 (CNI)？

CNI 是一个网络框架，允许通过一组 Go 编写的规范和库动态配置网络资源。该插件的规范概述了一个用于配置网络、配置 IP 地址和维护多主机连接的接口。

在 Kubernetes 环境中，CNI 与 kubelet 无缝集成，以允许使用底层或覆盖网络在 Pod 之间自动进行网络配置。底层网络是在由路由器和交换机组成的网络层的物理级别上定义的。相比之下，覆盖网络使用 VxLAN 等虚拟接口来封装网络流量。

指定网络配置类型后，运行时会定义容器要加入的网络，并调用 CNI 插件将接口添加到容器命名空间中，并通过调用 IPAM（IP 地址管理）插件来分配链接的子网和路由。

除了 Kubernetes 网络之外，CNI 还支持基于 Kubernetes 的平台（例如 OpenShift），通过软件定义网络 (SDN) 方法提供跨集群的统一容器通信。

## 绒布

Flannel 由 CoreOS 开发，是 Kubernetes 可用的最成熟的开源 CNI 项目之一。Flannel 提供了一个易于使用的网络模型，可以部署该模型来覆盖基本的 Kubernetes 网络配置和管理用例。

Flannel 通过配置覆盖网络来运行，该网络将子网分配给每个 Kubernetes 集群节点以进行内部 IP 地址分配。子网租赁和管理是通过名为 flanneld 的守护进程代理完成的，该代理打包为单个二进制文件，以便在 Kubernetes 集群和发行版上轻松安装和配置。

分配 IP 地址后，Flannel 利用 Kubernetes、etcd 集群或 API 来存储主机映射和其他网络相关配置，并通过封装数据包维持主机/节点之间的通信。

默认情况下，Flannel 使用 VXLAN 配置进行封装和通信，但有多种不同类型的后端可用，例如 host-gw、UDP。使用 Flannel，还可以启用 VxLAN-GBP 进行路由，这在多个主机位于同一网络上时是必需的。

对于封装流量的加密，Flannel 默认不实现任何机制。尽管如此，它还是提供了对 IPsec 加密的支持，可以在 Kubernetes 集群的工作节点之间建立加密隧道。

Flannel 是一个很棒的 CNI 插件，适合想要从集群管理员角度开始 Kubernetes CNI 之旅的初学者。其简单的网络模型在用于控制主机之间的流量传输之前没有任何缺点。

#### 优点

- IPsec 加密支持
- 单个二进制安装和配置

#### 缺点

- 不支持网络策略
- 不要通过单个守护进程运行多个主机、多个网络，同时可以为每个主机运行多个守护进程。

## 印花布

Calico 是另一个可用于 Kubernetes 生态系统的流行开源 CNI 插件。Calico 由 Tigera 维护，适用于网络性能、灵活性和功耗等因素至关重要的环境。与 Flannel 不同，Calico 提供先进的网络管理安全功能，同时提供主机和 Pod 之间连接的整体概览。

在标准 Kubernetes 集群上，Calico 可以轻松部署为每个节点上的 DaemonSet。集群中的每个节点都将安装三个 Calico 组件：Felix、BIRD 和用于管理多个网络任务的 confd。Felix 作为 Calico 代理处理节点路由，其中 BIRD 和 confd 管理路由配置更改。

对于节点之间的数据包路由，Calico 利用 BGP 路由协议而不是覆盖网络。Overlay组网方式可以通过IP-IN-IP或VXLAN实现，可以像Overlay网络一样封装跨子网发送的报文。

Calico BGP 协议使用未封装的 IP 网络结构，无需使用封装层包装数据包，从而提高 Kubernetes 工作负载的网络性能。集群内 Pod 流量使用 Wireguard 进行加密，它创建和管理节点之间的隧道以提供安全通信。

使用 Calico，跟踪和调试比其他工具容易得多，因为没有包装器操作数据包。开发人员和管理员可以轻松了解数据包行为并使用策略管理和访问控制列表等高级网络功能。

Calico 中的网络策略实现拒绝/匹配规则，可以通过清单应用这些规则来将入口策略分配给 Pod。用户可以定义全局范围的策略并与 Istio 服务网格集成来控制 Pod 流量、提高安全性并管理 Kubernetes 工作负载。

总体而言，Calico 对于想要控制网络组件的用户来说是一个绝佳的选择。Calico 可以轻松地与不同的 Kubernetes 平台（如 kops、Kubespray）一起使用，并通过 Calico Enterprise 提供商业支持。

#### 优点

- 对网络策略的支持
- 高网络性能
- SCTP 支持

#### 缺点

- 不支持多播

### 纤毛

Cilium 是由 Linux 内核开发人员开发的开源、高度可扩展的 Kubernetes CNI 解决方案。Cilium 通过利用 eBPF 过滤技术添加高级应用程序规则来保护 Kubernetes 服务之间的网络连接。Cilium 作为守护进程“cilium-agent”部署在 Kubernetes 集群的每个节点上，用于管理操作并将网络定义转换为 eBPF 程序。

Pod 之间的通信通过覆盖网络或利用路由协议进行。案例支持 IPv4 和 IPv6 地址。覆盖网络实现利用 VXLAN 隧道进行数据包封装，而本机路由则通过未封装的 BGP 协议进行。

Cilium 可以与多个 Kubernetes 集群一起使用，并可以提供多种 CNI 功能、高水平的检查以及跨所有集群的 Pod 到 Pod 连接。

其网络和应用程序层感知管理数据包检查以及数据包正在使用的应用程序协议。

Cilium 还通过 HTTP 请求过滤器支持 Kubernetes 网络策略。策略配置可以写入 YAML 或 JSON 文件中，并提供入口和出口强制执行。管理员可以根据请求方法或路径标头接受或拒绝请求，同时将策略与 Istio 等服务网格集成。

#### 优点

- 多集群支持
- 可与其他 CNI 一起使用

#### 缺点

- 可能需要与其他 CNI 配对以实现 BGP
- 多个集群设置复杂

### 编织网

Weave Net 由 Weavescope 开发，是一个支持 CNI 的网络解决方案，允许在 Kubernetes 集群中灵活联网。WeaveNet 最初是为容器开发的，但后来演变为 Kubernetes 网络插件。Weavenet 可以作为守护进程集在 Kubernetes 集群上轻松安装和配置，在每个节点上安装必要的网络组件。

WeaveNet 的工作原理是创建一个网状覆盖网络，负责连接集群中的所有节点。网络内部。Weave Net 利用内核系统在节点之间进行数据包传输。内核利用的协议被称为快速数据路径，可将数据包直接传输到目标 Pod，而无需多次进出用户空间。

如果快速数据路径不起作用或者数据包必须传输到另一台主机。Weavenet 使用慢速套筒协议进行传输。主机名解析、负载平衡和容错等功能是通过名为 WeaveDns 的 Weavenet DNS 服务器提供的。

对于数据包封装和加密，WeaveNet 使用适用于 Kubernetes 的 VxLAN，并使用 NaCl 和 IPsec 加密来实现快速数据路径和套筒流量。

Weavenet 不使用 etcd 来存储网络配置。这些设置保存在 DaemonSet 创建的每个 pod 之间共享的数据库文件中。

在网络策略支持方面，WeaveNet 使用 weave-npc 容器来管理 Kubernetes 网络策略。该容器是默认安装和配置的，只需要网络规则来保护主机之间的通信。

#### 优点

- 内核级通信
- 网络策略和加密支持
- 为故障排除提供付费支持

#### 缺点

- 由于基于内核的路由，仅支持 Linux
- 由于默认加密标准导致网络速度降低

### 运河

Canal 是一家 CNI 提供商，结合了 Flannel 和 Calico 网络功能，为 Kubernetes 集群提供统一的网络解决方案。Canal 将 Flannel 覆盖网络层和 VXLAN 封装与 Calico 的网络组件（例如 Felix、主机代理和网络策略）集成在一起。总体而言，对于想要利用具有网络策略规则的覆盖网络模型来实现更严格安全性的组织来说，Canal 是一个不错的选择。

#### 优点

- Flannel 覆盖网络的网络策略支持
- 提供统一的方式来部署 Flannel 和 Calico

#### 缺点

- 两个项目之间没有太多的深度集成

## 汇总矩阵

|                  | 绒布       | 印花布            | 纤毛        | 维维网     | 运河       |
| ---------------- | ---------- | ----------------- | ----------- | ---------- | ---------- |
| 部署方式         | 守护进程集 | 守护进程集        | 守护进程集  | 守护进程集 | 守护进程集 |
| 封装和路由       | VxLAN      | IPinIP、BGP、eBPF | VxLAN、eBPF | VxLAN      | VxLAN      |
| 对网络策略的支持 | 不         | 是的              | 是的        | 是的       | 是的       |
| 使用的数据存储   | 等         | 等                | 等          | 不         | 等         |
| 加密             | 是的       | 是的              | 是的        | 是的       | 不         |
| 入口支持         | 不         | 是的              | 是的        | 是的       | 是的       |
| 企业支持         | 不         | 是的              | 不          | 是的       | 不         |

## 选择 CNI 提供商

没有任何一个 CNI 提供商能够满足所有项目需求。为了轻松设置和配置，Flannel 和 Weavenet 提供了强大的功能。Calico 的性能更好，因为它通过 BGP 使用底层网络。Cilium 通过 BPF 采用完全不同的应用层过滤模型，更适合企业安全。

此外，由于运营需求因项目而异，因此没有必要依赖单一提供商。使用和测试多种解决方案将满足复杂的网络需求，同时提供更可靠的网络体验。

[# Kubernetes](https://kubevious.io/blog/tag/kubernetes)[#网络](https://kubevious.io/blog/tag/networking)[＃CNI _](https://kubevious.io/blog/tag/cni)[#法兰绒](https://kubevious.io/blog/tag/flannel)[#印花布](https://kubevious.io/blog/tag/calico)[#编织网](https://kubevious.io/blog/tag/weavenet)[#纤毛](https://kubevious.io/blog/tag/cilium)[#运河](https://kubevious.io/blog/tag/canal)