REM
REM     Script:        check_tbs_fragmentation_ratio.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Feb 19, 2024
REM
REM     Last tested:
REM             11.2.0.4
REM             19.13.0.0
REM
REM     Purpose:
REM       This sql script uses to check all of the production tablespaces' fragmentation ratio of oracle database.
REM

set linesize 400
set pagesize 400
col tablespace_name for a30

select a.tablespace_name,
       sqrt(max(a.blocks)/sum(a.blocks))*(100/sqrt(sqrt(count(a.blocks)))) FSFI
from dba_free_space a, dba_tablespaces b
where a.tablespace_name = b.tablespace_name
and b.contents not in ('TEMPORARY','UNDO')
group by a.tablespace_name
order by 2;
