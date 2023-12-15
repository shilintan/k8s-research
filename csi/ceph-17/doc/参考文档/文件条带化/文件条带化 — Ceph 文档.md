# 文件条带化[](https://docs.ceph.com/en/quincy/dev/file-striping/#file-striping)

下面的文本描述了来自 Ceph 文件系统客户端的文件如何跨 RADOS 中存储的对象进行存储。

## CEPH_文件_布局[](https://docs.ceph.com/en/quincy/dev/file-striping/#ceph-file-layout)

Ceph 将给定文件的数据分布（条带化）到多个底层对象上。文件数据映射到这些对象的方式由 ceph_file_layout 结构定义。数据分布是经过修改的 RAID 0，其中数据在一组对象中条带化，最大达到（每个文件）固定大小，此时另一组对象保存文件的数据。第二组也保存不超过固定量的数据，然后使用另一组，依此类推。

定义一些术语将有助于解释文件数据在 Ceph 对象中的布局方式。

- - 文件

    连续数据的集合，从Ceph客户端的角度命名（即使用Ceph存储的Linux系统上的文件）。文件的数据被划分为固定大小的“条带单元”，这些单元存储在 ceph“对象”中。

- - 条带单元

    文件的 RAID 0 分布中使用的数据块的大小（以字节为单位）。文件的所有条带单元都具有相同的大小。最后一个条带单元通常是不完整的，即它表示文件末尾的数据以及超出该文件直至固定条带单元大小末尾的未使用“空间”。

- - 条带数

    构成文件数据的 RAID 0“条带”的连续条带单元的数量。

- - 条纹

    连续范围的文件数据，RAID 0 在固定大小的“条带单元”块中跨“条带计数”对象进行条带化。

- - 目的

    由 Ceph 存储维护的数据集合。对象用于保存部分 Ceph 客户端文件。

- - 对象集

    一组对象一起表示文件的连续部分。

ceph_file_layout 结构中的三个字段定义了此映射：

```
u32 fl_stripe_unit;
u32 fl_stripe_count;
u32 fl_object_size;
```

（它们实际上以磁盘格式 __le32 进行维护。）

从上面的定义中应该可以清楚前两个字段的作用。

第三个字段是用于备份文件数据的对象的最大大小（以字节为单位）。对象大小是条带单元的倍数。

文件的数据被分成条带单元，连续的条带单元存储在对象集中的对象上。集合中对象的数量与条带数相同。存储文件数据的对象不会超过文件指定的对象大小，因此在经过一些固定数量的完整条带后，将使用新的对象集来存储后续文件数据。

请注意，默认情况下，Ceph 使用一种简单的条带化策略，其中 object_size 等于 stripe_unit，stripe_count 为 1。这只是在每个对象中放置一个 stripe_unit。

这是一个更复杂的示例：

```
file size = 1 trillion = 1000000000000 bytes

fl_stripe_unit = 64KB = 65536 bytes
fl_stripe_count = 5 stripe units per stripe
fl_object_size = 64GB = 68719476736 bytes
```

这意味着：

```
file stripe size = 64KB * 5 = 320KB = 327680 bytes
each object holds 64GB / 64KB = 1048576 stripe units
file object set size = 64GB * 5 = 320GB = 343597383680 bytes
    (also 1048576 stripe units * 327680 bytes per stripe unit)
```

因此，文件的 1 万亿字节可以分为完整的对象集，然后是完整的条带，然后是完整的条带单元，最后是单个不完整的条带单元：

```
- 1 trillion bytes / 320GB per object set = 2 complete object sets
    (with 312805232640 bytes remaining)
- 312805232640 bytes / 320KB per stripe = 954605 complete stripes
    (with 266240 bytes remaining)
- 266240 bytes / 64KB per stripe unit = 4 complete stripe units
    (with 4096 bytes remaining)
- and the final incomplete stripe unit holds those 4096 bytes.
```

下面的 ASCII 艺术试图捕捉这一点：

