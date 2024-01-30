REM
REM     Script:        top_10_segments_on_specific_tbs.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Jan 30, 2024
REM
REM     Purpose:
REM       This sql script shows top 10 segment objects on specific tablespace.
REM

set linesize 400
set pagesize 100
col segment_name for a35

select * from (
select segment_name,
       segment_type,
       round(sum(bytes)/1024/1024/1024, 2) size_gb
from dba_segments
where tablespace_name = upper('&ts_name')
group by segment_name, segment_type
order by 3 desc
) where rownum <= 10;
