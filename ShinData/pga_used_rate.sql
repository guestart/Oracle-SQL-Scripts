REM
REM     Script:        pga_used_rate.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Jul 04, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Checking the pga used rate of oracle database.
REM

select pt.inst_id,
       'PGA' name,
       round(pt.total, 2) total,
       round(pu.used, 2) used,
       round(pu.used/pt.total*100, 2) pctused
from (select inst_id,
             value/1024/1024 total
      from gv$pgastat where name = 'aggregate PGA target parameter'
      order by inst_id
     ) pt,
     (select inst_id,
             value/1024/1024 used
      from gv$pgastat where name = 'total PGA allocated'
      order by inst_id
     ) pu
where pt.inst_id = pu.inst_id;