```
   _________   _________   _________   _________   _________
  /object  0\ /object  1\ /object  2\ /object  3\ /object  4\
  +=========+ +=========+ +=========+ +=========+ +=========+
  |  stripe | |  stripe | |  stripe | |  stripe | |  stripe |
o |   unit  | |   unit  | |   unit  | |   unit  | |   unit  | stripe 0
b |     0   | |     1   | |     2   | |     3   | |     4   |
j |---------| |---------| |---------| |---------| |---------|
e |  stripe | |  stripe | |  stripe | |  stripe | |  stripe |
c |   unit  | |   unit  | |   unit  | |   unit  | |   unit  | stripe 1
t |     5   | |     6   | |     7   | |     8   | |     9   |
  |---------| |---------| |---------| |---------| |---------|
s |     .   | |     .   | |     .   | |     .   | |     .   |
e       .           .           .           .           .
t |     .   | |     .   | |     .   | |     .   | |     .   |
  |---------| |---------| |---------| |---------| |---------|
0 |  stripe | |  stripe | |  stripe | |  stripe | |  stripe | stripe
  |   unit  | |   unit  | |   unit  | |   unit  | |   unit  | 1048575
  | 5242875 | | 5242876 | | 5242877 | | 5242878 | | 5242879 |
  \=========/ \=========/ \=========/ \=========/ \=========/

   _________   _________   _________   _________   _________
  /object  5\ /object  6\ /object  7\ /object  8\ /object  9\
  +=========+ +=========+ +=========+ +=========+ +=========+
  |  stripe | |  stripe | |  stripe | |  stripe | |  stripe | stripe
o |   unit  | |   unit  | |   unit  | |   unit  | |   unit  | 1048576
b | 5242880 | | 5242881 | | 5242882 | | 5242883 | | 5242884 |
j |---------| |---------| |---------| |---------| |---------|
e |  stripe | |  stripe | |  stripe | |  stripe | |  stripe | stripe
c |   unit  | |   unit  | |   unit  | |   unit  | |   unit  | 1048577
t | 5242885 | | 5242886 | | 5242887 | | 5242888 | | 5242889 |
  |---------| |---------| |---------| |---------| |---------|
s |     .   | |     .   | |     .   | |     .   | |     .   |
e       .           .           .           .           .
t |     .   | |     .   | |     .   | |     .   | |     .   |
  |---------| |---------| |---------| |---------| |---------|
1 |  stripe | |  stripe | |  stripe | |  stripe | |  stripe | stripe
  |   unit  | |   unit  | |   unit  | |   unit  | |   unit  | 2097151
  | 10485755| | 10485756| | 10485757| | 10485758| | 10485759|
  \=========/ \=========/ \=========/ \=========/ \=========/

   _________   _________   _________   _________   _________
  /object 10\ /object 11\ /object 12\ /object 13\ /object 14\
  +=========+ +=========+ +=========+ +=========+ +=========+
  |  stripe | |  stripe | |  stripe | |  stripe | |  stripe | stripe
o |   unit  | |   unit  | |   unit  | |   unit  | |   unit  | 2097152
b | 10485760| | 10485761| | 10485762| | 10485763| | 10485764|
j |---------| |---------| |---------| |---------| |---------|
e |  stripe | |  stripe | |  stripe | |  stripe | |  stripe | stripe
c |   unit  | |   unit  | |   unit  | |   unit  | |   unit  | 2097153
t | 10485765| | 10485766| | 10485767| | 10485768| | 10485769|
  |---------| |---------| |---------| |---------| |---------|
s |     .   | |     .   | |     .   | |     .   | |     .   |
e       .           .           .           .           .
t |     .   | |     .   | |     .   | |     .   | |     .   |
  |---------| |---------| |---------| |---------| |---------|
2 |  stripe | |  stripe | |  stripe | |  stripe | |  stripe | stripe
  |   unit  | |   unit  | |   unit  | |   unit  | |   unit  | 3051756
  | 15258780| | 15258781| | 15258782| | 15258783| | 15258784|
  |---------| |---------| |---------| |---------| |---------|
  |  stripe | |  stripe | |  stripe | |  stripe | | (partial| (partial
  |   unit  | |   unit  | |   unit  | |   unit  | |  stripe | stripe
  | 15258785| | 15258786| | 15258787| | 15258788| |  unit)  | 3051757)
  \=========/ \=========/ \=========/ \=========/ \=========/
```