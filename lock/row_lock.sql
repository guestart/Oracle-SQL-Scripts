关于行锁等待事件enq: TX - row lock contention ，通常是Application级别的问题。常见的TX锁等待原因：
1 应用代码逻辑层有问题，导致同时修改相同数据引发锁等待。
2 应用代码逻辑层有问题，导致事务不提交引发锁等待。
3 主键或者唯一键冲突引发锁等待。
4 位图索引维护引发锁等待。
5 事务回滚导致的锁等待。
6 慢SQL导致的锁等待。

根据经验，大多数行锁的产生都来自于事务未能及时提交、SQL低效等原因。
当发生行锁问题时，对应用的影响是很大的，应用会报出无法完成正常事务。
就需要快速的排查问题原因，并通过相应手段避免行锁持续的影响。

-- 模拟

DROP TABLE tx_eg;
CREATE TABLE tx_eg ( num number, txt varchar2(10), sex varchar2(10) ) INITRANS 1 MAXTRANS 1;
INSERT into tx_eg VALUES ( 1, 'First','FEMALE' );
INSERT into tx_eg VALUES ( 2, 'Second','MALE' );
INSERT into tx_eg VALUES ( 3, 'Third','MALE' );
INSERT into tx_eg VALUES ( 4, 'Fourth','MALE' );
INSERT into tx_eg VALUES ( 5, 'Fifth','MALE' );
COMMIT;

--Ses#1:
UPDATE tx_eg SET txt='Garbage' WHERE num=1;
--Ses#2:
UPDATE tx_eg SET txt='Garbage' WHERE num=1;
......
多增加几个会话

-- 数据库出现大量的行锁等待 enq: TX - row lock contention

-- 告警SQL:

SELECT event,
       wait_class,
       session_state,
       blocking_session,
       blocking_session_serial#,
       count(*)
FROM v$active_session_history
WHERE sample_time BETWEEN sysdate - interval '60' minute AND sysdate
AND event = 'enq: TX - row lock contention'
GROUP BY event,
         wait_class,
         session_state,
         blocking_session,
         blocking_session_serial#
ORDER BY count(*) DESC, event;

1. 当行锁正在发生时

1.1 查询哪些会话引起的行锁等待(列出了引起阻塞的被阻塞的所有会话)

select p.spid,
       s.sid,
       s.serial#,
       l.oracle_username,
       s.machine,
       s.program,
       o.object_name
from v$process p, v$session s, v$locked_object l, dba_objects o
where p.addr = s.paddr
and s.sid = l.session_id
and l.object_id = o.object_id;

91281	1153	45130	SYSTEM	k8s227	sqlplus@k8s227 (TNS V1-V3)	TX_EG
90091	401	  48708	SYSTEM	k8s227	sqlplus@k8s227 (TNS V1-V3)	TX_EG
91376	1169	10379	SYSTEM	k8s227	sqlplus@k8s227 (TNS V1-V3)	TX_EG

当前有3个会话引起了行锁等待, 它们分别是 '1153,45130', '401,48708', '1169,10379'.
-- 新增: 操作系统进程为列spid的值, 主机名为列machine的值.
-- 新增: 在操作系统的oracle用户下执行 netstat -anp | grep 'spid列的值' 可以找到应用主机的IP地址

1.2 查询行锁等待相关的SQL语句

SELECT distinct s.SQL_ID,
       substr(t.SQL_TEXT,0,1000) as sql_text
FROM gv$session s, gv$lock l, gv$LOCKED_OBJECT lo, dba_objects do, v$sqlstats t
WHERE s.blocking_session IS NOT NULL
AND s.BLOCKING_INSTANCE = l.inst_id
AND s.blocking_session = l.sid
AND t.SQL_ID = s.SQL_ID
AND l.block > 0
AND s.sid = lo.session_id
AND lo.object_id = do.object_id;

1ssx3w9sj0sub  UPDATE tx_eg SET txt='Garbage' WHERE num=1

SQL语句的 sql_id 为1ssx3w9sj0sub, 文本语句为 UPDATE tx_eg SET txt='Garbage' WHERE num=1.

1.3 查询行锁等待事件产生的阻塞链

