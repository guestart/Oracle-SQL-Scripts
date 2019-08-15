REM
REM      Script:      dig_ip_via_trigger.sql
REM      Author:      Quanwen Zhao
REM      Dated:       Aug 15, 2019
REM
REM      Purpose:
REM          This SQL script uses to dig all of IP Addresses connecting to Oracle DB Server, the precondition
REM          is that after creating a trigger "on_logon_trigger" you must force all of machines having connected
REM          to this Oracle DB server have to reconnect. Only in this way you're able to query out the value of
REM          column "client_info" (showing real IP) from Oracle Dynamic Performance View "v$session".
REM
REM      Last tested:
REM              Oracle 11.2.0.4.0
REM

PROMPT =========================
PROMPT Executing on "SYS" schema
PROMPT =========================

CREATE OR REPLACE TRIGGER on_logon_trigger
AFTER LOGON ON DATABASE
BEGIN
    DBMS_APPLICATION_INFO.SET_CLIENT_INFO(SYS_CONTEXT('userenv', 'ip_address'));
END; 
/

SET LINESIZE 200
SET PAGESIZE 200

COLUMN machine     FORMAT a20
COLUMN client_info FORMAT a15

SELECT machine
       , client_info
       , count(*)
FROM v$session
WHERE username IS NOT NULL
AND username <> 'SYS'
GROUP BY machine
         , client_info
ORDER BY count(*) DESC
/

