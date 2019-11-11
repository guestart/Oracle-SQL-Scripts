REM
REM     Script:        compare_plsql_output.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Nov 11, 2019
REM
REM     Purpose:
REM       This SQL script usually uses to compare the output result of two types of PLSQL code:
REM         https://livesql.oracle.com/apex/livesql/file/content_I7MK5SLZ8O4DZJPP2EXOFOKIW.html
REM       BTW it has been published by Steven Feuerstein (@sfonplsql) as a Twitter quiz on Nov 6, 2019:
REM         https://twitter.com/sfonplsql/status/1192164495654825984
REM       and explored in his blog post:
REM         https://stevenfeuersteinonplsql.blogspot.com/2019/11/plsql-puzzle-what-code-can-be-removed.html
REM

-- First creating a named procedure "puzzle_plsql_1" on SYS schema of Oracle Database 11.2.0.4.0
-- 

CREATE OR REPLACE PROCEDURE
puzzle_plsql_1
IS
   indx        PLS_INTEGER;

   TYPE objects_t IS TABLE OF all_objects.object_name%TYPE
      INDEX BY PLS_INTEGER;

   l_empty     objects_t;
   l_objects   objects_t := l_empty;
BEGIN
   l_objects.delete;
   
   IF l_objects.LAST IS NOT NULL
   THEN
      DBMS_OUTPUT.put_line (l_objects.COUNT);
   END IF;

   l_objects (100) := 'BLIP';

     SELECT object_name
       BULK COLLECT INTO l_objects
       FROM all_objects
      WHERE object_name LIKE '%TABLE%'
   ORDER BY object_name;

   FOR indx IN 1 .. l_objects.COUNT
   LOOP
      DBMS_OUTPUT.put_line (l_objects (indx));
      EXIT WHEN indx = l_objects.COUNT;
   END LOOP;
END puzzle_plsql_1;
/

-- Next executing it (SQL> @puzzle_plsql_1.sql) and save output result to a TXT file "puzzle_plsql_1.txt"
-- 

PROMPT ==================
PROMPT puzzle_plsql_1.sql
PROMPT ==================

SET serveroutput ON
SET feedback     OFF
SET termout      OFF

SPOOL /home/oracle/puzzle_plsql_1.txt
  EXECUTE puzzle_plsql_1;
SPOOL OFF

SET termout      ON
SET feedback     ON
SET serveroutput OFF

-- First creating a named procedure "puzzle_plsql_2" ON SYS schema of Oracle Database 11.2.0.4.0
-- 

CREATE OR REPLACE PROCEDURE
puzzle_plsql_2
IS 
   TYPE objects_t IS TABLE OF all_objects.object_name%TYPE; 
 
   l_objects   objects_t; 
BEGIN 
     SELECT object_name 
       BULK COLLECT INTO l_objects 
       FROM all_objects 
      WHERE object_name LIKE '%TABL%' 
   ORDER BY object_name; 
 
   FOR indx IN 1 .. l_objects.COUNT 
   LOOP 
      DBMS_OUTPUT.put_line (l_objects (indx)); 
   END LOOP; 
END puzzle_plsql_2;
/

-- Next executing it (SQL> @puzzle_plsql_2.sql) and save output result to a TXT file "puzzle_plsql_2.txt"
-- 

PROMPT ==================
PROMPT puzzle_plsql_2.sql
PROMPT ==================

SET serveroutput ON
SET feedback     OFF
SET termout      OFF

SPOOL /home/oracle/puzzle_plsql_2.txt
  EXECUTE puzzle_plsql_2;
SPOOL OFF

SET termout      ON
SET feedback     ON
SET serveroutput OFF

-- Comparing "puzzle_plsql_2.txt" with "puzzle_plsql_1.txt".

HOST SDIFF puzzle_plsql_1.txt puzzle_plsql_2.txt > diff.txt

HOST CAT diff.txt
