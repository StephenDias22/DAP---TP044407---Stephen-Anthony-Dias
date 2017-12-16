
/* Data Entry */
Proc import out=DAP_Assi
	datafile= '/home/dias_stephen0/D.A.P Assignment/TP044407_DAP.xls'
	dbms= xls replace;
	getnames= yes;
	namerow=5;
	datarow=6;
	endrow=525;
	endcol=O;
run;

/*Adding Column Names*/
data prep1;
	set DAP_Assi;
	Rename 
	Att1= State
	Att2= City
	Att3= Year
	Att4= Population
	Att5= Violent_Crime
	Att6= Murder
	Att7= Rape_rev
	Att8= Rape_leg
	Att9= Robbery
	Att10= Agg_Assault
	Att11= Prop_theft
	Att12= Burglary
	Att13= Lar_theft
	Att14= M_veh_theft
	Att15= Arson;
run;

proc contents data=prep1;
run;

/*checking for missing values */
proc means data=prep1 nmiss;
run;

/* Imputing missing values */
proc stdize data=prep1 out=imputed1
            missing=mean reponly;
            var Violent_crime
                Murder
                Rape_rev
                Robbery
                Agg_Assault
                Prop_theft
                Burglary
                Lar_theft
                M_veh_theft
                Arson;
data imputed2;
set imputed1;
retain 
	m_population
 	m_state
 	m_city;
	If not missing (population) 
	then m_population=round(population+(Population*0.078));
	else population=m_population;

	If not missing (state) 
	then m_state=state;
	else state=m_state;

	If not missing (city) 
	then m_city=city;
	else city=m_city;
drop
	m_population
	m_state
	m_city;
run;
/* checking missing values after imputation */
proc means data=imputed2 nmiss;
run;
/* frequency check */
proc freq data=imputed2;
tables
		Violent_crime
                Murder
                Rape_rev
                Robbery
                Agg_Assault
                Prop_theft
                Burglary
                Lar_theft
                M_veh_theft
                Arson;
run;

/* rounding imputed values */
data rounded;
set imputed2;
	violent_crime=round(violent_crime,1);
	Murder=round(murder,1);
	Rape_rev=round(rape_rev,1);
	Robbery=round(robbery,1);
	Agg_Assault=round(agg_assault,1);
	Prop_theft=round(prop_theft,1);
	Burglary=round(burglary,1);
	Lar_theft=round(lar_theft,1);
	M_veh_theft=round(M_veh_theft,1);
	Arson=round(arson,1);
run;
proc print data=rounded;
run;

/* Data reduction and combining */
	data prep2;
	set rounded;
	drop 
	rape_leg;
	run;

data final;
set prep2;
	total_theft=sum(Prop_theft, Arson);
drop
 	murder 
 	rape_rev 
 	Robbery 
 	Agg_Assault 
 	Prop_theft 
 	Burglary 
 	Lar_theft 
 	M_veh_theft 
 	Arson;
run;


proc print data=final;
sum violent_crime total_theft;
var state city year violent_crime total_theft;
run;


/* Objective 1 */
TITLE1'Total Crime by year and population';  
PROC TABULATE DATA=final; 
     CLASS year; 
     VAR population violent_crime total_theft; 
	 TABLE    
           year='Year'*(population='Population'*(sum=''*f=comma16.) 
           violent_crime='Violent Crime'*(SUM=''*f=comma16.)  
           total_theft='Total Theft'*(sum=''*f=comma16.));
           
RUN; 
TITLE1; 
/* initializing new excel file for visualization of total crime in both years */
FILENAME REFFILE '/home/dias_stephen0/D.A.P Assignment/Total crime by year and population.xlsx';
PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=Total_crime_viz;
	GETNAMES=YES;
RUN;
PROC CONTENTS DATA=WORK.IMPORT; RUN;









/* Objective 2 */

/* Sorting data in descending order and creating visual by year  */
proc sort data=final out=sorted_vc2014;
by descending violent_crime;
where year=2014;
run;

proc sort data=final out =sorted_vc2015;
by descending violent_crime;
where year=2015;
run;

proc sort data=final out= sorted_tt2014;
by descending total_theft;
where year= 2014;
run;

proc sort data=final out=sorted_tt2015;
by descending total_theft;
where year=2015;
run;

