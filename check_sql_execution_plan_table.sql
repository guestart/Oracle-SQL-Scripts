REM
REM     Script:        check_sql_execution_plan_table.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Jul 19, 2018
REM
REM     Last tested
REM             11.2.0.4
REM     Purpose:  
REM             This sql script usually checks the SQL statement's execution plan.
REM

SET LINESIZE 200
SET PAGESIZE 200

SET VERIFY OFF

SELECT * FROM table(DBMS_XPLAN.DISPLAY_CURSOR('&sql_id',NULL,'ALLSTATS ALL'));

SET VERIFY ON

SET LINESIZE 80
SET PAGESIZE 14
