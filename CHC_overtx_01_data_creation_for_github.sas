**********************************************************************************************************************/
/* Purpose: This code show shows CHC Aim 1 (refer to https://github.com/Carolina-Hysterectomy-Cohort/Welcome-to-CHC) */
/*          data set being updated and prepared for analysis. Data prepartion includes use of variables that  	     */
/*          capture confidential data.  Though variable names of protected information is present in code,           */
/*           any identfying information has been redacted and replaced with deindentified values where applicable.   */
/*********************************************************************************************************************/


/*****CHC Aim 1 dataset creation******/


/***CHC AIM 1 DATA ELEMENTS***/
/*** 
1. CLINICAL SEVERITY MARKERS (PAIN, BLEEDING AND BULK SCORE) -  CODE FROM SEVERITY PAPER
2. CO-MORBIDITIES (SEVERITY INDICES)
3. CLINICAL INDICATION 
4. PROVIDER DATA
5. PAT_MRN_ID, RACE_ETH, AGE, BMI, CENSUS DATA, FERTILITY, SURGICAL HISTORY, PREGNANCY HISTORY ***/


Libname  /* statements for the location of your data */ ;

data check;
set libname.hyst_master_JM; /*Creation of this data set can be found in CHC_master_01_dataset_creation_for_github.sas*/;
run;

/******
1. CLINICAL SEVERITY SCORES
	****/
proc format;
value ed 0="No ED visits"
		 1="1 ED visit"
		 2=">1 ED visit";
value hct 0="HCT of At Least 30"
		  1="HCT < 30";
value hbg 0="HGB of At Least 10"
		  1="HGB < 10"; 
run;

data aim1_bleed_a;
set check;
if aim1_2_sample =1;

/*	C_ed_visits_menorrhagia_prior*/
	IF C_ed_visits_menorrhagia_prior=0 THEN ED_menorrhagia=0;
		ELSE IF C_ed_visits_menorrhagia_prior=1 THEN ED_menorrhagia=1;
		ELSE IF C_ed_visits_menorrhagia_prior>1 THEN ED_menorrhagia=2;

	/*	C_ed_visits_anemia_prior*/
	IF C_ed_visits_anemia_prior=0 THEN ED_ANEMIA=0;
		ELSE IF C_ed_visits_anemia_prior=1 THEN ED_ANEMIA=1;
		ELSE IF C_ed_visits_anemia_prior>1 THEN ED_ANEMIA=2;


format ED_ANEMIA ED_menorrhagia ed.;
format C_HGB_result_KD_low hbg.;
format C_HCT_result_KD_low hct.;

run;


data aim1_bleed_b;
set aim1_bleed_a;
/*1 POINT SCALES*/
/*DX: VB at surgery*/
	/*  C_DX_MENORRHAGIA*/
/*SYMP: Heavy Bleeding*/
	/*	R_GYNSYMP_NOTE_HEAVYBLEED*/
/*SYMP: Irregular Bleeding */
	/*	R_GYNSYMP_NOTE_IRREGBLEED*/
/*MD: Heavy Bleeding as indication*/
	/*  R_OPNOTE_DX_MENORRHAGIA*/
/**/
/*2 POINT SCALES*/
/*DX: VB prior to surgery*/
	/*	C_DX_MENORRHAGIA_PRIOR*/
/*SYMP: Period > 7 days*/
	/*	R_GYNSYMP_NOTE_PERIODDURATION7*/
/*SYMP: LH/Dizziness*/
	/*	R_GYNSYMP_NOTE_DIZZYFATIGUE*/
/**/
/*3 POINT SCALES*/
/*MD: Iron Use*/
	/*	R_MEDUSE_RX_IRON*/
/*DX: ED Visit – Bleeding 1 */
if ED_menorrhagia=1 then ED_BLEEDING_1=1;
	else if ED_menorrhagia IN(0,2) then ED_BLEEDING_1=0;
/*DX: Anemia at surgery*/
	/*	C_DX_ANEMIA*/
/**/
/*4 POINT SCALES*/
/*LAB: Anemia Hgb*/
/*	C_HGB_result_KD_low*/
/*LAB: Anemia Hct*/
	/*	C_HCT_result_KD_low*/
/*MD: Anemia as indication*/
	/*	R_OPNOTE_DX_ANEMIA*/
/*DX: ED Visit – Bleeding 1+ */
if ED_menorrhagia=2 then ED_BLEEDING_2=1;
	else if ED_menorrhagia IN(0,1) then ED_BLEEDING_2=0;
/*DX: ED Visit – Anemia 1 */
if ED_ANEMIA=1 then ED_ANEMIA_1=1;
	else if ED_ANEMIA IN(0,2) then ED_ANEMIA_1=0;
/*DX: Anemia prior to surgery */
	/*	C_DX_ANEMIA_PRIOR*/
/**/
/*5 POINT SCALES*/
/*MD: Blood Tx*/
/*DX: ED Visit –Anemia 1+ */
if ED_ANEMIA=2 then ED_ANEMIA_2=1;
	else if ED_ANEMIA IN(0,1) then ED_ANEMIA_2=0;
/**/
	

bleed_score		=sum(C_DX_MENORRHAGIA,R_GYNSYMP_NOTE_HEAVYBLEED,R_GYNDX_NOTE_ABNORMALBLEEDING,R_OPNOTE_DX_MENORRHAGIA,
					 2*R_PLAN_AUB,2*C_DX_MENORRHAGIA_PRIOR,2*R_GYNSYMP_NOTE_PERIODDURATION7,2*R_GYNSYMP_NOTE_DIZZYFATIGUE,
					 3*R_MEDUSE_RX_IRON,3*ED_BLEEDING_1,3*C_DX_ANEMIA,
					 4*C_HGB_result_KD_low,4*R_OPNOTE_DX_ANEMIA,4*ED_BLEEDING_2,4*ED_ANEMIA_1,4*C_DX_ANEMIA_PRIOR,
					 5*ED_ANEMIA_2,5*R_MEDHX_HX_BLOODTRANS);
bleed_score_nl  =sum(C_DX_MENORRHAGIA,R_GYNSYMP_NOTE_HEAVYBLEED,R_GYNDX_NOTE_ABNORMALBLEEDING,R_OPNOTE_DX_MENORRHAGIA,
					 2*R_PLAN_AUB,2*C_DX_MENORRHAGIA_PRIOR,2*R_GYNSYMP_NOTE_PERIODDURATION7,2*R_GYNSYMP_NOTE_DIZZYFATIGUE,
					 3*R_MEDUSE_RX_IRON,3*ED_BLEEDING_1,3*C_DX_ANEMIA,
					 4*R_OPNOTE_DX_ANEMIA,4*ED_BLEEDING_2,4*ED_ANEMIA_1,4*C_DX_ANEMIA_PRIOR,
					 5*ED_ANEMIA_2,5*MED_HX_BLOODTRANS);


if bleed_score > 0 and bleed_score <= 2 then bleed_score_qrt = ">0 and <= 2";
else if bleed_score > 2 and bleed_score <= 5 then bleed_score_qrt = ">2 and <= 5";
else if bleed_score > 5 and bleed_score <= 10 then bleed_score_qrt = ">5 and <=10";
else if bleed_score = 0 then bleed_score_qrt = "0";
else if bleed_score > 10 then bleed_score_qrt = "> 10";