/* sorted visual for violent crimes in 2014 by state*/
title1 'Top 5 states with violent crimes in 2014';
ods graphics / reset width=6.4in height=8in imagemap;
proc sgplot data=SORTED_VC2014;
hbar State / response=Violent_Crime datalabel stat=Sum name='Bar' categoryorder=respdesc datalabelfitpolicy=none;
yaxis label="State";
xaxis grid label="No. of Violent Crimes";
run;
ods graphics / reset;
title1;
/* sorted visual for violent crimes in 2015 by state*/
title1 'Top 5 states with violent crimes in 2015';
ods graphics / reset width=6.4in height=8in imagemap;
proc sgplot data=SORTED_VC2015;
hbar State / response=Violent_Crime datalabel stat=Sum name='Bar' categoryorder=respdesc datalabelfitpolicy=none;
yaxis label="State";
xaxis grid label="No. of Violent Crimes";
run;
ods graphics / reset;
title1;
/* creating a table for violent crimes in both years based on the states from visual */
proc sort data=final out=sorted_VC ;
by descending violent_crime;
where state in ('CALIFORNIA', 'TEXAS', 'NEW YORK','FLORIDA', 'ILLINOIS');
run;

TITLE1'Violent crime by population and state';  
PROC TABULATE DATA=sorted_VC; 
     CLASS state year; 
     VAR population violent_crime; 
	 TABLE 
	 	   State='', 
           year='Year'*(population='Population'*(sum=''*f=comma16.) 
           violent_crime='Violent Crime'*(SUM=''*f=comma16.)) 
          / box='State';
RUN; 
TITLE1;


/* 2014 */
/* sorted visual for total theft in 2014 by state*/
title1 'Top 5 states with total theft in 2014';
ods graphics / reset width=6.4in height=8in imagemap;
proc sgplot data=SORTED_tt2014;
hbar State / response=total_theft datalabel stat=Sum name='Bar' categoryorder=respdesc datalabelfitpolicy=none;
yaxis label="State";
xaxis grid label="No. of theft's";
run;
ods graphics / reset;
title1;
/* creating a table for total theft in 2014 years based on the states from visual */
proc sort data=final out=sorted_TTst14 ;
by descending total_theft;
where state in ('CALIFORNIA', 'FLORIDA', 'ARIZONA','WASHINGTON', 'TENNESSEE') and year=2014;
run;

TITLE1'Total Theft in 2014 by population and state';  
PROC TABULATE DATA=sorted_TTst14; 
     CLASS state year; 
     VAR population total_theft; 
	 TABLE 
	 	   State='', 
           year='Year'*(population='Population'*(sum=''*f=comma16.) 
           total_theft='Total Theft'*(SUM=''*f=comma16.)) 
          / box='State';
RUN; 
TITLE1;
/* sorted visual for violent crimes in 2015 by state*/
title1 'Top 5 states with total theft in 2015';
ods graphics / reset width=6.4in height=8in imagemap;
proc sgplot data=SORTED_tt2015;
hbar State / response=total_theft datalabel stat=Sum name='Bar' categoryorder=respdesc datalabelfitpolicy=none;
yaxis label="State";
xaxis grid label="No. of theft's";
run;
ods graphics / reset;
/* creating a table for total theft in both years based on the states from visual */
proc sort data=final out=sorted_TTst15 ;
by descending total_theft;
where state in ('CALIFORNIA', 'FLORIDA', 'ARIZONA','OHIO9', 'WASHINGTON') and year=2015;
run;

TITLE1'Total Theft by population and state';  
PROC TABULATE DATA=sorted_TTst15; 
     CLASS state year; 
     VAR population total_theft; 
	 TABLE 
	 	   State='', 
           year='Year'*(population='Population'*(sum=''*f=comma16.) 
           total_theft='Total Theft'*(SUM=''*f=comma16.)) 
          / box='State';
RUN; 
TITLE1;

/* Objective 3 */
/* sorted visual for violent crimes in 2014 by City*/
title1 'Top 5 cities with violent crimes in 2014';
ods graphics / reset width=6.4in height=8in imagemap;
proc sgplot data=SORTED_VC2014;
hbar City / response=Violent_Crime  stat=Sum name='Bar' categoryorder=respdesc datalabelfitpolicy=none;
yaxis label="City";
xaxis grid label="No. of Violent Crimes";
run;
ods graphics / reset;
title1;
/* creating a table for violent crimes in 2014 based on the Cities from visual 1 */
proc sort data=final out=sorted_VCcity14 ;
by descending violent_crime;
where CITY in ('CHICAGO', 'PHOENIX', 'SAN FRANCISCO','CLEVELAND', 'MIAMI') and year=2014;
run;

