REM
REM     Script:        dg_rec_apply_max_seq.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Nov 18, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Checking received and applied max log sequence of physical standby on oracle data guard primary database.
REM

with al_pry as
(select thread#,
        max(sequence#) max_seq
 from v$archived_log
 group by thread#
),
ads as
(select dest_id,
        db_unique_name
 from v$archive_dest_status
 where type = 'PHYSICAL' and db_unique_name = lower('&&stby_db_uname')
),
al_stby_ar as
(select thread#,
        max(sequence#) max_seq
 from v$archived_log
 where dest_id in (select dest_id from v$archive_dest where target = 'STANDBY' and db_unique_name = lower('&&stby_db_uname'))
 and archived = 'YES'
 group by thread#
),
al_stby_ap as
(select thread#,
        max(sequence#) max_seq
 from v$archived_log
 where dest_id in (select dest_id from v$archive_dest where target = 'STANDBY' and db_unique_name = lower('&&stby_db_uname'))
 and applied = 'YES'
 group by thread#
)
select p.thread# pry_inst_id,
       p.max_seq pry_max_seq,
       ads.db_unique_name stby_db_uname,
       ar.max_seq stby_rec_max_seq,
       ap.max_seq stby_app_max_seq
from al_pry p, ads, al_stby_ar ar, al_stby_ap ap
where p.thread# = ar.thread#
and ar.thread# = ap.thread#(+)
order by p.thread#;
