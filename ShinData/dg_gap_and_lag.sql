REM
REM     Script:        dg_gap_and_lag.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Nov 18, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Checking the gap and lag situation on oracle data guard physical standby database.
REM

with al_rfs as
(select thread#,
        max(sequence#) max_seq,
        registrar,
        applied
 from v$archived_log
 where registrar = 'RFS'
 group by thread#, registrar, applied
),
ag as
(select thread#,
        low_sequence#,
        high_sequence#
 from v$archive_gap
),
ds as
(select inst_id,
        name,
        value,
        unit
 from gv$dataguard_stats
 where name like '%lag'
),
al_rfs_ds as
(select a.thread# stby_inst_id,
        a.thread# thread_number,
        a.max_seq stby_max_seq,
        a.registrar stby_registrar,
        a.applied stby_applied_status,
        b.name,
        b.value
 from al_rfs a, ds b
)
select ad.stby_inst_id,
       ad.thread_number,
       ad.stby_max_seq,
       ad.stby_registrar,
       ad.stby_applied_status,
       nvl(ag.low_sequence#, 0) no_rec_low_sequence#,
       nvl(ag.high_sequence#, 0) no_rec_high_sequence#,
       nvl(ag.high_sequence#, 0) - nvl(ag.low_sequence#, 0) gap_nums,
       ad.name lag_type,
       ad.value lag_time
from al_rfs_ds ad, ag
where ad.thread_number = ag.thread#(+)
order by ad.stby_inst_id, lag_type desc;