-- 
-- The following Demo is a detailed and specific example from Production System of Oracle 11.2.0.4.0.
-- 
-- Considering security reason I deliberately hidden real IP Address and hostname.
-- 
-- SYS@xxxx> SET LINESIZE 200
-- SYS@xxxx> SET PAGESIZE 200
-- SYS@xxxx> 
-- SYS@xxxx> COLUMN machine     FORMAT a20
-- SYS@xxxx> COLUMN client_info FORMAT a15
-- SYS@xxxx> 
-- SYS@xxxx> SELECT machine
--   2         , client_info
--   3         , count(*)
--   4  FROM v$session
--   5  WHERE username IS NOT NULL
--   6  AND username <> 'SYS'
--   7  GROUP BY machine
--   8           , client_info
--   9  ORDER BY count(*) DESC
--  10  /
-- 
-- MACHINE              CLIENT_INFO       COUNT(*)
-- -------------------- --------------- ----------
-- xxxxxxx102-132       xxx.xxx.xxx.xxx         80
-- xxxx_xxx01           xxx.xxx.xxx.xxx         10
-- xxxx_xxx02           xxx.xxx.xxx.xxx         10
-- xxxx_xxx53           xxx.xxx.xxx.xxx         10
-- xxxx_xxx28           xxx.xxx.xxx.xxx         10
-- xxxx_xxx13           xxx.xxx.xxx.xxx         10
-- xxxx_xxx46           xxx.xxx.xxx.xxx         10
-- xxxx_xxx24           xxx.xxx.xxx.xxx         10
-- xxxx_interface       xxx.xxx.xxx.xxx         10
-- xxxx_xxx68           xxx.xxx.xxx.xxx         10
-- xxxx_xxx70           xxx.xxx.xxx.xxx         10
-- xxxx_xxx35           xxx.xxx.xxx.xxx         10
-- xxxx_xxx94           xxx.xxx.xxx.xxx         10
-- xxxx_xxx01           xxx.xxx.xxx.xxx         10
-- xxxx_xxx58           xxx.xxx.xxx.xxx         10
-- xxxx_xxx09           xxx.xxx.xxx.xxx         10
-- xxxx_xxx34           xxx.xxx.xxx.xxx         10
-- xxxx_xxx97           xxx.xxx.xxx.xxx         10
-- xxxx_xxx50           xxx.xxx.xxx.xxx         10
-- xxxx_xxx04           xxx.xxx.xxx.xxx         10
-- xxxx_xxx96           xxx.xxx.xxx.xxx         10
-- xxxx_xxx21           xxx.xxx.xxx.xxx         10
-- xxxx_xxx91           xxx.xxx.xxx.xxx         10
-- xxxx_xxx95           xxx.xxx.xxx.xxx         10
-- xxxx_xxx63           xxx.xxx.xxx.xxx         10
-- xxxx_xxx74           xxx.xxx.xxx.xxx         10
-- xxxx_xxx32           xxx.xxx.xxx.xxx         10
-- xxxx_xxx33           xxx.xxx.xxx.xxx         10
-- xxxx_xxx20           xxx.xxx.xxx.xxx         10
-- xxxx_xxx14           xxx.xxx.xxx.xxx         10
-- xxxx_xxx62           xxx.xxx.xxx.xxx         10
-- xxxx_xxx16           xxx.xxx.xxx.xxx         10
-- xxxx_xxx10           xxx.xxx.xxx.xxx         10
-- xxxx_xxx75           xxx.xxx.xxx.xxx         10
-- xxxx_xxx73           xxx.xxx.xxx.xxx         10
-- xxxx_xxx93           xxx.xxx.xxx.xxx         10
-- xxxx_xxx71           xxx.xxx.xxx.xxx         10
-- xxxx_xxx12           xxx.xxx.xxx.xxx         10
-- xxxx_xxx27           xxx.xxx.xxx.xxx         10
-- xxxx_xxx100          xxx.xxx.xxx.xxx         10
-- xxxx_xxx87           xxx.xxx.xxx.xxx         10
-- xxxx_xxx51           xxx.xxx.xxx.xxx         10
-- xxxx_xxx86           xxx.xxx.xxx.xxx         10
-- xxxx_xxx38           xxx.xxx.xxx.xxx         10
-- xxxx_xxx44           xxx.xxx.xxx.xxx         10
-- xxxx_xxx03           xxx.xxx.xxx.xxx         10
-- xxxx_xxx69           xxx.xxx.xxx.xxx         10
-- xxxx_xxx98           xxx.xxx.xxx.xxx         10
-- xxxx_xxx39           xxx.xxx.xxx.xxx         10
-- xxxx_xxx82           xxx.xxx.xxx.xxx         10
-- xxxx_xxx03           xxx.xxx.xxx.xxx         10
-- xxxx_xxx59           xxx.xxx.xxx.xxx         10
-- xxxx_xxx99           xxx.xxx.xxx.xxx         10
-- xxxx_xxx04           xxx.xxx.xxx.xxx         10
-- xxxx_xxx76           xxx.xxx.xxx.xxx         10
-- xxxx_xxx01           xxx.xxx.xxx.xxx         10
-- xxxx_xxx18           xxx.xxx.xxx.xxx         10
-- xxxx_xxx56           xxx.xxx.xxx.xxx         10
-- xxxx_xxx61           xxx.xxx.xxx.xxx         10
-- xxxx_xxx07           xxx.xxx.xxx.xxx         10
-- xxxx_xxx02           xxx.xxx.xxx.xxx         10
-- xxxx_xxx05           xxx.xxx.xxx.xxx         10
-- xxxx_xxx06           xxx.xxx.xxx.xxx         10
-- xxxx_xxx90           xxx.xxx.xxx.xxx         10
-- xxxx_xxx01           xxx.xxx.xxx.xxx         10
-- xxxx_xxx64           xxx.xxx.xxx.xxx         10
-- xxxx_xxx65           xxx.xxx.xxx.xxx         10
-- xxxx_xxx15           xxx.xxx.xxx.xxx         10
-- xxxx_xxx17           xxx.xxx.xxx.xxx         10
-- xxxx_xxx25           xxx.xxx.xxx.xxx         10
-- xxxx_xxx30           xxx.xxx.xxx.xxx         10
-- xxxx_xxx78           xxx.xxx.xxx.xxx         10
-- xxxx_xxx45           xxx.xxx.xxx.xxx         10
-- xxxx_xxx72           xxx.xxx.xxx.xxx         10
-- xxxx_xxx42           xxx.xxx.xxx.xxx         10
-- xxxx_xxx23           xxx.xxx.xxx.xxx         10
-- xxxx_xxx11           xxx.xxx.xxx.xxx         10
-- xxxx_xxx49           xxx.xxx.xxx.xxx         10
-- xxxx_xxx60           xxx.xxx.xxx.xxx         10
-- xxxx_xxx05           xxx.xxx.xxx.xxx         10
-- xxxx_xxx92           xxx.xxx.xxx.xxx         10
-- xxxx_xxx81           xxx.xxx.xxx.xxx         10
-- xxxx_xxx67           xxx.xxx.xxx.xxx         10
-- xxxx_xxx31           xxx.xxx.xxx.xxx         10
-- xxxx_xxx07           xxx.xxx.xxx.xxx         10
-- xxxx_xxx43           xxx.xxx.xxx.xxx         10
-- xxxx_xxx40           xxx.xxx.xxx.xxx         10
-- xxxx_xxx80           xxx.xxx.xxx.xxx         10
-- xxxx_xxx08           xxx.xxx.xxx.xxx         10
-- xxxx_xxx89           xxx.xxx.xxx.xxx         10
-- xxxx_xxx48           xxx.xxx.xxx.xxx         10
-- xxxx_xxx54           xxx.xxx.xxx.xxx         10
-- xxxx_xxx83           xxx.xxx.xxx.xxx         10
-- xxxx_xxx36           xxx.xxx.xxx.xxx         10
-- xxxx_xxx55           xxx.xxx.xxx.xxx         10
-- xxxx_xxx22           xxx.xxx.xxx.xxx         10
-- xxxx_xxx77           xxx.xxx.xxx.xxx         10
-- xxxx_xxx52           xxx.xxx.xxx.xxx         10
-- xxxx_xxx79           xxx.xxx.xxx.xxx         10
-- xxxx_xxx08           xxx.xxx.xxx.xxx         10
-- xxxx_xxx47           xxx.xxx.xxx.xxx         10
-- xxxx_xxx41           xxx.xxx.xxx.xxx         10
-- xxxx_xxx37           xxx.xxx.xxx.xxx         10
-- xxxx_xxx19           xxx.xxx.xxx.xxx         10
-- xxxx_xxx84           xxx.xxx.xxx.xxx         10
-- xxxx_xxx02           xxx.xxx.xxx.xxx         10
-- xxxx_xxx26           xxx.xxx.xxx.xxx         10
-- xxxx_xxx88           xxx.xxx.xxx.xxx         10
-- xxxx_xxx85           xxx.xxx.xxx.xxx         10
-- xxxx_xxx66           xxx.xxx.xxx.xxx         10
-- xxxx_xxx06           xxx.xxx.xxx.xxx          9
-- orclxx               xxx.xxx.xxx.xxx          6
-- xxxx                 xxx.xxx.xxx.xxx          2
-- orclx02              xxx.xxx.xxx.xxx          1
-- WIN-S3OFS4L0XXX      xxx.xxx.xxx.xxx          1
-- 
-- 115 rows selected.
