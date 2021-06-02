REM
REM     Script:     identity_column_compare.sql
REM     Author:     Quanwen Zhao
REM     Dated:      Jun 02, 2021
REM
REM     Last tested:
REM             LiveSQL (19.8.0.0)
REM             21.0.0.0 (my opc test environment)
REM
REM     Purpose:
REM         This SQL script focuses on comparing comsuing time (and cpu time) by
REM         using 3 different identity column in 3 different tables to insert some
REM         dummy data into those tables.
REM

-- 
-- Creating a table with an identity column using a trigger on pre 12c.
-- 

CREATE TABLE identity_pre_12c (
  id          number not null,
  annotation  varchar2(30)
);

CREATE SEQUENCE seq_identity;

CREATE OR REPLACE TRIGGER identity_trigger
BEFORE INSERT ON identity_pre_12c
FOR EACH ROW
WHEN (new.id IS NULL)
BEGIN
	:new.id := seq_identity.NEXTVAL;
END;
/

-- 
-- Firstly creating a sequence in order to invoke the *NEXTVAL* of this sequence
-- in identity column of a table subsequently being created.
-- 

CREATE SEQUENCE seq_identity_default;

-- Creating a table with an identity column by invoking the default sequence from 12c.

CREATE TABLE identity_from_12c (
  id         number default seq_identity_default.NEXTVAL not null,
  annotation varchar2(30)
);

-- 
-- Creating a table with a real identity column from 12c.
-- 

CREATE TABLE real_identity_from_12c (
  id         number generated always as identity,
  annotation varchar2(30)
);

PROMPT ====================================================================
PROMPT Here I am using a little piece of plsql code snippet to compare the 
PROMPT consuming time about inserting some dummy data on 3 different tables
PROMPT using corresponding identity column.
PROMPT ====================================================================

-- Reference this example from Tim Hall.
-- https://oracle-base.com/articles/12c/identity-columns-in-oracle-12cr1#performance

SET SERVEROUTPUT ON

DECLARE
  get_time     NUMBER;
  get_cpu_time NUMBER;
  
  TYPE t_annotation IS TABLE OF identity_pre_12c.annotation%TYPE;
  dummy_data t_annotation;
BEGIN
	-- Inserting some data into a collection named "dummy_data".
	SELECT 'DUMMY DATA'
	BULK COLLECT INTO dummy_data
	FROM dual
	CONNECT BY level <= 50000;
	
	-- A solution of using trigger on pre 12c.
	get_time := DBMS_UTILITY.GET_TIME();
	get_cpu_time := DBMS_UTILITY.GET_CPU_TIME();
	
	FORALL i IN dummy_data.FIRST .. dummy_data.LAST
	  INSERT INTO identity_pre_12c (annotation) VALUES (dummy_data(i));
	
	DBMS_OUTPUT.PUT_LINE('Identity_Pre_12c : ' ||
	                    'Time = ' || TO_CHAR(DBMS_UTILITY.GET_TIME() - get_time) || ' hsecs ' ||
	                    'CPU Time = ' || TO_CHAR(DBMS_UTILITY.GET_CPU_TIME() - get_cpu_time) || ' hsecs '
	                   );
	  
	-- A solution of using default value of invoking sequence.NEXTVAL from 12c.
	get_time := DBMS_UTILITY.GET_TIME();
	get_cpu_time := DBMS_UTILITY.GET_CPU_TIME();
	
	FORALL i IN dummy_data.FIRST .. dummy_data.LAST
	  INSERT INTO identity_from_12c (annotation) VALUES (dummy_data(i));
	
	DBMS_OUTPUT.PUT_LINE('Identity_From_12c : ' ||
	                    'Time = ' || TO_CHAR(DBMS_UTILITY.GET_TIME() - get_time) || ' hsecs ' ||
	                    'CPU Time = ' || TO_CHAR(DBMS_UTILITY.GET_CPU_TIME() - get_cpu_time) || ' hsecs '
	                   );
	
	-- A solution of using a real identity column from 12c.
  get_time := DBMS_UTILITY.GET_TIME();
	get_cpu_time := DBMS_UTILITY.GET_CPU_TIME();
	
	FORALL i IN dummy_data.FIRST .. dummy_data.LAST
	  INSERT INTO real_identity_from_12c (annotation) VALUES (dummy_data(i));
	
	DBMS_OUTPUT.PUT_LINE('Real_Identity_From_12c : ' ||
	                    'Time = ' || TO_CHAR(DBMS_UTILITY.GET_TIME() - get_time) || ' hsecs ' ||
	                    'CPU Time = ' || TO_CHAR(DBMS_UTILITY.GET_CPU_TIME() - get_cpu_time) || ' hsecs '
	                   );
END;
/

-- running on LiveSQL.
-- 
-- Identity_Pre_12c : Time = 99 hsecs CPU Time = 99 hsecs 
-- Identity_From_12c : Time = 24 hsecs CPU Time = 24 hsecs 
-- Real_Identity_From_12c : Time = 24 hsecs CPU Time = 24 hsecs 

-- running on 21c.
-- 
-- SQL> conn / as sysdba
-- 
-- SQL> create user c##qwz identified by "Zhqw8315Guestart!@";
-- 
-- User created.
-- 
-- SQL> grant connect, resource to c##qwz;
-- 
-- Grant succeeded.
-- 
-- SQL> alter user c##qwz default tablespace users quota 10m on users;
-- 
-- User altered.
-- 
-- SQL> conn c##qwz/"Zhqw8315Guestart!@"
-- Connected.
-- 
-- Identity_Pre_12c : Time = 87 hsecs CPU Time = 86 hsecs
-- Identity_From_12c : Time = 30 hsecs CPU Time = 18 hsecs
-- Real_Identity_From_12c : Time = 28 hsecs CPU Time = 17 hsecs
