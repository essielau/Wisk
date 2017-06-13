/* For Project 3: Evaluating Sales Promotion Effects */
/* The key SAS learning objective is to estimate multinomial logit (MNL) */
/* models using PROC MDC. We will also apply PROC GENMOD and PROC REG */
/* to estimate Binary logit and semi-log models, respectively. */
/* Category: liquid laundry detergent                    */

/* Set the number of lines per page in the output file */
options ps=60;

/*Define the libary name first in order to locate the data files.*/
/* You need to change the path according to dir on your computer*/

libname proj3 '/folders/myfolders/BUMK706/Week6/Computer Session/';


/*********** Part I: Purchase Incidence Model ******************/
/*** Data: 'deterg.sas7bdat' ***/
data deterg;
set proj3.deterg;

/* Create category level variables for the purchase incidence model.   */
/* These are the variables that may affect the attractiveness */
/* of the category. They are defined as follows.              */
/* avg_rp: average regular price of the category.             */ 
/* avg_pc: average price cut of the category.                 */ 
/* cat_disp: =1 if any brand in the category is on in-store   */
/*           display; 0 otherwise.                            */
/* cat_feat: =1 if any brand in the category is on feature    */
/*           advertising; 0 otherwise.                        */
avg_rp=mean(of regpr1-regpr4);
avg_pc=mean(of pcut1-pcut4);
cat_disp=0;
cat_feat=0;
if disp1=1 or disp2=1 or disp3=1 or disp4=1 then cat_disp=1;
if feat1=1 or feat2=1 or feat3=1 or feat4=1 then cat_feat=1;

/* Get descriptive statistics of key variables */
proc means;
var regpr1-regpr4 pcut1-pcut4 disp1-disp4 feat1-feat4 
    avg_rp avg_pc cat_disp cat_feat;

proc freq;
table incid;     /* purchase incidence frequency */

proc freq;
table choice*incid;  /* brand shares, only need the tabulation when incid=1 */

proc means;
var volume;
class choice;    /* average purchase volume by brand */

/* Estimate a Binary logit model using PROC GENMOD */
proc genmod data=deterg descending;
     model incid = avg_rp avg_pc cat_disp cat_feat lbpromot / 
           dist=binomial link=logit;
     title 'Binary Logit Model for Category Purchase Incidence = 1';
run;

/* FYI: One can also use PROC LOGISTIC to estimate the binary logit model */
/* You will see that estimation results from the two PROC's are very similar. */
*proc logistic data=deterg descending;
*model incid = avg_rp avg_pc cat_disp cat_feat lbpromot;
*title 'Use PROC LOGISTIC to estimate Binary logit model for Incidence = 1';
*run;


/************** Part II: Brand Choice Model *******************/
/*** Data: 'choice_det.sas7bdat' ***/

data choice;
set proj3.choice_det;

/* PROC MDC does not automatically add the intercept terms in */
/* a model. The following statements creates three brand-specific */
/* dummy variables for estimating the intercepts. Like in a  */
/* regression model, we should use (K-1) intercepts for K brands */
intcpt1=0;
intcpt2=0;
intcpt3=0;
if brand=1 then intcpt1=1;
if brand=2 then intcpt2=1;
if brand=3 then intcpt3=1;
chd=2;
if decision=1 then chd=1;

/* Get descriptive statistics of key variables */
proc means data=choice;
var regpr pcut disp feat;
class brand;
title;  /* suppress the previously defined title,otherwise stay in effect until redefined */

/* Estimate a multinomial logit (MNL) model for brand choice decisions. */
/* This model is called the "conditional logit model" in PROC MDC.*/
/* It is specified by defining TYPE=CLOGIT in the MODEL statement. */
*proc mdc data=choice;
*   model decision = intcpt1 intcpt2 intcpt3 regpr pcut disp feat /type=clogit
*         choice=(brand 1 2 3 4);
*   id caseid;
*   title 'Multinomial Logit Model for Brand Choice';
* run; 

proc phreg data=choice NOSUMMARY;
model chd*chd(2) = intcpt1 intcpt2 intcpt3 regpr pcut disp feat 
  /ties=breslow;
strata caseid;  
   title 'Multinomial Logit Model for Brand Choice';
run;

/***************** Part III: Purchase Quantity Models ****************/
/* Estimating the quantity model for one brand at a time.            */
/* A semi-log model is estimated for each brand  */ 
/* A parsimonious model with only price cut promotion is estiamted for */
/* each brand here. You should test the effects of display and feature ad */
/* and modify your final model accordingly. Note that the Excel template */
/* file "promotion_effects.xlsx" needs to be modified if you use a different */
/* purchase quantity model for any brand. */
/* Data: The observations in "deterg.sas7bdat" where brand k is chosen */

data temp1;
set deterg;
if choice=1;   /* keep only those observations when brand 1 was chosen */
logvol1=log(volume);
proc reg;
model logvol1 = avol regpr1 pcut1 lbpromot;
*model logvol1 = avol regpr1 pcut1 disp1 feat1 lbpromot;
title 'Semi-log (conditional) purchase quantity model for brand 1';
run;

data temp2;
set deterg;
if choice=2;   /* keep only those observations when brand 2 was chosen */
logvol2=log(volume);
proc reg;
model logvol2=avol regpr2 pcut2 lbpromot;
*model logvol2 = avol regpr2 pcut2 disp2 feat2 lbpromot;
title 'Semi-log (conditional) purchase quantity model for brand 2';
run;

data temp3;
set deterg;
if choice=3;   /* keep only those observations when brand 3 was chosen */
logvol3=log(volume);
proc reg;
model logvol3=avol regpr3 pcut3 lbpromot;
*model logvol3 = avol regpr3 pcut3 disp3 feat3 lbpromot;
title 'Semi-log (conditional) purchase quantity model for brand 3';
run;

data temp4;
set deterg;
if choice=4;   /* keep only those observations when brand 4 was chosen */
logvol4=log(volume);
proc reg;
model logvol4=avol regpr4 pcut4 lbpromot;
*model logvol4 = avol regpr4 pcut4 disp4 feat4 lbpromot;
title 'Semi-log (conditional) purchase quantity model for brand 4';
run;
