REM
REM     Script:        user_index_expressions.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Mar 29, 2020
REM
REM     Last tested:
REM             19.3.0.0
REM
REM     Purpose:  
REM       This sql script checks the related index expressions on several columns
REM       by inputting a table name when using SQL*Plus to connect to a user on Oracle Database.
REM

SET VERIFY OFF

SET LINESIZE 300
SET PAGESIZE 150

COLUMN index_name        FORMAT a30
COLUMN column_expression FORMAT a35

SELECT index_name
     , column_expression
FROM   user_ind_expressions
WHERE  table_name = UPPER('&tabname')
ORDER BY index_name
;
