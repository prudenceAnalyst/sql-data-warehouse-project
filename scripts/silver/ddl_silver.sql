/*
===============================================================================
DDL Script: Create Silver Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'silver' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/

IF OBJECT_ID('silver.patients', 'U') IS NOT NULL
    DROP TABLE silver.patients;
GO

CREATE TABLE silver.patients (
	PATIENT_ID NVARCHAR (20),
	CODE_SERVICE NVARCHAR (20),
	GENDER NVARCHAR (30),
	MONTH_OF_BIRTH NVARCHAR (30),
	DISTRICT NVARCHAR (250),
	BEGINDATE NVARCHAR (20),
	ENDDATE NVARCHAR (20),
	INSURER NVARCHAR (250),
	OUTCOME NVARCHAR (50),
	TYPE1 NVARCHAR (50),
	DIAGCODE NVARCHAR (250),
	Satisfaction NVARCHAR (20),
	dwh_create_date DATETIME DEFAULT GETDATE()
);
GO

IF OBJECT_ID('silver.bill', 'U') IS NOT NULL
    DROP TABLE silver.bill;
GO

CREATE TABLE silver.bill (
	visit_date NVARCHAR(20),
	Patient_id NVARCHAR(20),
	total_bill NVARCHAR(20),
	patient_cost NVARCHAR(20),
	insurance_cost NVARCHAR(20),
	payment_status NVARCHAR(30),
	dwh_create_date DATETIME DEFAULT GETDATE()
);
GO

SELECT * FROM silver.bill;

IF OBJECT_ID('silver.medicaments', 'U') IS NOT NULL
    DROP TABLE silver.medicaments;
GO

CREATE TABLE silver.medicaments (
	visit_date NVARCHAR (20),
	prestation NVARCHAR(350),
	INVOICEGROUP NVARCHAR(100),
	quantity NVARCHAR (20),
	unity_price NVARCHAR (20),
	total_price NVARCHAR (20),
	patient_cost NVARCHAR (20),
	insurance_cost NVARCHAR (20),
	department NVARCHAR(150),
	dwh_create_date DATETIME DEFAULT GETDATE()
);
GO

IF OBJECT_ID('silver.diagnosis', 'U') IS NOT NULL
    DROP TABLE silver.diagnosis;
GO

CREATE TABLE silver.diagnosis (
    Code NVARCHAR (10),
	Diagnosis NVARCHAR(250),
	dwh_create_date DATETIME DEFAULT GETDATE()
);
GO
