REM
REM     Script:        user_index_columns.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Mar 29, 2020
REM
REM     Last tested:
REM             19.3.0.0
REM
REM     Purpose:  
REM       This sql script checks the related index columns info by inputting a table name
REM       when using SQL*Plus to connect to a user on Oracle Database.
REM

SET VERIFY OFF

SET LINESIZE 300
SET PAGESIZE 150

COLUMN index_name  FORMAT a30
COLUMN column_name FORMAT a30
COLUMN descend     FORMAT a7

SELECT index_name
     , column_name
     , descend  
FROM   user_ind_columns
WHERE  table_name = UPPER('&tabname')
ORDER BY index_name
       , column_name
;
