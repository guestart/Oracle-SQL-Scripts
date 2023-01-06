REM
REM     Script:        sql_tuning_advisor_report.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Jul 25, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       The SQL script uses to generate and check Oracle SQL Tuning Advisor Report.
REM       You know, sql_id '4d8svnv5rvtws' comes from a specific sql.
REM

SET SERVEROUTPUT ON

DECLARE
  my_task_name VARCHAR2(30);
BEGIN
  my_task_name := DBMS_SQLTUNE.CREATE_TUNING_TASK(sql_id      => '4d8svnv5rvtws',
                                                  scope       => 'COMPREHENSIVE',
                                                  time_limit  => 3600,
                                                  task_name   => 'sql_tuning_4d8svnv5rvtws',
                                                  description => 'SQL TUNE ADVISOR REPORT');
  DBMS_SQLTUNE.EXECUTE_TUNING_TASK(task_name => 'sql_tuning_4d8svnv5rvtws');
END;
/

SET LONG 100000000
SET LONGCHUNKSIZE 1000
SET LINESIZE 300

SELECT DBMS_SQLTUNE.REPORT_TUNING_TASK('sql_tuning_4d8svnv5rvtws') FROM DUAL;
