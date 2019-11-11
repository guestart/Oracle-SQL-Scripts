REM
REM     Script:        compare_plsql_output_2.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Nov 11, 2019
REM
REM     Purpose:
REM       The 2nd version of SQL script "compare_plsql_output.sql" which has been simplified by still using anonymous PLSQL block,
REM       this means that my processing flow will become simple.

-- Running the following SQL script files "puzzle_plsql_1.sql" on SQL*Plus, such as, "SQL> @puzzle_plsql_1.sql".
-- 

PROMPT ==================
PROMPT puzzle_plsql_1.sql
PROMPT ==================

SET serveroutput ON
SET feedback     OFF
SET termout      OFF

SPOOL /home/oracle/puzzle_plsql_1.txt
BEGIN
  DECLARE
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
  END;
END;
/
SPOOL OFF

SET termout      ON
SET feedback     ON
SET serveroutput OFF

-- Running the following SQL script files "puzzle_plsql_2.sql" on SQL*Plus, such as, "SQL> @puzzle_plsql_2.sql".
-- 

PROMPT ==================
PROMPT puzzle_plsql_2.sql
PROMPT ==================

SET serveroutput ON
SET feedback     OFF
SET termout      OFF

SPOOL /home/oracle/puzzle_plsql_2.txt
BEGIN
  DECLARE 
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
  END;
END;
/
SPOOL OFF

SET termout      ON
SET feedback     ON
SET serveroutput OFF

-- Comparing "puzzle_plsql_2.txt" with "puzzle_plsql_1.txt".

HOST SDIFF puzzle_plsql_1.txt puzzle_plsql_2.txt > diff.txt

HOST CAT diff.txt
