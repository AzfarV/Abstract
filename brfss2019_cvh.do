* rename all variables to lower case
rename *, lower
rename _*, lower
 
**# Variables for CVH as defined by AHA Simple 7
*blood pressure
label define bloodp 1 "Yes" 2 "Yes, but pregnancy" 3 "No" 4 "Borderline or Pre Hyp" 7 "Dont know" 9 "Refused"
label values bphigh4 bloodp

gen has_bphigh = 1 if bphigh4 == 1
replace has_bphigh = 0 if bphigh4 > 1
label define has_bphigh  0 "No" 1 "Yes"

*cholesterol
label define dyslipid 1 "Yes" 2 "No" 7 "Dont know" 9 "Refused"
label values toldhi2 dyslipid

gen has_highcho = 1 if toldhi2 == 1
replace has_highcho = 0 if toldhi2 > 1
label define has_highcho 0 "No " 1 "Yes"
label values has_highcho has_highcho

*blood sugar
label define diab 1 "Yes" 2 "Yes, but pregnancy" 3 "No" 4 "No, pre diabetes" 7 "Dont know" 9 "Refused"
label values diabete4 diab

gen has_diab = 1 if diabete4 == 1
replace has_diab = 0 if diabete4 > 1
label define has_diab 0 "No" 1 "Yes"

*exercise
recode _pa150r3 (2/3 = 0) (1 = 1) (9 = .)
label define exer150 0"0-149 mins" 1"150+ mins"
label values _pa150r3 exer150

gen has_noexer = 1 if _pa150r3 == 0
replace has_noexer = 0 if _pa150r3 == 1
label define has_noexerc 0"150+ mins" 1"no exercise" 
label values has_noexer has_noexerc

*food
recode fvgreen1 (101/192 = 1) (201/293 = 2) (300 = 3) (301/394 = 4) (555 = 5) (777/999 = .) gen (fvgreennew)
recode fvgreennew (5 = 1) (1/4 = 2)
label define fvgreen 1"Never eaten" 2"Eaten for some period"
label values fvgreennew fvgreen

recode fruit2 (101/198 = 1) (201/280 = 2) (300 = 3) (301/390 = 4) (555 = 5) (777/999 = .), gen (fruitnew)
recode fruitnew (5 = 1) (1/4 = 2)
label define fruit2 1"Never eaten" 2"Eaten for some period"
label values fruitnew fruit2

gen has_nofood = 1 if fvgreennew == 1 | fruitnew == 1
replace has_nofood = 0 if fvgreennew > 1 | fruitnew > 1

*weight
label define bmicat 1 "BMI < 1850" 2 "1850 <= BMI < 2500 " 3 "> 2500 <= BMI < 3000" 4 "3000 <= BMI < 9999"
label values _bmi5cat bmicat

gen has_highbmi = 1 if _bmi5cat >= 3
replace has_highbmi = 0 if _bmi5cat < 3
label define has_highbmi 0 "BMI < 25" 1 "BMI >= 25"
label values has_highbmi has_highbmi

*smoking
recode smokday2 (1/2 = 1) (3 = 2) (7/9 = .) 
label define smoke 1"Some+Every day" 2"Not at all"
label values smokday2 smoke

recode smoke100  (1 = 1) (2 = 2) (7/9 = .)
label define smoke100 1"Yes" 2"No"
label values smoke100 smoke100

gen has_smoked = 1 if smokday2 == 1 | smoke100 == 1
replace has_smoked = 0 if smokday2 >= 2 | smoke100 >= 2

* Generate an CVH 
gen cvh = 0
replace cvh = 1 if has_bphigh == 1 | has_highcho == 1 | has_diab == 1 | has_noexer == 1 | has_nofood == 1 | has_highbmi == 1 

* Generate CVH score 0 - 7 based on number of conditions observed in each inidivudal (high being 5 or more)
gen cvh_score = has_bphigh + has_highcho + has_diab + has_noexer + has_nofood + has_highbmi + has_smoked
gen cvh_high = 1 if cvh_score >= 5 
replace cvh_high = 0 if cvh_score < 5