TITLE1'Violent crime by population and city for 2014';  
PROC TABULATE DATA=sorted_VCcity14; 
     CLASS CITY year; 
     VAR population violent_crime; 
	 TABLE 
	 	   CITY='', 
           year='Year'*(population='Population'*(sum=''*f=comma16.) 
           violent_crime='Violent Crime'*(SUM=''*f=comma16.)) 
          / box='CITY';
RUN; 
TITLE1;
/* sorted visual for violent crimes in 2015 by City*/
title1 'Top 5 cities with violent crimes in 2015';
ods graphics / reset width=6.4in height=8in imagemap;
proc sgplot data=SORTED_VC2015;
hbar City / response=Violent_Crime stat=Sum name='Bar' categoryorder=respdesc datalabelfitpolicy=none;
yaxis label="City";
xaxis grid label="No. of Violent Crimes";
run;
ods graphics / reset;
title1;
/* creating a table for violent crimes in 2015 based on the Cities from visual 2 */
proc sort data=final out=sorted_VCcity15 ;
by descending violent_crime;
where CITY in ('CHICAGO', 'PHOENIX', 'SAN FRANCISCO','ALBUQUERQUE', 'FORT WORTH') and year=2015;
run;

TITLE1'Violent crime by population and city for 2015';  
PROC TABULATE DATA=sorted_VCcity15; 
     CLASS CITY year; 
     VAR population violent_crime; 
	 TABLE 
	 	   CITY='', 
           year='Year'*(population='Population'*(sum=''*f=comma16.) 
           violent_crime='Violent Crime'*(SUM=''*f=comma16.)) 
          / box='CITY';
RUN; 
TITLE1;
/* sorted visual for total theft in 2014 by City */
title1 'Top 5 cities with total theft in 2014';
ods graphics / reset width=6.4in height=8in imagemap;
proc sgplot data=SORTED_tt2014;
hbar CITY / response=total_theft stat=Sum name='Bar' categoryorder=respdesc datalabelfitpolicy=none;
yaxis label="CITY";
xaxis grid label="No. of theft's";
run;
ods graphics / reset;
title1;
/* creating a table for total theft in 2014 based on the cities from visual */
proc sort data=final out=sorted_TTcity14 ;
by descending total_theft;
where City in ('HOUSTON', 'COLUMBUS', 'DETROIT','OKLAHOMA CITY', 'SPRINGFIELD') and year=2014;
run;

TITLE1'Total Theft in 2014 by population and city';  
PROC TABULATE DATA=sorted_TTcity14; 
     CLASS City year; 
     VAR population total_theft; 
	 TABLE 
	 	   CITY='', 
           year='Year'*(population='Population'*(sum=''*f=comma16.) 
           total_theft='Total Theft'*(SUM=''*f=comma16.)) 
          / box='CITY';
RUN; 
TITLE1;
/* sorted visual for total theft in 2015 by City*/
title1 'Top 5 cities with total theft in 2015';
ods graphics / reset width=6.4in height=8in imagemap;
proc sgplot data=SORTED_tt2015;
hbar CITY / response=total_theft stat=Sum name='Bar' categoryorder=respdesc datalabelfitpolicy=none;
yaxis label="City";
xaxis grid label="No. of theft's";
run;
ods graphics / reset;
/* creating a table for total theft in 2015 based on the cities from visual */
proc sort data=final out=sorted_TTcity15 ;
by descending total_theft;
where City in ('HOUSTON', 'PHILADELPHIA', 'JACKSONVILLE','SAN DIEGO', 'NASHVILLE') and year=2015;
run;

TITLE1'Total Theft in 2015 by population and city';  
PROC TABULATE DATA=sorted_TTcity15; 
     CLASS City year; 
     VAR population total_theft; 
	 TABLE 
	 	   CITY='', 
           year='Year'*(population='Population'*(sum=''*f=comma16.) 
           total_theft='Total Theft'*(SUM=''*f=comma16.)) 
          / box='CITY';
RUN; 
TITLE1;





