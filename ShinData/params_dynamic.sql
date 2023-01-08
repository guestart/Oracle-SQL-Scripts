REM
REM     Script:        params_dynamic.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Aug 04, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Checking the dynamic parameters of oracle database.
REM

-- Those parameters taking effect on system level:

select name,
       decode(type, 1, 'Boolean', 2, 'String', 3, 'Integer', 4, 'Parameter file', 5, 'Reserved', 6, 'Big integer') type,
       value,
       description
from v$parameter where  issys_modifiable = 'IMMEDIATE'
order by name;

-- Those parameters taking effect on session level:

select name,
       decode(type, 1, 'Boolean', 2, 'String', 3, 'Integer', 4, 'Parameter file', 5, 'Reserved', 6, 'Big integer') type,
       value,
       description
from v$parameter where  isses_modifiable = 'TRUE'
order by name;
