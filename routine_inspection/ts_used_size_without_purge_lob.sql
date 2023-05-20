SELECT t.tablespace_name,
       nvl(sr.used_bytes,0)/power(2,20)                                      AS used_size_mb,
       f.sum_bytes/power(2,20)                                               AS sum_size_mb,
       round(decode(f.sum_bytes,0,0,nvl(sr.used_bytes,0)/f.sum_bytes*100),2) AS used_rate,
       f.autoext,
       f.status,
       t.bigfile
FROM dba_tablespaces t
LEFT JOIN (WITH ds_not_bin AS
           (SELECT tablespace_name,
                   SUM(bytes) used_bytes
            FROM dba_segments
            WHERE segment_name NOT LIKE 'BIN$%'
            GROUP BY tablespace_name
           ),
           ds_rec_lob AS
           (SELECT ts_name,
                   SUM(space*8192) used_bytes
            FROM dba_recyclebin
            WHERE type LIKE 'LOB%'
            GROUP BY ts_name
           )
           SELECT dnb.tablespace_name,
                  dnb.used_bytes - nvl(drl.used_bytes,0) used_bytes
           FROM ds_not_bin dnb
           LEFT JOIN ds_rec_lob drl
           ON dnb.tablespace_name = drl.ts_name
          ) sr
ON t.tablespace_name = sr.tablespace_name
INNER JOIN (SELECT tablespace_name,
                  min(online_status)                                               AS status,
                  DECODE(SUM(DECODE(autoextensible,'NO',0,1)),0,'NO','YES')        AS autoext,
                  sum(case autoextensible when 'YES' then maxbytes else bytes end) AS sum_bytes
           FROM dba_data_files
           GROUP BY tablespace_name
          ) f
ON t.tablespace_name = f.tablespace_name
ORDER BY 1;
