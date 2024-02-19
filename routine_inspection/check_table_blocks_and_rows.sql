REM
REM     Script:        check_table_blocks_and_rows.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Feb 19, 2024
REM
REM     Last tested:
REM             11.2.0.4
REM             19.13.0.0
REM
REM     Purpose:
REM       This sql script uses to check all of tables' blocks and rows of the specific oracle production user.
REM

set linesize 400
set pagesize 400
col table_name for a30

select table_name, blocks, empty_blocks, num_rows
from dba_tables where owner = upper('&owner_name')
order by 2 desc, 4 desc;
