REM
REM     Script:        sga_used_rate.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Jul 04, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Checking the sga used rate of oracle database.
REM

select st.inst_id,
       'SGA' name,
       round(st.total, 2) total,
       round(st.total-sf.free, 2) used,
       round((st.total-sf.free)/st.total*100, 2) pctused
from (select inst_id,
             sum(value)/1024/1024 total from gv$sga
      group by inst_id
      order by inst_id
     ) st,
     (select inst_id,
             sum(bytes)/1024/1024 free from gv$sgastat where name='free memory'
             group by inst_id
             order by inst_id
     ) sf
where st.inst_id = sf.inst_id;
