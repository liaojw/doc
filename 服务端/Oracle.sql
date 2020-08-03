http://localhost:1158/em/

--查看当前有哪些用户正在使用数据
SELECT osuser, a.username,cpu_time/executions/1000000||'s', sql_fulltext,machine 
from v$session a, v$sqlarea b
where a.sql_address =b.address order by cpu_time/executions desc;

查看该用户下表的数量
select count(table_name) from user_tables


创建表空间：
create tablespace testspace datafile 'C:/oracle/product/10.2.0/oradata/bpe/testspace.dbf' size 100M autoextend on next 5M MAXSIZE UNLIMITED;
create tablespace bpeapps datafile 'D:/app/Administrator/oradata/orcl/bpeapps.dbf' size 300M autoextend on next 10M MAXSIZE UNLIMITED;
create tablespace bpedb datafile 'D:/app/Administrator/oradata/orcl/bpedb.dbf' size 100M autoextend on next 10M MAXSIZE UNLIMITED;
create tablespace whreadbpe datafile 'D:/app/Administrator/oradata/orcl/whreadbpe.dbf' size 300M autoextend on next 10M MAXSIZE UNLIMITED;

CREATE USER "BPEUSER"  PROFILE "DEFAULT" IDENTIFIED BY "BPEUSER" DEFAULT TABLESPACE "WHREADBPE" TEMPORARY TABLESPACE "TEMP" ACCOUNT UNLOCK;
GRANT "CONNECT" TO "BPEUSER";
GRANT "DBA" TO "BPEUSER";
GRANT "RESOURCE" TO "BPEUSER";

D:\app\Administrator\oradata\orcl
删除表空间：
drop tablespace testspace including contents and datafiles;

级联删除表：
drop table "CSEI"."Tbs_Rep_Formula_Temp" cascade constraints PURGE
清空回收站
purge recyclebin

创建用户并授权：
CREATE USER "TESTUSER"  PROFILE "DEFAULT" IDENTIFIED BY "123456" DEFAULT TABLESPACE "BPEDB" TEMPORARY TABLESPACE "TEMP" ACCOUNT UNLOCK;
GRANT "CONNECT" TO "TESTUSER";
GRANT "DBA" TO "TESTUSER";
GRANT "RESOURCE" TO "TESTUSER";

CREATE USER "BPEAPPS"  PROFILE "DEFAULT" IDENTIFIED BY "BPEAPPS" DEFAULT TABLESPACE "BPEAPPS" TEMPORARY TABLESPACE "TEMP" ACCOUNT UNLOCK;
GRANT "CONNECT" TO "BPEAPPS";
GRANT "DBA" TO "BPEAPPS";
GRANT "RESOURCE" TO "BPEAPPS";

创建用户及相关级联表，视图，索引，序列，触发器等。
DROP USER TESTUSER CASCADE;

64位数据库导入
CREATE OR REPLACE DIRECTORY test_dir AS 'D:/Oracle/admin/oracl/dpdump';
GRANT READ, WRITE ON DIRECTORY test_dir TO csei;
impdp csei/csei@ORCL directory=test_dir dumpfile=csei.dmp schemas=csei
(低版本数据库导入时只能识别带版本号的)
impdp csei/csei@ORCL directory=test_dir dumpfile=csei23.dmp schemas=csei version=10.2.0.1.0
dmp文件放到Oracle服务端的D:/Oracle/admin/oracl/dpdump目录



SELECT osuser, a.username,cpu_time/executions/1000000||'s', sql_fulltext,machine 
from v$session a, v$sqlarea b
where a.sql_address =b.address order by cpu_time/executions desc;

select  o.SID,USER_NAME,MACHINE,count(*) as  num_cursor 
from v$open_cursor o, v$session s 
where  o.SID=s.SID and USER_NAME='BPEUSER' group by o.SID,USER_NAME,MACHINE order by USER_NAME,MACHINE


select USER_NAME,count(*) as  num_cursor 
from v$open_cursor o, v$session s 
where  o.SID=s.SID and USER_NAME='BPEUSER' group by USER_NAME order by USER_NAME



select username,lockwait,status,machine,program from v$session where sid in
(select session_id from v$locked_object)


select sql_text from v$sql where hash_value in 
(select sql_hash_value from v$session where sid in
(select session_id from v$locked_object))

现11G出现一个type为AE, MODE为4的锁

connect / as sysdba
alter user username account unlock

杀进程中的会话   alter system kill session 'sid,serial#'; 例如：  alter system kill session '29,5497';

ALTER SYSTEM KILL SESSION 'SID,SERIR#' 

select b.username,b.sid,b.serial#,logon_time  from v$locked_object a,v$session b  where a.session_id = b.sid order by b.logon_time;

