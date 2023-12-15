## [【ceph】ceph.conf配置文件](https://www.cnblogs.com/bandaoyu/p/16752317.html)

《ceph配置文件》[ceph配置文件_勤学-365的博客-CSDN博客_ceph配置文件](https://blog.csdn.net/qq_23929673/article/details/94147277)

《Ceph配置参数分析》[Ceph配置参数分析_for_tech的博客-CSDN博客_ceph 参数](https://blog.csdn.net/for_tech/article/details/72123223)

《ceph的ceph.conf文件配置》[ceph的ceph.conf文件配置_一束阳光penn的博客-CSDN博客_ceph.conf](https://blog.csdn.net/qq_32485197/article/details/88891957)



# 查看和临时修改配置

## 修改ceph进程的配置：（临时生效）

1、任何存储节点修改用tell

ceph tell osd.0 injectargs '--debug-osd 0/5'

ceph tell mon.* injectargs '--osd_recovery_max_active 5'

2、需要到该进程节点上面修改

ceph osd find osd.0 //查到osd.0的ip后登录到该机器完后修改

Ceph daemon osd.0 config get debug_ms //查看日志级别

Ceph daemon osd.0 config Set debug_ms 5 //修改日志级别为5

ceph daemon osd.0 config set debug_osd 0/5



## 查看ceph进程配置



1. 查看ceph默认配置：

\# ceph --show-config

2. 查看 *.id（如osd.1） 的默认配置：

如需查看osd.1，mon.node1的ceph配置

\# ceph -n osd.1 --show-config
\# ceph -n mon.node1 --show-config
或

\# ceph-osd -i 1 --show-config
\# ceph-mon -i node1--show-config
又或者：

\# cd /var/run/ceph
\# ceph --admin-daemon ceph-osd.1.asok config show
\# ceph --admin-daemon ceph-mon.node1.asok config show
该命令要求必须在 osd.1 , mon.node1节点上才能执行
这三种方法显示结果都是一样的，不过第三种方法的显示格式和一二种不同而已。

3. 查看 *.id（如osd.1）的某项默认配置中

如查看 osd.1 或 mon.node1的 osd_scrub_max_interval 设置

\# ceph -n osd.1 --show-config | grep osd_scrub_max_interval
\# ceph -n mon.node1 --show-config | grep osd_scrub_max_interval
或

\# ceph-osd -i 1 --show-config | grep osd_scrub_max_interval
\# ceph-mon -i node1--show-config | grep osd_scrub_max_interval
又或者：

\# cd /var/run/ceph
\# ceph --admin-daemon ceph-osd.1.asok config get osd_scrub_max_interval
\# ceph --admin-daemon ceph-mon.node1.asok config get osd_scrub_max_interval
同样这个命令要求必须在 osd.1 , mon.node1节点上才能执行
这三种方法显示结果都是一样的，不过第三种方法的显示格式和一二种不同而已。

4. 修改 *.id（如osd.1） 的默认配置中的某一个字段：

如修改 osd.1 或 mon.node1的 osd_scrub_max_interval为 5 分钟

\# cd /var/run/ceph
\# ceph --admin-daemon ceph-osd.1.asok config set osd_scrub_max_interval 300
\# ceph --admin-daemon ceph-mon.node1.asok config set osd_scrub_max_interval 300
同样这个命令要求必须在 osd.1 , mon.node1节点上才能执行

原文链接：https://blog.csdn.net/bandaoyu/article/details/119894927

# Ceph配置参数分析

概述
Ceph的配置参数很多，从网上也能搜索到一大批的调优参数，但这些参数为什么这么设置？设置为这样是否合理？解释的并不多

本文从当前我们的ceph.conf文件入手，解释其中的每一项配置，做为以后参数调优和新人学习的依据；

**参数详解**

0，一些自定义的参数

在ceph基础上自研开发，自己定义一些参数，然后在项目中用到。


1，一些固定配置参数

> fsid = 6d529c3d-5745-4fa5-*-*
> mon_initial_members = **, **, **
> mon_host = *.*.*.*, *.*.*.*, *.*.*.*
> 以上通常是通过ceph-deploy生成的，都是ceph monitor相关的参数，不用修改；

2，网络配置参数

> public_network = 10.10.2.0/24  默认值 ""
> cluster_network = 10.10.2.0/24 默认值 ""
> public network：monitor与osd，client与monitor，client与osd通信的网络，最好配置为带宽较高的万兆网络；
> cluster network：OSD之间通信的网络，一般配置为带宽较高的万兆网络；
> 参考： http://docs.ceph.com/docs/master/rados/configuration/network-config-ref/


3，pool size配置参数

> osd_pool_default_size = 3    默认值 3
> osd_pool_default_min_size = 1  默认值 0 // 0 means no specific default; ceph will use size-size/2
> 这两个是创建ceph pool的时候的默认size参数，一般配置为3和1，3副本能足够保证数据的可靠性；


4，认证配置参数

> 
> auth_service_required = none  默认值 "cephx"
> auth_client_required = none   默认值 "cephx, none"
> auth_cluster_required = none  默认值 "cephx"
> 以上是Ceph authentication的配置参数，默认值为开启ceph认证；
> **在内部使用的ceph集群中一般配置为none，即不使用认证，这样能适当加快ceph集群访问速度；**

5，osd down out配置参数

> mon_osd_down_out_interval = 3600  默认值 300 // seconds  ceph标记一个osd为down and out的最大时间间隔
> mon_osd_min_down_reporters = 3   默认值 2   //mon标记一个osd为down的最小reporters个数<即多少个reporter报告某osddown就判定为down？>（报告该osd为down的其他osd为reporter）
> mon_osd_report_timeout = 900    默认值 900 //mon标记一个osd为down的最长等待时间
> osd_heartbeat_interval = 10    默认值 6  //osd发送heartbeat给其他osd的间隔时间（同一PG之间的osd才会有heartbeat）
> osd_heartbeat_grace = 60      默认值 20 //osd报告其他osd为down的最大时间间隔，grace调大，也有副作用，如果某个osd异常退出，等待其他osd上报的时间必须为grace，在这段时间段内，这个osd负责的pg的io会hang住，所以尽量不要将grace调的太大。
> 基于实际情况合理配置上述参数，能减少或及时发现osd变为down（降低IO hang住的时间和概率），延长osd变为down and out的时间（防止网络抖动造成的数据recovery）；
>
> 参考：
>
> http://docs.ceph.com/docs/master/rados/configuration/mon-osd-interaction/
>
> http://blog.wjin.org/posts/ceph-osd-heartbeat.html



6，objecter配置参数

> 
> objecter_inflight_ops = 10240        默认值 1024
> objecter_inflight_op_bytes = 1048576000   默认值 100M
>
> osd client端objecter的throttle配置，它的配置会影响librbd，RGW端的性能；
>
> 配置建议：
>
> 调大这两个值



7，ceph rgw配置参数

> 
> rgw_frontends = "civetweb num_threads=500"        默认值 "fastcgi, civetweb port=7480" ，
> rgw_thread_pool_size = 200    //默认值 100,
> rgw_override_bucket_index_max_shards = 20        默认值 0
>  
> rgw_max_chunk_size = 1048576               默认值 512 * 1024
> rgw_cache_lru_size = 10000                默认值 10000 // num of entries in rgw cache
> rgw_bucket_default_quota_max_objects = *         默认值 -1 // number of objects allowed
>
> rgw_frontends：rgw的前端配置，一般配置为使用轻量级的civetweb；prot为访问rgw的端口，根据实际情况配置；num_threads为civetweb的线程数；
> rgw_thread_pool_size：rgw前端web的线程数，与rgw_frontends中的num_threads含义一致，但num_threads 优于 rgw_thread_pool_size的配置，两个只需要配置一个即可；
> rgw_override_bucket_index_max_shards：rgw bucket index object的最大shards数，增大这个值能提升bucket index object的访问时间，但也会加大bucket的ls时间；
> rgw_max_chunk_size：rgw最大chunk size，针对大文件的对象存储场景可以把这个值调大；
>
> rgw_cache_lru_size：rgw的lru cache size，对于读较多的应用场景，调大这个值能加快rgw的响应熟读；
> rgw_bucket_default_quota_max_objects：配合该参数限制一个bucket的最大objects个数；
> 参考：
>
> http://docs.ceph.com/docs/jewel/install/install-ceph-gateway/
>
> http://ceph-users.ceph.narkive.com/mdB90g7R/rgw-increase-the-first-chunk-size
>
> https://access.redhat.com/solutions/2122231



8，debug配置参数



> 日志文件（log file level）和 内存日志（memory level），可以子系统（ms、osd、rdb等）设置为统一级别，也可以分别为不同级别(用正斜杠（/）分隔它们)。如下：
>
> debug {subsystem} = {log-level}/{memory-level}
>
> \#for example
>
> \#日志文件级别 和 内存日志级别都设置成5
> debug ms = 5
>
> \#日志文件级别设置为1，内存日志级别设置为5
>
> debug ms = 1/5
>  
>
> 
> debug_lockdep = 0/0
> debug_context = 0/0
> debug_crush = 0/0
> debug_buffer = 0/0
> debug_timer = 0/0
> debug_filer = 0/0
> debug_objecter = 0/0
> debug_rados = 0/0
> debug_rbd = 0/0
> debug_journaler = 0/0
> debug_objectcatcher = 0/0
> debug_client = 0/0
> debug_osd = 0/0
> debug_optracker = 0/0
> debug_objclass = 0/0
> debug_filestore = 0/0
> debug_journal = 0/0
> debug_ms = 0/0
> debug_mon = 0/0
> debug_monc = 0/0
> debug_tp = 0/0
> debug_auth = 0/0
> debug_finisher = 0/0
> debug_heartbeatmap = 0/0
> debug_perfcounter = 0/0
> debug_asok = 0/0
> debug_throttle = 0/0
> debug_paxos = 0/0
> debug_rgw = 0/0 
>
> 关闭了所有的debug信息，能一定程度加快ceph集群速度，但也会丢失一些关键log，出问题的时候不好分析；
> 参考：
>
> http://www.10tiao.com/html/362/201609/2654062487/1.html



9，osd op配置参数

> 
> osd_enable_op_tracker = true    默认值 true
> osd_num_op_tracker_shard = 32    默认值 32
> osd_op_threads = 5         默认值 2
> osd_disk_threads = 1        默认值 1
> osd_op_num_shards = 15       默认值 5
> osd_op_num_threads_per_shard = 2  默认值 2
>
> osd_enable_op_tracker：追踪osd op状态的配置参数， 默认为true；不建议关闭 ，关 闭后osd的 slow_request，ops_in_flight，historic_ops 无法正常统计；
>
> \# ceph daemon /var/run/ceph/ceph-osd.0.asok dump_ops_in_flight
> op_tracker tracking is not enabled now, so no ops are tracked currently, even those get stuck.  Please enable "osd_enable_op_tracker", and the tracker will start to track new ops received afterwards.
> \# ceph daemon /var/run/ceph/ceph-osd.0.asok dump_historic_ops
> op_tracker tracking is not enabled now, so no ops are tracked currently, even those get stuck.  Please enable "osd_enable_op_tracker", and the tracker will start to track new ops received afterwards.
>
> 打开op tracker后，若集群iops很高， osd_num_op_tracker_shard可以适当调大，因为每个shard都有个独立的mutex锁；
> class OpTracker {
> ...
>   struct ShardedTrackingData {
>     Mutex ops_in_flight_lock_sharded;
>     xlist<TrackedOp *> ops_in_flight_sharded;
>     explicit ShardedTrackingData(string lock_name):
>       ops_in_flight_lock_sharded(lock_name.c_str()) {}
>   };
>   vector<ShardedTrackingData*> sharded_in_flight_list;
>   uint32_t num_optracker_shards;
> ...
> };
> osd_op_threads：对应的work queue有peering_wq（osd peering请求），recovery_gen_wq（PG recovery请求）；
> osd_disk_threads：对应的work queue为 remove_wq（PG remove请求）；
>  
>
> osd_op_num_shards和osd_op_num_threads_per_shard：对应的thread pool为osd_op_tp，work queue为op_shardedwq；
>
> 处理的请求包括：
>
> OpRequestRef
>
> PGSnapTrim
>
> PGScrub
>
> **调大osd_op_num_shards可以增大osd ops的处理线程数，增大并发性，提升OSD性能；**



10，osd client message配置参数

> osd_client_message_size_cap = 1048576000  默认值 500*1024L*1024L   // client data allowed in-memory (in bytes)
> osd_client_message_cap = 1000       默认值 100   // num client messages allowed in-memory
>
> 这个是osd端收到client messages的capacity配置，**配置大的话能提升osd的处理能力**，但会占用较多的系统内存；
> 配置建议：
> 服务器内存足够大的时候，适当增大这两个值


11，osd scrub配置参数

> 
> //OSD Scrub的开始结束时间，根据具体业务指定；
> osd_scrub_begin_hour = 10         默认值 0
> osd_scrub_end_hour = 5          默认值 24
>  
> // 连续两次scrubs之间的scrubbing sleeps的秒数（The time in seconds that scrubbing sleeps between two consecutive scrubs）
> osd_scrub_sleep = 1             默认值 0    // sleep between [deep]scrub ops, osd在每次执行scrub时的睡眠时间；有个bug跟这个配置有关，建议关闭； 
> osd_scrub_load_threshold = 8      默认值 0.5  //osd开启scrub的系统load阈值，根据系统的load average值配置该参数；
>  
> // chunky scrub配置的最小/最大objects数，以下是默认值
> //根据PG中object的个数配置；针对RGW全是小文件的情况，这两个值需要调大；
> osd_scrub_chunk_min = 5
> osd_scrub_chunk_max = 25
>
> Ceph osd scrub是保证ceph数据一致性的机制，scrub以PG为单位，但每次scrub回获取PG lock，所以它可能会影响PG正常的IO；
> Ceph后来引入了chunky的scrub模式，每次scrub只会选取PG的一部分objects，完成后释放PG lock，并把下一次的PG scrub加入队列；这样能很好的减少PG scrub时候占用PG lock的时间，避免过多影响PG正常的IO；
> 同理，引入的osd_scrub_sleep参数会让线程在每次scrub前释放PG lock，然后睡眠一段时间，也能很好的减少scrub对PG正常IO的影响；
> 配置建议：
>
> 参考：
>
> http://www.jianshu.com/p/ea2296e1555c
>
> http://tracker.ceph.com/issues/19497



12，osd thread timeout配置参数

> 
> osd_op_thread_timeout = 100         默认值 15
> osd_op_thread_suicide_timeout = 300     默认值 150
>  
> osd_recovery_thread_timeout = 100      默认值 30
> osd_recovery_thread_suicide_timeout = 300  默认值 300
>
> osd_op_thread_timeout和osd_op_thread_suicide_timeout关联的work queue为：
> op_shardedwq - 关联的请求为：OpRequestRef，PGSnapTrim，PGScrub
> peering_wq - 关联的请求为：osd peering
> osd_recovery_thread_timeout和osd_recovery_thread_suicide_timeout关联的work queue为：
>
> recovery_wq - 关联的请求为：PG recovery
>  
>
> Ceph的work queue都有个基类 WorkQueue_，定义如下：
>
> /// Pool of threads that share work submitted to multiple work queues.
> class ThreadPool : public md_config_obs_t {
> ...
>   /// Basic interface to a work queue used by the worker threads.
>   struct WorkQueue_ {
>     string name;
>     time_t timeout_interval, suicide_interval;
>     WorkQueue_(string n, time_t ti, time_t sti)
>       : name(n), timeout_interval(ti), suicide_interval(sti)
>     { }
> ...
>
> 这里的timeout_interval和suicide_interval分别对应上面所述的配置timeout和suicide_timeout；
> 当thread处理work queue中的一个请求时，会受到这两个timeout时间的限制：
>
> timeout_interval - 到时间后设置m_unhealthy_workers+1
> suicide_interval - 到时间后调用assert，OSD进程crush
> 对应的处理函数为：
>
> bool HeartbeatMap::_check(const heartbeat_handle_d *h, const char *who, time_t now)
> {
>   bool healthy = true;
>   time_t was;
>   was = h->timeout.read();
>   if (was && was < now) {
>     ldout(m_cct, 1) << who << " '" << h->name << "'"
>             << " had timed out after " << h->grace << dendl;
>     healthy = false;
>   }
>   was = h->suicide_timeout.read();
>   if (was && was < now) {
>     ldout(m_cct, 1) << who << " '" << h->name << "'"
>             << " had suicide timed out after " << h->suicide_grace << dendl;
>     assert(0 == "hit suicide timeout");
>   }
>   return healthy;
> }
>
> 当前仅有RGW添加了worker的perfcounter，所以也只有RGW可以通过perf dump查看total/unhealthy的worker信息：
>
> [root@ yangguanjun]# ceph daemon /var/run/ceph/ceph-client.rgw.*.asok perf dump | grep worker
>     "total_workers": 32,
>     "unhealthy_workers": 0
>
> 对应的配置项为：
>
> OPTION(rgw_num_async_rados_threads, OPT_INT, 32) // num of threads to use for async rados operations
>
> 配置建议：
> *_thread_timeout：这个值配置越小越能及时发现处理慢的请求，所以不建议配置很大；特别是针对速度快的设备，建议调小该值；
> *_thread_suicide_timeout：这个值配置小了会导致超时后的OSD crush，所以建议调大；特别是在对应的throttle调大后，更应该调大该值；
> 13，fielstore op thread配置参数
> filestore_op_threads = 5           默认值 2
> filestore_op_thread_timeout = 100      默认值 60
> filestore_op_thread_suicide_timeout = 300  默认值 180
> filestore_op_threads：对应的thread pool为op_tp，对应的work queue为op_wq；filestore的所有请求都经过op_wq处理；
> 增大该参数能提升filestore的处理能力，提升filestore的性能；配合filestore的throttle一起调整；
> filestore_op_thread_timeout和filestore_op_thread_suicide_timeout关联的work queue为：
>
> op_wq
> 配置的含义与上一节中的thread_timeout/thread_suicide_timeout保持一致；



13，filestore merge/split配置参数

> 
> filestore_merge_threshold = -1   默认值 10
> filestore_split_multiple = 10000  默认值 2
> 这两个参数是管理filestore的目录分裂/合并的，filestore的每个目录允许的最大文件数为： filestore_split_multiple * abs(filestore_merge_threshold) * 16
> 在RGW的小文件应用场景，会很容易达到默认配置的文件数（320），若在写的过程中触发了filestore的分裂，则会非常影响filestore的性能；
>  
>
> 每次filestore的目录分裂，会依据如下规则分裂为多层目录，最底层16个子目录：
>
> 例如PG 31.4C0,  hash结尾是4C0，若该目录分裂，会分裂为 DIR_0/DIR_C/DIR_4/{DIR_0, DIR_F}；
>
> 原始目录下的object会根据规则放到不同的子目录里，object的名称格式为: *__head_xxxxX4C0_*，分裂时候X是几，就放进子目录DIR_X里。比如object：*__head_xxxxA4C0_*, 就放进子目录 DIR_0/DIR_C/DIR_4/DIR_A 里；
>
> 解决办法：
>
>  1）增大merge/split配置参数的值，使单个目录容纳更多的文件；
>
> 2）filestore_merge_threshold配置为负数；这样会提前触发目录的预分裂，避免目录在某一时间段的集中分裂，详细机制没有调研；
>
> 3）创建pool时指定expected-num-objects；这样会依据目录分裂规则，在创建pool的时候就创建分裂的子目录，避免了目录分裂对filestore性能的影响；
>
> 参考：
>
> http://docs.ceph.com/docs/master/rados/configuration/filestore-config-ref/
>
> http://docs.ceph.com/docs/jewel/rados/operations/pools/#create-a-pool
>
> http://blog.csdn.net/for_tech/article/details/51251936
>
> http://ivanjobs.github.io/page3/



14，filestore fd cache配置参数

> filestore_fd_cache_shards =  32  默认值 16   // FD number of shards
> filestore_fd_cache_size = 32768  默认值 128  // FD lru size
> filestore的fd cache是加速访问filestore里的file的，在非一次性写入的应用场景，增大配置可以很明显的提升filestore的性能；

15，filestore sync配置参数

> 
> filestore_wbthrottle_enable = false  默认值 true    SSD的时候建议关闭
> filestore_min_sync_interval = 1    默认值 0.01 s   最小同步间隔秒数，sync fs的数据到disk，FileStore::sync_entry()
> filestore_max_sync_interval = 10    默认值 5 s    最大同步间隔秒数，sync fs的数据到disk，FileStore::sync_entry()
> filestore_commit_timeout = 1000    默认值 600 s   FileStore::sync_entry() 里 new SyncEntryTimeout(m_filestore_commit_timeout)
> filestore_wbthrottle_enable的配置是关于filestore writeback throttle的，即我们说的filestore处理workqueue op_wq的数据量阈值；默认值是true，开启后XFS相关的配置参数有：
> OPTION(filestore_wbthrottle_xfs_bytes_start_flusher, OPT_U64, 41943040)
> OPTION(filestore_wbthrottle_xfs_bytes_hard_limit, OPT_U64, 419430400)
> OPTION(filestore_wbthrottle_xfs_ios_start_flusher, OPT_U64, 500)
> OPTION(filestore_wbthrottle_xfs_ios_hard_limit, OPT_U64, 5000)
> OPTION(filestore_wbthrottle_xfs_inodes_start_flusher, OPT_U64, 500)
> OPTION(filestore_wbthrottle_xfs_inodes_hard_limit, OPT_U64, 5000)
>
> 
> 若使用普通HDD，可以保持其为true；针对SSD，建议将其关闭，不开启writeback throttle；
>
> filestore_min_sync_interval和filestore_max_sync_interval是配置filestore flush outstanding IO到disk的时间间隔的；增大配置可以让系统做尽可能多的IO merge，减少filestore写磁盘的压力，但也会增大page cache占用内存的开销，增大数据丢失的可能性；
>
> filestore_commit_timeout是配置filestore sync entry到disk的超时时间，在filestore压力很大时，调大这个值能尽量避免IO超时导致OSD crush；



16，filestore throttle配置参数

> 
> filestore_expected_throughput_bytes =  536870912  默认值 200MB   /// Expected filestore throughput in B/s
> filestore_expected_throughput_ops = 2000      默认值 200    /// Expected filestore throughput in ops/s
> filestore_queue_max_bytes= 1048576000        默认值 100MB
> filestore_queue_max_ops = 5000           默认值 50
>  
> /// Use above to inject delays intended to keep the op queue between low and high
> filestore_queue_low_threshhold = 0.3        默认值 0.3
> filestore_queue_high_threshhold = 0.9        默认值 0.9
>  
> filestore_queue_high_delay_multiple = 2       默认值 0   /// Filestore high delay multiple.  Defaults to 0 (disabled)
> filestore_queue_max_delay_multiple = 10       默认值 0   /// Filestore max delay multiple.  Defaults to 0 (disabled)
> 在jewel版本里，引入了dynamic throttle，来平滑普通throttle带来的长尾效应问题；
> 一般在使用普通磁盘时，之前的throttle机制即可很好的工作，所以这里默认 filestore_queue_high_delay_multiple 和 filestore_queue_max_delay_multiple 都为0；
> 针对高速磁盘，需要在部署之前，通过小工具 ceph_smalliobenchfs 来测试下，获取合适的配置参数；
>
> 
> BackoffThrottle的介绍如下：
>
> /**
> \* BackoffThrottle
> *
> \* Creates a throttle which gradually induces delays when get() is called
> \* based on params low_threshhold, high_threshhold, expected_throughput,
> \* high_multiple, and max_multiple.
> *
> \* In [0, low_threshhold), we want no delay.
> *
> \* In [low_threshhold, high_threshhold), delays should be injected based
> \* on a line from 0 at low_threshhold to
> \* high_multiple * (1/expected_throughput) at high_threshhold.
> *
> \* In [high_threshhold, 1), we want delays injected based on a line from
> \* (high_multiple * (1/expected_throughput)) at high_threshhold to
> \* (high_multiple * (1/expected_throughput)) +
> \* (max_multiple * (1/expected_throughput)) at 1.
> *
> \* Let the current throttle ratio (current/max) be r, low_threshhold be l,
> \* high_threshhold be h, high_delay (high_multiple / expected_throughput) be e,
> \* and max_delay (max_muliple / expected_throughput) be m.
> *
> \* delay = 0, r \in [0, l)
> \* delay = (r - l) * (e / (h - l)), r \in [l, h)
> \* delay = h + (r - h)((m - e)/(1 - h))
> */ 
>
> 参考：
>
> http://docs.ceph.com/docs/jewel/dev/osd_internals/osd_throttles/
> http://blog.wjin.org/posts/ceph-dynamic-throttle.html
> https://github.com/ceph/ceph/blob/master/src/doc/dynamic-throttle.txt
> Ceph BackoffThrottle分析



17，filestore finisher threads配置参数

> 
> filestore_ondisk_finisher_threads = 2 默认值 1
> filestore_apply_finisher_threads = 2  默认值 1
> 这两个参数定义filestore commit/apply的finisher处理线程数，默认都为1，任何IO commit/apply完成后，都需要经过对应的ondisk/apply finisher thread处理；
> 在使用普通HDD时，磁盘性能是瓶颈，单个finisher thread就能处理好；
>
> 但在使用高速磁盘的时候，IO完成比较快，单个finisher thread不能处理这么多的IO commit/apply reply，它会成为瓶颈；所以在jewel版本里引入了finisher thread pool的配置，这里一般配置为2即可；



18，journal配置参数 

> 
> journal_max_write_bytes=1048576000    默认值 10M   
> journal_max_write_entries=5000      默认值 100
>  
> journal_throttle_high_multiple = 2    默认值 0   /// Multiple over expected at high_threshhold. Defaults to 0 (disabled).
> journal_throttle_max_multiple = 10    默认值 0   /// Multiple over expected at max.  Defaults to 0 (disabled).
>  
> /// Target range for journal fullness
> OPTION(journal_throttle_low_threshhold, OPT_DOUBLE, 0.6)
> OPTION(journal_throttle_high_threshhold, OPT_DOUBLE, 0.9)
> journal_max_write_bytes和journal_max_write_entries 是journal一次write的数据量和entries限制；
>
> 针对SSD分区做journal的情况，这两个值要增大，这样能增大journal的吞吐量；
>
>  journal_throttle_high_multiple和journal_throttle_max_multiple是JournalThrottle的配置参数，JournalThrottle是BackoffThrottle的封装类，所以JournalThrottle与我们在filestore throttle介绍的dynamic throttle工作原理一样；
>
> int FileJournal::set_throttle_params()
> {
>   stringstream ss;
>   bool valid = throttle.set_params(
>            g_conf->journal_throttle_low_threshhold,
>            g_conf->journal_throttle_high_threshhold,
>            g_conf->filestore_expected_throughput_bytes,
>            g_conf->journal_throttle_high_multiple,
>            g_conf->journal_throttle_max_multiple,
>            header.max_size - get_top(),
>            &ss);
> ...
> }
>
> 从上述代码中看出相关的配置参数有：
>
> journal_throttle_low_threshhold
> journal_throttle_high_threshhold
> filestore_expected_throughput_bytes


19，rbd cache配置参数

> 
> [client]
> rbd_cache_size = 134217728          默认值 32M // cache size in bytes
> rbd_cache_max_dirty = 100663296       默认值 24M // dirty limit in bytes - set to 0 for write-through caching
> rbd_cache_target_dirty = 67108864      默认值 16M // target dirty limit in bytes
> rbd_cache_writethrough_until_flush = true  默认值 true // whether to make writeback caching writethrough until flush is called, to be sure the user of librbd will send flushs so that writeback is safe
> rbd_cache_max_dirty_age = 5         默认值 1.0  // seconds in cache before writeback starts
> rbd_cache_size：client端每个rbd image的cache size，不需要太大，可以调整为64M，不然会比较占client端内存；
> 参照默认值，根据rbd_cache_size的大小调整rbd_cache_max_dirty和rbd_cache_target_dirty；
> rbd_cache_max_dirty：在writeback模式下cache的最大bytes数，默认是24MB；当该值为0时，表示使用writethrough模式；
> rbd_cache_target_dirty：在writeback模式下cache向ceph集群写入的bytes阀值，默认16MB；注意该值一定要小于rbd_cache_max_dirty值
> rbd_cache_writethrough_until_flush：在内核触发flush cache到ceph集群前rbd cache一直是writethrough模式，直到flush后rbd cache变成writeback模式；
>
> rbd_cache_max_dirty_age：标记OSDC端ObjectCacher中entry在cache中的最长时间；
>
> 参考：
>
> https://my.oschina.net/linuxhunter/blog/541997
> ————————————————
> 版权声明：本文为CSDN博主「for_tech」的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
> 原文链接：https://blog.csdn.net/for_tech/article/details/72123223



# 生产环境Ceph配置参数实例



[global]
ms_async_connect_dont_route = false



> 一些固定配置参数：
>
> fsid = 2ff7e20e-3d58-4d4f-9e12-91b5b9bbd602
> mon_initial_members = rdma61, rdma63, rdma64
> mon_host = 192.169.31.51, 192.169.31.53, 192.169.31.54
>
> 以上通常是通过ceph-deploy生成的，都是ceph monitor相关的参数，不用修改；

> public_network = 192.169.31.0/24
> cluster_network = 172.17.31.0/24
>
> public network：monitor与osd，client与monitor，client与osd通信的网络，最好配置为带宽较高的万兆网络；
> cluster network：OSD之间通信的网络，一般配置为带宽较高的万兆网络；
> 参考： http://docs.ceph.com/docs/master/rados/configuration/network-config-ref/

> 
> auth_cluster_required = cephx #默认值 "cephx"
> auth_service_required = cephx #默认值 "cephx, none"
> auth_client_required = cephx  #默认值 "cephx"
>
> 以上是Ceph authentication的配置参数，默认值为开启ceph认证；
>
> 在内部使用的ceph集群中一般配置为none，即不使用认证，这样能适当加快ceph集群访问速度；


manage_network = 182.200.31.0/24   #管理网

> //bluestore相关：
> storage_type = bluestore            #存储引擎
> bluestore_block_db_size = 10737418240 #bluestore db大小
> bluestore_block_wal_size = 1073741824 #bluestore wal大小
>
> 参考：[ceph配置文件_勤学-365的博客-CSDN博客_ceph配置文件](https://blog.csdn.net/qq_23929673/article/details/94147277)


osd_objectstore = bluestore
ec_os_switch = true


ms_manage_type = async+posix
ms_public_type = async+rdma  #osd和client之间的消息交互
ms_cluster_type = async+rdma  #osd节点之间的消息交互


is_master_subcluster = True
subcluster_name = nodepool  #节点池名称


public_addr = 192.169.31.51
manage_addr = 182.200.31.51
cluster_addr = 172.17.31.51


local_is_devmgr_installed = True
local_product_type = UniStor X10536 G3
local_is_x10000 = True
ms_async_rdma_device_name = mlx5_0
ms_async_rdma_front_device_name = mlx5_0
ms_async_rdma_back_device_name = mlx5_1
ms_async_rdma_is_busy_polling = false
ms_async_rdma_resv_mem_num = 4
debug_ms = -1

[mon]
all_manage_ip = 182.200.31.51, 182.200.31.53, 182.200.31.54
all_public_ip = 192.169.31.51, 192.169.31.53, 192.169.31.54
all_cluster_ip = 172.17.31.51, 172.17.31.53, 172.17.31.54
latest_normal_mon = 182.200.31.53
master_zk_id = 2ff7e20e-3d58-4d4f-9e12-91b5b9bbd602
master_mon_manage_ip = 182.200.31.51, 182.200.31.53, 182.200.31.54
master_mon_public_ip = 192.169.31.51, 192.169.31.53, 192.169.31.54
master_mon_cluster_ip = 172.17.31.51, 172.17.31.53, 172.17.31.54

[osd]
heartbeat_file = /var/lib/ceph/osd/$cluster-$id/heartbeat
osd_crush_update_on_start = false
heartbeat_suicide_trace = true
ms_async_rdma_resv_mem_num = 52
ms_async_rdma_polling_repeat = 0
ms_async_rdma_is_busy_polling = true
ms_async_rdma_poll_timeout_ms = 500
debug_ms = 0
[mds]
ms_dispatch_throttle_bytes = 4294967296

[client]
log_file = /var/log/storage/TGT/ceph-client.$id.log
rbd_blacklist_expire_seconds = 10
objecter_tick_interval = 10
mon_client_hunt_interval = 0.5
rbd cache = false
admin_socket = $run_dir/$cluster-$id.$pid.$cctid.asok
rados_mon_op_timeout = 75
rados_osd_op_timeout = 75
client_mount_timeout = 75

[handy]
manage_ip = 182.200.31.51
master_subcluster_ip = 182.200.31.51