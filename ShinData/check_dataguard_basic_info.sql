REM
REM     Script:        check_dataguard_basic_info.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Nov 11, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM

set linesize 200

col open_mode         for a20
col database_role     for a18
col protection_mode   for a25
col switchover_status for a20
col protection_level  for a25

select inst_id,
       open_mode,
       database_role,
       switchover_status,
       protection_mode,
       protection_level
from gv$database
order by 1;
