REM
REM     Script:        backup_files_by_piece.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Sep 20, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Checking backup files by rman backup piece on oracle database.
REM

SELECT pkey,
       bs_tag,
       fname,
       completion_time,
       bs_type,
       bs_device_type,
       bs_status,
       compressed
FROM v$backup_files
WHERE obsolete = 'NO'
AND file_type = 'PIECE'
ORDER BY pkey;
