/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'DWH_ERP_CRM' after checking if it already exists. 
    If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas 
    within the database: 'bronze', 'silver', and 'gold'.
	
WARNING:
    Running this script will drop the entire 'DWH_ERP_CRM' database if it exists. 
    All data in the database will be permanently deleted. Proceed with caution 
    and ensure you have proper backups before running this script.
*/

USE master;
GO

-- Drop and recreate the 'DWH_ERP_CRM' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DWH_ERP_CRM')
BEGIN
    ALTER DATABASE DWH_ERP_CRM SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DWH_ERP_CRM;
END;
GO

-- Create the 'DWH_ERP_CRM' database
CREATE DATABASE DWH_ERP_CRM;
GO

USE DWH_ERP_CRM;
GO

-- Create Schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO