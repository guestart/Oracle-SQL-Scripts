REM
REM     Script:        rman_async_io.sql
REM     Author:        Quanwen Zhao
REM     Dated:         DEC 03, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Checking the async io situation duroing the period of rman backup on your oracle database.
REM

SELECT device_type device,
       type,
       filename,
       to_char(open_time, 'yyyymmdd hh24:mi:ss') open,
       to_char(close_time, 'yyyymmdd hh24:mi:ss') close,
       maxopenfiles,
       elapsed_time elapse,
       bytes,
       io_count,
       short_waits,
       long_waits,
       effective_bytes_per_second e_bytes
FROM v$backup_async_io 
WHERE close_time > SYSDATE - 1
AND type = 'AGGREGATE'
ORDER BY close_time DESC;
