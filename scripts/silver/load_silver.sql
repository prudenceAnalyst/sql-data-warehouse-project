/*
===============================================================================
This script loads Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This script performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
===============================================================================*/

TRUNCATE TABLE silver.patients;
GO

INSERT INTO silver.patients
(
	PATIENT_ID,
	CODE_SERVICE,
	GENDER,
	MONTH_OF_BIRTH,
	DISTRICT,
	BEGINDATE,
	ENDDATE,
	INSURER,
	OUTCOME,
	TYPE1,
	DIAGCODE,
	Satisfaction
)
SELECT
	PATIENT_ID,
	CODE_SERVICE,
	CASE
        WHEN UPPER(GENDER) = 'M' THEN 'Male'
        WHEN UPPER(GENDER) = 'F' THEN 'Female'
        ELSE 'N/A'
    END AS GENDER,
	TRY_CONVERT(DATE, MONTH_OF_BIRTH) AS MONTH_OF_BIRTH,
	LOWER (DISTRICT) AS DISTRICT,
	TRY_CONVERT(DATE, BEGINDATE, 103) AS BEGINDATE,
	TRY_CONVERT(DATE, ENDDATE, 103) AS ENDDATE,
	INSURER,
	CASE WHEN OUTCOME IN ('better', 'missing', 'healed', '1', '2', '3', '4') THEN 'Healed'
		 WHEN OUTCOME IS NULL THEN 'Healed'
	     WHEN OUTCOME LIKE '%transf%' THEN 'Transfered'
	     WHEN OUTCOME LIKE '%dead%' THEN 'Dead'
	     WHEN OUTCOME = '0' THEN 'Improving'
	     WHEN OUTCOME = '5000' THEN 'Unknown'
	     ELSE OUTCOME
    END AS OUTCOME,
	TYPE1,
	DIAGCODE,
	CASE
        WHEN Satisfaction = 5 THEN 'Excellent'
        WHEN Satisfaction = 4 THEN 'Very good'
		WHEN Satisfaction = 3 THEN 'Good'
		WHEN Satisfaction = 2 THEN 'Fair'
		WHEN Satisfaction = 1 THEN 'Poor'
        ELSE 'N/A'
    END AS Satisfaction	
FROM (
SELECT	*,
ROW_NUMBER() OVER (PARTITION BY PATIENT_ID ORDER BY BEGINDATE DESC) AS flag_last
FROM bronze.patients) t
WHERE flag_last = 1;

GO

TRUNCATE TABLE silver.bill;
GO

INSERT INTO silver.bill
(
	visit_date,
	Patient_id,
	total_bill,
	patient_cost,
	insurance_cost,
	payment_status
)
SELECT
    visit_date,
	Patient_id,
	CONVERT(INT, total_bill) AS total_bill,
	CONVERT(INT, patient_cost) AS patient_cost,
	CONVERT(INT, insurance_cost) AS insurance_cost,
	payment_status
FROM bronze.bill;

GO

TRUNCATE TABLE silver.medicaments
GO

INSERT INTO silver.medicaments
		(
		    Visit_date,
			prestation,
			INVOICEGROUP,
			quantity,
			unity_price,
			patient_cost,
			insurance_cost,
			department	
		)
		SELECT
		visit_date,
		prestation,
		CASE WHEN INVOICEGROUP LIKE '%MAT%' THEN 'MEDICAL MATERIAL'
					 WHEN INVOICEGROUP LIKE '%MED%' THEN 'MEDICAMENTS'
					 WHEN INVOICEGROUP LIKE '%ACT%' THEN 'ACTES'
					 WHEN INVOICEGROUP LIKE '%DIVER%' THEN 'OTHER'
					 WHEN INVOICEGROUP LIKE '%AUTRE%' THEN 'OTHER'
					 WHEN INVOICEGROUP IS NULL THEN 'OTHER'
					 WHEN INVOICEGROUP LIKE '%ECHO%' THEN 'ECHOGRAPHY'
					 WHEN INVOICEGROUP LIKE '%LAB%' THEN 'LABORATORY'
					 WHEN INVOICEGROUP LIKE '%RADIO%' THEN 'RADIOLOGY'
					 ELSE INVOICEGROUP
				END AS INVOICEGROUP,
				TRY_CONVERT (INT, quantity) AS quantity,
				TRY_CONVERT (INT, unity_price) AS unity_price,
				TRY_CONVERT (INT, patient_cost) AS patient_cost,
				TRY_CONVERT (INT, insurance_cost) AS insurance_cost,
				department
		FROM bronze.medicaments;

TRUNCATE TABLE silver.diagnosis;
GO

INSERT INTO silver.diagnosis
(
	Code,
	Diagnosis
)
SELECT
   Code,
   Diagnosis
FROM bronze.diagnosis;

GO
