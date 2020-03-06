REM
REM     Script:        topN_query_descending_index(bug).sql
REM     Author:        Quanwen Zhao
REM     Dated:         Mar 06, 2020
REM
REM     Last tested:
REM             19.3.0.0
REM
REM     Purpose:  
REM       This sql script uses to observe the execution plan of top-N (20) query on Oracle Database
REM       via calling DBMS_XPLAN.display_cursor().
REM
REM       Here I intend to only use "ROWNUM" methods to check the row-source execution plan just
REM       retrieving top 20 lines of SQL query.
REM

CONN qwz/qwz;

ALTER SESSION SET nls_date_format = 'YYYY-MM-DD';

DROP TABLE staff PURGE;
  
CREATE TABLE staff
  ( id        NUMBER       CONSTRAINT staff_pk PRIMARY KEY
  , name      VARCHAR2 (6) NOT NULL
  , sex       NUMBER   (1) NOT NULL
  , birth_day DATE         NOT NULL
  , address   VARCHAR2(16) NOT NULL
  , email     VARCHAR2(15)
  , qq        NUMBER   (9)
  )
NOLOGGING  
;
  
INSERT /*+ APPEND */
INTO staff (id, name, sex, birth_day, address, email, qq)
SELECT ROWNUM                                                                      AS id
     , DBMS_RANDOM.string('A', 6)                                                  AS name
     , ROUND(DBMS_RANDOM.value(0, 1))                                              AS sex
     , TO_DATE('1977-06-14', 'YYYY-MM-DD') + TRUNC(DBMS_RANDOM.value(-4713, 9999)) AS birth_day
     , DBMS_RANDOM.string('L', 16)                                                 AS address
     , DBMS_RANDOM.string('L', 6) || '@' || DBMS_RANDOM.string('L', 4) || '.com'   AS email
     , DBMS_RANDOM.value(10000001, 999999999)                                      AS qq
FROM dual
CONNECT BY level <= 1e4;
  
COMMIT;
  
CREATE INDEX idx_staff_nb ON staff (name, birth_day);
  
EXEC DBMS_STATS.gather_table_stats('','STAFF');

SET LINESIZE 300
SET PAGESIZE 150
SET SERVEROUTPUT OFF
  
ALTER SESSION SET statistics_level = all;

PROMPT ======================
PROMPT Descending Index (1st)
PROMPT ======================

CREATE INDEX idx_staff_desc_nb ON staff (name DESC, birth_day DESC);
ALTER INDEX idx_staff_nb INVISIBLE;

SELECT *
  FROM (   SELECT *
             FROM staff
            WHERE name like 'q%'
         ORDER BY name DESC
                , birth_day DESC
       )
 WHERE ROWNUM <= 20;
 
        ID NAME          SEX BIRTH_DAY  ADDRESS          EMAIL                   QQ
---------- ------ ---------- ---------- ---------------- --------------- ----------
      2352 qzzgEu          0 1978-05-27 dgedeirqhqacunfy lzkueq@yogn.com  237411687
      5259 qzQtfg          0 1990-01-04 xyosklnpkemrwrlh hwexfw@njyp.com  661387128
      8877 qzCmpl          0 2003-09-03 pzzzztbdzjhfzqus mlxfgt@mpik.com   79574047
      2745 qyqjYu          1 1984-11-01 inqenztyaxvlaetw dszhho@bdrq.com  211040055
      6295 qyqiSD          1 1987-06-15 mnpvchlcbkugtfzq rlhqml@eibi.com  279127083
      9674 qykOro          0 1964-11-25 yiawsptjfjkrkdwq fvigpc@xgtz.com  361018054
      4910 qxuswS          1 2001-04-21 qziuyuxemmdtaguj vqiyex@ipgr.com  582485271
      6518 qxlUgY          0 1995-03-20 axvqqxavvohdftxj pokauq@enln.com  465220477
      3657 qxSzGc          1 1974-02-02 sauvobevcecgcllh pexggy@nuwb.com  998276009
      7963 qxFktX          1 1983-02-18 lvovcilnlueyxhqk uywkse@fwpe.com  102420921
      2379 qwhsZN          0 1975-11-11 ggtchqsicoknyweq esuuwg@jwcv.com   64822749
      1953 qweIWD          1 1983-02-18 nvrfqilmbonlfvov msbopg@ssaz.com  105006759
      2420 qwWXuq          0 1969-01-20 mljlhfmppciwpnwx eidozw@ptfx.com  176107250
      6897 qvizlM          1 2000-03-15 dcwpwexvbacltnbv bqwlxi@lwut.com  182492319
      8251 qviWkb          0 1990-11-05 fwkdanfftltawwuc mjuhew@bwlq.com  348161621
      4106 qvQeXk          0 1976-02-26 qsdbsxkcpfgmzurk txscxe@cgrq.com  602680801
      4300 qusGcY          1 1965-05-11 rgsyubvlgwamleha zzqqgn@svol.com  517782598
      4011 quYPah          1 2000-05-25 gcahbialxfycqhli wpgoat@ugyd.com  260555290
      8067 quEcuI          0 1968-11-02 qletmgcfootgdwkp aoqdsh@iido.com  835499902
      8215 qtjxdn          0 1994-08-28 nqhnezxexwtsplqy asikwx@mppe.com  226751859
 
