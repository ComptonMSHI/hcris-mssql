/*
hosp10 RECORD COUNTS BY YEAR FOR THE QUARTER ENDING 2018-03-31 [hosp10.hosp10]                                                      			
FY	       RPT count	  ALPHA count	    NMRC count
2010	2322	1347622	7397272
2011	6150	3534353	19341879
2012	6227	3594970	19687768
2013	6248	3664554	19907610
2014	6247	3659511	19809785
2015	6255	3637134	19661609
2016	6158	3595530	19406811
2017	900	545037	3090913
TOTAL	40507	23578711	128303647

Ref: https://www.cms.gov/Research-Statistics-Data-and-Systems/Downloadable-Public-Use-Files/Cost-Reports/Hospital-2010-form.html
*/

SELECT COUNT(*) FROM MCR_NEW_NMRC WHERE FORM='2552-10'; -- 128303647 

SELECT COUNT(*) FROM MCR_NEW_ALPHA WHERE FORM='2552-10'; -- 24258452 (HIGHER July Release)

SELECT COUNT(*) FROM MCR_NEW_RPT WHERE FORM='2552-10'; -- 44392 (HIGHER July Release)

SELECT COUNT(*) FROM mcrFormData_Nmrc WHERE FORM='2552-10'; -- 128303647 
SELECT COUNT(*) FROM mcrFormData_Alpha WHERE FORM='2552-10'; -- 17948807
SELECT COUNT(*) FROM mcrFormData_Alpha_Desc WHERE FORM='2552-10'; -- 6309645

/*
HOSP RECORD COUNTS BY YEAR FOR THE QUARTER ENDING 2018-03-31 [HOSP.HOSP]                                                            			
FY	       RPT count	  ALPHA count	    NMRC count
1995	2	141	2878
1996	6062	670885	12478350
1997	6380	739823	13469799
1998	6327	808358	13439896
1999	6210	832186	13272836
2000	6195	888780	13745150
2001	6172	966385	11906388
2002	6198	1031855	11287953
2003	6193	1083900	11093105
2004	6265	1053055	11089783
2005	6248	1078823	10989728
2006	6233	1087420	10826659
2007	6180	1068909	10618244
2008	6208	1082755	10534639
2009	6202	1080751	10398870
2010	3851	675420	6382242
2011	34	4321	33641
TOTAL	90960	14153767	171570161
*/

SELECT COUNT(*) FROM MCR_NEW_NMRC WHERE FORM='2552-96'; -- 171570161

SELECT COUNT(*) FROM MCR_NEW_ALPHA WHERE FORM='2552-96'; -- 14153767

SELECT COUNT(*) FROM MCR_NEW_RPT WHERE FORM='2552-96'; -- 90960


SELECT COUNT(*) FROM mcrFormData_Nmrc WHERE FORM='2552-96'; -- 171570161 
SELECT COUNT(*) FROM mcrFormData_Alpha WHERE FORM='2552-96'; -- 7629799
SELECT COUNT(*) FROM mcrFormData_Alpha_Desc WHERE FORM='2552-96'; -- 6523968


SELECT COUNT(*) FROM mcrFormData_Nmrc; -- 299873808
SELECT COUNT(*) FROM mcrFormData_Alpha; -- 25578606
											-- 325,452,414
SELECT COUNT(*) FROM mcrFormData; -- 46052696
SELECT COUNT(*) FROM mcrMeasures; -- 130169