**#Stroke Variable
* tabulate and create label for stroke variable
label define cvdstrk3_1 1 "Yes" 2 "No" 7 "Not Sure" 9 "Refused"
label values cvdstrk3 cvdstrk3_1
tab cvdstrk3 

* Create new stroke variable with only two pertient values (drop the unsure / unknown response)
gen cvdstrk3_nomiss = cvdstrk3 
replace cvdstrk3_nomiss = . if cvdstrk3 > 2

* rename and recode the final stroke variable for analysis 
rename cvdstrk3_nomiss stroke
recode stroke (1 = 1) (2 = 0)



**# Recodeing of state variables to define 1) Division 2) Region 3) Stroke belt 
* Stroke belt deined as per Howard et al. paper in stroke (Feb 2020)
* REGARDS (Reasons for Geographic and Racial Differences in Stroke), include the states of North Carolina, South Carolina, Georgia, Tennessee, Alabama, Mississippi and Arkansas, and Louisiana

* labeling states
label define states 1"Alabama" 2"Alaska" 4"Arizona" 5"Arkansas" 6"California" 8"Colorado" 9"Connecticut" 10"Delaware" 11"District of Columbia" 12"Florida" 13"Georgia" 15"Hawaii" 16"Idaho" 17"Illinois" 18"Indiana" 19"Iowa" 20"Kansas" 21"Kentucky" 22"Louisiana" 23"Maine" 24"Maryland" 25"Massachusetts" 26"Michigan" 27"Minnesota" 28"Mississippi" 29"Missouri" 30"Montana" 31"Nebraska" 32"Nevada" 33"New Hampshire" 35"New Mexico" 36"New York" 37"North Carolina" 38"North Dakota" 39"Ohio" 40"Oklahoma" 41"Oregon" 42"Pennsylvania" 44"Rhode Island" 45"South Carolina" 46"South Dakota" 47"Tennessee" 48"Texas" 49"Utah" 50"Vermont" 51"Virginia" 53"Washington" 54"West Viriginia" 55"Wisconsin" 56"Wyoming" 66"Guam" 72"Puerto Rico"
label values _state states

* genrating and labeling divisions
gen division = 0
replace division = 1 if inlist(_state,2,53,41,6,15)
replace division = 2 if inlist(_state,30,16,56,32,49,8,4,35)
replace division = 3 if inlist(_state,38,46,31,20,27,19,29)
replace division = 4 if inlist(_state,40,48,5,22)
replace division = 5 if inlist(_state,55,26,17,18,39)
replace division = 6 if inlist(_state,21,47,28,1)
replace division = 7 if inlist(_state,10,11,24,51,54,37,45,13,12)
replace division = 8 if inlist(_state,36,42)
replace division = 9 if inlist(_state,23,33,50,25,9,44)

label define divs 0"territories" 1"pacific" 2"mountain" 3"west north central" 4"west south central" 5"east north central" 6"east south central" 7"south atlantic" 8"middle atlantic" 9"new england"
label values division divs

* genrating and labeling regions
generate region = 0
replace region = 1 if inlist(division,1,2)
replace region = 2 if inlist(division,3,5)
replace region = 3 if inlist(division,4,6,7)
replace region = 4 if inlist(division,8,9)

label define regs 0"territories" 1"west" 2"midwest" 3"south" 4"northeast"
label values region regs

* genrating and labeling the stroke belt
gen strkbelt = 0
replace strkbelt = 1 if inlist(_state,37,45,13,47,1,28,5,22)
label define strokebelt 0"Not in stroke belt" 1"In stroke belt"
label values strkbelt strokebelt

gen strkbelt_new = strkbelt
replace strkbelt_new = . if division == 0 | inlist(_state,2,15)

gen strkbeltnoterr = strkbelt
replace strkbeltnoterr = . if division == 0