20 rows selected.

SELECT * FROM table(DBMS_XPLAN.display_cursor(NULL, NULL, 'ALLSTATS LAST OUTLINE +COST'));
 
Plan hash value: 4121444944
 
-----------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation               | Name  | Starts | E-Rows | Cost (%CPU)| A-Rows |   A-Time   | Buffers |  OMem |  1Mem | Used-Mem |
-----------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT        |       |      1 |        |    30 (100)|     20 |00:00:00.01 |      96 |       |       |          |
|*  1 |  COUNT STOPKEY          |       |      1 |        |            |     20 |00:00:00.01 |      96 |       |       |          |
|   2 |   VIEW                  |       |      1 |    176 |    30   (4)|     20 |00:00:00.01 |      96 |       |       |          |
|*  3 |    SORT ORDER BY STOPKEY|       |      1 |    176 |    30   (4)|     20 |00:00:00.01 |      96 |  6144 |  6144 | 6144  (0)|
|*  4 |     TABLE ACCESS FULL   | STAFF |      1 |    176 |    29   (0)|    184 |00:00:00.01 |      96 |       |       |          |
-----------------------------------------------------------------------------------------------------------------------------------
 
Outline Data
-------------
 
  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$2")
      OUTLINE_LEAF(@"SEL$1")
      NO_ACCESS(@"SEL$1" "from$_subquery$_001"@"SEL$1")
      FULL(@"SEL$2" "STAFF"@"SEL$2")
      END_OUTLINE_DATA
  */
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - filter(ROWNUM<=20)
   3 - filter(ROWNUM<=20)
   4 - filter("NAME" LIKE 'q%')

SELECT *
  FROM (   SELECT /*+ index_desc(staff idx_staff_desc_nb) */ *
             FROM staff
            WHERE name like 'q%'
         ORDER BY name DESC
                , birth_day DESC
       )
 WHERE ROWNUM <= 20;
 
        ID NAME          SEX BIRTH_DAY  ADDRESS          EMAIL                   QQ
---------- ------ ---------- ---------- ---------------- --------------- ----------
      2352 qzzgEu          0 1978-05-27 dgedeirqhqacunfy lzkueq@yogn.com  237411687
      5259 qzQtfg          0 1990-01-04 xyosklnpkemrwrlh hwexfw@njyp.com  661387128
      8877 qzCmpl          0 2003-09-03 pzzzztbdzjhfzqus mlxfgt@mpik.com   79574047
      2745 qyqjYu          1 1984-11-01 inqenztyaxvlaetw dszhho@bdrq.com  211040055
      6295 qyqiSD          1 1987-06-15 mnpvchlcbkugtfzq rlhqml@eibi.com  279127083
      9674 qykOro          0 1964-11-25 yiawsptjfjkrkdwq fvigpc@xgtz.com  361018054
      4910 qxuswS          1 2001-04-21 qziuyuxemmdtaguj vqiyex@ipgr.com  582485271
      6518 qxlUgY          0 1995-03-20 axvqqxavvohdftxj pokauq@enln.com  465220477
      3657 qxSzGc          1 1974-02-02 sauvobevcecgcllh pexggy@nuwb.com  998276009
      7963 qxFktX          1 1983-02-18 lvovcilnlueyxhqk uywkse@fwpe.com  102420921
      2379 qwhsZN          0 1975-11-11 ggtchqsicoknyweq esuuwg@jwcv.com   64822749
      1953 qweIWD          1 1983-02-18 nvrfqilmbonlfvov msbopg@ssaz.com  105006759
      2420 qwWXuq          0 1969-01-20 mljlhfmppciwpnwx eidozw@ptfx.com  176107250
      6897 qvizlM          1 2000-03-15 dcwpwexvbacltnbv bqwlxi@lwut.com  182492319
      8251 qviWkb          0 1990-11-05 fwkdanfftltawwuc mjuhew@bwlq.com  348161621
      4106 qvQeXk          0 1976-02-26 qsdbsxkcpfgmzurk txscxe@cgrq.com  602680801
      4300 qusGcY          1 1965-05-11 rgsyubvlgwamleha zzqqgn@svol.com  517782598
      4011 quYPah          1 2000-05-25 gcahbialxfycqhli wpgoat@ugyd.com  260555290
      8067 quEcuI          0 1968-11-02 qletmgcfootgdwkp aoqdsh@iido.com  835499902
      8215 qtjxdn          0 1994-08-28 nqhnezxexwtsplqy asikwx@mppe.com  226751859
 
