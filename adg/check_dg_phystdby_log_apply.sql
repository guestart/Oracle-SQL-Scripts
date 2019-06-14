-- My standby database ARCHIVE LOG LIST shows 0 but standby sync run successful without issues,
-- So do not use  ARCHIVE LOG LIST on standby side.
 
-- Use following query on primary / standby to make sure it sync upto date.
 
-- Primary:
 
SELECT thread#
       , max(sequence#) AS "Last Primary Seq Generated"
FROM v$archived_log val
     , v$database vdb
WHERE val.resetlogs_change# = vdb.resetlogs_change#
GROUP BY thread#
ORDER BY 1
/
 
-- PhyStdby:
 
SELECT thread#
       , max(sequence#) AS "Last Standby Seq Received"
FROM v$archived_log val
     , v$database vdb
WHERE val.resetlogs_change# = vdb.resetlogs_change#
GROUP BY thread#
ORDER BY 1
/
 
SELECT thread#
       , max(sequence#) AS "Last Standby Seq Applied"
FROM v$archived_log val
     , v$database vdb
WHERE val.resetlogs_change# = vdb.resetlogs_change#
AND val.applied IN ('YES','IN-MEMORY')
GROUP BY thread#
ORDER BY 1
/
