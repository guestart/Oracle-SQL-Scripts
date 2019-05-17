<html>
<h1> Oracle SQL Libs </h1>
<body>
<h3>ASH:</h3>
<pre>
<a href="https://github.com/guestart/oracle-sql-libs/blob/master/ash_event_count_topN.sql">ash_event_count_topN.sql</a> - View the Top-N event counts from ASH
<a href="https://github.com/guestart/oracle-sql-libs/blob/master/ash_event_count_topN_new.sql">ash_event_count_topN_new.sql</a> - The improved version of "ash_event_count_topN.sql"
<a href="https://github.com/guestart/oracle-sql-libs/blob/master/ash_event_count_topN_2.sql">ash_event_count_topN_2.sql</a> - The improved version of "ash_event_count_topN_new.sql"
</pre>
<h3>STATISTICS INFO:</h3>
<pre>
<a href="https://github.com/guestart/oracle-sql-libs/blob/master/all_tables_stats_on_all_proc_users.sql">all_tables_stats_on_all_proc_users.sql</a> - Check statistics of all of tables from all of production users
<a href="https://github.com/guestart/oracle-sql-libs/blob/master/all_tables_mods_on_all_proc_users.sql">all_tables_mods_on_all_proc_users.sql</a> - Check DML of all of tables from all of production users
<a href="https://github.com/guestart/oracle-sql-libs/blob/master/table_stats_on_proc_user.sql">table_stats_on_proc_user.sql</a> - Only check statistics of table or user which has been appointed
<a href="https://github.com/guestart/oracle-sql-libs/blob/master/table_mods_on_proc_user.sql">table_mods_on_proc_user.sql</a> - Only check modifications of table or user which has been appointed
<a href="https://github.com/guestart/oracle-sql-libs/blob/master/table_column_statistics.sql">table_column_statistics.sql</a> - Check some related statistics of column of table
</pre>
<h3>SQL TUNING:</h3>
<pre>
<a href="https://github.com/guestart/oracle-sql-libs/blob/master/check_data_dictionary_tables_and_views.sql">check_data_dictionary_tables_and_views.sql</a> - Check data dictionary tables and views of Oracle
<a href="https://github.com/guestart/oracle-sql-libs/blob/master/check_sql_multiple_execution_plans.sql">check_sql_multiple_execution_plans.sql</a> - Check SQL multiple execution plans
<a href="https://github.com/guestart/oracle-sql-libs/blob/master/check_sql_multiple_execution_plans_2.sql">check_sql_multiple_execution_plans_2.sql</a> - Check SQL multiple execution plans-2
<a href="https://github.com/guestart/oracle-sql-libs/blob/master/check_sql_execution_plan_table.sql">check_sql_execution_plan_table.sql</a> - Check the SQL statement's execution plan
</pre>
<h3>Capturing bad SQL:</h3>
<pre>
<a href="https://github.com/guestart/oracle-sql-libs/blob/master/buffer_gets_rank_top_5_sql_on_sqlstats.sql">buffer_gets_rank_top_5_sql_on_sqlstats.sql</a> - Ranking Top 5 SQL for buffer_gets (High CPU) on "v$sqlstats" of Oracle
<a href="https://github.com/guestart/oracle-sql-libs/blob/master/disk_reads_rank_top_5_sql_on_sqlstats.sql">disk_reads_rank_top_5_sql_on_sqlstats.sql</a> - Ranking Top 5 SQL for disk_reads (High I/O) on "v$sqlstats" of Oracle
<a href="https://github.com/guestart/oracle-sql-libs/blob/master/poor_parsing_applications_rank_top_5_sql_on_sqlstats.sql">poor_parsing_applications_rank_top_5_sql_on_sqlstats.sql</a> - Ranking Top 5 SQL for poor parsing applications (parse_calls/executions) on "v$sqlstats" of Oracle
<a href="https://github.com/guestart/oracle-sql-libs/blob/master/shared_memory_rank_top_5_sql_on_sqlstats.sql">shared_memory_rank_top_5_sql_on_sqlstats.sql</a> - Ranking Top 5 SQL for shared memory (Memory hogs) on "v$sqlstats" of Oracle
</pre>
<h3> Routine Inspection:</h3>
<pre>
<a href="https://github.com/guestart/oracle-sql-libs/blob/master/all_prod_user.sql">all_prod_user.sql</a> - Listing all of production users by dba_users (excluding sys related users)
<a href="https://github.com/guestart/oracle-sql-libs/blob/master/per_machine_act_conn_num_aggr_by_user.sql">per_machine_act_conn_num_aggr_by_user.sql</a> - Showing per machine's active connect numbers after aggregating by username on v$session, meanwhile showing column client_info, that's to say, client's ip address
<a href="https://github.com/guestart/oracle-sql-libs/blob/master/top_10_segment_on_system_tbs.sql">top_10_segment_on_system_tbs.sql</a> - Showing top 10 segment objects on system tablespace
<a href="https://github.com/guestart/oracle-sql-libs/blob/master/top_10_segment_on_sysaux_tbs.sql">top_10_segment_on_sysaux_tbs.sql</a> - Showing top 10 segment objects on sysaux tablespace
</pre>
</body>
</html>
