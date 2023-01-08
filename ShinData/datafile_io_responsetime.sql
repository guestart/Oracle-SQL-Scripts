REM
REM     Script:        datafile_io_responsetime.sql
REM     Author:        Quanwen Zhao
REM     Dated:         May 13, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Checking the datafile io response time of oracle database.
REM

SELECT d.inst_id,
       d.name,
       f.phyrds,
       f.phyblkrd,
       f.phywrts,
       f.phyblkwrt,
       f.readtim*10  readtime,
       f.writetim*10 writetime
FROM gv$datafile d, gv$filestat f
WHERE d.file# = f.file#
AND d.inst_id = f.inst_id
ORDER BY f.phyrds DESC,
         f.phywrts DESC;
