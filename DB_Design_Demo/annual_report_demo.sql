REM
REM     Script:        annual_report_demo.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Jan 23, 2020
REM
REM     Last tested:
REM             19.3.0.0
REM

-- Using a simple SQL Demo to build my Annual Report

DROP TABLE work_category;
DROP TABLE daily_work;

DROP SEQUENCE work_cgy_seq;
DROP SEQUENCE daily_work_seq;

CREATE SEQUENCE work_cgy_seq;
CREATE SEQUENCE daily_work_seq;

PROMPT ============================
PROMPT Creating table work_category
PROMPT and inserting category data
PROMPT ============================

CREATE TABLE work_category (
   wc_id    NUMBER DEFAULT work_cgy_seq.NEXTVAL,
   cgy_abbr VARCHAR2(5) NOT NULL,
   cgy_full VARCHAR2(50) NOT NULL,
   CONSTRAINT work_category_pk PRIMARY KEY (cgy_abbr),
   CONSTRAINT work_category_uk UNIQUE (wc_id)
);

INSERT INTO work_category (cgy_abbr, cgy_full) VALUES ('TS', 'Trouble Shooting');
INSERT INTO work_category (cgy_abbr, cgy_full) VALUES ('SR', 'Service Request');
INSERT INTO work_category (cgy_abbr, cgy_full) VALUES ('RI', 'Routine Inspection');
INSERT INTO work_category (cgy_abbr, cgy_full) VALUES ('WPLS', 'Writing PLSQL Script');
INSERT INTO work_category (cgy_abbr, cgy_full) VALUES ('UPLS', 'Updating PLSQL Script');
INSERT INTO work_category (cgy_abbr, cgy_full) VALUES ('WSQS', 'Writing SQL Script');
INSERT INTO work_category (cgy_abbr, cgy_full) VALUES ('USQS', 'Updating SQL Script');
INSERT INTO work_category (cgy_abbr, cgy_full) VALUES ('WSHS', 'Writing SHELL Script');
INSERT INTO work_category (cgy_abbr, cgy_full) VALUES ('USHS', 'Updating SHELL Script');
INSERT INTO work_category (cgy_abbr, cgy_full) VALUES ('WBN', 'Writing Blog Note');
INSERT INTO work_category (cgy_abbr, cgy_full) VALUES ('UBN', 'Updating Blog Note');
INSERT INTO work_category (cgy_abbr, cgy_full) VALUES ('PAT', 'Posting AskTOM Thread');
INSERT INTO work_category (cgy_abbr, cgy_full) VALUES ('RAT', 'Replying AskTOM Thread');
INSERT INTO work_category (cgy_abbr, cgy_full) VALUES ('POT', 'Posting ODC Thread');
INSERT INTO work_category (cgy_abbr, cgy_full) VALUES ('ROT', 'Replying ODC Thread');
INSERT INTO work_category (cgy_abbr, cgy_full) VALUES ('PWT', 'Posting WordPress Thread');
INSERT INTO work_category (cgy_abbr, cgy_full) VALUES ('RWT', 'Replying WordPress Thread');
INSERT INTO work_category (cgy_abbr, cgy_full) VALUES ('SGOSP', 'Submitting Github Open Source Project');
INSERT INTO work_category (cgy_abbr, cgy_full) VALUES ('UGOSP', 'Updating Github Open Source Project');
INSERT INTO work_category (cgy_abbr, cgy_full) VALUES ('SLC', 'Submitting LiveSQL Code');

COMMIT;

PROMPT =========================
PROMPT Creating table daily_work
PROMPT and inserting daily data
PROMPT =========================

CREATE TABLE daily_work (
   dw_id        NUMBER DEFAULT daily_work_seq.NEXTVAL,
   current_date DATE,
   repeat_date  VARCHAR2(30),
   cgy_abbr     VARCHAR2(5) NOT NULL,
   stuff        VARCHAR2(2000) NOT NULL,
   times        NUMBER default 1,
   annotation   VARCHAR2(50) NOT NULL,
   CONSTRAINT daily_work_uk UNIQUE (dw_id),
   CONSTRAINT daily_work_pk PRIMARY KEY (dw_id, cgy_abbr, stuff),
   CONSTRAINT daily_work_fk FOREIGN KEY (cgy_abbr) REFERENCES work_category (cgy_abbr)
);

-- Inserting the data of 'Trouble Shooting'

INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-01-29', 'TS', 'frequently showing ORA-01555 on the log file of expdp backup', 'Trouble Shooting');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-02-14', 'TS', 'frequently showing ORA-1653/1654 on the alert log file', 'Trouble Shooting');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-03-15', 'TS', 'can''t acquire ORA- message from alert_db.log via ZABBIX Server', 'Trouble Shooting');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-04-29', 'TS', 'the location of the listener log file is weird', 'Trouble Shooting');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-08-08', 'TS', 'Oracle DB Server shows connection time-out', 'Trouble Shooting');

COMMIT;

-- Inserting the data of 'Service Request'

INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-06-19', 'SR', 'add IP address of several App Server to the Oracle white list', 'Service Request');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-07-12', 'SR', 'add read-only user on Oracle DB Server', 'Service Request');

COMMIT;

-- Inserting the data of 'Routine Inspection'

INSERT INTO daily_work (repeat_date, cgy_abbr, stuff, times, annotation) VALUES ('every business day of 2019', 'RI', 'Oracle Database Server Host Routine Inspection', 250, 'Routine Inspection');
INSERT INTO daily_work (repeat_date, cgy_abbr, stuff, times, annotation) VALUES ('every business day of 2019', 'RI', 'Oracle Database Server System Routine Inspection', 250, 'Routine Inspection');
INSERT INTO daily_work (repeat_date, cgy_abbr, stuff, times, annotation) VALUES ('every business day of 2019', 'RI', 'Integrated Backup Machine Routine Inspection', 250, 'Routine Inspection');

COMMIT;

-- Inserting the data of 'Writing/Updating PLSQL Script'

INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-12-11', 'WPLS', 'writing dyn_crt_table_3.sql', 'Writing PLSQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-12-11', 'WPLS', 'writing dyn_crt_table_4.sql', 'Writing PSQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-07-06', 'WPLS', 'writing bgs_role_syn_2.sql', 'Writing PLSQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-07-06', 'WPLS', 'writing bgs_role_syn_3.sql', 'Writing PLSQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-06-30', 'WPLS', 'writing bth_grt_sel_2.sql', 'Writing PLSQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-06-30', 'WPLS', 'writing bth_grt_sel_3.sql', 'Writing PLSQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-11-11', 'WPLS', 'writing compare_plsql_output.sql', 'Writing PLSQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-11-11', 'WPLS', 'writing compare_plsql_output_2.sql', 'Writing PLSQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-12-12', 'WPLS', 'writing string-indexed_collection.sql', 'Writing PLSQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-12-29', 'UPLS', 'updating string-indexed_collection.sql', 'Updating PLSQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-07-06', 'WPLS', 'writing brs_role_syn_2.sql', 'Writing PLSQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-07-06', 'WPLS', 'writing brs_role_syn_3.sql', 'Writing PLSQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-07-02', 'WPLS', 'writing bth_rvk_sel_2.sql', 'Writing PLSQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-07-02', 'WPLS', 'writing bth_rvk_sel_3.sql', 'Writing PLSQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-07-23', 'WPLS', 'writing brgs_role_syn_tab.sql', 'Writing PLSQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-07-24', 'UPLS', 'updating brgs_role_syn_tab.sql', 'Updating PLSQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-07-23', 'WPLS', 'writing brgs_role_syn_tab_2.sql', 'Writing PLSQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-07-30', 'WPLS', 'writing brgs_role_syn_tab_3.sql', 'Writing PLSQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-07-31', 'UPLS', 'updating brgs_role_syn_tab_3.sql', 'Updating PLSQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-07-23', 'WPLS', 'writing brst2_scheduler.sql', 'Writing PLSQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-07-30', 'WPLS', 'writing brst3_scheduler.sql', 'Writing PLSQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-07-23', 'WPLS', 'writing brst_scheduler.sql', 'Writing PLSQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-07-30', 'WPLS', 'writing rgy_refresh_mview_uts.sql', 'Writing PLSQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-06-14', 'WPLS', 'writing switch_redo_log_for_recycle.sql', 'Writing PLSQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-06-21', 'WPLS', 'writing rman_backup_check_plsql_1.sql', 'Writing PLSQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-06-21', 'WPLS', 'writing rman_backup_check_plsql_2.sql', 'Writing PLSQL Script');

COMMIT;

