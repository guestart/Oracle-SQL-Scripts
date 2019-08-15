REM
REM      Script:      dig_ip_via_function.sql
REM      Author:      Quanwen Zhao
REM      Dated:       Aug 15, 2019
REM
REM      Purpose:
REM          This SQL script uses to dig all of IP Addresses connecting to Oracle DB Server, the precondition
REM          is that after creating a function "resolveHost()" you must force all of machines' "IP Address" and
REM          "hostname" to add to this file "/etc/hosts" on ROOT user of this Oracle DB Server. Only in this way
REM          you're able to acquire real IP by calling function "resoveHost(machine)", by the way within the prior
REM          function "resolveHost(machine)" extra parameter "machine" comes from Oracle Dynamic Performance View
REM          "v$session".
REM
REM     Last tested:
REM             Oracle 11.2.0.4.0
REM

PROMPT =========================
PROMPT Executing on "SYS" schema
PROMPT =========================

CREATE OR REPLACE FUNCTION resolveHost(name VARCHAR2)
RETURN VARCHAR2 deterministic
IS
BEGIN
  RETURN
    (
      UTL_INADDR.GET_HOST_ADDRESS(name)
    );     
EXCEPTION
  WHEN OTHERS THEN
    RETURN(null);
END;
/

SET LINESIZE 200
SET PAGESIZE 200

COLUMN machine FORMAT a20
COLUMN IP      FORMAT a15

SELECT machine
       , resolveHost(machine) AS IP
       , count(*)
FROM v$session
WHERE username IS NOT NULL
AND username <> 'SYS'
GROUP BY machine
         , resolveHost(machine)
ORDER BY count(*) DESC
/

