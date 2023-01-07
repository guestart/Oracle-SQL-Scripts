REM
REM     Script:        check_redo_log_size.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Oct 29, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Checking the redo log size of oracle database.
REM

set linesize 120
set pagesize 35

set trim on
set trims on

col group#   format 999
col thread#  format 999
col member   format a70 wrap
col status   format a10
col archived format a10
col fsize    format 999 heading "Size (MB)"

select l.group#, 
       l.thread#,
       f.member,
       l.archived,
       l.status,
       (bytes/1024/1024) size_mb
from v$log l, v$logfile f
where f.group# = l.group#
order by 1,2;

-- group# thread# member                                   archived  status  Size (MB)
-- ------ ------- ---------------------------------------- --------  ------- ---------
--      1	      1	/u01/app/oracle/oradata/orcl/redo01.log	 YES	     ACTIVE	        50
--      2	      1	/u01/app/oracle/oradata/orcl/redo02.log	 NO	       CURRENT	      50
--      3	      1	/u01/app/oracle/oradata/orcl/redo03.log	 YES	     ACTIVE	        50
