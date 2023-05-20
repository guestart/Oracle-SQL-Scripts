SELECT t.tablespace_name,
       nvl(s.used_bytes,0)/power(2,20)                                      AS used_size_mb,
       f.sum_bytes/power(2,20)                                              AS sum_size_mb,
       round(decode(f.sum_bytes,0,0,nvl(s.used_bytes,0)/f.sum_bytes*100),2) AS used_rate,
       f.autoext,
       f.status,
       t.bigfile
FROM dba_tablespaces t
LEFT JOIN (SELECT tablespace_name,
                  SUM(bytes) used_bytes
           FROM dba_segments
           WHERE segment_name NOT LIKE 'BIN$%'
           GROUP BY tablespace_name
          ) s
ON t.tablespace_name = s.tablespace_name
INNER JOIN (SELECT tablespace_name,
                  min(online_status)                                               AS status,
                  DECODE(SUM(DECODE(autoextensible,'NO',0,1)),0,'NO','YES')        AS autoext,
                  sum(case autoextensible when 'YES' then maxbytes else bytes end) AS sum_bytes
           FROM dba_data_files
           GROUP BY tablespace_name
          ) f
ON t.tablespace_name = f.tablespace_name
ORDER BY 1;
