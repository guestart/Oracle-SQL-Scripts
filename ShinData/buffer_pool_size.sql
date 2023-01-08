REM
REM     Script:        buffer_pool_size.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Jul 06, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Checking the buffer pool size via block_size of oracle database.
REM

select inst_id,
       decode(block_size,
              8192, 'DEFAULT 8K buffer cache',
              16384, 'DEFAULT 16K buffer cache',
              32768, 'DEFAULT 32K buffer cache'
             ) name,
       current_size size_mb
from gv$buffer_pool
order by inst_id,
         size_mb desc;