run;

proc freq data = aim1_bleed_b;
tables bleed_score bleed_score_nl bleed_score_qrt/ list missing;
run;

proc means data= aim1_bleed_b n mean stddev min q1 median q3 max;
var bleed_score bleed_score_nl;
run;

data bleed_score;
set aim1_bleed_b;
keep PAT_MRN_ID bleed_score;
run;



/*defining above or below 75th percentile*/

data aim1_bulk_a;
set check;
if aim1_2_sample=1;
merge=1;
run;


/**************************************************/


proc univariate data=aim1_bulk_a noprint;
   var R_OPNT_PATH_UTWEIGHT;
   output out=percentiles pctlpts=50 75 pctlpre=P;
run;
data pct;
set percentiles;
merge=1;
run;

/**only 1903 have utweight recorded***/
data aim1_bulk_b;
merge aim1_bulk_a pct;
by merge;
if R_OPNT_PATH_UTWEIGHT>P75 then high_utweight=1;
	else if R_OPNT_PATH_UTWEIGHT>.z then high_utweight=0;
label high_utweight="Uterine Weight At or Above 75th Percentile";
if R_OPNT_PATH_UTWEIGHT>P75 then high_utweight_c3=3;
	else if R_OPNT_PATH_UTWEIGHT>P50 then high_utweight_c3=2;
	else if R_OPNT_PATH_UTWEIGHT>.z then high_utweight_c3=1;
label high_utweight_c3="Uterine Weight Category (1=<50th Percentile, 2=50-75th Percentile, 3=At or Above 75th Percentile";
/*removing those with missing uterine weight*/
if R_OPNT_PATH_UTWEIGHT<.z then delete;
run;



proc format;
value weight 1="< 50th Percentile of Uterine Weight"
			 2="50-75th Percentile of Uterine Weight"
			 3=">=75th Percentile of Uterine Weight";
run;

/*%LET var = C_DX_BULK;*/
/*%LET label = Diagnosis Bulk;*/

%macro u_weight(var,label);
proc sort data=aim1_bulk_b; by &var.; run;
proc freq data=aim1_bulk_b noprint;
by &var.;                    				 /* X categories on BY statement */
tables high_utweight_c3 / out=FreqOut;    /* Y (stacked groups) on TABLES statement */
run;
title "% by Uterine Weight Group by &label.";
proc sgplot data=FreqOut;
vbar &var. / response=Percent group=high_utweight_c3 groupdisplay=stack;
xaxis discreteorder=data;
yaxis grid values=(0 to 100 by 10) label="%";
label &var.="&label.";
format high_utweight_c3 weight.;
keylegend / title="Uterine Weight Category";
run;
%mend u_weight;

%u_weight(C_DX_BULK,						DX: code at surgery);
%u_weight(R_GYNSYMP_NOTE_BLOAT,				SYMP: Bloating);
%u_weight(R_GYNSYMP_NOTE_PELVPRESSURE,		SYMP: Pelvic pressure);
%u_weight(C_DX_BULK_PRIOR,					DX: code prior to surgery);
%u_weight(R_GYNDX_NOTE_BULK,				SYMP: Bulk NOS);
%u_weight(R_OPNOTE_DX_BULK,					MD: Bulk as surgery indication);

data aim1_bulk_c (keep = C_Pr_PAT_ID
				PAT_MRN_ID
				C_DX_BULK					
				R_GYNSYMP_NOTE_BLOAT	
				R_GYNSYMP_NOTE_PELVPRESSURE
				C_DX_BULK_PRIOR			
				R_GYNDX_NOTE_BULK		
				R_OPNOTE_DX_BULK
				R_OPNT_PATH_UTWEIGHT
				high_utweight
				high_utweight_c3
				bulk_score
				bulk_score_v2
				bulk_score_nw
				diff
				Bulk_score_v2_qrt);
set aim1_bulk_b;
/*Creating score*/

/*1 POINT SCALES*/
/*SYMP: Bloating*/
if R_GYNSYMP_NOTE_BLOAT=1 then GYNSYMP_NOTE_BLOAT=1;
	else if R_GYNSYMP_NOTE_BLOAT=0 then GYNSYMP_NOTE_BLOAT=0;
/*SYMP: Pelvic pressure*/
if R_GYNSYMP_NOTE_PELVPRESSURE=1 then GYNSYMP_NOTE_PELVPRESSURE=1;
	else if R_GYNSYMP_NOTE_PELVPRESSURE=0 then GYNSYMP_NOTE_PELVPRESSURE=0;

/*2 POINT SCALES*/
/*DX: code at surgery*/
/*Creating indicator*/
if high_utweight_c3=2 then pct_50_75=1;	
	else if high_utweight_c3 IN(1,3) then pct_50_75=0;

/*3 POINT SCALES*/
/*SYMP: Bulk NOS*/
/*MD: Bulk indication*/
/*DX: prior to surgery*/

/*4 POINT SCALES*/
/*Uterine size > 75% */
bulk_score		=sum(GYNSYMP_NOTE_BLOAT,R_GYNSYMP_NOTE_PELVPRESSURE,
			  	 2*C_DX_BULK,
			  	 3*C_DX_BULK_PRIOR,3*R_GYNDX_NOTE_BULK,3*R_OPNOTE_DX_BULK,
			  	 4*high_utweight);
/*Giving people with 50-75th percentiel of uterine weight 2 extra points*/
bulk_score_v2	=sum(GYNSYMP_NOTE_BLOAT,R_GYNSYMP_NOTE_PELVPRESSURE,pct_50_75,
			  	 2*C_DX_BULK,
			  	 3*C_DX_BULK_PRIOR,3*R_GYNDX_NOTE_BULK,3*R_OPNOTE_DX_BULK,
			  	 4*high_utweight);
/*Removing uterine weight to explore distribution*/
bulk_score_nw	=sum(GYNSYMP_NOTE_BLOAT,R_GYNSYMP_NOTE_PELVPRESSURE,
			  	 2*C_DX_BULK,
			  	 3*C_DX_BULK_PRIOR,3*R_GYNDX_NOTE_BULK,3*R_OPNOTE_DX_BULK);
/*Looking at differences*/
diff = bulk_score-bulk_score_nw;

if Bulk_score_v2 > 4 and Bulk_score_v2 <= 14 then Bulk_score_v2_qrt = ">4 to <=14";
else if Bulk_score_v2 > 1 and Bulk_score_v2 <=4 then Bulk_score_v2_qrt = ">1 to <=4";
else if Bulk_score_v2 >0 and Bulk_score_v2 <= 1 then Bulk_score_v2_qrt = ">0 to <=1";
else if Bulk_score_v2 = 0 then Bulk_score_v2_qrt = "0";

run;
title;

proc freq data = aim1_bulk_c;
tables /*bulk_score Bulk_score_v2*/ Bulk_score_v2_qrt/ list missing;
run;

proc means data= aim1_bulk_c n mean stddev min q1 median q3 max;
var bulk_score bulk_score_v2 bulk_score_nw diff;
run;