-- Inserting the data of 'Writing/Updating SQL Script'

INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-06-16', 'WSQS', 'writing uffer_gets_rank_top_5_sql_on_sqlstats.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-06-16', 'WSQS', 'writing disk_reads_rank_top_5_sql_on_sqlstats.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-06-16', 'WSQS', 'writing poor_parsing_applications_rank_top_5_sql_on_sqlstats.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-06-16', 'WSQS', 'writing shared_memory_rank_top_5_sql_on_sqlstats.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-06-16', 'WSQS', 'writing check_dg_phystdby_log_apply.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-06-16', 'WSQS', 'writing check_dg_redo_apply.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-06-13', 'WSQS', 'writing ash_event_count_topN.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-06-13', 'WSQS', 'writing ash_event_count_topN_new.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-06-13', 'WSQS', 'writing ash_event_count_topN_2.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-08-15', 'WSQS', 'writing dig_ip_via_function.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-08-14', 'WSQS', 'writing dig_ip_via_listener_log_xml.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-08-19', 'WSQS', 'writing dig_ip_via_listener_log_xml_2.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-07-11', 'WSQS', 'writing expdp_exclude_stats.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-07-03', 'WSQS', 'writing bgs_role_syn.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-07-09', 'WSQS', 'writing bgs_role_syn_tab.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-07-24', 'USQS', 'updating bgs_role_syn_tab.sql', 'Updating SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-07-15', 'WSQS', 'writing bgs_role_syn_tab_2.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-07-24', 'USQS', 'updating bgs_role_syn_tab_2.sql', 'Updating SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-07-31', 'USQS', 'updating bgs_role_syn_tab_2.sql', 'Updating SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-07-18', 'WSQS', 'writing bgs_role_syn_tab_3.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-07-24', 'USQS', 'updating bgs_role_syn_tab_3.sql', 'Updating SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-07-29', 'WSQS', 'writing bgs_scheduler.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-08-07', 'USQS', 'updating bgs_scheduler.sql', 'Updating SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-06-30', 'WSQS', 'writing bth_grt_sel.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-07-05', 'USQS', 'updating bth_grt_sel.sql', 'Updating SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-06-14', 'WSQS', 'writing migration_before_and_after_compare.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-08-08', 'WSQS', 'writing materialized_view_demo.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-12-11', 'WSQS', 'writing dyn_crt_table.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-12-11', 'WSQS', 'writing dyn_crt_table_2.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-07-05', 'WSQS', 'writing brs_role_syn.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-07-09', 'WSQS', 'writing brs_role_syn_tab.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-07-15', 'WSQS', 'writing brs_role_syn_tab_2.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-07-18', 'WSQS', 'writing brs_role_syn_tab_3.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-07-02', 'WSQS', 'writing bth_rvk_sel.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-07-05', 'USQS', 'updating bth_rvk_sel.sql', 'Updating SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-05-11', 'WSQS', 'writing all_prod_user.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-11-11', 'WSQS', 'writing break_compute_demo.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-07-16', 'WSQS', 'writing check_total_size_oracle_db.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-06-14', 'WSQS', 'writing ctl_file_path_in_rman_backupsets.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-06-14', 'WSQS', 'writing db_buffer_cache_hit_ratio.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-11-07', 'WSQS', 'writing dropped_object_of_recyclebin.sqll', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-11-07', 'WSQS', 'writing get_ddl_of_object_via_passing_in_arguments.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-11-06', 'WSQS', 'writing get_ddl_of_object_via_using_accept.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-11-05', 'WSQS', 'writing get_ddl_of_object_via_using_substitution_variable.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-11-06', 'USQS', 'updating get_ddl_of_object_via_using_substitution_variable.sql', 'Updating SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-11-06', 'WSQS', 'writing get_dyn_perf_view_def.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-11-06', 'WSQS', 'writing get_dyn_perf_view_def_2.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-11-07', 'WSQS', 'writing get_dyn_perf_view_def_3.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-06-17', 'WSQS', 'writing hit_ratio_db_buffer_cache.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-06-17', 'WSQS', 'writing hit_ratio_db_buffer_cache_2.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-06-17', 'WSQS', 'writing hit_ratio_db_buffer_cache_3.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-05-11', 'WSQS', 'writing per_machine_act_conn_num_aggr_by_user.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-05-15', 'USQS', 'updating per_machine_act_conn_num_aggr_by_user.sql', 'Updating SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-07-05', 'WSQS', 'writing rman_backup_check.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-07-05', 'WSQS', 'writing rman_backup_check_2.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-07-05', 'WSQS', 'writing rman_backup_check_3.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-07-05', 'WSQS', 'writing rman_backup_check_4.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-06-14', 'WSQS', 'writing spfile_path_in_rman_backupsets.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-11-12', 'WSQS', 'writing tablespace_free_space.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-11-05', 'WSQS', 'writing tablespace_non-temp_compare_total_size.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-11-05', 'WSQS', 'writing tablespace_non-temp_compare_total_size_simple_version.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-11-05', 'WSQS', 'writing tablespace_non-temp_compare_total_size_with_as.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-11-05', 'WSQS', 'writing tablespace_non-temp_recyclebin_rollup_segment_name.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-10-30', 'WSQS', 'writing tablespace_per_used_size_and_rollup.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-11-01', 'USQS', 'updating tablespace_per_used_size_and_rollup.sql', 'Updating SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-10-30', 'WSQS', 'writing tablespace_per_used_size_and_total_size.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-11-01', 'USQS', 'updating tablespace_per_used_size_and_total_size.sql', 'Updating SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-10-30', 'WSQS', 'writing tablespace_used_size_1.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-11-01', 'USQS', 'updating tablespace_used_size_1.sql', 'Updating SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-10-30', 'WSQS', 'writing tablespace_used_size_2.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-11-01', 'USQS', 'updating tablespace_used_size_2.sql', 'Updating SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-10-30', 'WSQS', 'writing tablespace_utilization_rate.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-11-01', 'USQS', 'updating tablespace_utilization_rate.sql', 'Updating SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-11-18', 'USQS', 'updating tablespace_utilization_rate.sql', 'Updating SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-11-18', 'WSQS', 'writing tablespace_utilization_rate_2.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-11-15', 'WSQS', 'writing temporary_tablespace_used_size.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-11-18', 'USQS', 'updating temporary_tablespace_used_size.sql', 'Updating SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-11-15', 'WSQS', 'writing temporary_tablespace_used_size_2.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-05-11', 'WSQS', 'writing top_10_segment_on_sysaux_tbs.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-05-11', 'WSQS', 'writing top_10_segment_on_system_tbs.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-07-29', 'WSQS', 'writing scheduler_demo.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-08-08', 'WSQS', 'writing user_scheduler_job_log.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-08-08', 'WSQS', 'writing user_scheduler_jobs.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-06-13', 'WSQS', 'writing check_data_dictionary_tables_and_views.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-06-13', 'WSQS', 'writing check_sql_execution_plan_table.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-06-13', 'WSQS', 'writing check_sql_multiple_execution_plans.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-06-13', 'WSQS', 'writing check_sql_multiple_execution_plans_2.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-06-13', 'WSQS', 'writing all_tables_mods_on_all_proc_users.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-06-13', 'WSQS', 'writing all_tables_stats_on_all_proc_users.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-06-13', 'WSQS', 'writing table_column_statistics.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-06-13', 'WSQS', 'writing table_mods_on_proc_user.sql', 'Writing SQL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-06-13', 'WSQS', 'writing table_stats_on_proc_user.sql', 'Writing SQL Script');

