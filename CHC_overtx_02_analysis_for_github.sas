libname checkJM /*where dataset is saved*/;

/* Using format statement*/
%inc /*where formats are saved*/;

proc format;
value hosp 0="Non-academic location"
		   1="Academic Location";

value sev 3 = "Top 25th percentile of all 3 symp score"
		  2 = "Top 25th percentile of any 2 symp score"
		  1 = "Top 25th percentile of any 1 symp score"
		  0 = "Not in the top 25th percentile of any symp score";

value sevscore 2 = "Top 25th percentile of 2 or 3 symp score"
		  1 = "Top 25th percentile of any 1 symp score"
		  0 = "Not in the top 25th percentile of any symp score";

run;
/***Tables and Modeling***/

/**Table 1. Descriptive characteristics of the hysterectomy cohort by race (N=1857) **/

data race_three_level;
set checkJM.r01_aim1_6_1_22_jm;
*if race_six_level in ("Black", "White", "Hispanic");
run;

/***Table 1. Descriptive characteristics for Black, White and Hispanic population only (N=1753)***/

Title "Table 1. Descriptive characteristics of the hysterectomy cohort by race (N=1857)";
proc means data= race_three_level n /*mean stddev */median min q1 q3 max missing;
var R_AGE_HYST BMI_WOOUTLI bleed_score pain_score bulk_score_v2 count_prior_treat R_PREGHX_DELIV_COUNT w_cci;
class race_six_level;
run;

data race_three;
set race_three_level;
label count_prior_treat = 'Prior treatments';
label race_three = "Race";
label sym_sev = "Symp Sev";

 if race_six_level = "Hispanic" then race_three = "Hispanic";
else if race_six_level = "Black" then race_three = "Black";
else if race_six_level = "White" then race_three = "White";

if com_sev_analysis = 2 then sym_sev= "Any_2or3";
else if com_sev_analysis = 1 then sym_sev= "Any_1";
else if com_sev_analysis = 0 then sym_sev= "None";

If insurance_modified in ("Medicaid Only","Medicare Only","Agency Only") then payorgrp = "Public";
else if insurance_modified in ("Tricare Only","Private Insurance Only") then payorgrp = "Private";
else if insurance_modified in ("Self-Pay Only") then payorgrp = "Unins";

run;

proc freq data=race_three;
tables /*race_six_level*bulk_scoretop25*bleed_scoretop25*pain_scoretop25*/   payorgrp payorgrp*race_six_level/ missing;
run;

/***Clinical conditions present at the time of surgery***/

title "Clinical conditions and other covarites of interest - Race=Black";
proc freq data= checkJM.r01_aim1_6_1_22_jm;
tables BMI_CAT Fibroids Chronicpelvpain Endometriosis MENOR_AUB Cervdysplasia OVCYSTPELVMASS prev_laparotomy CDWH_HOSP_ID/ list missing;
where race_six_level = "Black";
run;

title "Clinical conditions and other covarites of interest - Race=White";
proc freq data= checkJM.r01_aim1_6_1_22_jm;
tables BMI_CAT Fibroids Chronicpelvpain Endometriosis MENOR_AUB Cervdysplasia OVCYSTPELVMASS prev_laparotomy CDWH_HOSP_ID / list missing;
where race_six_level = "White";
run;


title "Clinical conditions and other covarites of interest - Race=Hispanic";
proc freq data= checkJM.r01_aim1_6_1_22_jm;
tables BMI_CAT Fibroids Chronicpelvpain Endometriosis MENOR_AUB Cervdysplasia OVCYSTPELVMASS prev_laparotomy CDWH_HOSP_ID  / list missing;
where race_six_level = "Hispanic";
run;


title "Clinical conditions and other covarites of interest - Race=Asian";
proc freq data= checkJM.r01_aim1_6_1_22_jm;
tables BMI_CAT Fibroids Chronicpelvpain Endometriosis MENOR_AUB Cervdysplasia OVCYSTPELVMASS prev_laparotomy CDWH_HOSP_ID  / list missing;
where race_six_level = "Asian";
run;

title "Clinical conditions and other covarites of interest - Race=Native";
proc freq data= checkJM.r01_aim1_6_1_22_jm;
tables BMI_CAT Fibroids Chronicpelvpain Endometriosis MENOR_AUB Cervdysplasia OVCYSTPELVMASS prev_laparotomy CDWH_HOSP_ID / list missing;
where race_six_level = "Native";
run;
 	
