/*
===============================================================================
DDL Script: Creates Bronze Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/

-- Create SQL DDL for all needed csv files and develop SQL load scripts
IF OBJECT_ID('bronze.patients', 'U') IS NOT NULL
    DROP TABLE bronze.patients;
GO
  
CREATE TABLE bronze.patients
(
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
);

GO

IF OBJECT_ID('bronze.bill', 'U') IS NOT NULL
    DROP TABLE bronze.bill;
GO

CREATE TABLE bronze.bill (
	visit_date NVARCHAR(20),
	Patient_id NVARCHAR(20),
	total_bill NVARCHAR(20),
	patient_cost NVARCHAR(20),
	insurance_cost NVARCHAR(20),
	payment_status NVARCHAR(30),
);

GO

IF OBJECT_ID('bronze.medicaments', 'U') IS NOT NULL
    DROP TABLE bronze.medicaments;
GO

CREATE TABLE bronze.medicaments (
	visit_date NVARCHAR (20),
	prestation NVARCHAR(350),
	INVOICEGROUP NVARCHAR(100),
	quantity NVARCHAR (20),
	unity_price NVARCHAR (20),
	patient_cost NVARCHAR (20),
	insurance_cost NVARCHAR (20),
	department NVARCHAR(150)
);

GO

IF OBJECT_ID('bronze.diagnosis', 'U') IS NOT NULL
    DROP TABLE bronze.diagnosis;
GO

CREATE TABLE bronze.diagnosis (
	Code NVARCHAR (10),
	Diagnosis NVARCHAR(250)
);

GO
