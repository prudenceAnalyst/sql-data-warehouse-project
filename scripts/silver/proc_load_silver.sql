/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Silver.load_silver;
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME; 
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '================================================';
        PRINT 'Loading Silver Layer';
        PRINT '================================================';

		-- Loading silver.patients
        SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.patients';
		TRUNCATE TABLE silver.patients;
		PRINT '>> Inserting Data Into: silver.patients';
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
	TRY_CONVERT(DATE, MONTH_OF_BIRTH, 103) AS BIRTHDATE,
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

		SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

		-- Loading silver.bill
        SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.bill';
		TRUNCATE TABLE silver.bill;
		PRINT '>> Inserting Data Into: silver.bill';
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

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

-- Loading silver.medicaments
        SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.medicaments';
		TRUNCATE TABLE silver.medicaments;
		PRINT '>> Inserting Data Into: silver.medicaments';
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
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';


        -- Loading silver.diagnosis
        SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.diagnosis';
		TRUNCATE TABLE silver.diagnosis;
		PRINT '>> Inserting Data Into: silver.diagnosis';

  INSERT INTO silver.diagnosis
		(
			Code,
			Diagnosis
		)
 SELECT
	   Code,
	   Diagnosis
FROM bronze.diagnosis;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

		SET @batch_end_time = GETDATE();
		PRINT '=========================================='
		PRINT 'Loading Silver Layer is Completed';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '=========================================='
		
	END TRY
	BEGIN CATCH
		PRINT '=========================================='
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '=========================================='
	END CATCH
END