**# Survey Design Functions
* Declare data to be Survey Data 
svyset [pweight = _llcpwt], strata(_ststr) psu(_psu)

* The code below will generate column header values for Table 2. 
svy: tab stroke, count format(%14.3gc)
svy, subpop(if stroke == 1): tab cvh_high, count format(%14.3gc)
svy, subpop(if stroke == 1): tab cvh_high, prop format(%10.2f)



**# Code for Table 2 (CVH)
*FOR BINARY VARIABLES
*sex
label define sex 1"Male" 2"Female"
label values _sex sex
recode _sex (1 = 1) (2 = 0), gen (sex_male)
svy, subpop(if stroke == 1): tab sex_male cvh_high, prop col format(%10.3f)
svy, subpop(if stroke == 1): logistic cvh_high sex_male

*health care coverage
recode hlthpln1 (1=1) (2=2) (7/9=.)
label define healthcare 1"Yes" 2"No"
label values hlthpln1 healthcare
svy, subpop(if stroke == 1): tab hlthpln1 cvh_high, prop col format(%10.3f)
svy, subpop(if stroke == 1): logistic cvh_high hlthpln1

*vetran status
recode veteran3 (1=1) (2=2) (7/9=.)
label define veteran 1"Yes" 2"No"
label values veteran3 veteran
svy, subpop(if stroke == 1): tab veteran3 cvh_high, prop col format(%10.3f)
svy, subpop(if stroke == 1): logistic cvh_high veteran3

*in stroke belt
svy, subpop(if stroke == 1): tab strkbelt cvh_high, prop col format(%10.3f)
svy, subpop(if stroke == 1): logistic cvh_high strkbelt

*how many days was your physical health not good
recode physhlth (1/30=1) (77=.) (88=0) (99=.)
label def physhlthbad 0"None" 1"Some amount of Days" 
label values physhlth physhlthbad
svy, subpop(if stroke == 1): tab physhlth cvh_high, prop col format(%10.3f)
svy, subpop(if stroke == 1): logistic cvh_high physhlth

*how many days was your mental health not good
recode menthlth (1/30=1) (77=.) (88=0) (99=.)
label def menhlthbad 0"None" 1"Some amount of Days" 
label values menthlth menhlthbad
svy, subpop(if stroke == 1): tab menthlth cvh_high, prop col format(%10.3f)
svy, subpop(if stroke == 1): logistic cvh_high menthlth

*how many days did poor physical or mental health keep you from doing your usual activities?
recode poorhlth (1/30=1) (77=.) (88=0) (99=.)
label def poorphymen 0"None" 1"Some amount of Days" 
label values poorhlth poorphymen
svy, subpop(if stroke == 1): tab poorhlth cvh_high, prop col format(%10.3f)
svy, subpop(if stroke == 1): logistic cvh_high poorhlth

*do you have one person you think of as your personal doctor
recode persdoc2 (1/2=1) (3=2) (7/9=.)
label define persdc 1"Yes" 2"No"
label values persdoc2 persdc
svy, subpop(if stroke == 1): tab persdoc2 cvh_high, prop col format(%10.3f)
svy, subpop(if stroke == 1): logistic cvh_high persdoc2

*was there a time you needed to see a doctor but could not because of cost?
recode medcost (1=1) (2=2) (7/9=.)
label def medcost 1"Yes" 2"No"
label values medcost medcost
svy, subpop(if stroke == 1): tab medcost cvh_high, prop col format(%10.3f)
svy, subpop(if stroke == 1): logistic cvh_high medcost

*told you had a heart attack
recode cvdinfr4 (1=1) (2=2) (7/9=.)
label define heartatt 1"Yes" 2"No"
label values cvdinfr4 heartatt
svy, subpop(if stroke == 1): tab cvdinfr4 cvh_high, prop col format(%10.3f)
svy, subpop(if stroke == 1): logistic cvh_high cvdinfr4

