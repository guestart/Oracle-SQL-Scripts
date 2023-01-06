REM
REM     Script:        check_ip_by_monitor_user.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Nov 16, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       These PL/SQL scripts uses to add the acl configuration to a specific user
REM       in order to that user is able to check ip on your oracle database.
REM       You know, the PL/SQL script has a little difference on before and after 12cR1.
REM

-- before 12cR1:

-- 
-- SQL> 
-- SQL> conn dmpmon
-- Enter password: 
-- Connected.
-- SQL> 
-- SQL> select utl_inaddr.get_host_address(host_name) PHYSICAL_IP from gv$instance;
-- select utl_inaddr.get_host_address(host_name) PHYSICAL_IP from gv$instance
--        *
-- ERROR at line 1:
-- ORA-24247: network access denied by access control list (ACL)
-- ORA-06512: at "SYS.UTL_INADDR", line 19
-- ORA-06512: at "SYS.UTL_INADDR", line 40
-- ORA-06512: at line 1
-- 

-- adding the acl configuration to user 'dmpmon' only allowing the host 'db01' and 'db02':

begin
dbms_network_acl_admin.create_acl (
acl => 'UTL_INADDR.xml',
description => 'utl_inaddr',
principal => 'dmpmon',  -- username
is_grant => TRUE,
privilege => 'resolve'
);
commit;
end;
/

begin
dbms_network_acl_admin.assign_acl(
acl => 'UTL_INADDR.xml',
host => 'db01'  -- hostname
);
commit;
end;
/

begin
dbms_network_acl_admin.assign_acl(
acl => 'UTL_INADDR.xml',
host => 'db02'  -- hostname
);
commit;
end;
/

-- 
-- SQL> 
-- SQL> conn dmpmon
-- Enter password: 
-- Connected.
-- SQL> 
-- SQL> select utl_inaddr.get_host_address(host_name) PHYSICAL_IP from gv$instance;
-- 
-- PHYSICAL_IP
-- --------------------------------------------------------------------------------
-- 192.168.1.61
-- 192.168.1.62
-- 

-- after 12cR1:

-- 
-- SQL> 
-- SQL> conn c##dmpmon
-- Enter password: 
-- Connected.
-- SQL> 
-- SQL> select utl_inaddr.get_host_address(host_name) PHYSICAL_IP from gv$instance;
-- select utl_inaddr.get_host_address(host_name) PHYSICAL_IP from gv$instance
--        *
-- ERROR at line 1:
-- ORA-24247: network access denied by access control list (ACL)
-- ORA-06512: at "SYS.UTL_INADDR", line 19
-- ORA-06512: at "SYS.UTL_INADDR", line 40
-- ORA-06512: at line 1
-- 

-- adding the acl configuration to user 'c##dmpmon' only allowing the host 'yyds01' and 'yyds02':

BEGIN
  DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE(
    host => 'yyds01',  -- hostname
    ace  =>  xs$ace_type(
      privilege_list => xs$name_list('resolve'),
      principal_name => 'c##dmpmon',  -- username
      principal_type => xs_acl.ptype_db
     )
 );
END;
/

BEGIN
  DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE(
    host => 'yyds02',  -- hostname
    ace  =>  xs$ace_type(
      privilege_list => xs$name_list('resolve'),
      principal_name => 'c##dmpmon',  -- username
      principal_type => xs_acl.ptype_db
     )
 );
END;
/

-- 
-- SQL> 
-- SQL> conn c##dmpmon
-- Enter password: 
-- Connected.
-- SQL> 
-- SQL> select utl_inaddr.get_host_address(host_name) PHYSICAL_IP from gv$instance;
-- 
-- PHYSICAL_IP
-- --------------------------------------------------------------------------------
-- 192.168.12.181
-- 192.168.12.182
-- 
