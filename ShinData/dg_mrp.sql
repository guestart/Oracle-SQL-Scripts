REM
REM     Script:        dg_mrp.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Nov 18, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Checking "MRP_process_status" on oracle data guard physical standby database.
REM

set linesize 200
set pagesize 30

col key   for a20
col value for a15

select 'MRP_process_status' key,
       (select status from gv$managed_standby where process like 'MRP%') value
from dual;

KEY                  VALUE
-------------------- ------------------------------
MRP_process_status   APPLYING_LOG

or

KEY                  VALUE
-------------------- ---------------
MRP_process_status   WAIT_FOR_GAP

or

KEY                  VALUE
-------------------- ------------------------------
MRP_process_status