COMMIT;

-- Inserting the data of 'Writing/Updating SHELL Script'

INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-06-14', 'WSHS', 'writing check_dg_redo_apply.sh', 'Writing SHELL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-11-04', 'WSHS', 'writing batch_remove_listener_xml_on_2018.sh', 'Writing SHELL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-08-15', 'WSHS', 'writing dig_ip_via_listener_log_xml.sh', 'Writing SHELL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-06-14', 'WSHS', 'writing exp_test_and_del_yesterday.sh', 'Writing SHELL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-07-11', 'WSHS', 'writing exp_test_and_del_yesterday_2.sh', 'Writing SHELL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-07-05', 'WSHS', 'writing expdp_test_and_del_yesterday.sh', 'Writing SHELL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-07-11', 'WSHS', 'writing expdp_test_and_del_yesterday_2.sh', 'Writing SHELL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-06-13', 'WSHS', 'writing buddha_bless_never_downtime.sh', 'Writing SHELL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-06-13', 'WSHS', 'writing oracle_logo.sh', 'Writing SHELL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-06-13', 'WSHS', 'writing oracle_logo_2.sh', 'Writing SHELL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-06-13', 'WSHS', 'writing oracle_logo_3.sh', 'Writing SHELL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-06-14', 'WSHS', 'writing rman_backup.sh', 'Writing SHELL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-06-14', 'WSHS', 'writing rman_backup_ASM.sh', 'Writing SHELL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-06-13', 'WSHS', 'writing ssh_mutual_trust_linux_for_source.sh', 'Writing SHELL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-06-13', 'WSHS', 'writing ssh_mutual_trust_linux_for_target.sh', 'Writing SHELL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-06-13', 'WSHS', 'writing collect_info_from_source_oracle.sh', 'Writing SHELL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-06-13', 'WSHS', 'writing scp_log_file_to_target.sh', 'Writing SHELL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-06-13', 'WSHS', 'writing rman_restore_and_recover_to_target_oracle.sh', 'Writing SHELL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-06-13', 'WSHS', 'writing rman_validate_v2.sh', 'Writing SHELL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-06-13', 'WSHS', 'writing back_and_clean_alert_log.sh', 'Writing SHELL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-06-13', 'WSHS', 'writing back_and_clean_listener_log.sh', 'Writing SHELL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-06-14', 'WSHS', 'writing retention_expdp_test_dump_file_2days.sh', 'Writing SHELL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-06-13', 'WSHS', 'writing rotate_reserve_base_dmp.sh', 'Writing SHELL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-06-14', 'WSHS', 'writing scp_expdp_parallel_local_to_remote.sh', 'Writing SHELL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-06-14', 'WSHS', 'writing statistics_all_disk_files.sh', 'Writing SHELL Script');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-06-14', 'WSHS', 'writing statistics_all_disk_files_2.sh', 'Writing SHELL Script');

