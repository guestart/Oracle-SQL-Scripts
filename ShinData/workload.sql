REM
REM     Script:        workload.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Jan 06, 2023
REM
REM     Last tested:
REM             11.2.0.4
REM             12.1.0.2
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Checking the workload situation of oracle database, such as, current connection numbers (for total and active),
REM       sql throughput, transaction counts etc.
REM

-- before 12.1:

SELECT
    c.inst_id,
    m.end_time AS checktime,
    c.conn,
    c.activeconn,
    m.sqlthroughput,
    m.sqlavgtime,
    m.user_commits,
    m.user_rollbacks,
    m.user_commits + m.user_rollbacks transactioncount,
    m.transactionavgtime
FROM (
        WITH t1 AS (SELECT inst_id, count(*) conn FROM gv$session WHERE type = 'USER' GROUP BY inst_id),
        t2 AS  (SELECT inst_id, count(*) activeconn FROM gv$session WHERE type = 'USER' AND status = 'ACTIVE' GROUP BY inst_id)
        SELECT t1.inst_id, t1.conn, t2.activeconn
        FROM t1, t2
        WHERE t1.inst_id = t2.inst_id
     ) c,
     (   
        SELECT * FROM (
        SELECT inst_id, end_time, metric_name, round(value, 2) value FROM gv$sysmetric WHERE round(intsize_csec / 100, 0) = 60 AND metric_name IN ( 'Executions Per Sec', 'User Commits Per Sec', 'User Rollbacks Per Sec' )
        UNION ALL
        SELECT inst_id, end_time, metric_name, round(value * 10, 2) value FROM gv$sysmetric WHERE round(intsize_csec / 100, 0) = 60 AND metric_name IN ( 'SQL Service Response Time', 'Response Time Per Txn' )
        )
        PIVOT (
        AVG ( value )
        FOR metric_name
        IN ( 'Executions Per Sec' sqlthroughput, 'SQL Service Response Time' sqlavgtime, 'User Commits Per Sec' user_commits, 'User Rollbacks Per Sec' user_rollbacks, 'Response Time Per Txn' transactionavgtime ))
    ) m
WHERE c.inst_id = m.inst_id
ORDER BY inst_id;

-- from 12.2:

SELECT
    c.inst_id,
    m.end_time AS checktime,
    c.conn,
    c.activeconn,
    m.sqlthroughput,
    m.sqlavgtime,
    m.user_commits,
    m.user_rollbacks,
    m.user_commits + m.user_rollbacks transactioncount,
    m.transactionavgtime
FROM (
        WITH t1 AS (SELECT inst_id, count(*) conn FROM gv$session WHERE type = 'USER' GROUP BY inst_id),
        t2 AS  (SELECT inst_id, count(*) activeconn FROM gv$session WHERE type = 'USER' AND status = 'ACTIVE' GROUP BY inst_id)
        SELECT t1.inst_id, t1.conn, t2.activeconn
        FROM t1, t2
        WHERE t1.inst_id = t2.inst_id
     ) c,
     (   
        SELECT * FROM (
        SELECT inst_id, end_time, metric_name, round(value, 2) value FROM gv$sysmetric WHERE round(intsize_csec / 100, 0) = 60 AND sys_context('USERENV', 'CON_ID') = 1 AND metric_name IN ( 'Executions Per Sec', 'User Commits Per Sec', 'User Rollbacks Per Sec' )
        UNION ALL
        SELECT inst_id, end_time, metric_name, round(value * 10, 2) value FROM gv$sysmetric WHERE round(intsize_csec / 100, 0) = 60 AND sys_context('USERENV', 'CON_ID') = 1 AND metric_name IN ( 'SQL Service Response Time', 'Response Time Per Txn' )
        )
        PIVOT (
        AVG ( value )
        FOR metric_name
        IN ( 'Executions Per Sec' sqlthroughput, 'SQL Service Response Time' sqlavgtime, 'User Commits Per Sec' user_commits, 'User Rollbacks Per Sec' user_rollbacks, 'Response Time Per Txn' transactionavgtime ))
    ) m
WHERE c.inst_id = m.inst_id
UNION ALL
SELECT
    c.inst_id,
    m.end_time AS checktime,
    c.conn,
    c.activeconn,
    m.sqlthroughput,
    m.sqlavgtime,
    m.user_commits,
    m.user_rollbacks,
    m.user_commits + m.user_rollbacks transactioncount,
    m.transactionavgtime
FROM (
        WITH t1 AS (SELECT inst_id, count(*) conn FROM gv$session WHERE type = 'USER' GROUP BY inst_id),
        t2 AS  (SELECT inst_id, count(*) activeconn FROM gv$session WHERE type = 'USER' AND status = 'ACTIVE' GROUP BY inst_id)
        SELECT t1.inst_id, t1.conn, t2.activeconn
        FROM t1, t2
        WHERE t1.inst_id = t2.inst_id
     ) c,
     (   
        SELECT * FROM (
        SELECT inst_id, end_time, metric_name, round(value, 2) value FROM gv$con_sysmetric WHERE round(intsize_csec / 100, 0) = 60 AND sys_context('USERENV', 'CON_ID') <> 1 AND metric_name IN ( 'Executions Per Sec', 'User Commits Per Sec', 'User Rollbacks Per Sec' )
        UNION ALL
        SELECT inst_id, end_time, metric_name, round(value * 10, 2) value FROM gv$con_sysmetric WHERE round(intsize_csec / 100, 0) = 60 AND sys_context('USERENV', 'CON_ID') <> 1 AND metric_name IN ( 'SQL Service Response Time', 'Response Time Per Txn' )
        )
        PIVOT (
        AVG ( value )
        FOR metric_name
        IN ( 'Executions Per Sec' sqlthroughput, 'SQL Service Response Time' sqlavgtime, 'User Commits Per Sec' user_commits, 'User Rollbacks Per Sec' user_rollbacks, 'Response Time Per Txn' transactionavgtime ))
    ) m
WHERE c.inst_id = m.inst_id
ORDER BY inst_id;
