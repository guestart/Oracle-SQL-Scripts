REM
REM     Script:     insert_approach_compare.sql
REM     Author:     Quanwen Zhao
REM     Dated:      Jun 01, 2021
REM
REM     Last tested:
REM             LiveSQL (19.8.0.0)
REM             21.0.0.0 (my opc test environment)
REM
REM     Purpose:
REM         This SQL script focuses on comparing spending time (and cpu time) when
REM         using 3 number of different approaches to insert some data into a table.
REM

CREATE TABLE odptg_21c (
  id number         constraint odptg_pk primary key,
  name varchar2(55) not null
);

SET SERVEROUTPUT ON

DECLARE
  get_time     number;
  get_cpu_time number;
  insert_count number := 50000;
BEGIN
  get_time := DBMS_UTILITY.GET_TIME();
  get_cpu_time := DBMS_UTILITY.GET_CPU_TIME();
  
  FOR i IN 1 .. insert_count LOOP
    INSERT INTO odptg_21c VALUES (i, 'Database Performance Fundamentals');
  END LOOP;
  
  DBMS_OUTPUT.PUT_LINE('Single-row Insert Duration: ' ||
                       'Time is ' || (DBMS_UTILITY.GET_TIME() - get_time) || ' hsecs, ' ||
                       'CPU Time is ' || (DBMS_UTILITY.GET_CPU_TIME() - get_cpu_time) || ' hsecs '
                      );
  
  ROLLBACK;
  
  get_time := DBMS_UTILITY.GET_TIME();
  get_cpu_time := DBMS_UTILITY.GET_CPU_TIME();
  
  INSERT INTO odptg_21c SELECT level, 'Database Performance Fundamentals' FROM dual
  CONNECT BY level <= insert_count;
  
  DBMS_OUTPUT.PUT_LINE('Multiple-row Normal Insert Duration: ' ||
                       'Time is ' || (DBMS_UTILITY.GET_TIME() - get_time) || ' hsecs, ' ||
                       'CPU Time is ' || (DBMS_UTILITY.GET_CPU_TIME() - get_cpu_time) || ' hsecs '
                      );
  
  ROLLBACK;
  
  get_time := DBMS_UTILITY.GET_TIME();
  get_cpu_time := DBMS_UTILITY.GET_CPU_TIME();
  
  INSERT /*+ APPEND */ INTO odptg_21c SELECT level, 'Database Performance Fundamentals' FROM dual
  CONNECT BY level <= insert_count;
  
  DBMS_OUTPUT.PUT_LINE('Multiple-row Append Insert Duration: ' ||
                       'Time is ' || (DBMS_UTILITY.GET_TIME() - get_time) || ' hsecs, ' ||
                       'CPU Time is ' || (DBMS_UTILITY.GET_CPU_TIME() - get_cpu_time) || ' hsecs '
                      );  
  
  ROLLBACK;
END;
/

-- The return result on LiveSQL

Single-row Insert Duration: Time is 97 hsecs, CPU Time is 96 hsecs 
Multiple-row Normal Insert Duration: Time is 8 hsecs, CPU Time is 8 hsecs 
Multiple-row Append Insert Duration: Time is 7 hsecs, CPU Time is 7 hsecs 

-- The return result on 21c

Single-row Insert Duration: Time is 280 hsecs, CPU Time is 277 hsecs
Multiple-row Normal Insert Duration: Time is 12 hsecs, CPU Time is 11 hsecs
Multiple-row Append Insert Duration: Time is 9 hsecs, CPU Time is 7 hsecs
