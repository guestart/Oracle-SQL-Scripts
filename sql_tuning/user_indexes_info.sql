REM
REM     Script:        user_indexes_info.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Mar 29, 2020
REM
REM     Last tested:
REM             19.3.0.0
REM
REM     Purpose:  
REM       This sql script checks the related indexes info by inputting a table name
REM       when using SQL*Plus to connect to a user on Oracle Database.
REM

SET VERIFY OFF

SET LINESIZE 300
SET PAGESIZE 150

ALTER SESSION SET nls_date_format = 'YYYY-MM-DD';

COLUMN index_name    FORMAT a30
COLUMN index_type    FORMAT a30
COLUMN visibility    FORMAT a10
COLUMN last_analyzed FORMAT a13

SELECT index_name
     , index_type
     , blevel
     , leaf_blocks
     , clustering_factor
     , status
     , visibility
     , num_rows
     , last_analyzed   
FROM   user_indexes
WHERE  table_name = UPPER('&tabname')
;
