REM
REM     Script:        top10_indexes_occupied_by_size.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Sep 02, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Checking the top 10 indexes that occupied by size (gb) from dba_segments of oracle database.
REM

select owner,
       segment_name
       ,size_gb
from (select owner,
             segment_name,
             round(bytes/1024/1024/1024, 4) as size_gb,
             rownum rn
      from dba_segments
      where segment_type = 'INDEX'
      and not exists (select * from (SELECT username
                                     FROM dba_users
                                     WHERE created < (SELECT created FROM v$database)
                                    ) u
                      where dba_segments.owner = u.username
                     )
      order by 3 desc, 1
     )
where rn <= 10;