20 rows selected.
 
SELECT * FROM table(DBMS_XPLAN.display_cursor(NULL, NULL, 'ALLSTATS LAST OUTLINE +COST +HINT_REPORT'));
 
Plan hash value: 2642568052
 
--------------------------------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                              | Name              | Starts | E-Rows | Cost (%CPU)| A-Rows |   A-Time   | Buffers |  OMem |  1Mem | Used-Mem |
--------------------------------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                       |                   |      1 |        |   539 (100)|     20 |00:00:00.01 |     224 |       |       |          |
|*  1 |  COUNT STOPKEY                         |                   |      1 |        |            |     20 |00:00:00.01 |     224 |       |       |          |
|   2 |   VIEW                                 |                   |      1 |    176 |   539   (1)|     20 |00:00:00.01 |     224 |       |       |          |
|*  3 |    SORT ORDER BY STOPKEY               |                   |      1 |    176 |   539   (1)|     20 |00:00:00.01 |     224 |  9216 |  9216 | 8192  (0)|
|   4 |     TABLE ACCESS BY INDEX ROWID BATCHED| STAFF             |      1 |    176 |   538   (1)|    184 |00:00:00.01 |     224 |       |       |          |
|*  5 |      INDEX FULL SCAN DESCENDING        | IDX_STAFF_DESC_NB |      1 |    500 |    42   (0)|    184 |00:00:00.01 |      42 |       |       |          |
--------------------------------------------------------------------------------------------------------------------------------------------------------------
 
Outline Data
-------------
 
  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$2")
      OUTLINE_LEAF(@"SEL$1")
      NO_ACCESS(@"SEL$1" "from$_subquery$_001"@"SEL$1")
      INDEX_DESC(@"SEL$2" "STAFF"@"SEL$2" "IDX_STAFF_DESC_NB")
      BATCH_TABLE_ACCESS_BY_ROWID(@"SEL$2" "STAFF"@"SEL$2")
      END_OUTLINE_DATA
  */
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - filter(ROWNUM<=20)
   3 - filter(ROWNUM<=20)
   5 - filter(SYS_OP_UNDESCEND("STAFF"."SYS_NC00008$") LIKE 'q%')
 
Hint Report (identified by operation id / Query Block Name / Object Alias):
Total hints for statement: 1
---------------------------------------------------------------------------
 
   4 -  SEL$2 / STAFF@SEL$2
           -  index_desc(staff idx_staff_desc_nb)

SELECT *
  FROM (   SELECT /*+ index_rs_desc(staff idx_staff_desc_nb) */ *
             FROM staff
            WHERE name like 'q%'
         ORDER BY name DESC
                , birth_day DESC
       )
 WHERE ROWNUM <= 20;
 
SELECT * FROM table(DBMS_XPLAN.display_cursor(NULL, NULL, 'ALLSTATS LAST OUTLINE +COST +HINT_REPORT'));
 
......
 
Plan hash value: 4121444944
 
-----------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation               | Name  | Starts | E-Rows | Cost (%CPU)| A-Rows |   A-Time   | Buffers |  OMem |  1Mem | Used-Mem |
-----------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT        |       |      1 |        |    30 (100)|     20 |00:00:00.01 |      96 |       |       |          |
|*  1 |  COUNT STOPKEY          |       |      1 |        |            |     20 |00:00:00.01 |      96 |       |       |          |
|   2 |   VIEW                  |       |      1 |    198 |    30   (4)|     20 |00:00:00.01 |      96 |       |       |          |
|*  3 |    SORT ORDER BY STOPKEY|       |      1 |    198 |    30   (4)|     20 |00:00:00.01 |      96 |  6144 |  6144 | 6144  (0)|
|*  4 |     TABLE ACCESS FULL   | STAFF |      1 |    198 |    29   (0)|    184 |00:00:00.01 |      96 |       |       |          |
-----------------------------------------------------------------------------------------------------------------------------------
 
Outline Data
-------------
 
  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$2")
      OUTLINE_LEAF(@"SEL$1")
      NO_ACCESS(@"SEL$1" "from$_subquery$_001"@"SEL$1")
      FULL(@"SEL$2" "STAFF"@"SEL$2")
      END_OUTLINE_DATA
  */
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - filter(ROWNUM<=20)
   3 - filter(ROWNUM<=20)
   4 - filter("NAME" LIKE 'q%')
 
Hint Report (identified by operation id / Query Block Name / Object Alias):
Total hints for statement: 1 (U - Unused (1))
---------------------------------------------------------------------------
 
   4 -  SEL$2 / STAFF@SEL$2
         U -  index_rs_desc(staff idx_staff_desc_nb)

