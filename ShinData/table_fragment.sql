REM
REM     Script:        table_fragment.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Sep 12, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Checking the table fragment situation of oracle database.
REM

SELECT owner,
       table_name,
       tablespace_name,
       partitioned,
       num_rows,
       round((blocks * 8) / 1024, 2)                                                           AS hwmmb,
       round((num_rows * avg_row_len / 1024) / 1024, 2)                                        AS actualusedmb,
       round((blocks * 10 / 100) / 1024 * 8, 2)                                                AS pctfreemb,
       round((blocks * 8 - (num_rows * avg_row_len / 1024) - blocks * 8 * 10 / 100) / 1024, 2) AS wastemb
FROM dba_tables
WHERE temporary = 'N'
AND round((blocks * 8 - (num_rows * avg_row_len / 1024) - blocks * 8 * 10 / 100), 2) > 10240
AND num_rows > 100000
AND NOT EXISTS (SELECT * FROM (SELECT username
                               FROM dba_users
                               WHERE created < (SELECT created FROM v$database)
                              ) u
                WHERE dba_tables.owner = u.username
               );
