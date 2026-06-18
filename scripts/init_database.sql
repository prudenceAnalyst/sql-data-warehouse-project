/*
=============================================================
Create Database and Schemas
=============================================================
Script purpose:
	This script create new Database called 'health' after cheking if it already exists. 
	If the Database exists, it is dropped and recreated. Additionally, the script creates three Schemas
	within the Database: 'bronze', 'silver', and 'gold'.

WARNING:
	Running this script will drop the entire 'health' database if it exists.
	All data in the Database will be permanently deleted. Proceed with caution 
	and ensure you have proper back up before running this scripts
*/

USE master;
GO

--Drop and recreate the 'health' Database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'health')
BEGIN
	ALTER DATABASE health SET single_user WITH ROLLBACK IMMEDIATE;
	DROP DATABASE health;
END;

GO

-- Create the 'health' database
CREATE DATABASE health;
GO

USE health;
GO

-- Create Schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