data bulk_score;
set aim1_bulk_c;
keep PAT_MRN_ID Bulk_score_v2;
run;



data aim1_pain_a;
set check;
if aim1_2_sample=1;
merge=1;
run;

data aim1_pain_b;
set  aim1_pain_a;
/*proc freq data=in.severity_v1b;*/
/*tables*/
/*SYMP – Pelvic Pain*/
	/*	R_GYNSYMP_NOTE_PELVPAIN*/
/*SYMP – Painful periods*/
	/*	R_GYNSYMP_NOTE_PERIODPAIN*/
/*MEDS - Opoid*/
	/*	THESE NUMBERS ARE DIFFERENT THAN SHARONS*/
	/*  Updated 02.13.2020 based on questions for Sharon*/
	/*	c_med_opiod_prior*/
/*MEDS - NSAID*/
	/*	THESE NUMBERS ARE DIFFERENT THAN SHARONS*/
	/* Updated 02.13.2020 based on questions for Sharon*/
	/*	c_med_nsaid_prior*/
/*MD -  Pain as indication for surgery*/
/*		R_PLAN_CHRONICPELVPAIN*/
/*DX – Pain prior to surgery*/
	/*	C_DX_PAIN_PRIOR*/
/*DX – Pain at surgery*/
	/*	C_DX_PAIN*/
/*MD – Painful periods as indication*/
	/*updated 02.13.2020*/
	/*  R_OPNOTE_DX_DYSMENORRHEA */
/*MEDS – Tylenol */
	/*  C_Med_acetaminophen_prior*/
/*SYMP – Painful Intercourse*/
	/*  R_GYNSYMP_NOTE_INTERCOURSEPAIN*/
/*DX – ER visit*/
	/*C_ed_visits_pain_prior*/
	IF C_ed_visits_pain_prior=0 THEN ED_pain_c3=0;
		ELSE IF C_ed_visits_pain_prior=1 THEN ED_pain_c3=1;
		ELSE IF C_ed_visits_pain_prior>1 THEN ED_pain_c3=2;
	IF C_ed_visits_pain_prior=0 THEN ED_pain_c2=0;
		ELSE IF C_ed_visits_pain_prior>=1 THEN ED_pain_c2=1;
/*SYMP – Missing work*/
	/* R_GYNSYMP_NOTE_MISSDAYS*/
/*MEDS – Muscle Relaxant*/
	/* C_Med_MUSCLE_RELAXANTS*/
/*MEDS - Other*/
	/* C_Med_other_prior*/
/*MD – Painful intercourse as indication */
	/**/
	/* PREOPDX_DSYPAREUNIA 
	/**/
/*MD – Other pain as indication*/
	/* R_OPNOTE_DX_PAINOTHER*/

pain_score=sum(R_GYNSYMP_NOTE_PELVPAIN,R_GYNSYMP_NOTE_PERIODPAIN,R_GYNSYMP_NOTE_INTERCOURSEPAIN,C_Med_acetaminophen_prior,
				2*c_med_nsaid_prior,2*R_PLAN_CHRONICPELVPAIN,2*R_OPNOTE_DX_DYSMENORRHEA,
				3*C_DX_PAIN_PRIOR,3*C_DX_PAIN,3*C_Med_other_prior,
				4*c_med_opiod_prior,4*ED_pain_c2,4*C_Med_MUSCLE_RELAXANTS);
pain_score_no_opoid=sum(R_GYNSYMP_NOTE_PELVPAIN,R_GYNSYMP_NOTE_PERIODPAIN,R_GYNSYMP_NOTE_INTERCOURSEPAIN,C_Med_acetaminophen_prior,
				2*c_med_nsaid_prior,2*R_PLAN_CHRONICPELVPAIN,2*R_OPNOTE_DX_DYSMENORRHEA,
				3*C_DX_PAIN_PRIOR,3*C_DX_PAIN,3*C_Med_other_prior,
				4*ED_pain_c2,4*C_Med_MUSCLE_RELAXANTS);

if pain_score >8 and pain_score <= 26 then pain_score_qrt = "> 8 and <= 26";
else if pain_score > 4 and pain_score <=8 then pain_score_qrt = "> 4 and <= 8";
else if pain_score >1 and pain_score <= 4 then pain_score_qrt = ">1 and <=4";
else if pain_score >0 and pain_score <= 1 then pain_score_qrt = " >0 and <= 1";
else if pain_score = 0 then pain_score_qrt = "0";
;
run;

proc freq data = aim1_pain_b;
tables pain_score pain_score_qrt pain_score_no_opoid/ list missing;
run;

proc means data= aim1_pain_b n mean stddev min q1 median q3 max;
var pain_score pain_score_no_opoid;
run;

data pain_score;
set aim1_pain_b;
keep PAT_MRN_ID pain_score;
run;


/***1. CLINICAL SEVERITY SCORES***/

proc sort data=bleed_score;
by PAT_MRN_ID;

proc sort data=bulk_score;
by PAT_MRN_ID;


proc sort data=pain_score;
by PAT_MRN_ID;
run;

data libname.clin_sev_scores;
merge bleed_score (in=a) bulk_score (in=b) pain_score (in=c);
by PAT_MRN_ID;
run;


/***4. PROVIDER DATA ***/

libname provBDOR /*"Location where data is saved"*/;

data PROVBDOR.r01_aim1_prov_NPI; /**Keeping only the PAT_MRN_ID and the Lead Provider info**/
set PROVBDOR.r01_aim1_prov;
keep PAT_MRN_ID Lead_Provider ORLOG_LOCATION_NM c_hospital ;

/**Adding NPIs for those patients with missing provider info as adjudicated by Dr. EC on 5/3/21. ref: For_EC_Adjudication_provider_data n = 1882**/

*the section below have been replaced with deidentifided values ;

if AIM_1_2_PATID = 12015663 then lead_provider = 77737092;
if AIM_1_2_PATID = 12016229 then lead_provider = 77716983;
if AIM_1_2_PATID = 12014460 then lead_provider = 77737092;
if AIM_1_2_PATID = 12016278 then lead_provider = 77722485;
if AIM_1_2_PATID = 12014981 then lead_provider = 77737092;
if AIM_1_2_PATID = 12015750 then lead_provider = 77737092;
if AIM_1_2_PATID = 12016028 then lead_provider = 77754711;
if AIM_1_2_PATID = 12014006 then lead_provider = 77737092;
if AIM_1_2_PATID = 12015896 then lead_provider = 77737092;
if AIM_1_2_PATID = 12015113 then lead_provider = 77724230;
if AIM_1_2_PATID = 12015161 then lead_provider = 77737092;
if AIM_1_2_PATID = 12015163 then lead_provider = 77737092;
if AIM_1_2_PATID = 12016531 then lead_provider = 77736141;
if AIM_1_2_PATID = 12014311 then lead_provider = 77726109;


run; 


/***3. CLINICAL INDICATION (R_PLAN: FROM CHC HYST MASTER JGM) and
    5. PAT_MRN_ID, RACE_ETH, AGE, BMI, CENSUS DATA, (FERTILITY- Pending), PREGNANCY HX, SURGICAL HX (FROM CHC HYST MASTER JGM DATASET)***/

