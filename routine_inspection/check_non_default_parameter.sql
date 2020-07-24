REM
REM     Script:        check_non_default_parameter.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Jul 24, 2020
REM
REM     Purpose:  
REM       This SQL script usually uses to check whether there are some non-default parameters on oracle database.
REM       Reference here - https://docs.oracle.com/cd/E11882_01/server.112/e40402/statviews_4017.htm#REFRN23427
REM             and here - https://docs.oracle.com/cd/E11882_01/server.112/e40402/dynviews_2087.htm#REFRN30176
REM

SET LINESIZE 200
SET PAGESIZE 200

COLUMN parameter_name FORMAT a45
COLUMN value          FORMAT a15

SELECT DISTINCT parameter_name
              , value
FROM   dba_hist_parameter
WHERE  isdefault = 'FALSE' 
AND    ismodified IN ('MODIFIED', 'SYSTEM_MOD')
;

-- or

SET LINESIZE 200
SET PAGESIZE 200

COLUMN name  FORMAT a45
COLUMN value FORMAT a15

SELECT name
     , value
FROM   v$parameter
WHERE  isdefault = 'FALSE' 
AND    ismodified IN ('MODIFIED', 'SYSTEM_MOD')
;