PROMPT =====================
PROMPT Ascending Index (2nd)
PROMPT =====================

ALTER INDEX idx_staff_nb      VISIBLE;
ALTER INDEX idx_staff_desc_nb INVISIBLE;

SELECT *
  FROM (   SELECT *
             FROM staff
            WHERE name like 'q%'
         ORDER BY name DESC
                , birth_day DESC
       )
 WHERE ROWNUM <= 20;
 
        ID NAME          SEX BIRTH_DAY  ADDRESS          EMAIL                   QQ
---------- ------ ---------- ---------- ---------------- --------------- ----------
      2352 qzzgEu          0 1978-05-27 dgedeirqhqacunfy lzkueq@yogn.com  237411687
      5259 qzQtfg          0 1990-01-04 xyosklnpkemrwrlh hwexfw@njyp.com  661387128
      8877 qzCmpl          0 2003-09-03 pzzzztbdzjhfzqus mlxfgt@mpik.com   79574047
      2745 qyqjYu          1 1984-11-01 inqenztyaxvlaetw dszhho@bdrq.com  211040055
      6295 qyqiSD          1 1987-06-15 mnpvchlcbkugtfzq rlhqml@eibi.com  279127083
      9674 qykOro          0 1964-11-25 yiawsptjfjkrkdwq fvigpc@xgtz.com  361018054
      4910 qxuswS          1 2001-04-21 qziuyuxemmdtaguj vqiyex@ipgr.com  582485271
      6518 qxlUgY          0 1995-03-20 axvqqxavvohdftxj pokauq@enln.com  465220477
      3657 qxSzGc          1 1974-02-02 sauvobevcecgcllh pexggy@nuwb.com  998276009
      7963 qxFktX          1 1983-02-18 lvovcilnlueyxhqk uywkse@fwpe.com  102420921
      2379 qwhsZN          0 1975-11-11 ggtchqsicoknyweq esuuwg@jwcv.com   64822749
      1953 qweIWD          1 1983-02-18 nvrfqilmbonlfvov msbopg@ssaz.com  105006759
      2420 qwWXuq          0 1969-01-20 mljlhfmppciwpnwx eidozw@ptfx.com  176107250
      6897 qvizlM          1 2000-03-15 dcwpwexvbacltnbv bqwlxi@lwut.com  182492319
      8251 qviWkb          0 1990-11-05 fwkdanfftltawwuc mjuhew@bwlq.com  348161621
      4106 qvQeXk          0 1976-02-26 qsdbsxkcpfgmzurk txscxe@cgrq.com  602680801
      4300 qusGcY          1 1965-05-11 rgsyubvlgwamleha zzqqgn@svol.com  517782598
      4011 quYPah          1 2000-05-25 gcahbialxfycqhli wpgoat@ugyd.com  260555290
      8067 quEcuI          0 1968-11-02 qletmgcfootgdwkp aoqdsh@iido.com  835499902
      8215 qtjxdn          0 1994-08-28 nqhnezxexwtsplqy asikwx@mppe.com  226751859
 
20 rows selected.
 
SELECT * FROM table(DBMS_XPLAN.display_cursor(NULL, NULL, 'ALLSTATS LAST OUTLINE +COST'));
 
Plan hash value: 1920017108
 
----------------------------------------------------------------------------------------------------------------------
| Id  | Operation                      | Name         | Starts | E-Rows | Cost (%CPU)| A-Rows |   A-Time   | Buffers |
----------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT               |              |      1 |        |    22 (100)|     20 |00:00:00.01 |      24 |
|*  1 |  COUNT STOPKEY                 |              |      1 |        |            |     20 |00:00:00.01 |      24 |
|   2 |   VIEW                         |              |      1 |     20 |    22   (0)|     20 |00:00:00.01 |      24 |
|   3 |    TABLE ACCESS BY INDEX ROWID | STAFF        |      1 |    198 |    22   (0)|     20 |00:00:00.01 |      24 |
|*  4 |     INDEX RANGE SCAN DESCENDING| IDX_STAFF_NB |      1 |     20 |     2   (0)|     20 |00:00:00.01 |       4 |
----------------------------------------------------------------------------------------------------------------------
 
Outline Data
-------------
 
  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$2")
      OUTLINE_LEAF(@"SEL$1")
      NO_ACCESS(@"SEL$1" "from$_subquery$_001"@"SEL$1")
      INDEX_RS_DESC(@"SEL$2" "STAFF"@"SEL$2" ("STAFF"."NAME" "STAFF"."BIRTH_DAY"))
      END_OUTLINE_DATA
  */
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - filter(ROWNUM<=20)
   4 - access("NAME" LIKE 'q%')
       filter("NAME" LIKE 'q%')