COMMIT;

-- Inserting the data of 'Writing/Updating Blog Note'

INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-05-21', 'WBN', 'Writing ODRIS Part 1', 'Writing Blog Note');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-05-28', 'WBN', 'Writing ODRIS Part 2', 'Writing Blog Note');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-06-21', 'WBN', 'Writing Checking RMAN backup situation', 'Writing Blog Note');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-06-30', 'WBN', 'Writing Batch grant select', 'Writing Blog Note');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-07-06', 'WBN', 'Writing Batch grant select – 2', 'Writing Blog Note');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-07-08', 'UBN', 'Updating Batch grant select – 2', 'Updating Blog Note');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-07-09', 'WBN', 'Writing Batch grant select – 3', 'Writing Blog Note');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-07-12', 'UBN', 'Updating Batch grant select – 3', 'Updating Blog Note');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-07-24', 'UBN', 'Updating Batch grant select – 3', 'Updating Blog Note');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-07-12', 'WBN', 'Writing Showing Legacy Mode Parameter: “statistics=none” when expdp data of table', 'Writing Blog Note');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-07-25', 'WBN', 'Writing Batch grant select – 4', 'Writing Blog Note');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-07-29', 'UBN', 'Updating Batch grant select – 4', 'Updating Blog Note');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-07-30', 'UBN', 'Updating Batch grant select – 4', 'Updating Blog Note');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-08-01', 'UBN', 'Updating Batch grant select – 4', 'Updating Blog Note');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-08-07', 'UBN', 'Updating Batch grant select – 4', 'Updating Blog Note');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-07-31', 'WBN', 'Writing Batch grant select – 5', 'Writing Blog Note');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-08-02', 'UBN', 'Updating Batch grant select – 5', 'Updating Blog Note');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-08-09', 'WBN', 'Writing WordPress (itself)’s issue or bug?', 'Writing Blog Note');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-08-16', 'WBN', 'Writing Four Approaches about Digging IP Address Connecting to Oracle Database Server', 'Writing Blog Note');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-10-10', 'WBN', 'Writing OGB Appreciaiton Day : The Oracle Community', 'Writing Blog Note');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-10-28', 'WBN', 'Writing Steven Feuerstein help me better understand exception handle in ORACLE PL/SQL block', 'Writing Blog Note');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-10-30', 'UBN', 'Updating Steven Feuerstein help me better understand exception handle in ORACLE PL/SQL block', 'Updating Blog Note');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-11-08', 'WBN', 'Writing Get DDL of an Oracle SDDV', 'Writing Blog Note');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-11-14', 'WBN', 'Writing Get DDL of an Oracle DPV', 'Writing Blog Note');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-11-21', 'WBN', 'Writing Security Message', 'Writing Blog Note');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-12-11', 'WBN', 'Writing ACOUG Annual Meeting', 'Writing Blog Note');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-12-17', 'UBN', 'Updating ACOUG Annual Meeting', 'Updating Blog Note');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-12-12', 'WBN', 'Writing Dynamically creating Test tables', 'Writing Blog Note');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-12-31', 'WBN', 'Writing Real Execution Plan of Querying COUNT table', 'Writing Blog Note');