数据库导出：
 1 将数据库BPE完全导出,用户名BPEUSER 密码123456 导出到C:\bpedb.dmp中
   exp BPEUSER/123456@BPE file=C:\bpedb.dmp full=y
 2 将数据库中BPEUSER用户与TESTUSER用户的表导出
   exp BPEUSER/123456@BPE file=C:\bpedb2.dmp owner=(BPEUSER,TESTUSER)
 3 将数据库中的表SYS_DIC、SYS_USER导出
    exp BPEUSER/123456@BPE file=C:\bpedb3.dmp tables=(SYS_DIC,SYS_USER) 
 4 将数据库中的表SYS_DIC中的字段APPDICID以"3092"打头的数据导出
   exp BPEUSER/123456@BPE file=C:\bpedb4.dmp tables=(SYS_DIC) query=' where APPDICID like ''3092%'''

也可以在上面命令后面 加上 compress=y 来实现zip压缩导出dmp

删除BPE的所有表之后

数据的导入
 1 将C:\bpedb2.dmp 中的数据导入 BPE数据库中。
   imp BPEUSER/123456@BPE file=C:\bpedb2.dmp fromuser=bpeuser touser=bpeuser
   删除已经导入的表后，重试如下命令：
   imp BPEUSER/123456@BPE full=y  file=C:\bpedb2.dmp ignore=y
   如果有的表已经存在，然后再次导入报错，对该表就不进行导入，在后面加上 ignore=y 就可以了。
 2 将C:\bpedb2.dmp中的表SYS_DIC 导入
 imp BPEUSER/123456@BPE file=C:\bpedb2.dmp  tables=(SYS_DIC)
 基本上面的导入导出够用了。不少情况要先是将表彻底删除，然后导入。
 
 IMP SCOTT/TIGER IGNORE=Y TABLES=(EMP,DEPT) FULL=N
    或 TABLES=(T1:P1,T1:P2), 如果 T1 是分区表
 
注意：
 操作者要有足够的权限，权限不够它会提示。
 数据库时可以连上的。可以用tnsping BPE 来获得数据库BPE能否连上。

删除表的注意事项 
在删除一个表中的全部数据时使用 TRUNCATE TABLE 表名;
因为用TRUNCATE 才能立即使得TABLESPACE表空间该表的占用空间被释放



oracle复制表数据和结构
 
只复制表结构 加入了一个永远不可能成立的条件1=2，则此时表示的是只复制表结构，但是不复制表内容   
create table sys_dic2 as select * from sys_dic where 1=2;

表之间的数据复制 
insert into sys_dic2 (select * from sys_dic);


完全复制表(包括创建表和复制表中的记录)
create table sys_dic3 as select * from sys_dic



查看oracle的会话数和每个会话使用的游标数：
select  o.SID,USER_NAME,MACHINE,count(*) as  num_cursor 
from v$open_cursor o, v$session s 
where  o.SID=s.SID and USER_NAME='BPEUSER' group by o.SID,USER_NAME,MACHINE order by USER_NAME,MACHINE



查看oracle的某个会话用户打开使用的游标数总和：
SELECT USER_NAME,MACHINE,COUNT(SID),SUM(num_cursor) FROM (
select  o.SID,USER_NAME,MACHINE,count(*) as  num_cursor 
from v$open_cursor o, v$session s 
where  o.SID=s.SID and USER_NAME='BPEUSER' group by o.SID,USER_NAME,MACHINE order by USER_NAME,MACHINE
) A GROUP BY USER_NAME,MACHINE





数据库性能调整：
alter system set open_cursors=8000 scope=both;
alter system set processes=300 scope=spfile;
alter system set sessions=335 scope=spfile;
alter system set sga_max_size=4096m scope=spfile;
alter system set sga_target=2048m scope=spfile;
alter system set pga_aggregate_target=512m scope=spfile;

设置完成后重启oracle的三个主服务两次。



一、数据库死锁的现象
程序在执行的过程中，点击确定或保存按钮，程序没有响应，也没有出现报错。
二、死锁的原理
当对于数据库某个表的某一列做更新或删除等操作，执行完毕后该条语句不提
交，另一条对于这一列数据做更新操作的语句在执行的时候就会处于等待状态，
此时的现象是这条语句一直在执行，但一直没有执行成功，也没有报错。
三、死锁的定位方法
通过检查数据库表，能够检查出是哪一条语句被死锁，产生死锁的机器是哪一台。
1）用dba用户执行以下语句
select username,lockwait,status,machine,program from v$session where sid in
(select session_id from v$locked_object)
如果有输出的结果，则说明有死锁，且能看到死锁的机器是哪一台。字段说明：
Username：死锁语句所用的数据库用户；
Lockwait：死锁的状态，如果有内容表示被死锁。
Status： 状态，active表示被死锁
Machine： 死锁语句所在的机器。
Program： 产生死锁的语句主要来自哪个应用程序。
2）用dba用户执行以下语句，可以查看到被死锁的语句。
select sql_text from v$sql where hash_value in 
(select sql_hash_value from v$session where sid in
(select session_id from v$locked_object))



四、死锁的解决方法
     一般情况下，只要将产生死锁的语句提交就可以了，但是在实际的执行过程中。用户可
能不知道产生死锁的语句是哪一句。可以将程序关闭并重新启动就可以了。
　经常在Oracle的使用过程中碰到这个问题，所以也总结了一点解决方法。 

