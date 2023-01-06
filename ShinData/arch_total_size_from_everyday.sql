REM
REM     Script:        arch_total_size_from_everyday.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Nov 14, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Checking the geneated archive log total size (MB) from everyday on your oracle database.
REM

select trunc(completion_time) as ARC_DATE,
       count(*),
       round((sum(blocks * block_size) / 1024 / 1024), 2) as ARC_MB
from v$archived_log
group by trunc(completion_time)
order by trunc(completion_time);
