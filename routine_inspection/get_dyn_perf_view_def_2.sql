REM
REM     Script:        get_dyn_perf_view_def_2.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Nov 06, 2019
REM
REM     Notice:
REM       SQL> desc v$fixed_view_definition
REM             Name                                      Null?    Type
REM             ----------------------------------------- -------- ----------------------------
REM             VIEW_NAME                                          VARCHAR2(30)
REM             VIEW_DEFINITION                                    VARCHAR2(4000)
REM
REM     Purpose:
REM       The 2nd version of SQL script "get_dyn_perf_view_def.sql" - using "accept" of SQL*Plus command on Oracle Database.
REM

SET VERIFY   OFF
SET PAGESIZE 400

PROMPT =====================
PROMPT running on SYS schema
PROMPT =====================

ACCEPT view_name char PROMPT 'Please input a value of VIEW_NAME: ';

SELECT view_definition
  FROM v$fixed_view_definition
 WHERE view_name = UPPER ('&view_name')
/

-- A simple demo here which I give.
-- 
-- SQL> @get_dyn_perf_view_def_2.sql
-- =====================
-- running on SYS schema
-- =====================
-- Please input a value of VIEW_NAME: gv$temp_space_header
-- 
-- VIEW_DEFINITION
-- --------------------------------------------------------------------------------
-- select /*+ ordered use_nl(hc) */ hc.inst_id, ts.name, hc.ktfthctfno, (hc.ktfthcs
-- z - hc.ktfthcfree)*ts.blocksize, (hc.ktfthcsz - hc.ktfthcfree), hc.ktfthcfree*ts
-- .blocksize, hc.ktfthcfree, hc.ktfthcfno from ts$ ts, x$ktfthc hc where ts.conten
-- ts$ = 1 and ts.bitmapped <> 0 and ts.online$ = 1 and ts.ts# = hc.ktfthctsn and h
-- c.ktfthccval = 0