1）查找死锁的进程： 

sqlplus "/as sysdba" (sys/change_on_install)
SELECT s.username,l.OBJECT_ID,l.SESSION_ID,s.SERIAL#,
l.ORACLE_USERNAME,l.OS_USER_NAME,l.PROCESS 
FROM V$LOCKED_OBJECT l,V$SESSION S WHERE l.SESSION_ID=S.SID;

2）kill掉这个死锁的进程： 

　　alter system kill session ‘sid,serial#’; （其中sid=l.session_id） 



Oracle常用函数
字符函数   

10、select upper('coolszy') from dual; 将小写字母转换成大写，dual 为一虚表   
11、select lower('KUKA') from dual; 将大写字母转换成小写   
12、select initcap('kuka') from dual; 将首字母大写    
13、select concat('Hello',' world') from dual; 连接字符串，但没有||好用select concat('Hello','world') from dual;   
14、select substr('hello',1,3) from dual; 截取字符串   
15、select length('hello') from dual; 求字符串长度   
16、select replace('hello','l','x') from dual; 替换字符串    
17、select substr('hello',-3,3) from dual; 截取后三位   
  

数值函数   

18、select round(789.536) from dual; 四舍五入，舍去小数   
19、select round(789.536,2) from dual; 保留两位小数   
20、select round(789.536,-1) from dual; 对整数进行四舍五入   
21、select trunc(789.536) from dual; 舍去小数，但不进位   
22、select trunc(789.536,2) from dual;   
23、select trunc(789.536,-2) from dual;   
24、select mod(10,3) from dual; 返回10%3的结果   
    select ceil(10.6) from dual; 大于或等于数值n的最小整数　　
    select ceil(10.6) from dual; 小于等于数值n的最大整数　 

  

日期函数   

25、select sysdate from dual; 返回当前日期   
26、select months_between(sysdate,'16-6月 -08') from dual; 返回之间的月数   
27、select add_months(sysdate,4) from dual; 在日期上加上月数   
28、select next_day(sysdate,'星期一') from dual; 求下一个星期一   
29、select last_day(sysdate) from dual; 求本月的最后一天   
  

  

转换函数   

30、select to_char(sysdate,'yyyy') year,to_char(sysdate,'mm'),to_char(sysdate,'dd') from dual;   
31、select to_char(sysdate,'yyyy-mm-dd') from dual;   
32、select to_char(sysdate,'fmyyyy-mm-dd') from dual; 取消月 日 前面的0   
33、select to_char('20394','99,999') from dual; 分割钱 9表示格式   
34、select to_char('2034','L99,999') from dual; 加上钱币符号   
35、select to_number('123')*to_number('2') from dual;   
36、select to_date('1988-07-04','yyyy-mm-dd') from dual;    
  

通用函数   

37、select nvl(null,0) from dual; 如果为null，则用0代替   
38、select decode(1,1,'内容是1',2,'内容是2',3,'内容是3') from dual; 类似于 switch...case...  
select sid,serial#,username,
DECODE(command,
0,'None',
2,'Insert',
3,'Select',
6,'Update',
7,'Delete',
8,'Drop',
'Other') cmmand
from v$session where username is not null;





39、树语句：
SELECT t.* FROM SYS_DIC t WHERE t.dicLevel between 1 and 3 START WITH t.superDicID='0' CONNECT BY PRIOR t.dicID=t.superDicID 
ORDER SIBLINGS BY t.dispOrder,t.dicID






----创建测试表
create table student_score(
       name varchar2(20),
       subject varchar2(20),
       score number(4,1)
);

-----插入测试数据
insert into student_score (name,subject,score)values('张三','语文',78);
insert into student_score (name,subject,score)values('张三','数学',88);
insert into student_score (name,subject,score)values('张三','英语',98);
insert into student_score (name,subject,score)values('李四','语文',89);
insert into student_score (name,subject,score)values('李四','数学',76);
insert into student_score (name,subject,score)values('李四','英语',90);
insert into student_score (name,subject,score)values('王五','语文',99);
insert into student_score (name,subject,score)values('王五','数学',66);
insert into student_score (name,subject,score)values('王五','英语',91);

-----decode行转列

select name "姓名",
       sum(decode(subject, '语文', nvl(score, 0), 0)) "语文",
       sum(decode(subject, '数学', nvl(score, 0), 0)) "数学",
       sum(decode(subject, '英语', nvl(score, 0), 0)) "英语"
from student_score
group by name;

------ case when 行转列


自己关联自己表的应用：分组排序后，选择出每组中最大的记录


------ 内存整理

select * from v$parameter where name in('open_cursors','processes','sessions','sga_max_size','sga_target','pga_aggregate_target');

alter system set open_cursors=5000 scope=both;
alter system set processes=300 scope=spfile;
alter system set sessions=335 scope=spfile;
alter system set sga_max_size=1024m scope=spfile;
alter system set sga_target=1024m scope=spfile;
alter system set pga_aggregate_target=256m scope=spfile;