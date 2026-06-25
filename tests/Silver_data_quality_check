/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy, 
    and standardization across the 'silver' layer. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields.

Usage Notes:
    - Run these checks after data loading Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

-- ====================================================================
-- Checking 'silver.patients'
-- ====================================================================
-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT 
    PATIENT_ID,
    COUNT(*) 
FROM silver.patients
GROUP BY PATIENT_ID
HAVING COUNT(*) > 1 OR PATIENT_ID IS NULL;

-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT 
    CODE_SERVICE 
FROM silver.patients
WHERE CODE_SERVICE  != TRIM(CODE_SERVICE );

-- Data Standardization & Consistency
SELECT DISTINCT 
    GENDER
FROM silver.patients;

-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT 
    * 
FROM silver.patients
WHERE DISTRICT != TRIM(DISTRICT) 
   OR INSURER != TRIM(INSURER) 
   OR TYPE1 != TRIM(TYPE1);

-- Check for Invalid Date (ENDDATE > BEGINDATE)
-- Expectation: No Results
SELECT 
    * 
FROM silver.patients
WHERE ENDDATE < BEGINDATE;

-- Check for Invalid Dates
-- Expectation: No Invalid Dates
SELECT 
    NULLIF(BEGINDATE, 0) AS BEGINDATE
FROM silver.patients
WHERE BEGINDATE <= 0 
    OR LEN(BEGINDATE) != 10;

-- Check for Invalid Dates
-- Expectation: No Invalid Dates
SELECT 
    NULLIF(ENDDATE, 0) AS ENDDATE
FROM silver.patients
WHERE ENDDATE <= 0 
    OR LEN(ENDDATE) != 10;

-- Identify Out-of-Range Dates
-- Expectation: Birthdates between 1924-01-01 and Today
SELECT DISTINCT 
    MONTH_OF_BIRTH
FROM silver.patients
WHERE MONTH_OF_BIRTH < '1924-01-01' 
   OR MONTH_OF_BIRTH > GETDATE();

-- ====================================================================
-- Checking 'silver.bill'
-- ====================================================================
-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT 
    Patient_id,
    COUNT(*) 
FROM silver.bill
GROUP BY Patient_id
HAVING COUNT(*) > 1 OR Patient_id IS NULL;

-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT 
    payment_status
FROM silver.bill
WHERE payment_status != TRIM(payment_status);

-- Check for NULLs or Negative Values in total_bill
-- Expectation: No Results
SELECT 
    total_bill
FROM silver.bill
WHERE  total_bill < 0 OR  total_bill IS NULL;

-- Check for Invalid Dates
-- Expectation: No Invalid Dates
SELECT 
    NULLIF(visit_date, 0) AS visit_date 
FROM silver.bill
WHERE visit_date <= 0 
    OR LEN(visit_date) != 10 
    OR visit_date > 20500101 
    OR visit_date < 19000101;

-- Check Data Consistency: insurance_cost = total_bill - patient_cost
-- Expectation: No Results
SELECT DISTINCT 
    total_bill,
    patient_cost,
    insurance_cost 
FROM silver.bill
WHERE insurance_cost != total_bill - patient_cost
   OR insurance_cost IS NULL 
   OR total_bill <= 0 
   OR patient_cost <= 0
   OR insurance_cost < 0 
ORDER BY total_bill, patient_cost, insurance_cost;

-- Identify Out-of-Range Dates
-- Expectation: Birthdates between 1924-01-01 and Today
SELECT DISTINCT 
    visit_date 
FROM silver.bill
WHERE visit_date > '1926-01-01' 
   OR visit_date > GETDATE();

-- ====================================================================
-- Checking 'silver.medicaments'
-- ====================================================================

-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT 
    * 
FROM silver.medicaments
WHERE prestation != TRIM(prestation) 
   OR INVOICEGROUP != TRIM(INVOICEGROUP) 
   OR department != TRIM(department);

-- Data Standardization & Consistency
SELECT DISTINCT 
    INVOICEGROUP 
FROM silver.medicaments;

-- Check for Invalid Dates
-- Expectation: No Invalid Dates
SELECT 
    NULLIF(visit_date, 0) AS visit_date
FROM silver.medicaments
WHERE visit_date <= 0 
    OR LEN(visit_date) != 8;

-- Check Data Consistency: Sales = Quantity * Price
-- Expectation: No Results
SELECT DISTINCT 
    quantity,
    unity_price,
    total_price,
	  patient_cost,
	  insurance_cost
FROM silver.medicaments
WHERE total_price != quantity * unity_price
   OR total_price IS NULL 
   OR quantity IS NULL 
   OR unity_price IS NULL
   OR total_price < 0 
   OR insurance_cost != total_price - patient_cost
   OR insurance_cost IS NULL 
   OR patient_cost < 0
   OR insurance_cost < 0 
ORDER BY quantity, unity_price, total_price;

-- Identify Out-of-Range Dates
-- Expectation: visit_date between 2026-01-01 and Today 2025-01-01
SELECT DISTINCT 
    visit_date 
FROM silver.medicaments
WHERE visit_date < '2025-01-01' 
   OR visit_date > '2026-01-01';
