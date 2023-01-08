REM
REM     Script:        invalid_objects.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Sep 13, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Checking the current invalid objects that have existed on oracle database.
REM

SELECT c.owner,
       c.object_name,
       c.subobject_name,
       c.object_id,
       c.data_object_id,
       c.object_type,
       to_char(c.created, 'yyyy-mm-dd hh24:mi:ss')       AS created,
       to_char(c.last_ddl_time, 'yyyy-mm-dd hh24:mi:ss') AS last_ddl_time,
       c.timestamp,
       c.status,
       c.temporary,
       c.generated,
       c.secondary,
       c.namespace,
       c.edition_name
FROM dba_invalid_objects c
WHERE status = 'INVALID'
AND not exists (select * from (SELECT username
                               FROM dba_users
                               WHERE created < (SELECT created FROM v$database)
                              ) u
                where c.owner = u.username
               )
UNION ALL
SELECT a.owner,
       a.object_name,
       a.subobject_name,
       a.object_id,
       a.data_object_id,
       a.object_type,
       to_char(a.created, 'yyyy-mm-dd hh24:mi:ss')       AS created,
       to_char(a.last_ddl_time, 'yyyy-mm-dd hh24:mi:ss') AS last_ddl_time,
       a.timestamp,
       b.status,
       a.temporary,
       a.generated,
       a.secondary,
       a.namespace,
       a.edition_name
FROM dba_objects a, dba_indexes b
WHERE not exists (select * from (SELECT username
                                 FROM dba_users
                                 WHWERE created < (SELECT created FROM v$database)
                                ) u
                  where a.owner = u.username
                 )
AND a.owner = b.owner
AND a.object_name = b.index_name
AND a.object_type = 'INDEX'
AND b.status = 'UNUSABLE';
