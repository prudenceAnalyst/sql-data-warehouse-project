/*
===============================================================================
This script loads Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This script loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.
===============================================================================
*/

TRUNCATE TABLE bronze.patients
BULK INSERT bronze.patients
FROM 'C:\Users\ZEBRA\Desktop\project_data\health\csv_patients.csv'
WITH 
(
FIRSTROW = 2,
FIELDTERMINATOR = ','
);

GO

TRUNCATE TABLE bronze.bill
BULK INSERT bronze.bill
FROM 'C:\Users\ZEBRA\Desktop\project_data\health\csv_bill.csv'
WITH 
(
FIRSTROW = 2,
FIELDTERMINATOR = ','
);

GO

TRUNCATE TABLE bronze.medicaments
BULK INSERT bronze.medicaments
FROM 'C:\Users\ZEBRA\Desktop\project_data\health\cvs_medicaments.csv'
WITH 
(
FIRSTROW = 2,
FIELDTERMINATOR = ','
);

TRUNCATE TABLE bronze.diagnosis
BULK INSERT bronze.diagnosis
FROM 'C:\Users\ZEBRA\Desktop\project_data\MyBusinessAnalytics\diagnosis_code.csv'
WITH 
(
FIRSTROW = 2,
FIELDTERMINATOR = ','
);