select inst_id,
       sid,
       serial,
       event,
       status,
       tree,
       tree_level
from (select a.inst_id,
             a.sid,
             a.serial# as serial,
             a.sql_id,
             a.event,
             a.status,
             connect_by_isleaf as isleaf,
             sys_connect_by_path(a.sid||','||a.serial#||'@'||a.inst_id, ' <- ') tree,
             level as tree_level
      from gv$session a
      start with a.blocking_session is not null
      connect by (a.sid||'@'||a.inst_id) = prior (a.blocking_session||'@'||a.blocking_instance)
     ) t 
where sql_id is null
order by tree_level asc;

1	1153	45130	SQL*Net message from client	INACTIVE	 <- 401,48708@1 <- 1153,45130@1	2
1	1153	45130	SQL*Net message from client	INACTIVE	 <- 1169,10379@1 <- 1153,45130@1	2

发现该行锁产生了两条阻塞链,
会话 '1153,45130' 阻塞了 会话 '401,48708',
会话 '1153,45130' 阻塞了 会话 '1169,10379'.

1.4 建议手动杀掉所有引起阻塞和被阻塞的会话

select 'alter system kill session ''' || s.sid ||',' || s.serial# || ''';' kill_session
from v$process p, v$session s, v$locked_object l, dba_objects o
where p.addr = s.paddr
and s.sid = l.session_id
and l.object_id = o.object_id;

生成的杀掉会话的SQL语句为,
alter system kill session '1153,45130';
alter system kill session '401,48708';
alter system kill session '1169,10379';

2. 当行锁不存在时

2.1 在发生问题时间段内, 查询哪些会话引起的行锁等待(列出了引起阻塞的被阻塞的所有会话)

select * from (
select to_char(h.sample_time,'yyyy-mm-dd hh24:mi:ss') sample_time,
       h.inst_id,
       h.session_id,
       h.session_serial#,
       h.machine,
       h.program,
       h.current_obj#,
       o.object_name,
       o.object_type,
       h.blocking_session,
       h.blocking_session_serial#,
       h.blocking_inst_id 
from gv$active_session_history h, dba_objects o
where h.current_obj# = o.object_id
and h.sample_time between sysdate - INTERVAL '60' minute and sysdate
and h.event = 'enq: TX - row lock contention'
order by 1 desc, 2
) where rownum <= 30;

2022-10-28 14:09:07	1	791	3173	k8s227	sqlplus@k8s227 (TNS V1-V3)	148945	TX_EG	TABLE	20	19233	1
2022-10-28 14:09:06	1	15	36283	k8s227	sqlplus@k8s227 (TNS V1-V3)	148945	TX_EG	TABLE	20	19233	1
2022-10-28 14:09:06	1	791	3173	k8s227	sqlplus@k8s227 (TNS V1-V3)	148945	TX_EG	TABLE	20	19233	1
2022-10-28 14:09:05	1	15	36283	k8s227	sqlplus@k8s227 (TNS V1-V3)	148945	TX_EG	TABLE	20	19233	1
2022-10-28 14:09:05	1	791	3173	k8s227	sqlplus@k8s227 (TNS V1-V3)	148945	TX_EG	TABLE	20	19233	1
2022-10-28 14:09:04	1	15	36283	k8s227	sqlplus@k8s227 (TNS V1-V3)	148945	TX_EG	TABLE	20	19233	1
2022-10-28 14:09:04	1	791	3173	k8s227	sqlplus@k8s227 (TNS V1-V3)	148945	TX_EG	TABLE	20	19233	1
2022-10-28 14:09:03	1	15	36283	k8s227	sqlplus@k8s227 (TNS V1-V3)	148945	TX_EG	TABLE	20	19233	1
2022-10-28 14:09:03	1	791	3173	k8s227	sqlplus@k8s227 (TNS V1-V3)	148945	TX_EG	TABLE	20	19233	1
2022-10-28 14:09:02	1	15	36283	k8s227	sqlplus@k8s227 (TNS V1-V3)	148945	TX_EG	TABLE	20	19233	1
2022-10-28 14:09:02	1	791	3173	k8s227	sqlplus@k8s227 (TNS V1-V3)	148945	TX_EG	TABLE	20	19233	1
2022-10-28 14:09:01	1	15	36283	k8s227	sqlplus@k8s227 (TNS V1-V3)	148945	TX_EG	TABLE	20	19233	1
2022-10-28 14:09:01	1	791	3173	k8s227	sqlplus@k8s227 (TNS V1-V3)	148945	TX_EG	TABLE	20	19233	1
2022-10-28 14:09:00	1	15	36283	k8s227	sqlplus@k8s227 (TNS V1-V3)	148945	TX_EG	TABLE	20	19233	1
2022-10-28 14:09:00	1	791	3173	k8s227	sqlplus@k8s227 (TNS V1-V3)	148945	TX_EG	TABLE	20	19233	1
2022-10-28 14:08:59	1	15	36283	k8s227	sqlplus@k8s227 (TNS V1-V3)	148945	TX_EG	TABLE	20	19233	1
2022-10-28 14:08:59	1	791	3173	k8s227	sqlplus@k8s227 (TNS V1-V3)	148945	TX_EG	TABLE	20	19233	1
2022-10-28 14:08:58	1	15	36283	k8s227	sqlplus@k8s227 (TNS V1-V3)	148945	TX_EG	TABLE	20	19233	1
2022-10-28 14:08:58	1	791	3173	k8s227	sqlplus@k8s227 (TNS V1-V3)	148945	TX_EG	TABLE	20	19233	1
2022-10-28 14:08:57	1	15	36283	k8s227	sqlplus@k8s227 (TNS V1-V3)	148945	TX_EG	TABLE	20	19233	1
2022-10-28 14:08:57	1	791	3173	k8s227	sqlplus@k8s227 (TNS V1-V3)	148945	TX_EG	TABLE	20	19233	1
2022-10-28 14:08:56	1	15	36283	k8s227	sqlplus@k8s227 (TNS V1-V3)	148945	TX_EG	TABLE	20	19233	1
2022-10-28 14:08:56	1	791	3173	k8s227	sqlplus@k8s227 (TNS V1-V3)	148945	TX_EG	TABLE	20	19233	1
2022-10-28 14:08:55	1	15	36283	k8s227	sqlplus@k8s227 (TNS V1-V3)	148945	TX_EG	TABLE	20	19233	1
2022-10-28 14:08:55	1	791	3173	k8s227	sqlplus@k8s227 (TNS V1-V3)	148945	TX_EG	TABLE	20	19233	1
2022-10-28 14:08:54	1	15	36283	k8s227	sqlplus@k8s227 (TNS V1-V3)	148945	TX_EG	TABLE	20	19233	1
2022-10-28 14:08:54	1	791	3173	k8s227	sqlplus@k8s227 (TNS V1-V3)	148945	TX_EG	TABLE	20	19233	1
2022-10-28 14:08:53	1	15	36283	k8s227	sqlplus@k8s227 (TNS V1-V3)	148945	TX_EG	TABLE	20	19233	1
2022-10-28 14:08:53	1	791	3173	k8s227	sqlplus@k8s227 (TNS V1-V3)	148945	TX_EG	TABLE	20	19233	1
2022-10-28 14:08:52	1	15	36283	k8s227	sqlplus@k8s227 (TNS V1-V3)	148945	TX_EG	TABLE	20	19233	1

在发生问题时间段内, 有3个会话引起了行锁等待, 引起阻塞的会话是 '20,19233', 被阻塞的会话是 '791,3173', '15,36283'.

2.2 在发生问题时间段内, 查询行锁等待相关的SQL语句

select distinct h.inst_id,
       h.sql_id,
       substr(s.sql_text, 0, 1000) as sql_text
from gv$active_session_history h, v$sqlstats s
where h.sql_id = s.sql_id
and h.sample_time between sysdate - INTERVAL '60' minute and sysdate
and h.event = 'enq: TX - row lock contention'
order by 1, 2;

1	gzjxwfz7rjhhx	UPDATE tx_eg SET txt='Garbage' WHERE num=2

SQL语句的 sql_id 为 gzjxwfz7rjhhx, 文本语句为 UPDATE tx_eg SET txt='Garbage' WHERE num=2.

2.3 在发生问题时间段内, 查询行锁等待事件产生的阻塞链

with ash as (
select *
  from gv$active_session_history
 where sample_time between sysdate - interval '120' minute and sysdate),
ash2 as (
select sample_time,inst_id,session_id,session_serial#,sql_id,sql_opname,
       event,blocking_inst_id,blocking_session,blocking_session_serial#,
       level lv,
       connect_by_isleaf isleaf,
   sys_connect_by_path(inst_id||'_'||session_id||','||session_serial#||':'||sql_id||':'||sql_opname,'->') lock_chain,
       sys_connect_by_path(EVENT,',') EVENT_CHAIN ,
       connect_by_root(inst_id||'_'||session_id||','||session_serial#) root_sess
  from ash
 --start with event like 'enq: TX - row lock contention%'
 start with blocking_session is not null
 connect by nocycle 
        prior blocking_inst_id=inst_id
    and prior blocking_session=session_id
    and prior blocking_session_serial#=session_serial#
    and prior sample_id=sample_id)
select lock_chain lock_chain,
       case when blocking_session is not null then blocking_inst_id||'_'||blocking_session||','||blocking_session_serial# else inst_id||'_'||session_id||','||session_serial# end blocking_header, EVENT_CHAIN,
       count(*) cnt,
       TO_CHAR(min(sample_time),'YYYYMMDD HH24:MI:ss') first_seen,
       TO_CHAR(max(sample_time),'YYYYMMDD HH24:MI:ss') last_seen
   from ash2
  where isleaf=1
group by lock_chain,EVENT_CHAIN,case when blocking_session is not null then blocking_inst_id||'_'||blocking_session||','||blocking_session_serial# else inst_id||'_'||session_id||','||session_serial# end
having count(*)>1
order by first_seen, cnt desc;

->1_791,3173:gzjxwfz7rjhhx:UPDATE	1_20,19233	,enq: TX - row lock contention	309	20221028 14:03:59	20221028 14:09:07
->1_15,36283:gzjxwfz7rjhhx:UPDATE	1_20,19233	,enq: TX - row lock contention	305	20221028 14:04:02	20221028 14:09:06

发现该行锁产生了两条阻塞链,
会话 '20,19233' 阻塞了 会话 '791,3173',
会话 '20,19233' 阻塞了 会话 '15,36283'.

历史(锁链): -- 我和阔涛研究测试过:

with temp as
 (select c.*
    from (select t.*,
                 row_number() over(partition by sql_exec_start order by sample_time asc) rn
            from dba_hist_active_sess_history t
           where event = 'enq: TX - row lock contention'
           and SAMPLE_TIME between
         TO_DATE('2023-01-16 17:00:01', 'yyyy-mm-dd hh24:mi:ss') - interval '60'
   minute
     and TO_DATE('2023-01-16 17:00:01', 'yyyy-mm-dd hh24:mi:ss') + interval '20'
   minute ) c
   where c.rn = 1),
temp2 as
 (select instance_number,
         session_id,
         serial,
         event,
         session_state,
         tree,
         tree_level
    from (select a.instance_number,
                 a.session_id,
                 a.session_serial# as serial,
                 a.sql_id,
                 a.event,
                 a.session_state,
                 a.blocking_session,
                 sys_connect_by_path(a.session_id || ',' || a.session_serial# || '@' ||
                                     a.instance_number,
                                     ' <- ') tree,
                 level as tree_level
            from temp a
           start with a.blocking_session is not null
          connect by nocycle(a.session_id || '@' || a.instance_number) = prior
                     (a.blocking_session || '@' || a.blocking_inst_id)) t),
temp3 as
 (select max(tree_level) as tree_level
    from (select a.instance_number,
                 a.session_id,
                 a.session_serial# as serial,
                 a.sql_id,
                 a.event,
                 a.session_state,
                 a.blocking_session,
                 sys_connect_by_path(a.session_id || ',' || a.session_serial# || '@' ||
                                     a.instance_number,
                                     ' <- ') tree,
                 level as tree_level
            from temp a
           start with a.blocking_session is not null
          connect by nocycle(a.session_id || '@' || a.instance_number;