title "Clinical conditions and other covarites of interest - Race=Refused/Unknown";
proc freq data= checkJM.r01_aim1_6_1_22_jm;
tables BMI_CAT Fibroids Chronicpelvpain Endometriosis MENOR_AUB Cervdysplasia OVCYSTPELVMASS prev_laparotomy CDWH_HOSP_ID/ list missing;
where race_six_level = "Refused/Unknown";
run;


title "Clinical conditions and other covarites of interest - Race=Other";
proc freq data= checkJM.r01_aim1_6_1_22_jm;
tables BMI_CAT Fibroids Chronicpelvpain Endometriosis MENOR_AUB Cervdysplasia OVCYSTPELVMASS prev_laparotomy CDWH_HOSP_ID/ list missing;
where race_six_level = "Other";
run;


/***Histogram for previous treatments***/
title 'Histogram of prior treatments in the top 25th percentile of Sym severity';
ods graphics on;
proc univariate data=race_three noprint;
   class sym_sev race_three / keylevel = ('Any_1' 'Black');
   histogram count_prior_treat / 
                     ncols      = 3
                     nrows      = 3
					 midpoints = 0 to 8.0 by 1.0
                     odstitle   = title;
inset N mean std="Std Dev" median min max/ pos = ne format = 6.3;
run;

title "Histogram of prior treatments in the top 25th percentile of Sym severity (black, white and hispanic)";
ods graphics on;
proc univariate data=race_three noprint;
   class sym_sev;
   histogram count_prior_treat /nrows     = 3 
								midpoints = 0 to 8.0 by 1.0
                               odstitle  = title;
   inset N mean std="Std Dev" median min q1 q3 max/ pos = ne format = 6.3;
run;

title "Histogram of prior treatments in the top 25th percentile of Sym severity (black)";
ods graphics on;
proc univariate data=race_three noprint;
   class sym_sev;
   histogram count_prior_treat /nrows     = 3 
								midpoints = 0 to 8.0 by 1.0
                               odstitle  = title;
   inset N mean std="Std Dev" median min q1 q3 max/ pos = ne format = 6.3;
   where race_three = "Black"; 
run;

title "Histogram of prior treatments in the top 25th percentile of Sym severity (White)";
ods graphics on;
proc univariate data=race_three noprint;
   class sym_sev;
   histogram count_prior_treat /nrows     = 3 
								midpoints = 0 to 8.0 by 1.0
                               odstitle  = title;
   inset N mean std="Std Dev" median min q1 q3 max/ pos = ne format = 6.3;
   where race_three = "White"; 
run;

title "Histogram of prior treatments in the top 25th percentile of Sym severity (Hispanic)";
ods graphics on;
proc univariate data=race_three noprint;
   class sym_sev;
   histogram count_prior_treat /nrows     = 3 
								midpoints = 0 to 8.0 by 1.0
                               odstitle  = title;
   inset N mean std="Std Dev" median min q1 q3 max/ pos = ne format = 6.3;
   where race_three = "Hispanic"; 
run;

*title "Histogram of prior treatments in the top 25th percentile of Bulk (black, white and hispanic)";
title "Histogram of prior treatments for the study population";
ods graphics on;
proc univariate data=race_three noprint;
   class race_three;
   histogram count_prior_treat /nrows     = 3 
								midpoints = 0 to 8.0 by 1.0
                               odstitle  = title;
   inset N mean std="Std Dev" median min q1 q3 max/ pos = ne format = 6.1;
   *where bulk_scoretop25 = 1;
run;

title "Histogram of prior treatments in the top 25th percentile of Bleeding (black, white and hispanic)";
ods graphics on;
proc univariate data=race_three noprint;
   class race_three;
   histogram count_prior_treat /nrows     = 3 
								midpoints = 0 to 8.0 by 1.0
                               odstitle  = title;
   inset N mean std="Std Dev" median min q1 q3 max/ pos = ne format = 6.1;
   where bleed_scoretop25 = 1;
run;


title "Histogram of prior treatments in the top 25th percentile of Pain (black, white and hispanic)";
ods graphics on;
proc univariate data=race_three noprint;
   class race_three;
   histogram count_prior_treat /nrows     = 3 
								midpoints = 0 to 8.0 by 1.0
                               odstitle  = title;
   inset N mean std="Std Dev" median min q1 q3 max/ pos = ne format = 6.3;
   where pain_scoretop25 = 1;
run;

