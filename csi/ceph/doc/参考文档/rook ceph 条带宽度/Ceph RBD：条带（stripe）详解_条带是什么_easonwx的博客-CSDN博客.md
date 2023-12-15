引言
条带的概念
基本概念
条带（stripe）是把连续的一段数据按照一定size切分成多个数据块，这些数据块可以存储在指定数量的磁盘中。主要有如下两个概念：

条带大小（stripe_unit）：即每个数据块的大小，如设置为1M，那么5M的数据就可以切分成5个1M的数据块。
条带宽度（stripe_num）：即连续的数据可以存储在多少个磁盘中，如设置为6，那么12M的数据就可以存储在6个磁盘中。
条带数据如何分布？
如果stripe_unit设置为1M，stripe_num设置为6，那么10M的数据是如何存储的呢？

首先将10M的数据按照stripe_unit拆分成10段，uint0-uint9，每一段数据1M。
将10段数据依次循环存放到stripe_num设置的6块盘中。
disk0	disk1	disk2	disk3	disk4	disk5
uint0（1M）	uint1（1M）	uint2（1M）	uint3（1M）	uint4（1M）	uint5（1M）
uint6（1M）	uint7（1M）	uint8（1M）	uint9（1M）		
为什么要有条带？
优势：将数据拆分写入不同的磁盘，自动实现负载均衡，防止单盘出现的性能瓶颈。
劣势：数据存储在不同的磁盘上，读取时需要进行数据的合并，stripe_unit如果设置过小，数据合并和磁盘IOPS瓶颈也会产生。
Ceph RBD如何使用条带？
Ceph RADOS层本身是无条带概念的，需要RBD进行控制。RBD将RADOS对象看作是磁盘，其他概念与前文介绍相同。如果stripe_unit设置为1M，stripe_num设置为6，每个RADOS对象可以存储4M数据，那么40M的是按照如下存储的。

radosobj0	radosobj1	radosobj2	radosobj3	radosobj4	radosobj5
uint0（1M）	uint1（1M）	uint2（1M）	uint3（1M）	uint4（1M）	uint5（1M）
uint6（1M）	uint7（1M）	uint8（1M）	uint9（1M）	uint10（1M）	uint11（1M）
uint12（1M）	uint13（1M）	uint14（1M）	uint15（1M）	uint16（1M）	uint17（1M）
uint18（1M）	uint19（1M）	uint20（1M）	uint21（1M）	uint22（1M）	uint23（1M）
radosobj6	radosobj7	radosobj8	radosobj9	radosobj10	radosobj11
uint24（1M）	uint25（1M）	uint26（1M）	uint27（1M）	uint28（1M）	uint29（1M）
uint30（1M）	uint31（1M）	uint32（1M）	uint33（1M）	uint34（1M）	uint35（1M）
uint36（1M）	uint37（1M）	uint38（1M）	uint39（1M）	-	-
-	-	-	-	-	-
条带观察实践
创建rbd image，stripe_unit为1M，stripe_count为5
创建一个stripe_unit为1M，stripe_count为5的image。

[root@111]rbd create blockpool0/vol_2 --stripe-unit 1M --stripe-count 5 --size 50M
1
查询image状态
查询image状态。

[root@111]# rbd info blockpool0/vol_2
rbd image 'vol_2':
        size 50 MiB in 15 objects
        order 22 (4 MiB objects)
        snapshot_count: 0
        id: 35ca368138143
        block_name_prefix: rbd_data.35ca368138143
        format: 2
        features: layering, striping, exclusive-lock, object-map, fast-diff, deep-flatten
        op_features: 
        flags: 
        create_timestamp: Fri Jun 24 18:54:33 2022
        access_timestamp: Fri Jun 24 18:54:33 2022
        modify_timestamp: Fri Jun 24 18:54:33 2022
        stripe unit: 1 MiB
        stripe count: 5
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
条带的元数据保存在header对象中。

[root@111]# rados listomapvals rbd_header.35ca368138143 -p blockpool0
access_timestamp
value (8 bytes) :
00000000  e9 97 b5 62 2e f5 95 18                           |...b....|
00000008

create_timestamp
value (8 bytes) :
00000000  e9 97 b5 62 2e f5 95 18                           |...b....|
00000008

features
value (8 bytes) :
00000000  3f 00 00 00 00 00 00 00                           |?.......|
00000008

