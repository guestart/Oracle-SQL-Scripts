REM
REM     Script:        params_static.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Aug 03, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Checking the static parameters of oracle database.
REM

-- ISMODIFIED = 'MODIFIED'   --> isses_modifiable = 'FALSE'
-- ISMODIFIED = 'SYSTEM_MOD' --> issys_modifiable = 'FALSE'
-- isses_modifiable = 'FALSE' or issys_modifiable = 'FALSE'

select name,
       decode(type, 1, 'Boolean', 2, 'String', 3, 'Integer', 4, 'Parameter file', 5, 'Reserved', 6, 'Big integer') type,
       value,
       description
from v$parameter where ismodified = 'FALSE' 
order by name;
