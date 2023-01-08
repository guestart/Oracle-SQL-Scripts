REM
REM     Script:        sga_used_rate_hist.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Jun 26, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Checking the sga used rate from history of oracle database.
REM

with sga_total as (
select sn.instance_number,
       sn.snap_id,
       to_char(cast(sn.end_interval_time as date), 'yyyy-mm-dd hh24:mi:ss') snap_date_time,
       sum(sg.value)/1024/1024 total
from dba_hist_sga sg, dba_hist_snapshot sn
where sg.instance_number = sn.instance_number
and sg.snap_id = sn.snap_id
group by sn.instance_number,
         sn.snap_id,
         to_char(cast(sn.end_interval_time as date), 'yyyy-mm-dd hh24:mi:ss')
),
sga_free as (
select sn.instance_number,
       sn.snap_id,
       to_char(cast(sn.end_interval_time as date), 'yyyy-mm-dd hh24:mi:ss') snap_date_time,
       sum(sgs.bytes)/1024/1024 free
from dba_hist_sgastat sgs, dba_hist_snapshot sn
where sgs.instance_number = sn.instance_number
and sgs.snap_id = sn.snap_id
and sgs.name = 'free memory'
group by sn.instance_number,
         sn.snap_id,
         to_char(cast(sn.end_interval_time as date), 'yyyy-mm-dd hh24:mi:ss')
)
select st.instance_number,
       st.snap_id,
       st.snap_date_time,
       'SGA' name,
       round(st.total, 2) total,
       round(st.total-sf.free, 2) used,
       round((st.total-sf.free)/st.total * 100, 2) pctused
from sga_total st, sga_free sf
where st.instance_number = sf.instance_number
and st.snap_id = sf.snap_id
order by st.instance_number,
         st.snap_id,
         st.snap_date_time;