COMMIT;

-- Inserting the data of 'Posting/Replying AskTOM Thread'

INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-06-28', 'PAT', 'Posting How to analyse or dig log.xml of Oracle Listener Log with XMLTABLE?', 'Posting AskTOM Thread');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-08-19', 'RAT', 'Replying How to analyse or dig log.xml of Oracle Listener Log with XMLTABLE?', 'Replying AskTOM Thread');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-11-13', 'PAT', 'Posting Query both DBA_FREE_SPACE and DBA_TEMP_FREE_SPACE on view', 'Posting AskTOM Thread');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-11-18', 'RAT', 'Replying Query both DBA_FREE_SPACE and DBA_TEMP_FREE_SPACE on view', 'Replying AskTOM Thread');

COMMIT;

-- Inserting the data of 'Posting/Replying ODC Thread'

INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-04-15', 'POT', 'Posting How to determine where plenty of Mem used size has been consumed on Oracle DB Server?', 'Posting ODC Thread');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-04-16', 'ROT', 'Replying How to determine where plenty of Mem used size has been consumed on Oracle DB Server?', 'Replying ODC Thread');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-05-07', 'POT', 'Posting Why is it different for the query result of my two SQL?', 'Posting ODC Thread');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-05-09', 'ROT', 'Replying Why is it different for the query result of my two SQL?', 'Replying ODC Thread');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-05-06', 'POT', 'Posting ORA-00933: SQL command not properly ended', 'Posting ODC Thread');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-05-11', 'ROT', 'Replying ORA-00933: SQL command not properly ended', 'Replying ODC Thread');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-05-13', 'POT', 'Posting How to reviewing tail 20 lines for log.xml file by my SHELL script?', 'Posting ODC Thread');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-05-14', 'ROT', 'Replying How to reviewing tail 20 lines for log.xml file by my SHELL script?', 'Replying ODC Thread');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-05-14', 'POT', 'Posting How to query App machines'' IP by log.xml on SQL*Plus?', 'Posting ODC Thread');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-05-17', 'ROT', 'Replying How to query App machines'' IP by log.xml on SQL*Plus?', 'Replying ODC Thread');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-05-23', 'POT', 'Posting How to extract listener log file''s path?', 'Posting ODC Thread');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-05-27', 'ROT', 'Replying How to extract listener log file''s path?', 'Replying ODC Thread');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-05-27', 'POT', 'Posting How to output character strings with blank space using prompt on SQL*Plus?', 'Posting ODC Thread');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-05-28', 'ROT', 'Replying How to output character strings with blank space using prompt on SQL*Plus?', 'Replying ODC Thread');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-06-17', 'POT', 'Posting ORA-01427: single-row subquery returns more than one row', 'Posting ODC Thread');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-06-20', 'ROT', 'Replying ORA-01427: single-row subquery returns more than one row', 'Replying ODC Thread');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-06-27', 'POT', 'Posting ORA-01756: quoted string not properly terminated', 'Posting ODC Thread');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-07-04', 'ROT', 'Replying ORA-01756: quoted string not properly terminated', 'Replying ODC Thread');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-07-15', 'POT', 'Posting ORA-01775: looping chain of synonyms', 'Posting ODC Thread');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-07-19', 'ROT', 'Replying ORA-01775: looping chain of synonyms', 'Replying ODC Thread');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-07-22', 'POT', 'Posting Showing 4 number of compilation errors when running my procedure', 'Posting ODC Thread');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-07-23', 'ROT', 'Replying Showing 4 number of compilation errors when running my procedure', 'Replying ODC Thread');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-07-26', 'POT', 'Posting one blank line represents two blank lines on Syntax Highlighting of SQL', 'Posting ODC Thread');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-07-26', 'ROT', 'Replying one blank line represents two blank lines on Syntax Highlighting of SQL', 'Replying ODC Thread');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-08-06', 'POT', 'Posting Warning: Procedure created with compilation errors - PLS-00103', 'Posting ODC Thread');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-08-08', 'ROT', 'Replying Warning: Procedure created with compilation errors - PLS-00103', 'Replying ODC Thread');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-11-01', 'POT', 'Posting Why used size of several tablespace is different when separately running 2 SQL scripts checking tablespace used size?', 'Posting ODC Thread');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-11-11', 'ROT', 'Replying Why used size of several tablespace is different when separately running 2 SQL scripts checking tablespace used size?', 'Replying ODC Thread');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-11-12', 'POT', 'Posting How to show TEMP tablespace usage?', 'Posting ODC Thread');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-11-18', 'ROT', 'Replying How to show TEMP tablespace usage?', 'Replying ODC Thread');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-12-05', 'POT', 'Posting ORA-06502: PL/SQL: numeric or value error: character to number conversion error', 'Posting ODC Thread');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-12-06', 'ROT', 'Replying ORA-06502: PL/SQL: numeric or value error: character to number conversion error', 'Replying ODC Thread');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-12-09', 'POT', 'Posting ORA-19114: XPST0003 - error during parsing the XQuery expression', 'Posting ODC Thread');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-12-10', 'ROT', 'Replying ORA-19114: XPST0003 - error during parsing the XQuery expression', 'Replying ODC Thread');

