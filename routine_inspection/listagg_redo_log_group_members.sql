REM
REM     Script:     listagg_redo_log_group_members.sql
REM     Author:     Quanwen Zhao
REM     Dated:      Sep 18, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       The SQL script file describes how to listagg oracle redo log members in each redo log group using ', ' in order to make them locate on the same line.
REM

SET LINESIZE 200
SET PAGESIZE 50
COLUMN member FORMAT a55

SELECT a.thread#,
       a.group#,
       b.member,
       a.members 
FROM v$log a, v$logfile b
WHERE a.group# = b.group#
ORDER BY a.thread#, a.group#;

   THREAD#     GROUP# MEMBER                                                     MEMBERS
---------- ---------- ------------------------------------------------------- ----------
         1          1 +GRID/YYDSDB/ONLINELOG/group_1.290.1115251533                    2
         1          1 +DATA/YYDSDB/ONLINELOG/group_1.262.1115251481                    2
         1          2 +DATA/YYDSDB/ONLINELOG/group_2.263.1115251481                    2
         1          2 +GRID/YYDSDB/ONLINELOG/group_2.291.1115251535                    2
         1          3 +GRID/YYDSDB/ONLINELOG/group_3.289.1115251531                    2
         1          3 +DATA/YYDSDB/ONLINELOG/group_3.264.1115251483                    2
         2          4 +DATA/YYDSDB/ONLINELOG/group_4.277.1115253859                    2
         2          4 +GRID/YYDSDB/ONLINELOG/group_4.292.1115253877                    2
         2          5 +DATA/YYDSDB/ONLINELOG/group_5.278.1115253891                    2
         2          5 +GRID/YYDSDB/ONLINELOG/group_5.293.1115253907                    2
         2          6 +DATA/YYDSDB/ONLINELOG/group_6.279.1115253923                    2
         2          6 +GRID/YYDSDB/ONLINELOG/group_6.294.1115253937                    2

12 rows selected.

SET LINESIZE 200
SET PAGESIZE 50
COLUMN member FORMAT a95

SELECT a.thread#,
       a.group#,
       LISTAGG(b.member, ', ') WITHIN GROUP (ORDER BY b.member) AS member,
       a.members
FROM v$log a, v$logfile b
WHERE a.group# = b.group#
GROUP BY a.thread#,
         a.group#,
         a.members
ORDER BY a.thread#,
         a.group#;

   THREAD#     GROUP# MEMBER                                                                                             MEMBERS
---------- ---------- ----------------------------------------------------------------------------------------------- ----------
         1          1 +DATA/YYDSDB/ONLINELOG/group_1.262.1115251481, +GRID/YYDSDB/ONLINELOG/group_1.290.1115251533             2
         1          2 +DATA/YYDSDB/ONLINELOG/group_2.263.1115251481, +GRID/YYDSDB/ONLINELOG/group_2.291.1115251535             2
         1          3 +DATA/YYDSDB/ONLINELOG/group_3.264.1115251483, +GRID/YYDSDB/ONLINELOG/group_3.289.1115251531             2
         2          4 +DATA/YYDSDB/ONLINELOG/group_4.277.1115253859, +GRID/YYDSDB/ONLINELOG/group_4.292.1115253877             2
         2          5 +DATA/YYDSDB/ONLINELOG/group_5.278.1115253891, +GRID/YYDSDB/ONLINELOG/group_5.293.1115253907             2
         2          6 +DATA/YYDSDB/ONLINELOG/group_6.279.1115253923, +GRID/YYDSDB/ONLINELOG/group_6.294.1115253937             2

6 rows selected.