data Master;
set libname.Hyst_Master_JM;
if aim1_2_sample = 1;
keep PAT_MRN_ID 
    race_six_level 
	R_AGE_HYST 
	c_bmi_calc_estimate c_prior_height c_prior_weight
	county_urban 
	median_HHIncome 
	percent_collegedegree 
	percent_belowpoverty
	R_PLAN:
	R_SURGHX:
	R_PREGHX:
	R_SOCHX_FERTILITY
	R_GYNDX_NOTE:
	C_DX_:
	R_PRETX:
	insurance_modified
;
run;
	
/**Combining 1, 3,4, and 5**/

data libname.r01_Aim1_4_22_21;
merge Master libname.clin_sev_scores PROVBDOR.CHC_aim1_prov_NPI ;
by PAT_MRN_ID;

/**Condensing further to compare**/
if race_six_level = "Black" then race_condensed = "Black";
else if race_six_level = "White" then race_condensed = "White";
else race_condensed = "Other";

/**Pulling out some extreme values**/
if c_bmi_calc_estimate > 100 then BMI_WOOUTLI = .;
else BMI_WOOUTLI =c_bmi_calc_estimate;

/***Adding location information**/
if ORLOG_LOCATION_NM = "" then HOSP_LOCATION = c_hospital;
else HOSP_LOCATION = ORLOG_LOCATION_NM;

*values redacted;
if HOSP_LOCATION in ("XXXXXXX", "XXXXXXX", "XXXXXXX", "XXXXXXX", "XXXXXXX", "XXXXXXX", "XXXXXXX") then COMB_HOSP_ID = 0;
else if HOSP_LOCATION in ("XXXXXXX", "XXXXXXX", "XXXXXXX", "XXXXXXX", "XXXXXXX", "XXXXXXX", "XXXXXXX") then COMB_HOSP_ID = 1;

if ORLOG_LOCATION_NM in ("XXXXXXX", "XXXXXXX", "XXXXXXX", "XXXXXXX", "XXXXXXX", "XXXXXXX", "XXXXXXX") then OR_HOSP_ID = 0;
else if ORLOG_LOCATION_NM in ("XXXXXXX", "XXXXXXX", "XXXXXXX", "XXXXXXX", "XXXXXXX", "XXXXXXX", "XXXXXXX") then OR_HOSP_ID = 1;


label Lead_provider = ''; /**Had to remove previous permanent label of "Billing provider." SAS wouldn't accept direct label removal for some reason**/
label Lead_provider = 'LEAD PROVIDER'; /**Adding the new permanent label**/
drop R_plan_preg_excl R_plan_cancer_excl R_plan_bleed_excl R_PLAN_EXCL; /**Dropping off variables related to R_PLAN exclusion variables**/
run;

proc contents data=libname.r01_Aim1_4_22_21; *dataset derived from master dataset;
run;

/**Calculating the symptom severity score precentiles**/
 proc rank data=libname.r01_Aim1_4_22_21 groups=100 out=ranked_bulk;
 var Bulk_score_v2;
 ranks rank_Bulk_score_v2;
 run;

 proc rank data=ranked_bulk groups=100 out=ranked_pain;
 var pain_score;
 ranks rank_pain_score;
 run;

 proc rank data=ranked_pain groups=100 out=ranked_bleed;
 var bleed_score;
 ranks rank_bleed_score;
 run;

 data percentile_scores;
 set  ranked_bleed;
 keep PAT_MRN_ID rank_Bulk_score_v2 rank_pain_score rank_bleed_score;
run;




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


data libname.r01_Aim1_5_5_21;
merge libname.r01_Aim1_4_22_21 percentile_scores;
by PAT_MRN_ID;

if rank_Bulk_score_v2 > 75 then bulk_scoretop25 = 1;
else if rank_Bulk_score_v2 <= 75 then bulk_scoretop25 = 0;

if rank_pain_score > 75 then pain_scoretop25 = 1;
else if rank_pain_score <= 75 then pain_scoretop25 = 0;

if rank_bleed_score > 75 then bleed_scoretop25 = 1;
else if rank_bleed_score <= 75 then bleed_scoretop25 = 0;

/**we decided that it is best to use CDWH hosp location and not OR log location.**/

*variable name and values have been changed to deidentified values;
if FACILITY_ID in (99987261, 99987258) then CDWH_HOSP_ID = 1;
else if FACILITY_ID in (99987260, 99987256,99987253,99987263,99987264,99987252) then CDWH_HOSP_ID = 0; *FACILITY_ID is in data file made for secure research workspace.;

/***Creating combined severity scores*****/
if bulk_scoretop25 =1 and pain_scoretop25=1 and bleed_scoretop25 = 1 then combined_sev_score = 3;

else if bulk_scoretop25 =1 and pain_scoretop25=1 and bleed_scoretop25 = 0 then combined_sev_score = 2;
else if bulk_scoretop25 =1 and pain_scoretop25=0 and bleed_scoretop25 = 1 then combined_sev_score = 2;
else if bulk_scoretop25 =0 and pain_scoretop25=1 and bleed_scoretop25 = 1 then combined_sev_score = 2;

else if bulk_scoretop25 =1 and pain_scoretop25=0 and bleed_scoretop25 = 0 then combined_sev_score = 1;
else if bulk_scoretop25 =0 and pain_scoretop25=1 and bleed_scoretop25 = 0 then combined_sev_score = 1;
else if bulk_scoretop25 =0 and pain_scoretop25=0 and bleed_scoretop25 = 1 then combined_sev_score = 1;

else if bulk_scoretop25 =0 and pain_scoretop25=0 and bleed_scoretop25 = 0 then combined_sev_score = 0;

/***Combining combined sev score 3 and 2 for analysis***/

if combined_sev_score = 3 or combined_sev_score = 2 then com_sev_analysis = 2;
else com_sev_analysis = combined_sev_score;


format CDWH_HOSP_ID  COMB_HOSP_ID OR_HOSP_ID hosp.;
format combined_sev_score sev.;
format com_sev_analysis sevscore.;


run;

/***To check the number of providers in each care center***/
proc sql;
select c_hospital, count (distinct Lead_provider)
from libname.r01_Aim1_5_17_21
group by c_hospital;
quit;
run;

/**Adding the charlson's comorbidity index (summary score and weighted scores only) 
SAS code file name: r01_aim1_02_CCI_for_github.sas**/

data cci_scores_red;
set libname.cci_scores;
keep PAT_MRN_ID CCI W_CCI;
run;


/***This is the final dataset that we will be using for CHC Aim 1***/


data libname.r01_Aim1_5_17_21;   *Secure research workspace data file name = r01_Aim1_6_1_22_jm;
merge libname.r01_Aim1_5_5_21 (in=a) cci_scores_red (in=b);
by PAT_MRN_ID;
if a;

if R_SURGHX_LAPAROSCOPYGYN = 1 or R_SURGHX_LAPAROTOMYABDOM = 1 then prev_laparotomy = 1;
else if R_SURGHX_LAPAROSCOPYGYN = 0 and R_SURGHX_LAPAROTOMYABDOM = 0 then prev_laparotomy = 0;
else prev_laparotomy = .;