*told you had coronary heart disease
recode cvdcrhd4 (1=1) (2=2) (7/9=.)
label define chd 1"Yes" 2"No"
label values cvdcrhd4 chd
svy, subpop(if stroke == 1): tab cvdcrhd4 cvh_high, prop col format(%10.3f)
svy, subpop(if stroke == 1): logistic cvh_high cvdcrhd4

*ever had asthma
recode asthma3 (1=1) (2=2) (7/9=.)
label define everasthma 1"Yes" 2"No"
label values asthma3 everasthma
svy, subpop(if stroke == 1): tab asthma3 cvh_high, prop col format(%10.3f)
svy, subpop(if stroke == 1): logistic cvh_high asthma3

*still have asthma
recode asthnow (1=1) (2=2) (7/9=.)
label define curasthma 1"Yes" 2"No"
label values asthnow curasthma
svy, subpop(if stroke == 1): tab asthnow cvh_high, prop col format(%10.3f)
svy, subpop(if stroke == 1): logistic cvh_high asthnow

*ever had skin cancer
recode chcscncr (1=1) (2=2) (7/9=.)
label define skncncr 1"Yes" 2"No"
label values chcscncr skncncr
svy, subpop(if stroke == 1): tab chcscncr cvh_high, prop col format(%10.3f)
svy, subpop(if stroke == 1): logistic cvh_high chcscncr

*ever had other types of cancer
recode chcocncr (1=1) (2=2) (7/9=.)
label define othercncr 1"Yes" 2"No"
label values chcocncr othercncr
svy, subpop(if stroke == 1): tab chcocncr cvh_high, prop col format(%10.3f)
svy, subpop(if stroke == 1): logistic cvh_high chcocncr

*ever had COPD
recode chccopd (1=1) (2=2) (7/9=.)
label define evercopd 1"Yes" 2"No"
label values chccopd evercopd
svy, subpop(if stroke == 1): tab chccopd cvh_high, prop col format(%10.3f)
svy, subpop(if stroke == 1): logistic cvh_high chccopd

*ever had depressive disorder
recode addepev3 (1=1) (2=2) (7/9=.)
label define dprss 1"Yes" 2"No"
label values addepev3 dprss
svy, subpop(if stroke == 1): tab addepev3 cvh_high, prop col format(%10.3f)
svy, subpop(if stroke == 1): logistic cvh_high addepev3

*ever told you had kidney disease
recode chckdny2 (1=1) (2=2) (7/9=.)
label define kdny 1"Yes" 2"No"
label values chckdny2 kdny
svy, subpop(if stroke == 1): tab chckdny2 cvh_high, prop col format(%10.3f)
svy, subpop(if stroke == 1): logistic cvh_high chckdny2

*ever told you had arthritis
recode havarth4 (1=1) (2=2) (7/9=.)
label define arthritis 1"Yes" 2"No"
label values havarth4 arthritis
svy, subpop(if stroke == 1): tab havarth4 cvh_high, prop col format(%10.3f)
svy, subpop(if stroke == 1): logistic cvh_high havarth4

*ever suggested physical activity to help your arthritis
recode arthexer (1=1) (2=2) (7/9=.)
label define phyarth 1"Yes" 2"No"
label values arthexer phyarth
svy, subpop(if stroke == 1): tab arthexer cvh_high, prop col format(%10.3f)
svy, subpop(if stroke == 1): logistic cvh_high arthexer

*ever taken a course to manage problems related to your arthritis
recode arthedu (1=1) (2=2) (7/9=.)
label define eduarth 1"Yes" 2"No"
label values arthedu eduarth
svy, subpop(if stroke == 1): tab arthedu cvh_high, prop col format(%10.3f)
svy, subpop(if stroke == 1): logistic cvh_high arthedu

*are you limited of your activities because of arthritis
recode lmtjoin3 (1=1) (2=2) (7/9=.)
label define limitarth 1"Yes" 2"No"
label values lmtjoin3 limitarth
svy, subpop(if stroke == 1): tab lmtjoin3 cvh_high, prop col format(%10.3f)
svy, subpop(if stroke == 1): logistic cvh_high lmtjoin3

