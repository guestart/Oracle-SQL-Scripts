REM
REM     Script:        check_his_sql_temp_space.sql
REM     Author:        Quanwen Zhao
REM     Dated:         JAN 24, 2024
REM     Updated:       JAN 25, 2024
REM
REM     Last tested:
REM             11.2.0.4
REM             19.13.0.0
REM
REM     Purpose:
REM       This sql script uses to check the historical sql that used temp space allocated (bytes) for the specific production user during the period of sample time.
REM

-- checking v$active_session_history and v$sql.

set linesize 400
set pagesize 1000
set trimspool on
set trimout on space 1
set recsep off
set echo off
set feedback off
set timing off
set pause off

accept v_btime prompt "Enter the begin time (YYYYMMDDHH24MI): "
accept v_etime prompt "Enter the end   time (YYYYMMDDHH24MI): "
accept v_owner prompt "Enter the owner name: "

with tsa as (
select to_char(ash.sample_time, 'YYYY-MM-DD HH24:MI') sample_time,
       s.parsing_schema_name,
       ash.sql_id,
       ash.sql_child_number as sql_child,
       round(ash.temp_space_allocated / power(2, 30), 2) || ' G' as temp_used,
       round(ash.temp_space_allocated / (select sum(decode(dtf.autoextensible, 'yes', dtf.maxbytes, dtf.bytes)) from dba_temp_files dtf), 2) * 100 || ' %' as temp_pct,
       ash.program,
       ash.module,
       s.sql_text
from v$active_session_history ash, v$sql s
where ash.sample_time >= to_timestamp('&&v_btime', 'YYYYMMDDHH24MI')
and   ash.sample_time <= to_timestamp('&&v_etime', 'YYYYMMDDHH24MI')
and   s.parsing_schema_name = upper('&&v_owner')
and   ash.sql_id is not null
and   ash.temp_space_allocated is not null
and   ash.sql_id = s.sql_id
order by ash.temp_space_allocated desc
)
select * from tsa
where rownum <= 20;
undefine v_btime
undefine v_etime
undefine v_owner

-- checking dba_hist_active_sess_history, dba_hist_sqlstat and dba_hist_sqltext.

set linesize 400
set pagesize 1000
set trimspool on
set trimout on space 1
set recsep off
set echo off
set feedback off
set timing off
set pause off

accept v_btime prompt "Enter the begin time (YYYYMMDDHH24MI): "
accept v_etime prompt "Enter the end   time (YYYYMMDDHH24MI): "
accept v_owner prompt "Enter the owner name: "

with tsa as (
select to_char(dhash.sample_time, 'YYYY-MM-DD HH24:MI') sample_time,
       sqs.parsing_schema_name,
       dhash.sql_id,
       dhash.sql_child_number as sql_child,
       round(dhash.temp_space_allocated / power(2, 30), 2) || ' G' as temp_used,
       round(dhash.temp_space_allocated / (select sum(decode(dtf.autoextensible, 'yes', dtf.maxbytes, dtf.bytes)) from dba_temp_files dtf), 2) * 100 || ' %' as temp_pct,
       dhash.program,
       dhash.module,
       sqt.sql_text
from dba_hist_active_sess_history dhash, dba_hist_sqlstat sqs, dba_hist_sqltext sqt
where dhash.sample_time >= to_timestamp('&&v_btime', 'YYYYMMDDHH24MI')
and   dhash.sample_time <= to_timestamp('&&v_etime', 'YYYYMMDDHH24MI')
and   sqs.parsing_schema_name = upper('&&v_owner')
and   dhash.sql_id is not null
and   dhash.temp_space_allocated is not null
and   dhash.dbid = sqs.dbid
and   dhash.instance_number = sqs.instance_number
and   dhash.snap_id = sqs.snap_id
and   dhash.sql_id = sqs.sql_id
and   sqs.dbid = sqt.dbid
order by dhash.temp_space_allocated desc
)
select * from tsa
where rownum <= 20;
undefine v_btime
undefine v_etime
undefine v_owner