-- 
-- The following Demo is a detailed and specific example from Production System of Oracle 11.2.0.4.0.
-- 
-- Due to security reason I deliberately hidden real IP Address and hostname.
-- 
-- SYS@xxxx> SELECT machine
--   2         , resolveHost(machine) AS IP
--   3         , count(*)
--   4  FROM v$session
--   5  WHERE username IS NOT NULL
--   6  AND username <> 'SYS'
--   7  GROUP BY machine
--   8           , resolveHost(machine)
--   9  ORDER BY count(*) DESC
--  10  /
-- 
-- MACHINE              IP                COUNT(*)
-- -------------------- --------------- ----------
-- xxxxxxx102-132                               81
-- xxxx_web01                                   20
-- xxxx03               xxx.xxx.xxx.xxx         15
-- xxxx_web25                                   10
-- xxxx_web14                                   10
-- xxxx_web63                                   10
-- xxxx_web16                                   10
-- xxxx_web81                                   10
-- xxxx_web84                                   10
-- xxxx_web65                                   10
-- xxxx_web96                                   10
-- xxxx_mrg01                                   10
-- xxxx_web76                                   10
-- xxxx_web19                                   10
-- xxxx_web89                                   10
-- xxxx_interface                               10
-- xxxx_web45                                   10
-- xxxx_web56                                   10
-- xxxx_web47                                   10
-- xxxx_web11                                   10
-- xxxx_web100                                  10
-- xxxx_web49                                   10
-- xxxx_web74                                   10
-- xxxx_web24                                   10
-- xxxx_web18                                   10
-- xxxx_mrg04                                   10
-- xxxx_mrg06                                   10
-- xxxx_web15                                   10
-- xxxx_web79                                   10
-- xxxx_web07                                   10
-- xxxx_web31                                   10
-- xxxx_web21                                   10
-- xxxx_web28                                   10
-- xxxx_web68                                   10
-- xxxx_web75                                   10
-- xxxx_web06                                   10
-- xxxx_web78                                   10
-- xxxx_web71                                   10
-- xxxx_web52                                   10
-- xxxx_web12                                   10
-- xxxx_web02                                   10
-- xxxx_web72                                   10
-- xxxx_mrg07                                   10
-- xxxx_web13                                   10
-- xxxx_web33                                   10
-- xxxx_web10                                   10
-- xxxx_web77                                   10
-- xxxx_web91                                   10
-- xxxx_web39                                   10
-- xxxx_web22                                   10
-- xxxx_web86                                   10
-- xxxx_web23                                   10
-- xxxx_web51                                   10
-- xxxx_web38                                   10
-- xxxx_web08                                   10
-- xxxx_web69                                   10
-- xxxx_web41                                   10
-- xxxx_web05                                   10
-- xxxx_mrg05                                   10
-- xxxx_web53                                   10
-- xxxx_web55                                   10
-- xxxx_web98                                   10
-- xxxx_web85                                   10
-- xxxx_web73                                   10
-- xxxx_web32                                   10
-- xxxx_web64                                   10
-- xxxx_mrg02                                   10
-- xxxx_web88                                   10
-- xxxx_web46                                   10
-- xxxx_mrg03                                   10
-- xxxx_web44                                   10
-- xxxx_web50                                   10
-- xxxx_web48                                   10
-- xxxx_web27                                   10
-- xxxx_web35                                   10
-- xxxx_mrg08                                   10
-- xxxx_web62                                   10
-- xxxx_web20                                   10
-- xxxx_web17                                   10
-- xxxx_web94                                   10
-- xxxx_web93                                   10
-- xxxx_web70                                   10
-- xxxx_web92                                   10
-- xxxx_web99                                   10
-- xxxx_web95                                   10
-- xxxx_web90                                   10
-- xxxx_web34                                   10
-- xxxx_web42                                   10
-- xxxx_web87                                   10
-- xxxx_job02                                   10
-- xxxx_job01                                   10
-- xxxx_web37                                   10
-- xxxx_web66                                   10
-- xxxx_web59                                   10
-- xxxx_web60                                   10
-- xxxx_web54                                   10
-- xxxx_web36                                   10
-- xxxx_web80                                   10
-- xxxx_web67                                   10
-- xxxx_web09                                   10
-- xxxx_web40                                   10
-- xxxx_web58                                   10
-- xxxx_web82                                   10
-- xxxx_web03                                   10
-- xxxx_web04                                   10
-- xxxx_web43                                   10
-- xxxx_web61                                   10
-- xxxx_web83                                   10
-- xxxx_web30                                   10
-- xxxx_web26                                   10
-- xxxx_web97                                   10
-- xxxx                xxx.xxx.xxx.xxx           2
-- xxxx_solr03                                   1
-- WIN-S3OFS4L0XXX                               1
-- xxxx02              xxx.xxx.xxx.xxx           1
-- 
-- 115 rows selected.
-- 
-- 
-- [root@xxxx ~]# cat /etc/hosts
-- #127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
-- ::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
-- xx.xxx.x.xx     xxxx02
-- xx.xxx.x.xx     xxxx
-- xx.xxx.x.xxx    xxxx202
-- ......
-- # Adding all IP Address even connecting to this Oracle DB Server and hostname just a moment ago.
-- xxx.xxx.xxx.xxx   xxxxxxx102-132
-- xxx.xxx.xxx.xxx   xxxx03
-- xxx.xxx.xxx.xxx   xxxx_mrg01
-- xxx.xxx.xxx.xxx   xxxx_web09
-- xxx.xxx.xxx.xxx   xxxx_interface
-- xxx.xxx.xxx.xxx   xxxx_web13
-- xxx.xxx.xxx.xxx   xxxx_job02
-- xxx.xxx.xxx.xxx   xxxx_web58
-- xxx.xxx.xxx.xxx   xxxx_web01
-- xxx.xxx.xxx.xxx   xxxx_web70
-- xxx.xxx.xxx.xxx   xxxx_web35
-- xxx.xxx.xxx.xxx   xxxx_web94
-- xxx.xxx.xxx.xxx   xxxx_web28
-- xxx.xxx.xxx.xxx   xxxx_web24
-- xxx.xxx.xxx.xxx   xxxx_web68
-- xxx.xxx.xxx.xxx   xxxx_web53
-- xxx.xxx.xxx.xxx   xxxx_web46
-- xxx.xxx.xxx.xxx   xxxx_web34
-- xxx.xxx.xxx.xxx   xxxx_web04
-- xxx.xxx.xxx.xxx   xxxx_web50
-- xxx.xxx.xxx.xxx   xxxx_web21
-- xxx.xxx.xxx.xxx   xxxx_web96
-- xxx.xxx.xxx.xxx   xxxx_web91
-- xxx.xxx.xxx.xxx   xxxx_web97
-- xxx.xxx.xxx.xxx   xxxx_web62
-- xxx.xxx.xxx.xxx   xxxx_web14
-- xxx.xxx.xxx.xxx   xxxx_web32
-- xxx.xxx.xxx.xxx   xxxx_web95
-- xxx.xxx.xxx.xxx   xxxx_web10
-- xxx.xxx.xxx.xxx   xxxx_web75
-- xxx.xxx.xxx.xxx   xxxx_web93
-- xxx.xxx.xxx.xxx   xxxx_web20
-- xxx.xxx.xxx.xxx   xxxx_web63
-- xxx.xxx.xxx.xxx   xxxx_web73
-- xxx.xxx.xxx.xxx   xxxx_web33
-- xxx.xxx.xxx.xxx   xxxx_web74
-- xxx.xxx.xxx.xxx   xxxx_web16
-- xxx.xxx.xxx.xxx   xxxx_web71
-- xxx.xxx.xxx.xxx   xxxx_web39
-- xxx.xxx.xxx.xxx   xxxx_web38
-- xxx.xxx.xxx.xxx   xxxx_mrg06
-- xxx.xxx.xxx.xxx   xxxx_web100
-- xxx.xxx.xxx.xxx   xxxx_web86
-- xxx.xxx.xxx.xxx   xxxx_web51
-- xxx.xxx.xxx.xxx   xxxx_web44
-- xxx.xxx.xxx.xxx   xxxx_mrg03
-- xxx.xxx.xxx.xxx   xxxx_web69
-- xxx.xxx.xxx.xxx   xxxx_web98
-- xxx.xxx.xxx.xxx   xxxx_web87
-- xxx.xxx.xxx.xxx   xxxx_web12
-- xxx.xxx.xxx.xxx   xxxx_web27
-- xxx.xxx.xxx.xxx   xxxx_web02
-- xxx.xxx.xxx.xxx   xxxx_web76
-- xxx.xxx.xxx.xxx   xxxx_web59
-- xxx.xxx.xxx.xxx   xxxx_mrg04
-- xxx.xxx.xxx.xxx   xxxx_web18
-- xxx.xxx.xxx.xxx   xxxx_web01
-- xxx.xxx.xxx.xxx   xxxx_web61
-- xxx.xxx.xxx.xxx   xxxx_web99
-- xxx.xxx.xxx.xxx   xxxx_web56
-- xxx.xxx.xxx.xxx   xxxx_web07
-- xxx.xxx.xxx.xxx   xxxx_web82
-- xxx.xxx.xxx.xxx   xxxx_web03
-- xxx.xxx.xxx.xxx   xxxx_web90
-- xxx.xxx.xxx.xxx   xxxx_web64
-- xxx.xxx.xxx.xxx   xxxx_job01
-- xxx.xxx.xxx.xxx   xxxx_web25
-- xxx.xxx.xxx.xxx   xxxx_web78
-- xxx.xxx.xxx.xxx   xxxx_web65
-- xxx.xxx.xxx.xxx   xxxx_web17
-- xxx.xxx.xxx.xxx   xxxx_web06
-- xxx.xxx.xxx.xxx   xxxx_web30
-- xxx.xxx.xxx.xxx   xxxx_mrg05
-- xxx.xxx.xxx.xxx   xxxx_web15
-- xxx.xxx.xxx.xxx   xxxx_web45
-- xxx.xxx.xxx.xxx   xxxx_web48
-- xxx.xxx.xxx.xxx   xxxx_mrg07
-- xxx.xxx.xxx.xxx   xxxx_web42
-- xxx.xxx.xxx.xxx   xxxx_web92
-- xxx.xxx.xxx.xxx   xxxx_web23
-- xxx.xxx.xxx.xxx   xxxx_web54
-- xxx.xxx.xxx.xxx   xxxx_web81
-- xxx.xxx.xxx.xxx   xxxx_web89
-- xxx.xxx.xxx.xxx   xxxx_web83
-- xxx.xxx.xxx.xxx   xxxx_web31
-- xxx.xxx.xxx.xxx   xxxx_web11
-- xxx.xxx.xxx.xxx   xxxx_web49
-- xxx.xxx.xxx.xxx   xxxx_web60
-- xxx.xxx.xxx.xxx   xxxx_web67
-- xxx.xxx.xxx.xxx   xxxx_web36
-- xxx.xxx.xxx.xxx   xxxx_web08
-- xxx.xxx.xxx.xxx   xxxx_web80
-- xxx.xxx.xxx.xxx   xxxx_web40
-- xxx.xxx.xxx.xxx   xxxx_web43
-- xxx.xxx.xxx.xxx   xxxx_web72
-- xxx.xxx.xxx.xxx   xxxx_web05
-- xxx.xxx.xxx.xxx   xxxx_mrg08
-- xxx.xxx.xxx.xxx   xxxx_web47
-- xxx.xxx.xxx.xxx   xxxx_web37
-- xxx.xxx.xxx.xxx   xxxx_web85
-- xxx.xxx.xxx.xxx   xxxx_web84
-- xxx.xxx.xxx.xxx   xxxx_web19
-- xxx.xxx.xxx.xxx   xxxx_web77
-- xxx.xxx.xxx.xxx   xxxx_web26
-- xxx.xxx.xxx.xxx   xxxx_web22
-- xxx.xxx.xxx.xxx   xxxx_web88
-- xxx.xxx.xxx.xxx   xxxx_web55
-- xxx.xxx.xxx.xxx   xxxx_mrg02
-- xxx.xxx.xxx.xxx   xxxx_web79
-- xxx.xxx.xxx.xxx   xxxx_web41
-- xxx.xxx.xxx.xxx   xxxx_web66
-- xxx.xxx.xxx.xxx   xxxx_web52
-- xxx.xxx.xxx.xxx   xxxx_solr03
-- xxx.xxx.xxx.xxx   WIN-S3OFS4L0XXX
-- 
-- SYS@xxxx> SELECT machine
--   2         , resolveHost(machine) AS IP
--   3         , count(*)
--   4  FROM v$session
--   5  WHERE username IS NOT NULL
--   6  AND username <> 'SYS'
--   7  GROUP BY machine
--   8           , resolveHost(machine)
--   9  ORDER BY count(*) DESC
--  10  /
-- 
-- MACHINE              IP                COUNT(*)
-- -------------------- --------------- ----------
-- xxxxxxx102-132       xxx.xxx.xxx.xxx         81
-- xxxx_web01           xxx.xxx.xxx.xxx         20
-- xxxx_mrg01           xxx.xxx.xxx.xxx         10
-- xxxx_web13           xxx.xxx.xxx.xxx         10
-- xxxx_web09           xxx.xxx.xxx.xxx         10
-- xxxx_interface       xxx.xxx.xxx.xxx         10
-- xxxx_job02           xxx.xxx.xxx.xxx         10
-- xxxx_web58           xxx.xxx.xxx.xxx         10
-- xxxx_web35           xxx.xxx.xxx.xxx         10
-- xxxx_web68           xxx.xxx.xxx.xxx         10
-- xxxx_web94           xxx.xxx.xxx.xxx         10
-- xxxx_web53           xxx.xxx.xxx.xxx         10
-- xxxx_web28           xxx.xxx.xxx.xxx         10
-- xxxx_web24           xxx.xxx.xxx.xxx         10
-- xxxx_web46           xxx.xxx.xxx.xxx         10
-- xxxx_web70           xxx.xxx.xxx.xxx         10
-- xxxx_web34           xxx.xxx.xxx.xxx         10
-- xxxx_web96           xxx.xxx.xxx.xxx         10
-- xxxx_web50           xxx.xxx.xxx.xxx         10
-- xxxx_web04           xxx.xxx.xxx.xxx         10
-- xxxx_web97           xxx.xxx.xxx.xxx         10
-- xxxx_web21           xxx.xxx.xxx.xxx         10
-- xxxx_web91           xxx.xxx.xxx.xxx         10
-- xxxx_web95           xxx.xxx.xxx.xxx         10
-- xxxx_web62           xxx.xxx.xxx.xxx         10
-- xxxx_web14           xxx.xxx.xxx.xxx         10
-- xxxx_web32           xxx.xxx.xxx.xxx         10
-- xxxx_web10           xxx.xxx.xxx.xxx         10
-- xxxx_web20           xxx.xxx.xxx.xxx         10
-- xxxx_web75           xxx.xxx.xxx.xxx         10
-- xxxx_web93           xxx.xxx.xxx.xxx         10
-- xxxx_web33           xxx.xxx.xxx.xxx         10
-- xxxx_web63           xxx.xxx.xxx.xxx         10
-- xxxx_web73           xxx.xxx.xxx.xxx         10
-- xxxx_web74           xxx.xxx.xxx.xxx         10
-- xxxx_web71           xxx.xxx.xxx.xxx         10
-- xxxx_web16           xxx.xxx.xxx.xxx         10
-- xxxx_web38           xxx.xxx.xxx.xxx         10
-- xxxx_web100          xxx.xxx.xxx.xxx         10
-- xxxx_web39           xxx.xxx.xxx.xxx         10
-- xxxx_web86           xxx.xxx.xxx.xxx         10
-- xxxx_web51           xxx.xxx.xxx.xxx         10
-- xxxx_web44           xxx.xxx.xxx.xxx         10
-- xxxx_web98           xxx.xxx.xxx.xxx         10
-- xxxx_mrg03           xxx.xxx.xxx.xxx         10
-- xxxx_mrg06           xxx.xxx.xxx.xxx         10
-- xxxx_web69           xxx.xxx.xxx.xxx         10
-- xxxx_web87           xxx.xxx.xxx.xxx         10
-- xxxx_web12           xxx.xxx.xxx.xxx         10
-- xxxx_web27           xxx.xxx.xxx.xxx         10
-- xxxx_web59           xxx.xxx.xxx.xxx         10
-- xxxx_web02           xxx.xxx.xxx.xxx         10
-- xxxx_mrg04           xxx.xxx.xxx.xxx         10
-- xxxx_web18           xxx.xxx.xxx.xxx         10
-- xxxx_web76           xxx.xxx.xxx.xxx         10
-- xxxx_web61           xxx.xxx.xxx.xxx         10
-- xxxx_web99           xxx.xxx.xxx.xxx         10
-- xxxx_web56           xxx.xxx.xxx.xxx         10
-- xxxx_web07           xxx.xxx.xxx.xxx         10
-- xxxx_web82           xxx.xxx.xxx.xxx         10
-- xxxx_web03           xxx.xxx.xxx.xxx         10
-- xxxx_web90           xxx.xxx.xxx.xxx         10
-- xxxx_web06           xxx.xxx.xxx.xxx         10
-- xxxx_web64           xxx.xxx.xxx.xxx         10
-- xxxx_job01           xxx.xxx.xxx.xxx         10
-- xxxx_web25           xxx.xxx.xxx.xxx         10
-- xxxx_web78           xxx.xxx.xxx.xxx         10
-- xxxx_web65           xxx.xxx.xxx.xxx         10
-- xxxx_web17           xxx.xxx.xxx.xxx         10
-- xxxx_mrg05           xxx.xxx.xxx.xxx         10
-- xxxx_web30           xxx.xxx.xxx.xxx         10
-- xxxx_web15           xxx.xxx.xxx.xxx         10
-- xxxx_web11           xxx.xxx.xxx.xxx         10
-- xxxx_web89           xxx.xxx.xxx.xxx         10
-- xxxx_web81           xxx.xxx.xxx.xxx         10
-- xxxx_web42           xxx.xxx.xxx.xxx         10
-- xxxx_web23           xxx.xxx.xxx.xxx         10
-- xxxx_web54           xxx.xxx.xxx.xxx         10
-- xxxx_mrg07           xxx.xxx.xxx.xxx         10
-- xxxx_web60           xxx.xxx.xxx.xxx         10
-- xxxx_web67           xxx.xxx.xxx.xxx         10
-- xxxx_web45           xxx.xxx.xxx.xxx         10
-- xxxx_web36           xxx.xxx.xxx.xxx         10
-- xxxx_web08           xxx.xxx.xxx.xxx         10
-- xxxx_web92           xxx.xxx.xxx.xxx         10
-- xxxx_web31           xxx.xxx.xxx.xxx         10
-- xxxx_web40           xxx.xxx.xxx.xxx         10
-- xxxx_web43           xxx.xxx.xxx.xxx         10
-- xxxx_web72           xxx.xxx.xxx.xxx         10
-- xxxx_web83           xxx.xxx.xxx.xxx         10
-- xxxx_web48           xxx.xxx.xxx.xxx         10
-- xxxx_web80           xxx.xxx.xxx.xxx         10
-- xxxx_web05           xxx.xxx.xxx.xxx         10
-- xxxx_web49           xxx.xxx.xxx.xxx         10
-- xxxx_web22           xxx.xxx.xxx.xxx         10
-- xxxx_mrg08           xxx.xxx.xxx.xxx         10
-- xxxx_web47           xxx.xxx.xxx.xxx         10
-- xxxx_web37           xxx.xxx.xxx.xxx         10
-- xxxx_web85           xxx.xxx.xxx.xxx         10
-- xxxx_web84           xxx.xxx.xxx.xxx         10
-- xxxx_web19           xxx.xxx.xxx.xxx         10
-- xxxx_web88           xxx.xxx.xxx.xxx         10
-- xxxx_web26           xxx.xxx.xxx.xxx         10
-- xxxx_mrg02           xxx.xxx.xxx.xxx         10
-- xxxx_web77           xxx.xxx.xxx.xxx         10
-- xxxx_web41           xxx.xxx.xxx.xxx         10
-- xxxx_web55           xxx.xxx.xxx.xxx         10
-- xxxx_web66           xxx.xxx.xxx.xxx         10
-- xxxx_web52           xxx.xxx.xxx.xxx         10
-- xxxx_web79           xxx.xxx.xxx.xxx         10
-- xxxx03               xxx.xxx.xxx.xxx          5
-- xxxx                 xxx.xxx.xxx.xxx          2
-- xxxx02               xxx.xxx.xxx.xxx          1
-- WIN-S3OFS4L0XXX      xxx.xxx.xxx.xxx          1
-- xxxx_solr03          xxx.xxx.xxx.xxx          1
-- 
-- 115 rows selected.