/**it was decided to use a combination of GYNDX NOTE and R_PLAN variables to account for clinical conditions. Ref: Kemi meeting notes****/
if R_GYNDX_NOTE_FIBROIDS = 1 or R_PLAN_FIBROIDS = 1 then Fibroids = 1;
else if R_GYNDX_NOTE_FIBROIDS = 0 and R_PLAN_FIBROIDS = 0 then Fibroids = 0;

if R_GYNDX_NOTE_CHRONPELVPAIN = 1 or R_PLAN_CHRONICPELVPAIN = 1 then Chronicpelvpain = 1;
else if R_GYNDX_NOTE_CHRONPELVPAIN = 0 and R_PLAN_CHRONICPELVPAIN = 0 then Chronicpelvpain = 0;

if R_GYNDX_NOTE_ENDOMETRIOSIS = 1 or R_PLAN_ENDOMETRIOSIS = 1 then Endometriosis = 1;
else if R_GYNDX_NOTE_ENDOMETRIOSIS = 0 and R_PLAN_ENDOMETRIOSIS = 0 then Endometriosis = 0;

if r_plan_menorrhagia = 1 or R_GYNDX_NOTE_MENORRHAGIA = 1 or r_plan_aub = 1 or R_GYNDX_NOTE_ABNORMALBLEEDING = 1 then MENOR_AUB = 1;
else if r_plan_menorrhagia = 0 and R_GYNDX_NOTE_MENORRHAGIA = 0 and r_plan_aub = 0 and R_GYNDX_NOTE_ABNORMALBLEEDING = 0 then MENOR_AUB = 0;

if R_GYNDX_NOTE_CERVDYSPLASIA = 1 or R_PLAN_DYSPLASIA = 1 then Cervdysplasia = 1;
else if R_GYNDX_NOTE_CERVDYSPLASIA = 0 and R_PLAN_DYSPLASIA = 0 then Cervdysplasia = 0;

if R_GYNDX_NOTE_OVCYSTPELVMASS = 1 or R_PLAN_OVCYSTPELVMASS = 1 then OVCYSTPELVMASS = 1;
else if R_GYNDX_NOTE_OVCYSTPELVMASS = 0 and R_PLAN_OVCYSTPELVMASS = 0 then OVCYSTPELVMASS = 0;  

/*****
[...] do these 5 BMI categories: <25.0, 25.0-<30.0 (rounding), 30-<35, 35-<40, 40.0-top value. 
*/

if c_bmi_calc_estimate >25 and c_bmi_calc_estimate <= 30 then BMI_CAT = ">25.0 to <=30.0";
else if c_bmi_calc_estimate >30 and c_bmi_calc_estimate <= 35 then BMI_CAT = ">30.0 to <=35.0";
else if c_bmi_calc_estimate >35 and c_bmi_calc_estimate <= 40 then BMI_CAT = ">35.0 to <=40.0";
else if c_bmi_calc_estimate >40 then BMI_CAT = ">40.0";
else if c_bmi_calc_estimate ne . and c_bmi_calc_estimate <= 25 then BMI_CAT = "<= 25.0";

/***Ref: Prior Treatments list for adjudication ***/
if R_PRETX_HORMONALCONTRACEPT = 1 then HORMONALCONTRACEPT = 1; else HORMONALCONTRACEPT = 0;
if R_PRETX_PROGESTIN = 1 then PROGESTIN = 1; else PROGESTIN = 0;
if R_PRETX_DEPOPROVERA = 1 then DEPOPROVERA = 1; else DEPOPROVERA = 0;
if R_PRETX_IMPLANT = 1 then IMPLANT = 1; else IMPLANT = 0;
if R_PRETX_LYSTEDA = 1 then LYSTEDA = 1; else LYSTEDA = 0;
if R_PRETX_GNRH = 1 then GNRH = 1; else GNRH = 0;
if R_PRETX_IUD_HORMONAL = 1 then IUD_HORMONAL = 1; else IUD_HORMONAL = 0;
if R_SURGHX_UAE = 1 then UAE = 1; else UAE = 0;
if R_SURGHX_UTERINEABLATION = 1 then UTERINEABLATION = 1; else UTERINEABLATION = 0;
if R_SURGHX_MYOMECTOMY = 1 then MYOMECTOMY = 1; else MYOMECTOMY = 0;
if R_SURGHX_HYSTEROSCOPY = 1 then HYSTEROSCOPY = 1; else HYSTEROSCOPY = 0;
if R_SURGHX_LAPAROSCOPYGYN = 1 then LAPAROSCOPYGYN = 1; else LAPAROSCOPYGYN = 0;
if R_SURGHX_LAPAROTOMYGYN = 1 then LAPAROTOMYGYN = 1; else LAPAROTOMYGYN = 0;

count_prior_treat = sum (HORMONALCONTRACEPT, PROGESTIN, DEPOPROVERA, IMPLANT, LYSTEDA, GNRH, IUD_HORMONAL, UAE, UTERINEABLATION, 
MYOMECTOMY, HYSTEROSCOPY, LAPAROSCOPYGYN, LAPAROTOMYGYN);

run;

proc contents data=libname.r01_Aim1_5_17_21;
run;



 /* Libname statements for the location of your data */ 

/* Using format statement*/

proc contents data=libname.hosp_diag varnum;
run;


/*****Comorbidity measure creation *****/


/**Hospital diagnois table has final diagnoses and admission diagnoses. From reading up a bit more, final diagnoses was picked up**/
/**Also checking if any patients have both ICD-9 and ICD-10 coding.**/


data libname.hosp_diag_icd9;
set libname.hosp_diag;
 if ADMIT_OR_FINAL_DX = "HOSPITAL_FINAL";
 if CODE_TYPE = "ICD-9-CM";
 drop STUDY_ID;
 PAT_MRN_ID_9 = PAT_MRN_ID;
run;

data libname.hosp_diag_icd10;
set libname.hosp_diag;
 if ADMIT_OR_FINAL_DX = "HOSPITAL_FINAL";
 if CODE_TYPE = "ICD-10-CM";
 drop STUDY_ID;
 PAT_MRN_ID_10 = PAT_MRN_ID;
run;

data ICD_9;
set libname.hosp_diag_icd9;
rename   PAT_ID = PAT_ID_9
		 SURGERY_DATE = SURGERY_DATE_9
		 HSP_ACCOUNT_ID = HSP_ACCOUNT_ID_9
		 PAT_ENC_CSN_ID = PAT_ENC_CSN_ID_9
		 ADMIT_OR_FINAL_DX = ADMIT_OR_FINAL_DX_9
		 DIAGNOSIS_PRIORITY = DIAGNOSIS_PRIORITY_9
		 DIAGNOSIS_CODE = DIAGNOSIS_CODE_9
		 CODE_TYPE = CODE_TYPE_9
		 DIAGNOSIS_DESCRIPTION = DIAGNOSIS_DESCRIPTION_9
		 STUDY_DEFINED_CATEGORY = STUDY_DEFINED_CATEGORY_9;
run;

proc freq data=ICD_9;
tables DIAGNOSIS_CODE_9;
run;

/**N=736**/
proc sql;
select count(distinct DIAGNOSIS_CODE_9)as total_dg_9
from ICD_9;
quit;

