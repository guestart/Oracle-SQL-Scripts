REM
REM     Script:        top10_table_subpartitions_occupied_by_size.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Sep 01, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Checking the top 10 table subpartitions that occupied by size (gb) from dba_segments of oracle database.
REM

select owner,
       segment_name,
       size_gb 
from (select owner,
             segment_name,
             size_gb,
             rownum rn 
      from (select owner,
                   segment_name,
                   round(sum(bytes/1024/1024/1024), 4) as size_gb
            from dba_segments 
            where segment_type = 'TABLE SUBPARTITION'
            and not exists (select * from (SELECT username
                                           FROM dba_users
                                           WHERE created < (SELECT created FROM v$database)
                                          ) u
                            where dba_segments.owner = u.username
                           )
            group by owner,
                     segment_name 
            order by 3 desc, 1
           )
     )
where rn <= 10;