title "Histogram of prior treatments in the top 25th percentile of Bulk";
ods graphics on;
proc univariate data=race_three noprint;
   *class race_three;
   histogram count_prior_treat / 
								midpoints = 0 to 8.0 by 1.0
                               odstitle  = title;
   inset N mean std="Std Dev" median min q1 q3 max/ pos = ne format = 6.3;
   where bulk_scoretop25 = 1;
run;

title "Histogram of prior treatments in the top 25th percentile of Bleeding";
ods graphics on;
proc univariate data=race_three noprint;
   *class race_three;
   histogram count_prior_treat /
								midpoints = 0 to 8.0 by 1.0
                               odstitle  = title;
   inset N mean std="Std Dev" median min q1 q3 max/ pos = ne format = 6.3;
   where bleed_scoretop25 = 1;
run;


title "Histogram of prior treatments in the top 25th percentile of Pain";
ods graphics on;
proc univariate data=race_three noprint;
   *class race_three;
   histogram count_prior_treat /
								midpoints = 0 to 8.0 by 1.0
                               odstitle  = title;
   inset N mean std="Std Dev" median min q1 q3 max/ pos = ne format = 6.3;
   where pain_scoretop25 = 1;
run;




/**Kruskal-Wallis**/
proc npar1way data=race_three wilcoxon dscf;
class race_three;
var count_prior_treat;
run;

proc npar1way data=race_three wilcoxon dscf;
class race_three;
var count_prior_treat;
where pain_scoretop25 = 1;
run;

proc npar1way data=race_three wilcoxon dscf;
class race_three;
var count_prior_treat;
where bleed_scoretop25 = 1;
run;


proc npar1way data=race_three wilcoxon dscf;
class race_three;
var count_prior_treat;
where bulk_scoretop25 = 1;
run;


/***All categorical variables***/


title "Clinical conditions and other covarites of interest for the black, white and hispanic population";
proc freq data= race_three_level;
tables BMI_CAT Fibroids Chronicpelvpain Endometriosis MENOR_AUB Cervdysplasia OVCYSTPELVMASS prev_laparotomy CDWH_HOSP_ID/ list missing;
*where race_six_level = "Black";
run;

/**Frequncies to identify those with/without outcome***/
proc freq data= race_three_level;
tables OVCYSTPELVMASS*bulk_scoretop25 OVCYSTPELVMASS*bleed_scoretop25 OVCYSTPELVMASS*pain_scoretop25/ norow nocol nopercent missing;
where race_six_level = "White";
run;

/**Frequncies to identify those with/without outcome***/
proc freq data= race_three_level;
tables OVCYSTPELVMASS*bulk_scoretop25 OVCYSTPELVMASS*bleed_scoretop25 OVCYSTPELVMASS*pain_scoretop25/ norow nocol nopercent missing;
where race_six_level = "Black";
run;

/**Frequncies to identify those with/without outcomes***/
proc freq data= race_three_level;
tables OVCYSTPELVMASS*bulk_scoretop25 OVCYSTPELVMASS*bleed_scoretop25 OVCYSTPELVMASS*pain_scoretop25/ norow nocol nopercent missing;
where race_six_level = "Hispanic";
run;

proc freq data= race_three_level;
tables Cervdysplasia*bulk_scoretop25 Cervdysplasia*bleed_scoretop25 Cervdysplasia*pain_scoretop25/ norow nocol nopercent missing;
where race_six_level = "White";
run;

proc freq data= race_three_level;
tables Cervdysplasia*bulk_scoretop25 Cervdysplasia*bleed_scoretop25 Cervdysplasia*pain_scoretop25/ norow nocol nopercent missing;
where race_six_level = "Black";
run;

proc freq data= race_three_level;
tables Cervdysplasia*bulk_scoretop25 Cervdysplasia*bleed_scoretop25 Cervdysplasia*pain_scoretop25/ norow nocol nopercent missing;
where race_six_level = "Hispanic";
run;





/***Modeling****/
/**Restricting race six level to only white, hispanic and black**/

data race_rest;
set checkJM.r01_aim1_6_1_22_jm;
if Race_six_level in ("Hispanic", "White", "Black");

if com_sev_analysis = 1 then dicho_comb_score10 = 0;
else if com_sev_analysis = 0 then dicho_comb_score10 = 1;

if com_sev_analysis = 2 then dicho_comb_score21 = 0;
else if com_sev_analysis = 0 then dicho_comb_score21 = 1;

if count_prior_treat = 0 then prior_tx_cat = 0;
else if count_prior_treat = 1 then prior_tx_cat = 1;
else if count_prior_treat > 1 then prior_tx_cat = 2;