*does arthritis affect your work
recode arthdis2 (1=1) (2=2) (7/9=.)
label define wrkarth 1"Yes" 2"No"
label values arthdis2 wrkarth
svy, subpop(if stroke == 1): tab arthdis2 cvh_high, prop col format(%10.3f)
svy, subpop(if stroke == 1): logistic cvh_high arthdis2

*FOR CATEGORICAL VARIABLES
*age 
label define agegrps 1"Age 18 to 24" 2"Age 25 to 34" 3"Age 35 to 44" 4"Age 45 to 54" 5"Age 55 to 64" 6"Age 65 or older"
label values _age_g agegrps
svy, subpop(if stroke == 1): tab _age_g cvh_high, prop col format(%10.3f)
svy, subpop(if stroke == 1): logistic cvh_high i._age_g

*marital status
label define married 1"Married" 2"Divorced" 3"Widowed" 4"Separated" 5"Never Married" 6"Member of Unmarried Couple"
label values marital married
recode marital (9=.)
svy, subpop(if stroke == 1): tab marital cvh_high, prop col format(%10.3f)
svy, subpop(if stroke == 1): logistic cvh_high i.marita

*race 
label define _race_g1 1 "White - NH" 2 "Black - NH" 3 "Hispanic" 4 "Other race - NH" 5 "Multiracial - NH"
label values _race_g1 _race_g1
svy, subpop(if stroke == 1): tab _race_g1 cvh_high, prop col format(%10.3f)
svy, subpop(if stroke == 1): logistic cvh_high i._race_g1

tab race_analysis
recode race_analysis (1=1) (2=2) (3=3) (6=4) (4/7 = 5), gen (race_analysis_new)
label define newrace 1 "White" 2 "Black" 3 "Aapi" 4 "Hispanic" 5 "Native American+Mixed+Not known"
label values race_analysis_new newrace

*education 
recode educa (1 = 1) (2/3 = 2) (4 = 3) (5/6 = 4) (9 = .), gen (educa_new)
label define educa_new 1 "No School" 2 "Some School (No Grad)" 3 "High School Grad" 4 "Some College or Grad"
label values educa_new educa_new
svy, subpop(if stroke == 1): tab educa_new cvh_high, prop col format(%10.3f)
svy, subpop(if stroke == 1): logistic cvh_high i.educa_new

*income
gen income_new = income2
replace income_new = . if income2 == 77
replace income_new = . if income2 == 99
label define income_new 1 "Less than 10,000" 2 "10,000 - 14,999" 3 "15,000 - 19,999" 4 "20,000 - 24,999" 5 "25,000 - 34,999" 6 "35,000 - 49,999" 7 "50,000 - 74,999" 8 "75,000 or more"
label values income_new income_new
svy, subpop(if stroke == 1): tab income_new cvh_high, prop col format(%10.3f)
svy, subpop(if stroke == 1): logistic cvh_high i.income_new

recode income_new (1/2 = 1) (3/4 = 2) (5/6 = 3) (7/8 = 4), gen (income_4cat)
label define income_4cat 1 "Less than 10,000 - 14,999" 2 "15,000 - 24,999" 3 "25,000 - 49,000" 4 "50,000 - 75,000+"
label values income_4cat income_4cat


*employment status
recode employ1 (1=1) (2=2) (3/4 = 3) (5=4) (6=5) (7=6) (8=7) (9=.)
label define employ 1"Employed for wages" 2"Self-employed" 3"Out of work" 4"Homemaker" 5"Student" 6"Retired" 7"Unable to work"
label values employ1 employ
svy, subpop(if stroke == 1): tab employ1 cvh_high, prop col format(%10.3f)
svy, subpop(if stroke == 1): logistic cvh_high i.employ1

*home ownership
recode renthom1 (1=1) (2=2) (3=3) (7/9=.)
label define homeown 1"Own" 2"Rent" 3"Other arrangement"
label values renthom1 homeown
svy, subpop(if stroke == 1): tab renthom1 cvh_high, prop col format(%10.3f)
svy, subpop(if stroke == 1): logistic cvh_high i.renthom1

