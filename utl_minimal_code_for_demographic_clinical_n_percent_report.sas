Minimal code for demographic clinical N Percent report

Same result in SAS and WPS

github
https://tinyurl.com/y7wdnfn2
https://github.com/rogerjdeangelis/utl_minimal_code_for_demographic_clinical_n_percent_report

see
https://github.com/rogerjdeangelis?utf8=%E2%9C%93&tab=repositories&q=report&type=&language=


INPUT
=====

 WORK.HAVE total obs=2,012

   COUNTRY    STATE         ANSWER     TRT

   U.S.A.     California       1      GROUP2
   U.S.A.     All              1      GROUP2
   U.S.A.     All              1      Total
   U.S.A.     California       1      TOTAL
   U.S.A.     California       1      GROUP2
   U.S.A.     All              1      GROUP2
   U.S.A.     All              1      Total
   U.S.A.     California       1      TOTAL
   U.S.A.     California       1      GROUP1
 ....

EXAMPLE OUTPUT

  COUNTRY    STATE           GROUP1     GROUP2       TOTAL

  Canada     All             72(50%)    81(50%)    153(100%)

             Ontario         24(17%)    23(14%)    47(31%)
             Quebec          22(15%)    27(17%)    49(32%)
             Saskatchewan    26(18%)    31(19%)    57(37%)

  Mexico     All             85(50%)    72(50%)    157(100%)

             Campeche        21(12%)    27(19%)    48(31%)
             Michoacan       34(20%)    27(19%)    61(39%)
             Nuevo Leon      30(18%)    18(13%)    48(31%)

  U.S.A.     All             97(50%)    96(50%)    193(100%)

             California      14(7%)     20(10%)    34(18%)
             Colorado        21(11%)    31(16%)    52(27%)
             Florida         36(19%)    23(12%)    59(31%)
             Texas           26(13%)    22(11%)    48(25%)


PROCESS
=======

proc sql;
   create
     table want as
   select
    distinct
     l.trt
    ,l.country
    ,l.state
    ,r.sumgrp
    ,cats(put(sum(l.answer),4.),'(',put(sum(l.answer)/r.sumgrp,percent.),')') as answer
  from
     have as l, (select trt, country, sum(answer) as sumgrp from have group by trt, country) as r
  where
     l.trt        =  r.trt  and
     l.country    =  r.country
  group
     by l.trt, l.country, l.state
  order
     by country, state
;quit;

proc transpose data=cntpct out=want(drop=_name_);
by country state notsorted;
id trt;
var answer;
run;quit;

proc print data=want width=min;
by country;
id country;
run;quit;


OUTPUT
======

  COUNTRY    STATE           GROUP1     GROUP2       TOTAL

  Canada     All             72(50%)    81(50%)    153(100%)

             Ontario         24(17%)    23(14%)    47(31%)
             Quebec          22(15%)    27(17%)    49(32%)
             Saskatchewan    26(18%)    31(19%)    57(37%)

  Mexico     All             85(50%)    72(50%)    157(100%)

             Campeche        21(12%)    27(19%)    48(31%)
             Michoacan       34(20%)    27(19%)    61(39%)
             Nuevo Leon      30(18%)    18(13%)    48(31%)

  U.S.A.     All             97(50%)    96(50%)    193(100%)

             California      14(7%)     20(10%)    34(18%)
             Colorado        21(11%)    31(16%)    52(27%)
             Florida         36(19%)    23(12%)    59(31%)
             Texas           26(13%)    22(11%)    48(25%)

*                _               _       _
 _ __ ___   __ _| | _____     __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \   / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/  | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|   \__,_|\__,_|\__\__,_|

;

data have;

  set sashelp.prdsal2(keep=country state
     where=(state in (
     'Ontario      '
     ,'Quebec      '
     ,'Saskatchewan'
     ,'Campeche    '
     ,'Michoacan   '
     ,'Nuevo Leon  '
     ,'California  '
     ,'Colorado    '
     ,'Florida     '
     ,'Texas       '))) ;

  if uniform(4321) < 100/2304;
  answer=1;

  if uniform(1234)<.5 then trt='GROUP1';
  else trt='GROUP2';

  output;            * nway detail;

  savstate = state;
  state='All      ';
  output;            * sum over all states;

  savTrt=trt;
  trt="TOTAL";
  output;            * state=all total=all;

  state = savstate;
  trt="TOTAL  ";
  output;            * trt=total over each state;

  drop savState savtrt;
run;quit;

*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __
/ __|/ _ \| | | | | __| |/ _ \| '_ \
\__ \ (_) | | |_| | |_| | (_) | | | |
|___/\___/|_|\__,_|\__|_|\___/|_| |_|

;

%utl_submit_wps64('
libname wrk sas7bdat "%sysfunc(pathname(work))";
proc sql;
   create
     table want as
   select
    distinct
     l.trt
    ,l.country
    ,l.state
    ,r.sumgrp
    ,cats(put(sum(l.answer),4.),"(",put(sum(l.answer)/r.sumgrp,percent.),")") as answer
  from
     wrk.have as l, (select trt, country, sum(answer) as sumgrp from wrk.have group by trt, country) as r
  where
     l.trt        =  r.trt  and
     l.country    =  r.country
  group
     by l.trt, l.country, l.state
  order
     by country, state
;quit;

proc transpose data=want out=want(drop=_name_);
by country state notsorted;
id trt;
var answer;
run;quit;

proc print data=want;
id country;
by country;
run;quit;
');

