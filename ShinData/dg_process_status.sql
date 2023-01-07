REM
REM     Script:        dg_process_status.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Nov 18, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Checking the process status on oracle data guard primary and physical standby database.
REM

select inst_id,
       process,
       sequence#,
       status,
       delay_mins
from gv$managed_standby
order by inst_id,
         process;