data ICD_10;
set libname.hosp_diag_icd10;
rename   PAT_ID = PAT_ID_10
		 SURGERY_DATE = SURGERY_DATE_10
		 HSP_ACCOUNT_ID = HSP_ACCOUNT_ID_10
		 PAT_ENC_CSN_ID = PAT_ENC_CSN_ID_10
		 ADMIT_OR_FINAL_DX = ADMIT_OR_FINAL_DX_10
		 DIAGNOSIS_PRIORITY = DIAGNOSIS_PRIORITY_10
		 DIAGNOSIS_CODE = DIAGNOSIS_CODE_10
		 CODE_TYPE = CODE_TYPE_10
		 DIAGNOSIS_DESCRIPTION = DIAGNOSIS_DESCRIPTION_10
		 STUDY_DEFINED_CATEGORY = STUDY_DEFINED_CATEGORY_10;
run;


/**N=1181**/
 
proc sql;
select count(distinct DIAGNOSIS_CODE_10)as total_dg_10
from ICD_10;
quit;

proc sort data=ICD_9;
by PAT_MRN_ID;
proc sort data=ICD_10;
by PAT_MRN_ID;
run;

*****************CHARLSON'S COMORBIDITY INDEX*****************************;
******http://mchp-appserv.cpe.umanitoba.ca/concept/Charlson%20Comorbidities%20-%20Coding%20Algorithms%20for%20ICD-9-CM%20and%20ICD-10.pdf***;
data check_ICD_9;
set icd_9 ;

/**pickup variable represents the first three digits of the ICD-9 code. While defining the CCI, some codes to look at would be those that begin with 428 (428.x). Instead of defining every single possibility of 428 such as 428.4, 428.57, we could just usse the pick up***/
pickup = substr(DIAGNOSIS_CODE_9, 1,3);

/**Myocardial infarction***/
if pickup in ("410", "412") then MI_9  = 1; else MI_9=0;

/***Congestive Heart Failure***/
if DIAGNOSIS_CODE_9 in ("398.91", "402.01", "402.11", "402.91", "404.01", "404.3", "404.11", "404.13", "404.91", "404.93", 
"425.4", "425.5", "425.6", "425.7", "425.8", "425.9") then  CHF_9 = 1; 
if pickup = "428" then CHF_9 = 1;
else CHF_9 = 0;

/**Peripheral vascular disease**/
if DIAGNOSIS_CODE_9 in ("093.0", "437.3", "443.1", "443.2", "443.3", "443.4", "443.5", "443.6", "443.7", "443.8", 
"443.9", "447.1", "557.1", "557.9", "V43.4") then  PVD_9 = 1; 
if pickup in ("440", "441") then PVD_9  = 1; 
else PVD_9=0;

/**Cerebrovascular disease ***/
if DIAGNOSIS_CODE_9 in ("362.34") then  CerVD_9 = 1; 
if pickup in ("430", "431", "432", "433", "434", "435", "436", "437", "438") then CerVD_9  = 1; 
else CerVD_9=0;

/***Dementia***/
if DIAGNOSIS_CODE_9 in ("294.1", "331.2") then  Dementia_9 = 1; 
if pickup in ("290") then Dementia_9  = 1; 
else Dementia_9=0;

/***Chronic pulmonary disease***/
if DIAGNOSIS_CODE_9 in ("416.8", "416.9", "506.4", "508.1", "508.8") then  CPD_9 = 1; 
if pickup in ("490", "491", "492", "493", "494", "495", "496", "497", "498", "499", "500", "501", "502", "503", "504", "505") then CPD_9  = 1; 
else CPD_9=0;

/***Rheumatic disease***/
if DIAGNOSIS_CODE_9 in ("446.5", "710.0", "710.1", "710.2", "710.3", "710.4", "714.0", "714.1", "714.2", "714.8") then  Rh_D_9 = 1; 
if pickup in ("725") then Rh_D_9  = 1; 
else Rh_D_9 =0;

/***Peptic ulcer disease***/
if pickup in ("531", "532", "533", "534") then Pep_UD_9  = 1; 
else Pep_UD_9 =0;

/***Mild liver disease ***/
if DIAGNOSIS_CODE_9 in ("070.22", "070.23", "070.32", "070.33", "070.44", "070.54", "070.6", "070.9", "573.3", "573.4", "573.8", "573.9", "V42.7") then  MLD_9 = 1; 
if pickup in ("570", "571") then MLD_9  = 1; 
else MLD_9 =0;


/***Diabetes without chronic complication ***/
if DIAGNOSIS_CODE_9 in ("250.0", "250.1", "250.3", "250.8", "250.9") then  DWOCC_9 = 1; 
else DWOCC_9 =0;


/***Diabetes with chronic complication ***/
if DIAGNOSIS_CODE_9 in ("250.4", "250.5", "250.6", "250.7") then  DWCC_9 = 1; 
else DWCC_9 =0;


/***Hemiplegia or paraplegia***/
if DIAGNOSIS_CODE_9 in ("334.1", "344.0", "344.1", "344.2", "344.3", "344.4", "344.5", "344.6", "344.9") then  Hem_per_9 = 1;
if pickup in ("342", "343") then Hem_per_9  = 1;  
else Hem_per_9 =0;


/***Renal disease***/
if DIAGNOSIS_CODE_9 in ("403.01", "403.11", "403.91", "404.02", "404.03", "404.12", "404.13", "404.92", "404.93", "583.0",
"583.1", "583.2", "583.3", "583.4", "583.5", "583.6", "583.7", "588.0", "V42.0", "V45.1") then  ren_D_9 = 1;
if pickup in ("582", "585", "586", "V56") then ren_D_9  = 1;  
else ren_D_9 =0;

/***Any malignancy, including lymphoma and leukemia, except malignant neoplasm of skin****/
if DIAGNOSIS_CODE_9 in ("195.1", "195.2", "195.3", "195.4", "195.5", "195.6", "195.7", "195.8", "238.6") then  any_mal_9 = 1;
if pickup in ("140", "141", "142", "143", "144", "145", "146", "147", "148", "149", "150",
"151", "152", "153", "154", "155", "156", "157", "158", "159", "160",
"161", "162", "163", "164", "165", "166", "167", "168", "169", "170",
"171", "172", "174", "175", "176", "177", "178", "179", "180",
"181", "182", "183", "184", "185", "186", "187", "188", "189", "190",
"191", "192", "193", "194",
"200", "201", "202", "203", "204", "205", "206", "207", "208")
then any_mal_9  = 1;  
else any_mal_9 =0;

/***Moderate or severe liver disease ***/
if DIAGNOSIS_CODE_9 in ("456.0", "456.1", "456.2", "572.2", "572.3", "572.4", "572.5", "572.6", "572.7", "572.8") then  MSLD_9 = 1; 
if pickup in ("570", "571") then MSLD_9  = 1; 
else MSLD_9 =0;

/***Metastatic solid tumor ***/
if pickup in ("196", "197", "198", "199") then MetSLT_9  = 1; 
else MetSLT_9 =0;


/***AIDS/HIV***/
if pickup in ("042", "043", "044") then AIDS_9  = 1; 
else AIDS_9 =0;

