REM
REM     Script:        kill_sessions_base_on_sqlid.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Jul 15, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       The SQL script uses to immediately kill sessions from the same sql_id of oracle database.
REM       You know, sql_id 'a8fdq2kj0rmz7' comes from a specific sql.
REM

declare
  v_sid v$session.sid%type;
  v_serial# v$session.serial#%type;
  cursor cur_session is select sid, serial# from v$session where sql_id = 'a8fdq2kj0rmz7';
begin
  open cur_session;
  loop
    fetch cur_session into v_sid,v_serial#;
    execute immediate 'alter system kill session '''||v_sid||','||v_serial#||''' immediate';
    exit when cur_session%notfound;
    dbms_output.put_line('cursor date have been fetched ending');
  end loop;
  close cur_session;
end;
/
