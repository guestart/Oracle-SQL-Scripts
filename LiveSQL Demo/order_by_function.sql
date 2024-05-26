REM
REM     Script:        order_by_function.sql
REM     Author:        Quanwen Zhao
REM     Dated:         May 26, 2024
REM
REM     Last tested:
REM             Oracle Live SQL - 19.17 in current
REM
REM     Purpose:
REM       The demo's inspiration comes from the archived Oracle SQuizL topic on Sunday, 12 May, 2024 and its correct result like this,
REM       "SELECT CEIL ( start_time, 'mm' ) mth, COUNT(*) FROM tournaments GROUP BY mth ORDER BY mth".
REM       I simulated the demo by creating a table product_orders with two columns (id varchar2) and (name varchar2) and then select it
REM       by "order by to_number(id)".
REM

create table product_orders(id varchar2(10), name varchar2(100));

exec dbms_random.seed(0);

insert into product_orders(id, name)
select rownum, dbms_random.string('A', 6)
from dual
connect by level <= 20;

commit;

select id, name from product_orders order by 1;

ID	NAME
--  ------
1	  ByDWeb
10	xAShai
11	pJAoFN
12	kwUOkQ
13	YSTDiH
14	LFlroE
15	wNlhDw
16	NSgfVX
17	jDpnoD
18	ifkgpk
19	oJFEYO
2	  uOZjqF
20	nmXmVI
3	  UyjCyC
4	  zakIot
5	  zTeDDO
6	  PlOVWf
7	  cWehRW
8	  StTaSS
9	  GSNlBh

select id, name from product_orders order by to_number(id);

ID	NAME
--  ------
1	  ByDWeb
2	  uOZjqF
3	  UyjCyC
4	  zakIot
5	  zTeDDO
6	  PlOVWf
7	  cWehRW
8	  StTaSS
9	  GSNlBh
10	xAShai
11	pJAoFN
12	kwUOkQ
13	YSTDiH
14	LFlroE
15	wNlhDw
16	NSgfVX
17	jDpnoD
18	ifkgpk
19	oJFEYO
20	nmXmVI

select to_number(id), name from product_orders order by 1;

TO_NUMBER(ID)	NAME
------------- ------
1	            ByDWeb
2	            uOZjqF
3	            UyjCyC
4	            zakIot
5	            zTeDDO
6	            PlOVWf
7	            cWehRW
8	            StTaSS
9	            GSNlBh
10	          xAShai
11	          pJAoFN
12	          kwUOkQ
13	          YSTDiH
14	          LFlroE
15	          wNlhDw
16	          NSgfVX
17	          jDpnoD
18	          ifkgpk
19	          oJFEYO
20	          nmXmVI

select cast(id as number) id, name from product_orders order by 1;

ID	NAME
--  ------
1	  ByDWeb
2	  uOZjqF
3	  UyjCyC
4	  zakIot
5	  zTeDDO
6	  PlOVWf
7	  cWehRW
8	  StTaSS
9	  GSNlBh
10	xAShai
11	pJAoFN
12	kwUOkQ
13	YSTDiH
14	LFlroE
15	wNlhDw
16	NSgfVX
17	jDpnoD
18	ifkgpk
19	oJFEYO
20	nmXmVI
