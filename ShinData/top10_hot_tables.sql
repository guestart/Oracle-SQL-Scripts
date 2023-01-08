REM
REM     Script:        top10_hot_tables.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Sep 08, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Checking the top 10 hot tables that have been most frequently inserted, updated and deleted
REM       from dba_tab_modifications of oracle database.
REM

SELECT * FROM (
SELECT b.owner,
       b.table_name,
       b.segment_name,
       b.tablespace_name,
       h.inserts + h.updates + h.deletes AS h_sum,
       h.inserts,
       h.updates,
       h.deletes
FROM (
      SELECT t.owner,
             t.table_name,
             t.tablespace_name,
             t.num_rows,
             nvl(t.cluster_name, t.table_name) AS segment_name,
             t.partitioned,
             t.monitoring
      FROM dba_tables t
      WHERE NOT EXISTS (SELECT * FROM (SELECT username
                                       FROM dba_users
                                       WHERE created < (SELECT created FROM v$database)
                                      ) u
                        WHERE t.owner = u.username
                       )
     ) b,
     (
      SELECT table_name,
             SUM(inserts) AS inserts,
             SUM(updates) AS updates,
             SUM(deletes) AS deletes
      FROM dba_tab_modifications
      GROUP BY table_name
     ) h
WHERE b.table_name = h.table_name
ORDER BY h_sum DESC
) WHERE ROWNUM <= 10;
