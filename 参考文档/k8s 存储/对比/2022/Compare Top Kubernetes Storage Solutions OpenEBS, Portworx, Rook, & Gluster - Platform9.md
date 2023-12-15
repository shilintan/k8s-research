[Home](https://platform9.com/)>[Blog](https://platform9.com/blog)>[Compare Top Kubernetes Storage Solutions: OpenEBS, Portworx, Rook, & Gluster](https://platform9.com/blog/top-storage-solutions-for-kubernetes/)

# Compare Top Kubernetes Storage Solutions: OpenEBS, Portworx, Rook, & Gluster

[Kubernetes Storage](https://platform9.com/blog/category/kubernetes-storage/)

![img](./Compare Top Kubernetes Storage Solutions OpenEBS, Portworx, Rook, & Gluster - Platform9.assets/platform9-logo-circle-32x32.png)By[Platform9](https://platform9.com/blog/author/platform9/)

• Published on June 4, 2021 • Last updated December 6, 2022

If your organization is building out a microservice-based architecture, then you’re probably intimately familiar with Kubernetes. The ability to rapidly scale services up and down is one of Kubernetes’s top selling points; however, managing persistent storage in this highly dynamic environment can be challenging. This article will introduce you to the top four block storage vendors that you should consider for your domain: 

- [OpenEBS](https://openebs.io/)
- [Portworx](https://portworx.com/)
- [Rook](https://rook.io/)
- [Gluster](https://www.gluster.org/)

Below, we will evaluate and compare these vendors so that you will have the information you need to determine which one might be the right solution for your needs. 

## **What Should You Look for in a Kubernetes Storage Vendor?**

A core benefit of using Kubernetes is the ability to avoid vendor lock-in. All of the major public cloud providers have Kubernetes support, and it is even possible to manage clusters in a multi-cloud configuration. With that said, your storage solution should also be highly portable and support deployment on your hardware or in the cloud.

The next point may seem obvious, but it’s worth stating. Your storage solution needs to be performant and available. Ideally, it should be able to scale to meet the demands of a dynamic system, and if a node is lost or needs to be updated, it should be able to recover quickly and thoroughly.

Finally, you want a solution that can integrate seamlessly with your existing monitoring solution. The ability to observe your environment’s performance is a critical component of any successful system, and your storage solution is an integral part of that system.

### **OpenEBS**

[![img](./Compare Top Kubernetes Storage Solutions OpenEBS, Portworx, Rook, & Gluster - Platform9.assets/openebs.svg+xml)](https://openebs.io/)

OpenEBS is an easy-to-use open source storage solution, and it’s currently one of the most widely deployed Kubernetes storage solutions. OpenEBS uses a Container Attached Storage (CAS) model to create and manage volumes within your Kubernetes environment. OpenEBS manages the containerized storage controllers and replicas, ensuring that the system is available, up to date, and tuned for performance.

OpenEBS requires you to install iSCSI on your cluster. [iSCSI](https://kubernetes.io/docs/concepts/storage/volumes/#iscsi) (or SCSI over IP) is modeled after the original SCSI standard and allows you to attach a volume to a single consumer or pod. OpenEBS can support several different storage engines:

- **OpenEBS Mayastor** – Supports low latency, high availability, synchronous replication, snapshots, clones, and thin provisioning.
- **OpenEBS cStor** – Supports high availability, synchronous replication, snapshots, clones, and thin provisioning.
- **OpenEBS Jiva** – Supports high availability, synchronous replication, and thin provisioning.
- **Dynamic Local PV** – Supports low latency and Local PV.

Users can access OpenEBS support and get recommendations about which storage engine can best support their use case from the [#openebs](https://kubernetes.slack.com/messages/openebs/) channel of the Kubernetes Slack community. Users report it to be very responsive.

### **PortWorx**

[![img](./Compare Top Kubernetes Storage Solutions OpenEBS, Portworx, Rook, & Gluster - Platform9.assets/portworx-by-ps-logo_full-color-300x109.png)](https://portworx.com/)

PortWorx may be the most mature and well-supported storage solution currently available. Like OpenEBS, PortWorx uses the CAS model, but unlike OpenEBS, PortWorx is a closed-source, proprietary solution. 

With commercial backing and the recent acquisition of PortWorx by PureStore, PortWorx is the storage solution of choice for many of the world’s largest organizations that use Kubernetes for production workloads. They offer a three-node trial as well as configuration tools that enhance your ability to configure, deploy, and start using their storage solution quickly.

PortWorx designed their storage solution on Kubernetes for Kubernetes. It supports applications that require a rigorous, scalable, and distributed solution. You can learn more about PortWorx and what makes it a unique solution [here](https://portworx.com/makes-portworx-unique/).

### **Rook**

[![img](./Compare Top Kubernetes Storage Solutions OpenEBS, Portworx, Rook, & Gluster - Platform9.assets/rook-horizontal-color.svg+xml)](https://rook.io/)

A product of the Cloud Native Computing Foundation ([CNCF](https://www.cncf.io/projects/)), Rook is a community-driven endeavor that manages file, block, and object storage. Users can select from several different storage providers, depending on the needs of their applications. Rook provides users with a platform, a framework, and user support.

Ceph Rook is the most stable version available for use and provides a highly-scalable distributed storage solution. There are different versions of Rook (currently being developed) that can also support the following providers:

- CockroachDB
- Cassandra
- NFS
- YugabyteDB

Rook provides comprehensive [documentation](https://rook.io/docs/rook/v1.5/), including [Quickstart ](https://rook.io/docs/rook/v1.5/quickstart.html)guides for each of these storage providers, and you can ask questions in their [Slack channel](https://rook-io.slack.com/) if you get stuck.

### **Gluster**

[![img](./Compare Top Kubernetes Storage Solutions OpenEBS, Portworx, Rook, & Gluster - Platform9.assets/gluster-ant-150x150.png)](https://www.gluster.org/)

GlusterFS, along with Ceph, is one of the traditional storage solutions that was backed by [RedHat](https://www.redhat.com/en/technologies/storage/gluster). As with other RedHat projects, you have the option to use either an open source community version or a supported commercial version.

Gluster can aggregate data storage from a variety of sources into a scalable and distributed file system. [Heketi](https://github.com/heketi/heketi#heketi) is a RESTful volume management interface that helps automate volume provisioning from Kubernetes, thus saving you the overhead of manually creating and mapping Gluster volumes to your Kubernetes persistent volumes.

Unlike the aforementioned solutions, all of which were developed with Kubernetes in mind, Gluster is not so much a Kubernetes storage solution as it is a storage solution that you can use with Kubernetes. The Heketi project, which supports Kubernetes integration, has been in maintenance for more than a year, and it is only updated when users encounter significant bugs.

If you’d like to learn more about Gluster and experiment with their storage solutions, you can access a [Quick Start Guide](https://docs.gluster.org/en/latest/Quick-Start-Guide/Quickstart/) in their [documentation](https://docs.gluster.org/en/latest/).

### **Which Solution Is Best?**

As with any recommendation, your organization needs to consider a multitude of factors before making the final decision. You need to think about the workload you’re planning to run and the current and future infrastructure that will support it. You should try different solutions and see which one integrates best with your applications and your development team. Finally, you want to make sure that you select the storage vendor that best meets your needs while providing an active and responsive support system, whether that support is from the open source community or an experienced vendor.

|                               | **OpenEBS**                                                  | **PortWorx**                                                 | **Rook**                                      | **Gluster**               |
| ----------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ | --------------------------------------------- | ------------------------- |
| **License**                   | Open source                                                  | Commercial                                                   | Open source                                   | Open source / Commercial  |
| **Support**                   | [Slack Community](https://kubernetes.slack.com/messages/openebs/) | [Forum](https://forums.portworx.com/)[Slack](https://portworx.slack.com/)Support Portal | [Slack Community](https://rook-io.slack.com/) | RedHat Commercial Support |
| **Active Development**        | Yes                                                          | Yes                                                          | Yes                                           | Maintenance               |
| **Supported Storage Engines** | MayastorcStorJivaLocal PV                                    |                                                              | CephCockroachDBCassandraNFSYugabyteDB         |                           |