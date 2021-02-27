REM
REM     Script:        session_tz_and_timestamp_ltz_bug.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Feb 25, 2021
REM
REM     Last tested:
REM             19.8.0.0 -- LiveSQL
REM
REM     Purpose:
REM       A bug for sessiontimezone and timestamp with local time zone?
REM       You can also read my Oracle LiveSQL script shared page: https://livesql.oracle.com/apex/livesql/s/le8okspgljyqp3v0qvt4wh3pc
REM       I finished testing the Chris Saxon's LiveSQL script - https://livesql.oracle.com/apex/livesql/s/ermxk7o6mt2g8fwugojorrwlm
REM       and found that there has two number of bug(s):
REM         1. after altering the sessiontimezone, its value has not been changed;
REM         2. the value of column 'local_ts' in table 't' is not always correct by altering the value of sessiontimezone.
REM
REM       By the way Mentzel Ludith pointed out ot me on LinkedIn that it is NOT a bug on LiveSQL. If I run all of my STATEMENTS
REM       in a single session, it won't produce the case like me (get the same result with Chris) because LiveSQL is a WEB
REM       environment with shared sessions.
REM
REM       Hence, it's NOT bug!!! But it is very easy to misunderstand running those statements one by one
REM       particularly finished reading someone's shared script.
REM

SELECT dbtimezone, sessiontimezone FROM DUAL;

-- DBTIMEZONE	SESSIONTIMEZONE
-- ---------- ---------------
-- +00:00	    US/Pacific

ALTER SESSION SET time_zone = '00:00';

-- Statement processed.

-- As you can see the value of sessiontimezoe is still showing 'US/Pacific' although I set which is '00:00', so weird!!!

SELECT dbtimezone, sessiontimezone FROM DUAL;

-- DBTIMEZONE	SESSIONTIMEZONE
-- ---------- ---------------
-- +00:00	    US/Pacific

CREATE TABLE t (  
  non_local_ts TIMESTAMP WITH TIME ZONE,  
  local_ts     TIMESTAMP WITH LOCAL TIME ZONE  
);

-- Table created.

INSERT INTO t VALUES (   
  timestamp'2017-01-01 00:00:00 +10:00',   
  timestamp'2017-01-01 00:00:00 +10:00'   
);

-- 1 row(s) inserted.

-- You know, the session time zone is currently on '00:00', so the value of column local_ts should be '31-DEC-16 02.00.00.000000 PM'
-- (which need normalize to UTC, so it shoud be UTC time - 10 hours, because dbtimezone is '+00:00'),
-- but the query result is unexpectedly '31-DEC-16 06.00.00.000000 AM'. So weird!!!

SELECT * FROM t;

-- NON_LOCAL_TS	                       LOCAL_TS
-- ----------------------------------- ----------------------------
-- 01-JAN-17 12.00.00.000000 AM +10:00 31-DEC-16 06.00.00.000000 AM

ALTER SESSION SET time_zone = '-5:00';

-- Statement processed.

-- As you can see even if I altered the sessiontimezone to be '-05:00',
-- but the value of column local_ts is also the very weird '31-DEC-16 06.00.00.000000 AM'.
-- I think which is this '31-DEC-16 09.00.00.000000 AM'.

SELECT * FROM t;

-- NON_LOCAL_TS	                       LOCAL_TS
-- ----------------------------------- ----------------------------
-- 01-JAN-17 12.00.00.000000 AM +10:00 31-DEC-16 06.00.00.000000 AM
