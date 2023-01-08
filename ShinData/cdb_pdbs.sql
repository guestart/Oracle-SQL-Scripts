REM
REM     Script:        cdb_pdbs.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Aug 12, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Checking pdb basic info by connecting to cdb on oracle database.
REM       Note: You need to alter the c##monitor_user's permission in order to make it be able to check all pdbs.
REM

ALTER USER c##monitor_user SET container_data=all CONTAINER=current;

SELECT con_id,
       name as pdbname,
       dbid,
       open_mode,
       restricted,
       open_time,
       block_size,
       total_size
FROM v$pdbs;
