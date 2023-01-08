REM
REM     Script:        pga_used_rate_hist.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Jun 26, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Checking the pga used rate from history of oracle database.
REM

with pga_total as (
select sn.instance_number,
       sn.snap_id,
       to_char(cast(sn.end_interval_time as date), 'yyyy-mm-dd hh24:mi:ss') snap_date_time,
       pgs.value/1024/1024 total
from dba_hist_pgastat pgs, dba_hist_snapshot sn
where pgs.instance_number = sn.instance_number
and pgs.snap_id = sn.snap_id
and pgs.name = 'aggregate PGA target parameter'
),
pga_used as (
select sn.instance_number,
       sn.snap_id,
       to_char(cast(sn.end_interval_time as date), 'yyyy-mm-dd hh24:mi:ss') snap_date_time,
       pgs.value/1024/1024 used
from dba_hist_pgastat pgs, dba_hist_snapshot sn
where pgs.instance_number = sn.instance_number
and pgs.snap_id = sn.snap_id
and pgs.name = 'total PGA allocated'
)
select pt.instance_number,
       pt.snap_id,
       pt.snap_date_time,
       'PGA' name,
       round(pt.total, 2) total,
       round(pu.used, 2) used,
       round(pu.used/pt.total*100, 2) pctused
from pga_total pt, pga_used pu
where pt.instance_number = pu.instance_number
and pt.snap_id = pu.snap_id
order by pt.instance_number,
         pt.snap_id,
         pt.snap_date_time;
