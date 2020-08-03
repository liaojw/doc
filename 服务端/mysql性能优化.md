# mysql性能优化-慢查询分析、优化索引和配置
## 一、 优化概述
![](http://www.oicto.com/wp-content/uploads/2012/03/1.png)
MySQL数据库是常见的两个瓶颈是CPU和I/O的瓶颈，CPU在饱和的时候一般发生在数据装入内存或从磁盘上读取数据时候。磁盘I/O瓶颈发生在装入数据远大于内存容量的时候，如果应用分布在网络上，那么查询量相当大的时候那么平瓶颈就会出现在网络上，我们可以用mpstat, iostat, sar和vmstat来查看系统的性能状态。

除了服务器硬件的性能瓶颈，对于MySQL系统本身，我们可以使用工具来优化数据库的性能，通常有三种：使用索引，使用EXPLAIN分析查询以及调整MySQL的内部配置。
## 二、查询与索引优化分析
在优化MySQL时，通常需要对数据库进行分析，常见的分析手段有慢查询日志，EXPLAIN 分析查询，profiling分析以及show命令查询系统状态及系统变量，通过定位分析性能的瓶颈，才能更好的优化数据库系统的性能。
### Show命令
我们可以通过show命令查看MySQL状态及变量，找到系统的瓶颈：

```
Mysql> show status ——显示状态信息（扩展show status like ‘XXX’）

Mysql> show variables ——显示系统变量（扩展show variables like ‘XXX’）

Mysql> show innodb status ——显示InnoDB存储引擎的状态

Mysql> show processlist ——查看当前SQL执行，包括执行状态、是否锁表等

Shell> mysqladmin variables -u username -p password——显示系统变量

Shell> mysqladmin extended-status -u username -p password——显示状态信息
```

查看状态变量及帮助：

```
Shell> mysqld –verbose –help [|more #逐行显示]
```

### 慢查询日志
#### 慢查询日志开启：

```
在配置文件my.cnf或my.ini中在[mysqld]一行下面加入两个配置参数

log-slow-queries=/data/mysqldata/slow-query.log           

long_query_time=2                                                                 

注：log-slow-queries参数为慢查询日志存放的位置，一般这个目录要有mysql的运行帐号的可写权限，一般都将这个目录设置为mysql的数据存放目录；

long_query_time=2中的2表示查询超过两秒才记录；

在my.cnf或者my.ini中添加log-queries-not-using-indexes参数，表示记录下没有使用索引的查询。

log-slow-queries=/data/mysqldata/slow-query.log           

long_query_time=10                                                               

log-queries-not-using-indexes   
```
#### 慢查询日志开启方法二：
我们可以通过命令行设置变量来即时启动慢日志查询。由下图可知慢日志没有打开，slow_launch_time=# 表示如果建立线程花费了比这个值更长的时间,slow_launch_threads 计数器将增加
![](http://www.oicto.com/wp-content/uploads/2012/03/2.png)
设置慢日志开启
![](http://www.oicto.com/wp-content/uploads/2012/03/3.png)
MySQL后可以查询long_query_time 的值 。
![](http://www.oicto.com/wp-content/uploads/2012/03/4.png)
为了方便测试，可以将修改慢查询时间为5秒。
![](http://www.oicto.com/wp-content/uploads/2012/03/5.png)
#### 慢查询分析mysqldumpslow
我们可以通过打开log文件查看得知哪些SQL执行效率低下

```
[root@localhost mysql]# more slow-query.log                            

# Time: 081026 19:46:34                                                                          

# User@Host: root[root] @ localhost []                                                           

# Query_time: 11 Lock_time: 0 Rows_sent: 1 Rows_examined: 6552961        

select count(*) from t_user;      
```
从日志中，可以发现查询时间超过5 秒的SQL，而小于5秒的没有出现在此日志中。

如果慢查询日志中记录内容很多，可以使用mysqldumpslow工具（MySQL客户端安装自带）来对慢查询日志进行分类汇总。mysqldumpslow对日志文件进行了分类汇总，显示汇总后摘要结果。

进入log的存放目录，运行

```
[root@mysql_data]#mysqldumpslow  slow-query.log                                 

Reading mysql slow query log from slow-query.log                            

Count: 2 Time=11.00s (22s) Lock=0.00s (0s) Rows=1.0 (2), root[root]@mysql    

select count(N) from t_user;                                                

mysqldumpslow命令

/path/mysqldumpslow -s c -t 10 /database/mysql/slow-query.log    
```

这会输出记录次数最多的10条SQL语句，其中：

-s, 是表示按照何种方式排序，c、t、l、r分别是按照记录次数、时间、查询时间、返回的记录数来排序，ac、at、al、ar，表示相应的倒叙；

-t, 是top n的意思，即为返回前面多少条的数据；

-g, 后边可以写一个正则匹配模式，大小写不敏感的；

例如：

```
/path/mysqldumpslow -s r -t 10 /database/mysql/slow-log   
```

得到返回记录集最多的10个查询。

```
/path/mysqldumpslow -s t -t 10 -g “left join” /database/mysql/slow-log  
```

得到按照时间排序的前10条里面含有左连接的查询语句。

使用mysqldumpslow命令可以非常明确的得到各种我们需要的查询语句，对MySQL查询语句的监控、分析、优化是MySQL优化非常重要的一步。开启慢查询日志后，由于日志记录操作，在一定程度上会占用CPU资源影响mysql的性能，但是可以阶段性开启来定位性能瓶颈。
###explain分析查询
使用 EXPLAIN 关键字可以模拟优化器执行SQL查询语句，从而知道MySQL是如何处理你的SQL语句的。这可以帮你分析你的查询语句或是表结构的性能瓶颈。通过explain命令可以得到:

– 表的读取顺序

– 数据读取操作的操作类型

– 哪些索引可以使用

– 哪些索引被实际使用

– 表之间的引用

– 每张表有多少行被优化器查询
![](http://www.oicto.com/wp-content/uploads/2012/03/6.png)
EXPLAIN字段：

ØTable：显示这一行的数据是关于哪张表的

Øpossible_keys：显示可能应用在这张表中的索引。如果为空，没有可能的索引。可以为相关的域从WHERE语句中选择一个合适的语句

Økey：实际使用的索引。如果为NULL，则没有使用索引。MYSQL很少会选择优化不足的索引，此时可以在SELECT语句中使用USE INDEX（index）来强制使用一个索引或者用IGNORE INDEX（index）来强制忽略索引

Økey_len：使用的索引的长度。在不损失精确性的情况下，长度越短越好

Øref：显示索引的哪一列被使用了，如果可能的话，是一个常数

Ørows：MySQL认为必须检索的用来返回请求数据的行数

Øtype：这是最重要的字段之一，显示查询使用了何种类型。从最好到最差的连接类型为system、const、eq_reg、ref、range、index和ALL

nsystem、const：可以将查询的变量转为常量.  如id=1; id为 主键或唯一键.

neq_ref：访问索引,返回某单一行的数据.(通常在联接时出现，查询使用的索引为主键或惟一键)

nref：访问索引,返回某个值的数据.(可以返回多行) 通常使用=时发生

nrange：这个连接类型使用索引返回一个范围中的行，比如使用>或<查找东西，并且该字段上建有索引时发生的情况(注:不一定好于index)

nindex：以索引的顺序进行全表扫描，优点是不用排序,缺点是还要全表扫描

nALL：全表扫描，应该尽量避免

ØExtra：关于MYSQL如何解析查询的额外信息，主要有以下几种

nusing index：只用到索引,可以避免访问表. 

nusing where：使用到where来过虑数据. 不是所有的where clause都要显示using where. 如以=方式访问索引.

nusing tmporary：用到临时表

nusing filesort：用到额外的排序. (当使用order by v1,而没用到索引时,就会使用额外的排序)

nrange checked for eache record(index map:N)：没有好的索引.
![](http://www.oicto.com/wp-content/uploads/2012/03/7.png)
### profiling分析查询
通过慢日志查询可以知道哪些SQL语句执行效率低下，通过explain我们可以得知SQL语句的具体执行情况，索引使用等，还可以结合show命令查看执行状态。

如果觉得explain的信息不够详细，可以同通过profiling命令得到更准确的SQL执行消耗系统资源的信息。

profiling默认是关闭的。可以通过以下语句查看
![](http://www.oicto.com/wp-content/uploads/2012/03/11.png)
打开功能： mysql>set profiling=1; 执行需要测试的sql 语句：
![](http://www.oicto.com/wp-content/uploads/2012/03/12.png)
mysql> show profiles\G; 可以得到被执行的SQL语句的时间和ID

mysql>show profile for query 1; 得到对应SQL语句执行的详细信息

Show Profile命令格式：

SHOW PROFILE [type [, type] … ]                                    

    [FOR QUERY n]                                                            
    
    [LIMIT row_count [OFFSET offset]]                             

type:                                                                                  

    ALL                                                                               

  | BLOCK IO                                                                      

  | CONTEXT SWITCHES                                                   

  | CPU                                                                              

  | IPC                                                                                

  | MEMORY                                                                            

  | PAGE FAULTS                                                               

  | SOURCE                                                                        

  | SWAPS

以上的16rows是针对非常简单的select语句的资源信息，对于较复杂的SQL语句，会有更多的行和字段，比如converting HEAP to MyISAM 、Copying to tmp table等等，由于以上的SQL语句不存在复杂的表操作，所以未显示这些字段。通过profiling资源耗费信息，我们可以采取针对性的优化措施。
### 索引及查询优化
#### 索引的类型
Ø 普通索引：这是最基本的索引类型，没唯一性之类的限制。

Ø 唯一性索引：和普通索引基本相同，但所有的索引列值保持唯一性。

Ø 主键：主键是一种唯一索引，但必须指定为&rdquoRIMARY KEY”。

Ø 全文索引：MYSQL从3.23.23开始支持全文索引和全文检索。在MYSQL中，全文索引的索引类型为FULLTEXT。全文索引可以在VARCHAR或者TEXT类型的列上创建。

大多数MySQL索引(PRIMARY KEY、UNIQUE、INDEX和FULLTEXT)使用B树中存储。空间列类型的索引使用R-树，MEMORY表支持hash索引。
#### 单列索引和多列索引（复合索引）
索引可以是单列索引，也可以是多列索引。对相关的列使用索引是提高SELECT操作性能的最佳途径之一。
#### 多列索引：
MySQL可以为多个列创建索引。一个索引可以包括15个列。对于某些列类型，可以索引列的左前缀，列的顺序非常重要。

多列索引可以视为包含通过连接索引列的值而创建的值的排序的数组。一般来说，即使是限制最严格的单列索引，它的限制能力也远远低于多列索引。
#### 最左前缀
多列索引有一个特点，即最左前缀（Leftmost Prefixing）。假如有一个多列索引为key(firstname lastname age)，当搜索条件是以下各种列的组合和顺序时，MySQL将使用该多列索引：

firstname，lastname，age

firstname，lastname

firstname

也就是说，相当于还建立了key(firstname lastname)和key(firstname)。

索引主要用于下面的操作：

Ø 快速找出匹配一个WHERE子句的行。

Ø 删除行。当执行联接时，从其它表检索行。

Ø 对具体有索引的列key_col找出MAX()或MIN()值。由预处理器进行优化，检查是否对索引中在key_col之前发生所有关键字元素使用了WHERE key_part_# = constant。在这种情况下，MySQL为每个MIN()或MAX()表达式执行一次关键字查找，并用常数替换它。如果所有表达式替换为常量，查询立即返回。例如：

SELECT MIN(key2), MAX (key2)  FROM tb WHERE key1=10;

Ø 如果对一个可用关键字的最左面的前缀进行了排序或分组(例如，ORDER BY key_part_1,key_part_2)，排序或分组一个表。如果所有关键字元素后面有DESC，关键字以倒序被读取。

Ø 在一些情况中，可以对一个查询进行优化以便不用查询数据行即可以检索值。如果查询只使用来自某个表的数字型并且构成某些关键字的最左面前缀的列，为了更快，可以从索引树检索出值。

SELECT key_part3 FROM tb WHERE key_part1=1

有时MySQL不使用索引，即使有可用的索引。一种情形是当优化器估计到使用索引将需要MySQL访问表中的大部分行时。(在这种情况下，表扫描可能会更快些）。然而，如果此类查询使用LIMIT只搜索部分行，MySQL则使用索引，因为它可以更快地找到几行并在结果中返回。例如：
![](http://www.oicto.com/wp-content/uploads/2012/03/20111020040827120.png)
#### 合理的建立索引的建议：
(1)  越小的数据类型通常更好：越小的数据类型通常在磁盘、内存和CPU缓存中都需要更少的空间，处理起来更快。 

(2)  简单的数据类型更好：整型数据比起字符，处理开销更小，因为字符串的比较更复杂。在MySQL中，应该用内置的日期和时间数据类型，而不是用字符串来存储时间；以及用整型数据类型存储IP地址。

(3)  尽量避免NULL：应该指定列为NOT NULL，除非你想存储NULL。在MySQL中，含有空值的列很难进行查询优化，因为它们使得索引、索引的统计信息以及比较运算更加复杂。你应该用0、一个特殊的值或者一个空串代替空值

这部分是关于索引和写SQL语句时应当注意的一些琐碎建议和注意点。

1. 当结果集只有一行数据时使用LIMIT 1

2. 避免SELECT *，始终指定你需要的列

从表中读取越多的数据，查询会变得更慢。他增加了磁盘需要操作的时间，还是在数据库服务器与WEB服务器是独立分开的情况下。你将会经历非常漫长的网络延迟，仅仅是因为数据不必要的在服务器之间传输。

3. 使用连接（JOIN）来代替子查询(Sub-Queries)

       连接（JOIN）.. 之所以更有效率一些，是因为MySQL不需要在内存中创建临时表来完成这个逻辑上的需要两个步骤的查询工作。

4. 使用ENUM、CHAR 而不是VARCHAR，使用合理的字段属性长度

5. 尽可能的使用NOT NULL

6. 固定长度的表会更快

7. 拆分大的DELETE 或INSERT 语句

8. 查询的列越小越快

 

 Where条件

在查询中，WHERE条件也是一个比较重要的因素，尽量少并且是合理的where条件是很重要的，尽量在多个条件的时候，把会提取尽量少数据量的条件放在前面，减少后一个where条件的查询时间。

有些where条件会导致索引无效：

Ø where子句的查询条件里有！=，MySQL将无法使用索引。

Ø where子句使用了Mysql函数的时候，索引将无效，比如：select * from tb where left(name, 4) = ‘xxx’

Ø 使用LIKE进行搜索匹配的时候，这样索引是有效的：select * from tbl1 where name like ‘xxx%’，而like ‘%xxx%’ 时索引无效
## 三、    配置优化
安装MySQL后，配置文件my.cnf在 /MySQL安装目录/share/mysql目录中，该目录中还包含多个配置文件可供参考，有my-large.cnf ，my-huge.cnf，  my-medium.cnf，my-small.cnf，分别对应大中小型数据库应用的配置。win环境下即存在于MySQL安装目录中的.ini文件。

下面列出了对性能优化影响较大的主要变量，主要分为连接请求的变量和缓冲区变量。
### 1.   连接请求的变量：
#### 1)     max_connections
MySQL的最大连接数，增加该值增加mysqld 要求的文件描述符的数量。如果服务器的并发连接请求量比较大，建议调高此值，以增加并行连接数量，当然这建立在机器能支撑的情况下，因为如果连接数越多，介于MySQL会为每个连接提供连接缓冲区，就会开销越多的内存，所以要适当调整该值，不能盲目提高设值。

数值过小会经常出现ERROR 1040: Too many connections错误，可以过’conn%’通配符查看当前状态的连接数量，以定夺该值的大小。

show variables like ‘max_connections’ 最大连接数

show  status like ‘max_used_connections’响应的连接数

如下：

mysql> show variables like ‘max_connections‘;

+———————–+——-+

| Variable_name　| Value |

+———————–+——-+

| max_connections | 256　　|

+———————–+——-+

mysql> show status like ‘max%connections‘;

+———————–+——-+

| Variable_name　      | Value |

+—————————-+——-+

| max_used_connections | 256|

+—————————-+——-+

max_used_connections / max_connections * 100% （理想值≈ 85%） 

如果max_used_connections跟max_connections相同 那么就是max_connections设置过低或者超过服务器负载上限了，低于10%则设置过大。

#### 2)     back_log
MySQL能暂存的连接数量。当主要MySQL线程在一个很短时间内得到非常多的连接请求，这就起作用。如果MySQL的连接数据达到max_connections时，新来的请求将会被存在堆栈中，以等待某一连接释放资源，该堆栈的数量即back_log，如果等待连接的数量超过back_log，将不被授予连接资源。

back_log值指出在MySQL暂时停止回答新请求之前的短时间内有多少个请求可以被存在堆栈中。只有如果期望在一个短时间内有很多连接，你需要增加它，换句话说，这值对到来的TCP/IP连接的侦听队列的大小。

当观察你主机进程列表（mysql> show full processlist），发现大量264084 | unauthenticated user | xxx.xxx.xxx.xxx | NULL | Connect | NULL | login | NULL 的待连接进程时，就要加大back_log 的值了。

默认数值是50，可调优为128，对于Linux系统设置范围为小于512的整数。
#### 3)     interactive_timeout
一个交互连接在被服务器在关闭前等待行动的秒数。一个交互的客户被定义为对mysql_real_connect()使用CLIENT_INTERACTIVE 选项的客户。 

默认数值是28800，可调优为7200。
### 2.   缓冲区变量
全局缓冲：
#### 4)     key_buffer_size
key_buffer_size指定索引缓冲区的大小，它决定索引处理的速度，尤其是索引读的速度。通过检查状态值Key_read_requests和Key_reads，可以知道key_buffer_size设置是否合理。比例key_reads / key_read_requests应该尽可能的低，至少是1:100，1:1000更好（上述状态值可以使用SHOW STATUS LIKE ‘key_read%’获得）。

key_buffer_size只对MyISAM表起作用。即使你不使用MyISAM表，但是内部的临时磁盘表是MyISAM表，也要使用该值。可以使用检查状态值created_tmp_disk_tables得知详情。

举例如下：

mysql> show variables like ‘key_buffer_size‘;

+——————-+————+

| Variable_name | Value      |

+———————+————+

| key_buffer_size | 536870912 |

+———— ———-+————+

key_buffer_size为512MB，我们再看一下key_buffer_size的使用情况：

mysql> show global status like ‘key_read%‘;

+————————+————-+

| Variable_name　  | Value    |

+————————+————-+

| Key_read_requests| 27813678764 |

| Key_reads　　　|  6798830      |

+————————+————-+

一共有27813678764个索引读取请求，有6798830个请求在内存中没有找到直接从硬盘读取索引，计算索引未命中缓存的概率：

key_cache_miss_rate ＝Key_reads / Key_read_requests * 100%，设置在1/1000左右较好

默认配置数值是8388600(8M)，主机有4GB内存，可以调优值为268435456(256MB)。
#### 5)     query_cache_size
使用查询缓冲，MySQL将查询结果存放在缓冲区中，今后对于同样的SELECT语句（区分大小写），将直接从缓冲区中读取结果。

通过检查状态值Qcache_*，可以知道query_cache_size设置是否合理（上述状态值可以使用SHOW STATUS LIKE ‘Qcache%’获得）。如果Qcache_lowmem_prunes的值非常大，则表明经常出现缓冲不够的情况，如果Qcache_hits的值也非常大，则表明查询缓冲使用非常频繁，此时需要增加缓冲大小；如果Qcache_hits的值不大，则表明你的查询重复率很低，这种情况下使用查询缓冲反而会影响效率，那么可以考虑不用查询缓冲。此外，在SELECT语句中加入SQL_NO_CACHE可以明确表示不使用查询缓冲。

 

与查询缓冲有关的参数还有query_cache_type、query_cache_limit、query_cache_min_res_unit。

 

query_cache_type指定是否使用查询缓冲，可以设置为0、1、2，该变量是SESSION级的变量。

query_cache_limit指定单个查询能够使用的缓冲区大小，缺省为1M。

query_cache_min_res_unit是在4.1版本以后引入的，它指定分配缓冲区空间的最小单位，缺省为4K。检查状态值Qcache_free_blocks，如果该值非常大，则表明缓冲区中碎片很多，这就表明查询结果都比较小，此时需要减小query_cache_min_res_unit。

举例如下：

mysql> show global status like ‘qcache%‘;

+——————————-+—————–+

| Variable_name                  | Value　       |

+——————————-+—————–+

| Qcache_free_blocks　       | 22756　      |

| Qcache_free_memory　    | 76764704    |

| Qcache_hits　　　　　      | 213028692 |

| Qcache_inserts　　　　     | 208894227   |

| Qcache_lowmem_prunes   | 4010916      |

| Qcache_not_cached　| 13385031    |

| Qcache_queries_in_cache | 43560　|

| Qcache_total_blocks          | 111212　     |

+——————————-+—————–+

mysql> show variables like ‘query_cache%‘;

+————————————–+————–+

| Variable_name　　　　　       | Value　     |

+————————————–+———–+

| query_cache_limit　　　　　    | 2097152     |

| query_cache_min_res_unit　     | 4096　　  |

| query_cache_size　　　　　    | 203423744 |

| query_cache_type　　　　　   | ON　          |

| query_cache_wlock_invalidate | OFF　  |

+————————————–+—————+

查询缓存碎片率= Qcache_free_blocks / Qcache_total_blocks * 100%

如果查询缓存碎片率超过20%，可以用FLUSH QUERY CACHE整理缓存碎片，或者试试减小query_cache_min_res_unit，如果你的查询都是小数据量的话。

查询缓存利用率= (query_cache_size – Qcache_free_memory) / query_cache_size * 100%

查询缓存利用率在25%以下的话说明query_cache_size设置的过大，可适当减小；查询缓存利用率在80％以上而且Qcache_lowmem_prunes > 50的话说明query_cache_size可能有点小，要不就是碎片太多。

查询缓存命中率= (Qcache_hits – Qcache_inserts) / Qcache_hits * 100%

示例服务器查询缓存碎片率＝20.46％，查询缓存利用率＝62.26％，查询缓存命中率＝1.94％，命中率很差，可能写操作比较频繁吧，而且可能有些碎片。

每个连接的缓冲
#### 6)    record_buffer_size
每个进行一个顺序扫描的线程为其扫描的每张表分配这个大小的一个缓冲区。如果你做很多顺序扫描，你可能想要增加该值。

默认数值是131072(128K)，可改为16773120 (16M)

#### 7)     read_rnd_buffer_size
随机读缓冲区大小。当按任意顺序读取行时(例如，按照排序顺序)，将分配一个随机读缓存区。进行排序查询时，MySQL会首先扫描一遍该缓冲，以避免磁盘搜索，提高查询速度，如果需要排序大量数据，可适当调高该值。但MySQL会为每个客户连接发放该缓冲空间，所以应尽量适当设置该值，以避免内存开销过大。

一般可设置为16M 

#### 8)     sort_buffer_size
每个需要进行排序的线程分配该大小的一个缓冲区。增加这值加速ORDER BY或GROUP BY操作。

默认数值是2097144(2M)，可改为16777208 (16M)。

#### 9)     join_buffer_size
联合查询操作所能使用的缓冲区大小

record_buffer_size，read_rnd_buffer_size，sort_buffer_size，join_buffer_size为每个线程独占，也就是说，如果有100个线程连接，则占用为16M*100

#### 10)  table_cache
表高速缓存的大小。每当MySQL访问一个表时，如果在表缓冲区中还有空间，该表就被打开并放入其中，这样可以更快地访问表内容。通过检查峰值时间的状态值Open_tables和Opened_tables，可以决定是否需要增加table_cache的值。如果你发现open_tables等于table_cache，并且opened_tables在不断增长，那么你就需要增加table_cache的值了（上述状态值可以使用SHOW STATUS LIKE ‘Open%tables’获得）。注意，不能盲目地把table_cache设置成很大的值。如果设置得太高，可能会造成文件描述符不足，从而造成性能不稳定或者连接失败。

1G内存机器，推荐值是128－256。内存在4GB左右的服务器该参数可设置为256M或384M。

#### 11)  max_heap_table_size
用户可以创建的内存表(memory table)的大小。这个值用来计算内存表的最大行数值。这个变量支持动态改变，即set @max_heap_table_size=#

这个变量和tmp_table_size一起限制了内部内存表的大小。如果某个内部heap（堆积）表大小超过tmp_table_size，MySQL可以根据需要自动将内存中的heap表改为基于硬盘的MyISAM表。

#### 12)  tmp_table_size
通过设置tmp_table_size选项来增加一张临时表的大小，例如做高级GROUP BY操作生成的临时表。如果调高该值，MySQL同时将增加heap表的大小，可达到提高联接查询速度的效果，建议尽量优化查询，要确保查询过程中生成的临时表在内存中，避免临时表过大导致生成基于硬盘的MyISAM表。

mysql> show global status like ‘created_tmp%‘;

+——————————–+———+

| Variable_name　　           | Value　|

+———————————-+———+

| Created_tmp_disk_tables | 21197  |

| Created_tmp_files　　　| 58　　|

| Created_tmp_tables　　| 1771587 |

+——————————–+———–+

每次创建临时表，Created_tmp_tables增加，如果临时表大小超过tmp_table_size，则是在磁盘上创建临时表，Created_tmp_disk_tables也增加,Created_tmp_files表示MySQL服务创建的临时文件文件数，比较理想的配置是：

Created_tmp_disk_tables / Created_tmp_tables * 100% <= 25%比如上面的服务器Created_tmp_disk_tables / Created_tmp_tables * 100% ＝1.20%，应该相当好了

默认为16M，可调到64-256最佳，线程独占，太大可能内存不够I/O堵塞

#### 13)  thread_cache_size
可以复用的保存在中的线程的数量。如果有，新的线程从缓存中取得，当断开连接的时候如果有空间，客户的线置在缓存中。如果有很多新的线程，为了提高性能可以这个变量值。

通过比较 Connections和Threads_created状态的变量，可以看到这个变量的作用。

默认值为110，可调优为80。 

#### 14)  thread_concurrency
推荐设置为服务器 CPU核数的2倍，例如双核的CPU, 那么thread_concurrency的应该为4；2个双核的cpu, thread_concurrency的值应为8。默认为8

#### 15)  wait_timeout
指定一个请求的最大连接时间，对于4GB左右内存的服务器可以设置为5-10。

### 3.    配置InnoDB的几个变量
#### innodb_buffer_pool_size

对于InnoDB表来说，innodb_buffer_pool_size的作用就相当于key_buffer_size对于MyISAM表的作用一样。InnoDB使用该参数指定大小的内存来缓冲数据和索引。对于单独的MySQL数据库服务器，最大可以把该值设置成物理内存的80%。

根据MySQL手册，对于2G内存的机器，推荐值是1G（50%）。

 

#### innodb_flush_log_at_trx_commit

主要控制了innodb将log buffer中的数据写入日志文件并flush磁盘的时间点，取值分别为0、1、2三个。0，表示当事务提交时，不做日志写入操作，而是每秒钟将log buffer中的数据写入日志文件并flush磁盘一次；1，则在每秒钟或是每次事物的提交都会引起日志文件写入、flush磁盘的操作，确保了事务的ACID；设置为2，每次事务提交引起写入日志文件的动作，但每秒钟完成一次flush磁盘操作。

实际测试发现，该值对插入数据的速度影响非常大，设置为2时插入10000条记录只需要2秒，设置为0时只需要1秒，而设置为1时则需要229秒。因此，MySQL手册也建议尽量将插入操作合并成一个事务，这样可以大幅提高速度。

根据MySQL手册，在允许丢失最近部分事务的危险的前提下，可以把该值设为0或2。

 

#### innodb_log_buffer_size

log缓存大小，一般为1-8M，默认为1M，对于较大的事务，可以增大缓存大小。

可设置为4M或8M。

 

#### innodb_additional_mem_pool_size

该参数指定InnoDB用来存储数据字典和其他内部数据结构的内存池大小。缺省值是1M。通常不用太大，只要够用就行，应该与表结构的复杂度有关系。如果不够用，MySQL会在错误日志中写入一条警告信息。

根据MySQL手册，对于2G内存的机器，推荐值是20M，可适当增加。

 

#### innodb_thread_concurrency=8

推荐设置为 2*(NumCPUs+NumDisks)，默认一般为8
