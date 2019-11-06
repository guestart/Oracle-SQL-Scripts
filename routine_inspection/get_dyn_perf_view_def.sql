REM
REM     Script:        get_dyn_perf_view_def.sql
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
REM       This SQL script usually uses to get the definition of dynamic performance view on Oracle Database.
REM

SET VERIFY   OFF
SET PAGESIZE 400

PROMPT =====================
PROMPT running on SYS schema
PROMPT =====================

SELECT view_definition
  FROM v$fixed_view_definition
 WHERE view_name = UPPER ('&view_name')
/

-- A simple demo here which I give.
-- 
-- SQL> SELECT view_definition
--   2    FROM v$fixed_view_definition
--   3   WHERE view_name = UPPER ('&view_name')
--   4  /
-- Enter value for view_name: gv$temp_space_header
-- 
-- VIEW_DEFINITION
-- --------------------------------------------------------------------------------
-- select /*+ ordered use_nl(hc) */ hc.inst_id, ts.name, hc.ktfthctfno, (hc.ktfthcs
-- z - hc.ktfthcfree)*ts.blocksize, (hc.ktfthcsz - hc.ktfthcfree), hc.ktfthcfree*ts
-- .blocksize, hc.ktfthcfree, hc.ktfthcfno from ts$ ts, x$ktfthc hc where ts.conten
-- ts$ = 1 and ts.bitmapped <> 0 and ts.online$ = 1 and ts.ts# = hc.ktfthctsn and h
-- c.ktfthccval = 0