run;

proc print data=check_ICD_9;
where any_mal_9 = 1;
run;

/*count(case when any_mal_9=1 then any_mal_9 end) as total_count_1, - Basically counts the number of non null row values
sum(case when  any_mal_9 = 1 then 1 else 0 end) as total_count_2, - sums up all the 1s*/
/***Since the set up is already 1 and 0, we can directly give sum statement***/

proc sql;
create table icd_9_counts as
select PAT_MRN_ID, 
sum (MI_9) as total_MI_9,
sum(CHF_9) as total_CHF_9,
sum (PVD_9) as total_PVD_9,
sum(CerVD_9) as total_CerVD_9,
sum (Dementia_9) as total_Dementia_9,
sum(CPD_9) as total_CPD_9,
sum(Rh_D_9) as total_Rh_D_9,
sum(Pep_UD_9) as total_Pep_UD_9,
sum (MLD_9) as total_MLD_9,
sum (DWOCC_9) as total_DWOCC_9,
sum(DWCC_9) as total_DWCC_9,
sum(Hem_per_9) as total_Hem_per_9,
sum (ren_D_9) as total_ren_D_9,
sum(any_mal_9) as total_any_mal_9,
sum(MSLD_9) as total_MSLD_9,
sum(MetSLT_9) as total_MetSLT_9,
sum(AIDS_9) as total_AIDS_9
 
from check_ICD_9
group by PAT_MRN_ID;
run;

data check_ICD_10;
set icd_10;

/**pickup variable represents the first three digits of the ICD-10 code. While defining the CCI, some codes to look at would be those that begin with 428 (428.x). Instead of defining every single possibility of 428 such as 428.4, 428.57, we could just usse the pick up***/
pickup_10 = substr(DIAGNOSIS_CODE_10, 1,3);

/**Myocardial infarction***/
if DIAGNOSIS_CODE_10 in ("I25.2") then  MI_10 = 1;
if pickup_10 in ("I21", "I22") then MI_10  = 1;  
else MI_10=0;

/***Congestive Heart Failure***/
if DIAGNOSIS_CODE_10 in ("I09.9", "I11.0", "I13.0", "I13.2", "I25.5", "I42.0", "I42.5", "I42.6", "I42.7", "I42.8", 
"I42.9", "P29.0") then  CHF_10 = 1; 
if pickup_10 in ("I43", "I50")  then CHF_10 = 1;
else CHF_10 = 0;

/**Peripheral vascular disease**/
if DIAGNOSIS_CODE_10 in ("I73.1", "I73.8", "I73.9", "I77.1", "I79.0", "I79.2", "K55.1", "K55.8", "K55.9", "Z95.8", 
"Z95.9") then  PVD_10 = 1; 
if pickup_10 in ("I70", "I71") then PVD_10  = 1; 
else PVD_10=0;

/**Cerebrovascular disease ***/
if DIAGNOSIS_CODE_10 in ("H34.0") then  CerVD_10 = 1; 
if pickup_10 in ("G45", "G46", "I60", "I61", "I62", "I63", "I64", "I65", "I66", "I67", "I68", "I69") then CerVD_10  = 1; 
else CerVD_10=0;

/***Dementia***/
if DIAGNOSIS_CODE_10 in ("G31.1") then  Dementia_10 = 1; 
if pickup_10 in ("F00", "F01", "F02", "F03", "G30") then Dementia_10  = 1; 
else Dementia_10=0;

/***Chronic pulmonary disease***/
if DIAGNOSIS_CODE_10 in ("I27.8", "I27.9", "J68.4", "J70.1", "J70.3") then  CPD_10 = 1; 
if pickup_10 in ("J40", "J41", "J42", "J43", "J44", "J45", "J46", "J47", "J60", "J61", "J62", "J63", "J64", "J65", "J66", "J67") then CPD_10  = 1; 
else CPD_10=0;

/***Rheumatic disease***/
if DIAGNOSIS_CODE_10 in ("M31.5", "M35.1", "M35.3", "M36.0") then  Rh_D_10 = 1; 
if pickup_10 in ("M05", "M06", "M32", "M33", "M34") then Rh_D_10  = 1; 
else Rh_D_10 =0;

/***Peptic ulcer disease***/
if pickup_10 in ("K25", "K26", "K27", "K28") then Pep_UD_10  = 1; 
else Pep_UD_10 =0;

/***Mild liver disease ***/
if DIAGNOSIS_CODE_10 in ("K70.0", "K70.1", "K70.2", "K70.3", "K70.9", "K71.3", "K71.4", "K71.5", "K71.7", "K76.0", "K76.2", "K76.3", "K76.4", "K76.8", "K76.9", "Z94.4") then  MLD_10 = 1; 
if pickup in ("B18", "K73", "K74") then MLD_10  = 1; 
else MLD_10 =0;


/***Diabetes without chronic complication ***/
if DIAGNOSIS_CODE_10 in ("E10.0", "E10.l", "E10.6", "E10.8", "E10.9", "E11.0", "E11.1", "E11.6", "E11.8", "E11.9",
"E12.0", "E12.1", "E12.6", "E12.8", "E12.9", 
"E13.0", "E13.1", "E13.6", "E13.8", "E13.9",
"E14.0", "E14.1", "E14.6", "E14.8", "E14.9") then  DWOCC_10 = 1; 
else DWOCC_10 =0;


/***Diabetes with chronic complication ***/
if DIAGNOSIS_CODE_10 in ("E10.2", "E10.3", "E10.4", "E10.5", "E10.7",
"E11.2", "E11.3", "E11.4", "E11.5", "E11.7",
"E12.2", "E12.3", "E12.4", "E12.5", "E12.7",
"E13.2", "E13.3", "E13.4", "E13.5", "E13.7",
"E14.2", "E14.3", "E14.4", "E14.5", "E14.7") then  DWCC_10 = 1; 
else DWCC_10 =0;


/***Hemiplegia or paraplegia***/
if DIAGNOSIS_CODE_10 in ("G04.1", "G11.4", "G80.1", "G80.2", "G83.0", "G83.1", "G83.2", "G83.3", "G83.4", "G83.9") then  Hem_per_10 = 1;
if pickup_10 in ("G81", "G82") then Hem_per_10  = 1;  
else Hem_per_10 =0;


/***Renal disease***/
if DIAGNOSIS_CODE_10 in ("I12.0", "I13.1", "N03.2", "N03.3", "N03.4", "N03.5", "N03.6", "N03.7", "N05.2", "N05.3",
"N05.4", "N05.5", "N05.6", "N05.7", "N25.0", "Z49.0", "Z49.1", "Z49.2", "Z94.0", "Z99.2") then  ren_D_10 = 1;
if pickup_10 in ("N18", "N19") then ren_D_10  = 1;  
else ren_D_10 =0;