*number of adults
recode numadult (1=1) (2=2) (3=3) (4=4) (5/40=5)
label define adults 1"One Adult" 2"Two Adults" 3"Three Adults" 4"Four Adults" 5"Five plus Adults"
label values numadult adults
svy, subpop(if stroke == 1): tab numadult cvh_high, prop col format(%10.3f)
svy, subpop(if stroke == 1): logistic cvh_high i.numadult

recode numadult (1/2 = 1) (3/4 = 2) (5 = 3), gen (numadult_new)
label define newadult 1 "1-2 Adults" 2 "3-4 Adults" 3 "5+ Adults"
label values numadult_new newadult

*divisions
svy, subpop(if stroke == 1): tab division cvh_high, prop col format(%10.3f)
svy, subpop(if stroke == 1): logistic cvh_high i.division

*regions
svy, subpop(if stroke == 1): tab region cvh_high, prop col format(%10.3f)
svy, subpop(if stroke == 1): logistic cvh_high i.region

*general health status
recode genhlth (1=1) (2=2) (3=3) (4=4) (5=5) (7/9=.)
label define hlthstat 1"Excellent" 2"Very Good" 3"Good" 4"Fair" 5"Poor"
label values genhlth hlthstat
svy, subpop(if stroke == 1): tab genhlth cvh_high, prop col format(%10.3f)
svy, subpop(if stroke == 1): logistic cvh_high i.genhlth

*last routine checkup
recode checkup1 (1=1) (2=2) (3=3) (4=4) (7=.) (8=5) (9=.)
label define checkup 1"Within Year" 2"Within 2 Years" 3"Within 5 Years" 4"More than 5" 5"Never"
label values checkup1 checkup
svy, subpop(if stroke == 1): tab checkup1 cvh_high, prop col format(%10.3f)
svy, subpop(if stroke == 1): logistic cvh_high i.checkup1

**# MULTIVARIABLE MODELING 

*kitchen sink, results: 8 OR = 1, significance in male,native american,aapi,hispanic,low income,mountain,west south central,east south central,south atlantic,middle atlantic,general health status
svy, subpop (if stroke == 1): logistic cvh_high i._age_g i.sex_male i.marital i.race_analysis i.educa_new i.income_new i.employ1 i.renthom1 i.numadult i.division i.strkbelt i.genhlth i.checkup1 

*FINAL MODEL post Aug 6 meeting
svy, subpop (if stroke == 1): logistic cvh_high i._age_g i.sex_male i.race_analysis_new i.income_4cat ib3.numadult_new ib9.division strkbeltnoterr


findit coefplot
coefplot, drop(_cons) xline(1) transform(* = min(max(@,0),20)) eform

coefplot, drop(_cons)  headings(2._age_g = "{bf:Age}" 1.sex_male = "{bf:Sex}" 2.race_analysis_new = "{bf:Race}" 2.income_4cat = "{bf:Income}" 1.numadult_new = "{bf:Number of Adults}" 1.division = "{bf:Division}" strkbeltnoterr = "{bf:Stroke Belt Resident}") coeflabels(2._age_g = "25 - 34" 3._age_g = "35 - 44" 4._age_g = "45 - 54" 5._age_g = "55 - 64" 6._age_g = "65+" 1.sex_male = "Male" 2.race_analysis_new = "Black" 3.race_analysis_new = "AAPI" 4.race_analysis_new = "Hispanic" 5.race_analysis_new = "Other" 1.numadult_new = "1-2" 2.numadult_new = "3-4" 1.division = "Pacific" 2.division = "Mountain" 3.division = "West North Central" 4.division = "West South Central" 5.division = "East North Central" 6.division = "East South Central" 7.division = "South Atlantic" 8.division = "Middle Atlantic" strkbeltnoterr = "In Stroke Belt") xline(1) transform(* = min(max(@,0),20)) ef