run;
data race_rest_1703;
set race_rest;
if BMI_CAT = "" then delete;
if prev_laparotomy = . then delete;
if w_cci = . then delete;
run;



data race1703_dicho10_1;
set race_rest_1703;

if com_sev_analysis in (1, 0);

if com_sev_analysis = 1 then outcome = 1;
else if com_sev_analysis = 0 then outcome = 0;

run;

data race1703_dicho21_1;
set race_rest_1703;

if com_sev_analysis in (0, 2);

if com_sev_analysis = 0 then outcome = 0;
else if com_sev_analysis = 2 then outcome = 1;

run;



/***Table 2. Combined score regressions****/

title "Table 2a.ii Top 25th of at least one symptom severity score-Fully adjusted model";

proc glimmix data= race1703_dicho10_1 method= laplace ;
class CDWH_HOSP_ID (ref= "Academic Location") SHEPSID Race_six_level (ref="White");
model Outcome(event="1") = Race_six_level 
									r_age_hyst
									CDWH_HOSP_ID
									/cl dist=poisson link=log solution;
random intercept / subject =SHEPSID type=cs solution cl;


estimate 'RR Black vs. White' Race_six_level 1 0 -1/ exp cl;
estimate 'RR Hispanic vs. White' Race_six_level 0 1 -1/ exp cl;

title;

run;

title "Table 2a.ii Top 25th of at least one symptom severity score-Fully adjusted model";
proc glimmix data= race1703_dicho10_1 method= laplace ;
class CDWH_HOSP_ID (ref= "Academic Location") SHEPSID Race_six_level (ref="White") BMI_CAT (ref= ">25.0 to <=30.0") prev_laparotomy (ref= "0") 
Cervdysplasia(ref="0") OVCYSTPELVMASS(ref="0");

model Outcome(event="1") = Race_six_level 
									r_age_hyst
									BMI_CAT 
									w_cci
									prev_laparotomy
									count_prior_treat
									CDWH_HOSP_ID
									Cervdysplasia OVCYSTPELVMASS
									 
									/cl dist=poisson link=log solution;
random intercept / subject =SHEPSID type=cs solution cl;
estimate 'RR Black vs. White' Race_six_level 1 0 -1/ exp cl;
estimate 'RR Hispanic vs. White' Race_six_level 0 1 -1/ exp cl;
title;
run;


title "Table 2b.i Top 25th of 2 or 3 symptom severity scores-Simple model";
proc glimmix data= race1703_dicho21_1 method= laplace ;
class SHEPSID Race_six_level (ref="White") CDWH_HOSP_ID (ref= "Academic Location");
model outcome(event="1") = Race_six_level r_age_hyst CDWH_HOSP_ID /cl dist=poisson link=log solution;
random intercept / subject =SHEPSID type=cs solution cl;

estimate 'RR Black vs. White' Race_six_level 1 0 -1/ exp cl;
estimate 'RR Hispanic vs. White' Race_six_level 0 1 -1/ exp cl;
title;
run;


title "Table 2b.ii Top 25th of 2 or 3 symptom severity scores - Fully adjusted model";
proc glimmix data= race1703_dicho21_1 method= laplace ;
class CDWH_HOSP_ID (ref= "Academic Location") SHEPSID Race_six_level (ref="White") BMI_CAT (ref= ">25.0 to <=30.0") prev_laparotomy (ref= "0") 
Cervdysplasia(ref="0") OVCYSTPELVMASS(ref="0");

model Outcome(event="1") = Race_six_level 
									r_age_hyst
									BMI_CAT 
									w_cci
									prev_laparotomy
									count_prior_treat
									CDWH_HOSP_ID
									Cervdysplasia OVCYSTPELVMASS
									 
									/cl dist=poisson link=log solution;
random intercept / subject =SHEPSID type=cs solution cl;


estimate 'RR Black vs. White' Race_six_level 1 0 -1/ exp cl;
estimate 'RR Hispanic vs. White' Race_six_level 0 1 -1/ exp cl;

title;

run;

/***Table 3. Regressions for each severity score ***/


title "Table 3:Bulk Score - Simple model";
proc glimmix data= race_rest_1703 method= laplace ;
class SHEPSID Race_six_level (ref="White") CDWH_HOSP_ID (ref= "Academic Location");
model bulk_scoretop25 (event="1") = Race_six_level r_age_hyst CDWH_HOSP_ID/cl dist=poisson link=log solution;
random intercept / subject =SHEPSID type=cs solution cl;
estimate 'RR Black vs. White' Race_six_level 1 0 -1/ exp cl;
estimate 'RR Hispanic vs. White' Race_six_level 0 1 -1/ exp cl;
title;
run;

