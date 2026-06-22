/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/

-- =============================================================================
-- Create Dimension: gold.dim_patients
-- =============================================================================

IF OBJECT_ID('gold.dim_patients') IS NOT NULL
    DROP VIEW gold.dim_patients;
GO

CREATE VIEW gold.dim_patients AS
SELECT
    p.PATIENT_ID AS patient_id,
	p.DIAGCODE AS Diagnostic_code,
	p.CODE_SERVICE AS service_code,
	p.GENDER as Gender,
	p.MONTH_OF_BIRTH AS date_of_birth,
	DATEDIFF(YEAR, MONTH_OF_BIRTH,  BEGINDATE) AS actual_age,
	CASE WHEN DATEDIFF(YEAR, MONTH_OF_BIRTH,  BEGINDATE) < 5 THEN 'under 5'
		 WHEN DATEDIFF(YEAR, MONTH_OF_BIRTH,  BEGINDATE) BETWEEN 5 AND 9 THEN '5 - 9'
		 WHEN DATEDIFF(YEAR, MONTH_OF_BIRTH,  BEGINDATE) BETWEEN 10 AND 14 THEN '10 - 14'
		 WHEN DATEDIFF(YEAR, MONTH_OF_BIRTH,  BEGINDATE) BETWEEN 15 AND 17 THEN '15 - 17'
		 WHEN DATEDIFF(YEAR, MONTH_OF_BIRTH,  BEGINDATE) BETWEEN 18 AND 19 THEN '18 - 19'
		 WHEN DATEDIFF(YEAR, MONTH_OF_BIRTH,  BEGINDATE) BETWEEN 20 AND 24 THEN '20 - 24'
		 WHEN DATEDIFF(YEAR, MONTH_OF_BIRTH,  BEGINDATE) BETWEEN 25 AND 29 THEN '25 - 29'
		 WHEN DATEDIFF(YEAR, MONTH_OF_BIRTH,  BEGINDATE) BETWEEN 30 AND 34 THEN '30 - 34'
		 WHEN DATEDIFF(YEAR, MONTH_OF_BIRTH,  BEGINDATE) BETWEEN 35 AND 39 THEN '35 - 39'
		 WHEN DATEDIFF(YEAR, MONTH_OF_BIRTH,  BEGINDATE) BETWEEN 40 AND 44 THEN '40 - 44'
		 WHEN DATEDIFF(YEAR, MONTH_OF_BIRTH,  BEGINDATE) BETWEEN 45 AND 49 THEN '45 - 49'
		 WHEN DATEDIFF(YEAR, MONTH_OF_BIRTH,  BEGINDATE) BETWEEN 50 AND 54 THEN '50 - 54'
		 WHEN DATEDIFF(YEAR, MONTH_OF_BIRTH,  BEGINDATE) BETWEEN 55 AND 59 THEN '55 - 59'
		 WHEN DATEDIFF(YEAR, MONTH_OF_BIRTH,  BEGINDATE) BETWEEN 60 AND 64 THEN '60 - 64'
		 WHEN DATEDIFF(YEAR, MONTH_OF_BIRTH,  BEGINDATE) BETWEEN 65 AND 70 THEN '65 - 70'
		 WHEN DATEDIFF(YEAR, MONTH_OF_BIRTH,  BEGINDATE) >=70 THEN '>=70'
	ELSE 'unknown'
	END AS age_range,
	p.DISTRICT AS Patient_adrress,
	p.BEGINDATE AS registration_date,
	p.ENDDATE AS discharge_date,
	DATEDIFF (DAY, BEGINDATE, ENDDATE) AS length_of_stay,
	CASE
		WHEN DATEDIFF (DAY, BEGINDATE, ENDDATE) = 0 THEN 'Same day'
		WHEN DATEDIFF (DAY, BEGINDATE, ENDDATE) BETWEEN 1 AND 2 THEN 'Short'
		WHEN DATEDIFF (DAY, BEGINDATE, ENDDATE) BETWEEN 3 AND 5 THEN 'Average'
		WHEN DATEDIFF (DAY, BEGINDATE, ENDDATE) BETWEEN 6 AND 10 THEN 'Long'
		WHEN DATEDIFF (DAY, BEGINDATE, ENDDATE) > 10 THEN 'Extended'
	ELSE null
	END AS Stay_segment,
	p.INSURER AS insurance_provider,
	d.Diagnosis AS Diagnosis,
	p.OUTCOME AS patient_outcome,
	p.Satisfaction
FROM silver.patients p
LEFT JOIN silver.diagnosis d
ON p.DIAGCODE = d.Code;
 
GO

-- =============================================================================
-- Create Fact Table: gold.fact_bills
-- =============================================================================

IF OBJECT_ID('gold.fact_bills') IS NOT NULL
    DROP VIEW gold.fact_bills;
GO

CREATE VIEW gold.fact_bills AS
SELECT
   visit_date AS registration_date,
   Patient_id,
   total_bill,
   patient_cost AS patient_bill,
   insurance_cost AS insurance_bill,
   payment_status
FROM silver.bill;

GO

-- =============================================================================
-- Create Dimension: gold.fact_medicaments
-- =============================================================================

IF OBJECT_ID('gold.fact_medicaments') IS NOT NULL
    DROP VIEW gold.fact_medicaments;
GO

CREATE VIEW gold.fact_medicaments AS
SELECT
   visit_date,
   prestation,
   CASE
        WHEN INVOICEGROUP IS NULL 
             AND PRESTATION LIKE '%COMPRESSE%'
            THEN 'MEDICAL MATERIAL'
        ELSE INVOICEGROUP
       END AS category,
   quantity,
   unity_price,
   patient_cost,
   insurance_cost,
   department
FROM silver.medicaments;

GO

-- =============================================================================
-- Create Fact Table: gold.dim_diagnosis
-- =============================================================================
IF OBJECT_ID('gold.dim_diagnosis') IS NOT NULL
    DROP VIEW gold.dim_diagnosis;
GO

CREATE VIEW gold.dim_diagnosis AS
SELECT
   Code,
   Diagnosis
FROM silver.diagnosis;
GO
