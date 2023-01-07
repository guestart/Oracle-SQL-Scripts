REM
REM     Script:        isadg.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Nov 18, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Checking "IsADG" on oracle data guard physical standby database.
REM

set linesize 200
set pagesize 30
col key   for a5
col value for a5

select 'IsADG' key,
       decode(open_mode, 'MOUNTED', 'no', 'READ ONLY', 'yes') value
from v$database;

KEY   VALUE
----- -----
IsADG no
