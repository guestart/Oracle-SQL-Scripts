REM
REM     Script:        invoke_procedure_in_trigger.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Jul 31, 2020
REM
REM     Last tested:
REM             11.2.0.4
REM             12.1.0.2
REM             12.2.0.1
REM             18.3.0.0
REM             19.3.0.0
REM             19.5.0.0 -- LiveSQL
REM
REM     Purpose:
REM       If adding a comment after the call procedure clause in a trigger, PL/SQL compiler
REM       will report the very weird error of PLS-00103. So I emailed to Steven Feuerstein,
REM       he suggests me remove that comment and then it will normally work, which seems to
REM       be a bug.
REM

CREATE TABLE emp (empno NUMBER, ename VARCHAR2(10));

INSERT INTO emp VALUES(7839, 'King');
INSERT INTO emp VALUES(7698, 'Blake');
INSERT INTO emp VALUES(7782, 'Clark');

COMMIT;

SET SERVEROUTPUT ON

CREATE OR REPLACE PROCEDURE log_execution IS
BEGIN
  DBMS_OUTPUT.PUT_LINE('log_execution: Emp table has inserted 1 row.');
END;
/

CREATE OR REPLACE TRIGGER log_emp
BEFORE INSERT ON emp
FOR EACH ROW
CALL log_execution -- no semicolon needed
/

Warning: Trigger created with compilation errors.

show errors
Errors for TRIGGER LOG_EMP:

LINE/COL ERROR
-------- -----------------------------------------------------------------
1/37     PLS-00103: Encountered the symbol "end-of-file" when expecting
         one of the following:
         := . ( @ % ;
         The symbol ";" was substituted for "end-of-file" to continue.

-- if eliminating the comment '-- no semicolon needed' after the 'CALL log_execution' clause

CREATE OR REPLACE TRIGGER log_emp
BEFORE INSERT ON emp
FOR EACH ROW
CALL log_execution
/

Trigger created.

INSERT INTO emp VALUES(7566, 'Jones');
log_execution: Emp table has inserted 1 row.

1 row created.

COMMIT;