title "Table 3:Bleed Score - Simple model";
proc glimmix data= race_rest_1703 method= laplace ;
class SHEPSID Race_six_level (ref="White") CDWH_HOSP_ID (ref= "Academic Location");
model bleed_scoretop25 (event="1") = Race_six_level r_age_hyst CDWH_HOSP_ID/cl dist=poisson link=log solution;
random intercept / subject =SHEPSID type=cs solution cl;
estimate 'RR Black vs. White' Race_six_level 1 0 -1/ exp cl;
estimate 'RR Hispanic vs. White' Race_six_level 0 1 -1/ exp cl;

title;
run;

title "Table 3:Pain Score - Simple model";
proc glimmix data= race_rest_1703 method= laplace ;
class SHEPSID Race_six_level (ref="White") CDWH_HOSP_ID (ref= "Academic Location");
model pain_scoretop25 (event="1") = Race_six_level r_age_hyst CDWH_HOSP_ID/cl dist=poisson link=log solution;
random intercept / subject =SHEPSID type=cs solution cl;
estimate 'RR Black vs. White' Race_six_level 1 0 -1/ exp cl;
estimate 'RR Hispanic vs. White' Race_six_level 0 1 -1/ exp cl;

title;
run;



title "Table 3:Bulk Score - Fully adjusted model";

proc glimmix data= race_rest_1703 method= laplace;
class CDWH_HOSP_ID (ref= "Academic Location") SHEPSID Race_six_level (ref="White") BMI_CAT (ref= ">25.0 to <=30.0") prev_laparotomy (ref= "0") 
Cervdysplasia(ref="0") OVCYSTPELVMASS(ref="0");

model BULK_scoretop25 (event="1") = Race_six_level 
									r_age_hyst
									BMI_CAT 
									w_cci
									prev_laparotomy
									count_prior_treat
									CDWH_HOSP_ID
									Cervdysplasia OVCYSTPELVMASS
									 
									/cl dist=poisson link=log solution;
random intercept / subject =SHEPSID type=cs solution cl;

estimate 'RR Black vs. White' Race_six_level 1 0 -1/ exp cl;
estimate 'RR Hispanic vs. White' Race_six_level 0 1 -1/ exp cl;

run;
title;



title "Table 3:Bleed Score - Fully adjusted model";

proc glimmix data= race_rest_1703 method= laplace;
class CDWH_HOSP_ID (ref= "Academic Location") SHEPSID Race_six_level (ref="White") BMI_CAT (ref= ">25.0 to <=30.0") prev_laparotomy (ref= "0") 
Cervdysplasia(ref="0") OVCYSTPELVMASS(ref="0");

model bleed_scoretop25 (event="1") = Race_six_level 
									r_age_hyst
									BMI_CAT 
									w_cci
									prev_laparotomy
									count_prior_treat
									CDWH_HOSP_ID
									Cervdysplasia OVCYSTPELVMASS
									 
									/cl dist=poisson link=log solution;
random intercept / subject =SHEPSID type=cs solution cl;

estimate 'RR Black vs. White' Race_six_level 1 0 -1/ exp cl;
estimate 'RR Hispanic vs. White' Race_six_level 0 1 -1/ exp cl;

run;
title;


title "Table 3:Pain Score - Fully adjusted model";

proc glimmix data= race_rest_1703 method= laplace;
class CDWH_HOSP_ID (ref= "Academic Location") SHEPSID Race_six_level (ref="White") BMI_CAT (ref= ">25.0 to <=30.0") prev_laparotomy (ref= "0") 
Cervdysplasia(ref="0") OVCYSTPELVMASS(ref="0");

model pain_scoretop25 (event="1") = Race_six_level 
									r_age_hyst
									BMI_CAT 
									w_cci
									prev_laparotomy
									count_prior_treat
									CDWH_HOSP_ID
									Cervdysplasia OVCYSTPELVMASS
									 
									/cl dist=poisson link=log solution;
random intercept / subject =SHEPSID type=cs solution cl;

estimate 'RR Black vs. White' Race_six_level 1 0 -1/ exp cl;
estimate 'RR Hispanic vs. White' Race_six_level 0 1 -1/ exp cl;

run;
title;
