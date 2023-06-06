REM
REM     Script:        rman_backup_job_details.sql
REM     Author:        Quanwen Zhao
REM     Dated:         DEC 03, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Checking the rman backup job details on your oracle database.
REM

select input_type,
       status,
       to_char(start_time,'yyyy-mm-dd hh24:mi:ss') start_time,
       to_char(end_time, 'yyyy-mm-dd hh24:mi:ss') end_time,
       time_taken_display,
       input_bytes_display,
       output_bytes_display,
       input_bytes_per_sec_display,
       output_bytes_per_sec_display
from v$rman_backup_job_details
order by 3 desc;

set linesize 400
set pagesize 300
col TIME_TAKEN_DISPLAY for a10
col INPUG_SIZE for a10
col OUTPUG_SIZE for a10
col "output/s" for a10
col status for a10
col OUT_P for a5
select start_time,
       time_taken_display,
       status,
       input_type, 
       output_device_type OUT_P,
       input_bytes_display INPUG_SIZE,
       output_bytes_display OUTPUG_SIZE,
       output_bytes_per_sec_display as "output/s"
from v$rman_backup_job_details
order by start_time desc;
