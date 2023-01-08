REM
REM     Script:        sql_avg_elap_time_top60.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Nov 04, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Checking the top 60 sql statements that are descending by average elapsed time on oracle database.
REM

SELECT C.*,
       D.SQL_FULLTEXT AS SQL_TEXT,
       D.EXECUTIONS,
       D.LOADS,
       D.PARSE_CALLS,
       D.SORTS,
       ROUND(D.SORTS / DECODE(D.EXECUTIONS, 0, 1, D.EXECUTIONS), 0)                          AS AVG_SORTS,
       ROUND(D.CPU_TIME / 1000, 0)                                                           AS CPU_TIME,
       ROUND((D.CPU_TIME / 1000) / DECODE(D.EXECUTIONS, 0, 1, D.EXECUTIONS), 0)              AS AVG_CPU,
       ROUND(D.ELAPSED_TIME / 1000, 0)                                                       AS ELAPSED_TIME,
       ROUND(D.APPLICATION_WAIT_TIME / 1000, 0)                                              AS APPLICATION_WAIT_TIME,
       ROUND((D.APPLICATION_WAIT_TIME / 1000) / DECODE(D.EXECUTIONS, 0, 1, D.EXECUTIONS), 0) AS AVG_APPWAIT,
       ROUND(D.CONCURRENCY_WAIT_TIME / 1000, 0)                                              AS CONCURRENCY_WAIT_TIME,
       ROUND((D.CONCURRENCY_WAIT_TIME / 1000) / DECODE(D.EXECUTIONS, 0, 1, D.EXECUTIONS),0)  AS AVG_CONCURRENCYWAIT,
       ROUND(D.CLUSTER_WAIT_TIME / 1000, 0)                                                  AS CLUSTER_WAIT_TIME,
       ROUND((D.CLUSTER_WAIT_TIME / 1000) / DECODE(D.EXECUTIONS, 0, 1, D.EXECUTIONS),0)      AS AVG_CLUSTERWAIT,
       ROUND(D.USER_IO_WAIT_TIME / 1000, 0)                                                  AS USER_IO_WAIT_TIME,
       ROUND(D.USER_IO_WAIT_TIME / DECODE(D.EXECUTIONS, 0, 1, D.EXECUTIONS), 0)              AS AVG_IOWAIT,
       D.PHYSICAL_READ_REQUESTS,
       D.PHYSICAL_READ_BYTES,
       D.PHYSICAL_WRITE_REQUESTS,
       D.PHYSICAL_WRITE_BYTES
FROM (SELECT *
      FROM (SELECT A.SQL_ID,
                   A.INST_ID,
                   ROUND((A.ELAPSED_TIME / 1000) / DECODE(A.EXECUTIONS, 0, 1, A.EXECUTIONS), 0) AS AVG_EXLAPSED
            FROM GV$SQLSTATS A
            ORDER BY AVG_EXLAPSED DESC)
      WHERE ROWNUM <= 60) C,
     GV$SQLSTATS D
WHERE C.SQL_ID = D.SQL_ID
AND C.INST_ID = D.INST_ID;