COMMIT;

-- Inserting the data of 'Posting/Replying WordPress Thread'

INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-07-01', 'PWT', 'Posting How to modify my post''s ugly and inelegant URL?', 'Posting WordPress Thread');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-07-01', 'RWT', 'Replying How to modify my post''s ugly and inelegant URL?', 'Replying WordPress Thread');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-08-01', 'PWT', 'Posting How to change alternate pictures on my blog?', 'Posting WordPress Thread');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-08-09', 'RWT', 'Replying How to change alternate pictures on my blog?', 'Replying WordPress Thread');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-08-18', 'PWT', 'Posting Why not attach picture/image on WordPress Forums?', 'Posting WordPress Thread');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-08-21', 'RWT', 'Replying Why not attach picture/image on WordPress Forums?', 'Replying WordPress Thread');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-08-18', 'PWT', 'Posting Are these some issues or bugs on WP?', 'Posting WordPress Thread');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-08-21', 'RWT', 'Replying Are these some issues or bugs on WP?', 'Replying WordPress Thread');

COMMIT;

-- Inserting the data of 'Submitting/Updating Github Open Source Project'

INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-05-18', 'SGOSP', 'submitting ODRIS', 'Submitting Github Open Source Project');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-05-26', 'UGOSP', 'updating ODRIS', 'Updating Github Open Source Project');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-12-25', 'SGOSP', 'submitting A Demo Checking Execution Plan of Querying COUNT table', 'Submitting Github Open Source Project');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-12-24', 'SGOSP', 'submitting A Demo Spending Time of Querying COUNT table', 'Submitting Github Open Source Project');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-12-29', 'UGOSP', 'updating A Demo Spending Time of Querying COUNT table', 'Updating Github Open Source Project');

COMMIT;

-- Inserting the data of 'Submitting LiveSQL Code'

INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-12-25', 'SLC', 'Submitting Checking Real Execution Plan(s) of Separately Querying COUNT(*|1|id|flag) on 4 different TEST Table(s)', 'Submitting LiveSQL Code');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-12-25', 'SLC', 'Submitting Checking Real Execution Plan(s) of Separately Querying COUNT(*|1|id|flag) on 4 different TEST2 Table(s)', 'Submitting LiveSQL Code');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-12-26', 'SLC', 'Submitting Checking Real Execution Plan(s) of Separately Querying COUNT(*|1|id|flag) on 4 different TEST3 Table(s)', 'Submitting LiveSQL Code');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-12-26', 'SLC', 'Submitting Checking Real Execution Plan(s) of Separately Querying COUNT(*|1|id|flag) on 4 different TEST4 Table(s)', 'Submitting LiveSQL Code');
INSERT INTO daily_work (current_date, cgy_abbr, stuff, annotation) VALUES (date '2019-12-29', 'SLC', 'Submitting Observing Spending Time of Separately Querying COUNT(*|1|id|flag) on some Test Tables', 'Submitting LiveSQL Code');

COMMIT;