modify_timestamp
value (8 bytes) :
00000000  e9 97 b5 62 2e f5 95 18                           |...b....|
00000008

object_prefix
value (26 bytes) :
00000000  16 00 00 00 72 62 64 5f  64 61 74 61 2e 33 35 63  |....rbd_data.35c|
00000010  61 33 36 38 31 33 38 31  34 33                    |a368138143|
0000001a

order
value (1 bytes) :
00000000  16                                                |.|
00000001

size
value (8 bytes) :
00000000  00 00 20 03 00 00 00 00                           |.. .....|
00000008

snap_seq
value (8 bytes) :
00000000  00 00 00 00 00 00 00 00                           |........|
00000008

stripe_count
value (8 bytes) :
00000000  05 00 00 00 00 00 00 00                           |........|
00000008

stripe_unit
value (8 bytes) :
00000000  00 00 10 00 00 00 00 00                           |........|
00000008
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
35
36
37
38
39
40
41
42
43
44
45
46
47
48
49
50
51
写入25M数据，查询对象size
查询每一个data对象，发现每一个对象写入1M数据。

[root@111]# rados -p blockpool0 ls | grep 35ca368138143
rbd_data.35ca368138143.0000000000000003
rbd_header.35ca368138143
rbd_data.35ca368138143.0000000000000006
rbd_data.35ca368138143.0000000000000005
rbd_data.35ca368138143.0000000000000000
rbd_data.35ca368138143.0000000000000001
rbd_object_map.35ca368138143
rbd_data.35ca368138143.0000000000000004
rbd_data.35ca368138143.0000000000000002
rbd_data.35ca368138143.0000000000000009
rbd_data.35ca368138143.0000000000000008
rbd_data.35ca368138143.0000000000000007

[root@111]# rados -p blockpool0 stat2 rbd_data.35ca368138143.0000000000000000
blockpool0/rbd_data.35ca368138143.0000000000000000 mtime 2022-06-24 19:44:39.951527, size 4194304
[root@111]# rados -p blockpool0 stat2 rbd_data.35ca368138143.0000000000000001
blockpool0/rbd_data.35ca368138143.0000000000000001 mtime 2022-06-24 19:44:39.976697, size 4194304
[root@111]# rados -p blockpool0 stat2 rbd_data.35ca368138143.0000000000000002
blockpool0/rbd_data.35ca368138143.0000000000000002 mtime 2022-06-24 19:44:40.001234, size 4194304
[root@111]# rados -p blockpool0 stat2 rbd_data.35ca368138143.0000000000000003
blockpool0/rbd_data.35ca368138143.0000000000000003 mtime 2022-06-24 19:44:40.024567, size 4194304
[root@111]# rados -p blockpool0 stat2 rbd_data.35ca368138143.0000000000000004
blockpool0/rbd_data.35ca368138143.0000000000000004 mtime 2022-06-24 19:44:40.047441, size 4194304
[root@111]# rados -p blockpool0 stat2 rbd_data.35ca368138143.0000000000000005
blockpool0/rbd_data.35ca368138143.0000000000000005 mtime 2022-06-24 19:44:40.074516, size 1048576
[root@111]# rados -p blockpool0 stat2 rbd_data.35ca368138143.0000000000000006
blockpool0/rbd_data.35ca368138143.0000000000000006 mtime 2022-06-24 19:44:40.099117, size 1048576
[root@111]# rados -p blockpool0 stat2 rbd_data.35ca368138143.0000000000000007
blockpool0/rbd_data.35ca368138143.0000000000000007 mtime 2022-06-24 19:44:40.126181, size 1048576
[root@111]# rados -p blockpool0 stat2 rbd_data.35ca368138143.0000000000000008
blockpool0/rbd_data.35ca368138143.0000000000000008 mtime 2022-06-24 19:44:40.149522, size 1048576
[root@111]# rados -p blockpool0 stat2 rbd_data.35ca368138143.0000000000000009
blockpool0/rbd_data.35ca368138143.0000000000000009 mtime 2022-06-24 19:44:40.175659, size 1048576
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
参考文献
https://docs.ceph.com/en/quincy/man/8/rbd/
————————————————
版权声明：本文为CSDN博主「easonwx」的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
原文链接：https://blog.csdn.net/easonwx/article/details/125451010