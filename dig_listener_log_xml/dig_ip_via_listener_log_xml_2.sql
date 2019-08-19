REM
REM        Script:        dig_ip_via_listener_log_xml_2.sql
REM        Author:        Quanwen Zhao
REM        Dated:         Aug 19, 2019
REM
REM        Purpose:
REM            The 2nd version of the prior SQL script "dig_ip_via_listener_log_xml.sql" on the directory "dig_listener_log_xml",
REM            the sole distinguish is this time I use "*" (using "NEWLINE" on 1st version) as a record delimited character
REM            when I create that external table.
REM
REM        Last tested:
REM                Oracle 11.2.0.4.0
REM

PROMPT =========================
PROMPT Executing on "SYS" schema
PROMPT =========================

CREATE OR REPLACE DIRECTORY xmldir AS '/u01/app/oracle/diag/tnslsnr/xxxx/listener/alert';

DROP TABLE listener_log_xml;

CREATE TABLE listener_log_xml (line VARCHAR2(4000))
ORGANIZATION EXTERNAL (
  TYPE ORACLE_LOADER
  DEFAULT DIRECTORY xmldir
  ACCESS PARAMETERS (
    RECORDS DELIMITED BY '*'
    NOBADFILE
    NOLOGFILE
    NODISCARDFILE
    FIELDS LDRTRIM
    MISSING FIELD VALUES ARE NULL
    REJECT ROWS WITH ALL NULL FIELDS
    (
      line CHAR(4000)
    )
  )
  LOCATION ('log.xml')
)
REJECT LIMIT UNLIMITED
/
    
SET LONG 999999999    
SET PAGESIZE 80

SELECT line FROM listener_log_xml WHERE rownum <= 6
/

SELECT * FROM listener_log_xml WHERE line LIKE '%PORT%' AND rownum <= 12
/

SET PAGESIZE 200
COLUMN host FORMAT a15

SELECT DISTINCT SUBSTR(host, 1, INSTR(host, ')')-1) AS host
FROM
  ( SELECT SUBSTR(line, INSTR(line, 'HOST=', 1)+5) AS host
    FROM  
      ( SELECT *
        FROM listener_log_xml
        WHERE line LIKE '%PORT%'
      )
  )
ORDER BY 1
/

-- 
-- The following demo is a detailed operation steps on a specific production system of oracle database.
-- 
-- BTW due to security reason I deliberately hidden my real IP Address and db_name 
-- on version 11.2.0.4.0 of my oracle Production System.
-- 
-- SYS@xxxx> create or replace directory LISTENER_LOG_XML as '/u01/app/oracle/diag/tnslsnr/xxxx/listener/alert';
-- 
-- Directory created.
-- 
-- SYS@xxxx> drop table listener_log_xml;
-- drop table listener_log_xml
--            *
-- ERROR at line 1:
-- ORA-00942: table or view does not exist
-- 
-- SYS@xxxx> create table listener_log_xml (line varchar2(4000))
--   2  organization external (
--   3    type oracle_loader
--   4    default directory LISTENER_LOG_XML
--   5    access parameters (
--   6      records delimited by '*'
--   7      nobadfile
--   8      nologfile
--   9      nodiscardfile
--  10      fields ldrtrim
--  11      missing field values are null
--  12      reject rows with all null fields
--  13      ( 
--  14        line char(4000)
--  15      )
--  16    )
--  17    location ('log.xml')
--  18  )
--  19  reject limit unlimited
--  20  /
-- 
-- Table created.
-- 
    
-- SYS@xxxx> SET LONG 999999999    
-- SYS@xxxx> SET PAGESIZE 80
-- 
-- SYS@xxxx> SELECT line FROM listener_log_xml WHERE rownum <= 6
-- /
-- 
-- LINE
-- --------------------------------------------------------------------------------
-- <msg time='2019-08-12T20:38:17.906+08:00' org_id='oracle' comp_id='tnslsnr'
--  type='UNKNOWN' level='16' host_id='xxxx'
--  host_addr='xxx.xxx.xxx.xxx' version='1'>
--  <txt>12-AUG-2019 20:38:17
-- 
--  (CONNECT_DATA=(CID=(PROGRAM=)(HOST=__jdbc__)(USER=root))(SERVICE_NAME=xxxx)
-- (CID=(PROGRAM=)(HOST=__jdbc__)(USER=root)))
-- 
--  (ADDRESS=(PROTOCOL=tcp)(HOST=xxx.xxx.xxx.xxx)(PORT=55604))
--  establish
--  xxxx
--  0
--  </txt>
-- </msg>
-- <msg time='2019-08-12T20:38:17.906+08:00' org_id='oracle' comp_id='tnslsnr'
--  type='UNKNOWN' level='16' host_id='xxxx'
--  host_addr='xxx.xxx.xxx.xxx'>
--  <txt>12-AUG-2019 20:38:17
-- 
-- 
-- 6 rows selected.
-- 
-- SYS@xxxx> SELECT * FROM listener_log_xml WHERE line LIKE '%PORT%' AND rownum <= 12
-- /
-- 
-- LINE
-- --------------------------------------------------------------------------------
--  (ADDRESS=(PROTOCOL=tcp)(HOST=xxx.xxx.xxx.xxx)(PORT=55604))
--  (ADDRESS=(PROTOCOL=tcp)(HOST=xxx.xxx.xxx.xxx)(PORT=55600))
--  (ADDRESS=(PROTOCOL=tcp)(HOST=xxx.xxx.xxx.xxx)(PORT=55606))
--  (ADDRESS=(PROTOCOL=tcp)(HOST=xxx.xxx.xxx.xxx)(PORT=55608))
--  (ADDRESS=(PROTOCOL=tcp)(HOST=xxx.xxx.xxx.xxx)(PORT=55610))
--  (ADDRESS=(PROTOCOL=tcp)(HOST=xxx.xxx.xxx.xxx)(PORT=55612))
--  (ADDRESS=(PROTOCOL=tcp)(HOST=xxx.xxx.xxx.xxx)(PORT=55614))
--  (ADDRESS=(PROTOCOL=tcp)(HOST=xxx.xxx.xxx.xxx)(PORT=55616))
--  (ADDRESS=(PROTOCOL=tcp)(HOST=xxx.xxx.xxx.xxx)(PORT=55618))
--  (ADDRESS=(PROTOCOL=tcp)(HOST=xxx.xxx.xxx.xxx)(PORT=55620))
--  (ADDRESS=(PROTOCOL=tcp)(HOST=xxx.xxx.xxx.xxx)(PORT=55624))
--  (ADDRESS=(PROTOCOL=tcp)(HOST=xxx.xxx.xxx.xxx)(PORT=55622))
-- 
-- 12 rows selected.
-- 
-- SYS@xxxx> SET PAGESIZE 200
-- SYS@xxxx> COLUMN host FORMAT a15
-- SYS@xxxx> 
-- SYS@xxxx> SELECT DISTINCT SUBSTR(host, 1, INSTR(host, ')')-1) AS host
--   2  FROM
--   3    ( SELECT SUBSTR(line, INSTR(line, 'HOST=', 1)+5) AS host
--   4      FROM  
--   5        ( SELECT *
--   6          FROM listener_log_xml
--   7          WHERE line LIKE '%PORT%'
--   8        )
--   9    )    
--  10  WHERE rownum <= 12
--  11  /
-- 
-- HOST
-- ---------------
-- xxx.xxx.xxx.xxx