/***Any malignancy, including lymphoma and leukemia, except malignant neoplasm of skin****/
if pickup_10 in ("C00", "C01", "C02", "C03", "C04", "C05", "C06", "C07", "C08", "C09", "C10",
"C11", "C12", "C13", "C14", "C15", "C16", "C17", "C18", "C19", "C20",
"C21", "C22", "C23", "C24", "C25", "C26", 
"C30", "C31", "C32", "C33", "C34", "C37", "C38", "C39", "C40",
"C41", "C43", "C45", "C46", "C47", "C48", "C49", "C50", "C51", "C52",
"C53", "C54", "C55", "C56", "C57", "C58", "C60", "C61", "C62", "C63", "C64", "C65", "C66", "C67", "C68", "C69",
"C70", "C71", "C72", "C73", "C74", "C75", "C76", "C81", "C82", "C83", "C84", "C85", "C88",
"C90", "C91", "C92", "C93", "C94", "C95", "C96", "C97")
then any_mal_10  = 1;  
else any_mal_10 =0;

/***Moderate or severe liver disease ***/
if DIAGNOSIS_CODE_10 in ("I85.0", "I85.9", "I86.4", "I98.2", "K70.4", "K71.1", "K72.1", "K72.9", "K76.5", "K76.6", "K76.7") then  MSLD_10 = 1; 
else MSLD_10 =0;

/***Metastatic solid tumor ***/
if pickup_10 in ("C77", "C78", "C79", "C80") then MetSLT_10  = 1; 
else MetSLT_10 =0;


/***AIDS/HIV***/
if pickup_10 in ("B20", "B21", "B22", "B24") then AIDS_10  = 1; 
else AIDS_10 =0;

run;


proc sql;
create table icd_10_counts as
select PAT_MRN_ID, 
sum (MI_10) as total_MI_10,
sum(CHF_10) as total_CHF_10,
sum (PVD_10) as total_PVD_10,
sum(CerVD_10) as total_CerVD_10,
sum (Dementia_10) as total_Dementia_10,
sum(CPD_10) as total_CPD_10,
sum(Rh_D_10) as total_Rh_D_10,
sum(Pep_UD_10) as total_Pep_UD_10,
sum (MLD_10) as total_MLD_10,
sum (DWOCC_10) as total_DWOCC_10,
sum(DWCC_10) as total_DWCC_10,
sum(Hem_per_10) as total_Hem_per_10,
sum (ren_D_10) as total_ren_D_10,
sum(any_mal_10) as total_any_mal_10,
sum(MSLD_10) as total_MSLD_10,
sum(MetSLT_10) as total_MetSLT_10,
sum(AIDS_10) as total_AIDS_10
 
from check_ICD_10
group by PAT_MRN_ID;
run;


data cci_1;
set icd_9_counts icd_10_counts;
run;
proc sort data=cci_1;
by PAT_MRN_ID;
run;


data libname.cci_2;
set cci_1;
if (total_MI_9 >=1  OR  total_MI_10 >=1) THEN MI = 1; ELSE MI=0;
if (total_CHF_9 >=1  OR  total_CHF_9 >=1) THEN CHF = 1; ELSE CHF=0;
if (total_PVD_9 >=1  OR  total_PVD_10 >=1) THEN PVD = 1; ELSE PVD=0;
if (total_CerVD_9 >=1  OR  total_CerVD_10 >=1) THEN CERVD = 1; ELSE CERVD=0;
if (total_Dementia_9 >=1  OR  total_Dementia_10 >=1) THEN DEMENTIA = 1; ELSE DEMENTIA=0;
if (total_CPD_9 >=1  OR  total_CPD_10 >=1) THEN CPD = 1; ELSE CPD=0;
if (total_Rh_D_9 >=1  OR  total_Rh_D_10 >=1) THEN RHD = 1; ELSE RHD=0;
if (total_Pep_UD_9 >=1  OR  total_Pep_UD_10 >=1) THEN PUD = 1; ELSE PUD=0;
if (total_MLD_9 >=1  OR  total_MLD_10 >=1) THEN MLD = 1; ELSE MLD=0;
if (total_DWOCC_9 >=1  OR  total_DWOCC_10 >=1) THEN DWOCC = 1; ELSE DWOCC=0;
if (total_DWCC_9 >=1  OR  total_DWCC_10 >=1) THEN DWCC = 1; ELSE DWCC=0;
if (total_Hem_per_9 >=1  OR  total_Hem_per_10 >=1) THEN HEM_PER = 1; ELSE HEM_PER=0;
if (total_ren_D_9 >=1  OR  total_ren_D_10 >=1) THEN RENDIS = 1; ELSE RENDIS=0;
if (total_any_mal_9 >=1  OR  total_any_mal_10 >=1) THEN ANY_MALIG = 1; ELSE ANY_MALIG=0;
if (total_MSLD_9 >=1  OR  total_MSLD_10 >=1) THEN MSLD = 1; ELSE MSLD=0;
if (total_MetSLT_9 >=1  OR  total_MetSLT_10 >=1) THEN METSLT = 1; ELSE METSLT=0;
if (total_AIDS_9 >=1  OR  total_AIDS_10 >=1) THEN AIDS = 1; ELSE AIDS=0;

CCI = MI + CHF + PVD + CERVD + DEMENTIA + CPD + RHD + PUD + MLD + DWOCC + DWCC + HEM_PER + RENDIS + ANY_MALIG + 
MSLD + METSLT + AIDS;

*** use Charlson weights to calculate a weighted score;
W_CCI = MI + CHF + PVD + CERVD + DEMENTIA + CPD + RHD + PUD + MLD + DWOCC + (2*DWCC) + (2*HEM_PER) + (2*RENDIS) + (2*ANY_MALIG) + 
(3*MSLD) + (6*METSLT) + (6*AIDS);

label 	MI = "Myocardial infarction"
	    CHF = "Congestive heart failure"
        PVD = "Peripheral Vascular Disease"
		CERVD = "Cerebrovascular Disease"
		DEMENTIA = "Dementia"
		CPD = "Chronic Pulmonary Disease"
		RHD = "Connective Tissue Disease-Rheumatic Disease"
		PUD = "Peptic Ulcer Disease"
		MLD = "Mild Liver Disease"
		DWOCC = "Diabetes without complications"
		DWCC = "Diabetes with complications"
		HEM_PER = "Paraplegia and Hemiplegia"
		RENDIS = "Renal Disease"
		ANY_MALIG = "Cancer"
		MSLD = "Moderate or Severe Liver Disease"
		METSLT = "Metastatic Carcinoma"
		AIDS = "HIV/AIDS"
		CCI = "Sum of 17 Charlson Comorbidity Groups"
		W_CCI = "Weighted Sum of 17 Charlson Comorbidity Groups"
;

keep PAT_MRN_ID MI CHF PVD CERVD DEMENTIA CPD RHD PUD MLD DWOCC DWCC HEM_PER RENDIS ANY_MALIG MSLD AIDS CCI W_CCI;
run;

/***This patient alone has two rows because they had both ICD-9 and ICD-10 codes. 
However, their scores are zero for all comorbidities. So, I plan to use just the top row for this patient.***/
proc print data= libname.cci_2;

*variable name and values replaced with deidentified values;
where AIM_1_2_PATID = 12015124;
RUN;

proc univariate data =libname.cci_2;
   histogram CCI / normal;
run;

proc univariate data =libname.cci_2;
   histogram W_CCI / normal;
run;

data libname.cci_scores;
set libname.cci_2;
by PAT_MRN_ID;
if first.PAT_MRN_ID;
run;
