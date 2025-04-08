/*
=========================================================

   DATA QUALITY, TRANSFORMATION & CLEANSING

=========================================================
*/

/*
=========================================================

   CRM Customer Info Table

=========================================================
*/


/*-------------------------------------------------------
   BEFORE TRANSFORMATION
--------------------------------------------------------*/

-- Check for nulls or duplicates in the Primary Key
-- Expectation: No result returned if data is clean

-- Retrieve the customer info table
SELECT TOP 10 *
FROM bronze.crm_cust_info;

-- Check for duplicates or NULL primary key values
SELECT cst_id, COUNT (*)
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Starting with few random checks, for issues
-- Verify the newest record for a specific customer (e.g., cst_id = 29466), notice the cst_create_date
SELECT *
FROM bronze.crm_cust_info
WHERE cst_id = 29466;

/*
=========================================================
   ISSUE: DUPLICATE PRIMARY KEY
=========================================================
*/

/*-------------------------------------------------------
   WINDOW FUNCTION APPROACH
--------------------------------------------------------*/

-- Use ROW_NUMBER with a WINDOW function to sort the records
-- and flag the latest record with flag_last = 1 for each cst_id
SELECT *,
ROW_NUMBER() OVER (PARTITION BY cst_id 
                   ORDER BY cst_create_date DESC) as flag_last
FROM bronze.crm_cust_info

-- Identify the records that should be deleted (duplicates where flag_last != 1)
SELECT *
  FROM (
    SELECT *,
    ROW_NUMBER() OVER (PARTITION BY cst_id 
                      ORDER BY cst_create_date DESC) as flag_last
    FROM bronze.crm_cust_info
  )t
WHERE flag_last != 1

-- Retrieve the records with no duplicates (only the latest record per cst_id, flag_last = 1)
SELECT *
  FROM (
    SELECT *,
    ROW_NUMBER() OVER (PARTITION BY cst_id 
                       ORDER BY cst_create_date DESC) as flag_last
    FROM bronze.crm_cust_info
  )t
WHERE flag_last = 1

/*-------------------------------------------------------
   Common Table Expression (CTE) APPROACH
--------------------------------------------------------*/

/* 
   Use a CTE to assign a row number (rn) for each record within the same cst_id partition,
   ordering by the creation date in descending order. 
   This flags the newest record as rn = 1.
*/

WITH RankedCust AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY cst_id 
                              ORDER BY cst_create_date DESC) AS rn
    FROM bronze.crm_cust_info
)
SELECT *
FROM RankedCust;

-- Identify records that should be deleted (duplicates, where rn is not 1)
WITH RankedCust AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY cst_id 
                              ORDER BY cst_create_date DESC) AS rn
    FROM bronze.crm_cust_info
)
SELECT *
FROM RankedCust
WHERE rn <> 1;

-- Retrieve de-duplicated records (only the newest record per cst_id)
WITH RankedCust AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY cst_id 
                              ORDER BY cst_create_date DESC) AS rn
    FROM bronze.crm_cust_info
)
SELECT *
FROM RankedCust
WHERE rn = 1;

/*
=========================================================
   ISSUE: UNWANTED SPACES IN STRING
=========================================================
*/

-- Verify that there are no leading or trailing spaces in the column
-- Expectation: No result returned if data is clean 
-- Change the columnname as per the string columns in the table & check
SELECT cst_firstname
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

-- Clean the first and last name fields by removing unwanted spaces.
-- Only the latest record for each customer (flag_last = 1) is considered.
SELECT 
   cst_id, 
   cst_key,
   TRIM (cst_firstname) AS cst_firstname,
   TRIM (cst_lastname) AS cst_lastname,
   cst_marital_status, 
   cst_gndr, 
   cst_create_date
FROM (
   SELECT *,
      ROW_NUMBER() OVER (PARTITION BY cst_id
                         ORDER BY cst_create_date DESC) as flag_last
   FROM bronze.crm_cust_info
   )t
WHERE flag_last = 1;

/*
=========================================================
   ISSUE: CHECK FOR CONSISTANCY
=========================================================
*/

-- Inspect distinct gender values to review current data consistency.
SELECT DISTINCT cst_gndr
FROM bronze.crm_cust_info;

-- Standardize gender and marital status values:
--   - Change 'F' to 'Female' and 'M' to 'Male' for gender.
--   - Change 'S' to 'Single' and 'M' to 'Married' for marital status.
-- Uses TRIM and UPPER to eliminate discrepancies due to casing or extra spaces.
SELECT 
   cst_id, 
   cst_key,
   TRIM (cst_firstname) AS cst_firstname,
   TRIM (cst_lastname) AS cst_lastname,
   CASE 
      WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single' 
      WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married' 
      ELSE 'n/a'
   END cst_marital_status,
   CASE 
      WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female' 
      WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male' 
      ELSE 'n/a'
   END cst_gndr,
   cst_create_date
FROM (
   SELECT *,
      ROW_NUMBER() OVER (PARTITION BY cst_id
                         ORDER BY cst_create_date DESC) as flag_last
   FROM bronze.crm_cust_info
   )t
WHERE flag_last = 1;

/*
=========================================================
   INSERT CLEAN DATA TO SILVER LAYER
=========================================================
*/

-- Insert the cleaned and standardized records into the silver layer.
-- This step includes:
--   - Trimming spaces from first and last names.
--   - Converting marital status and gender codes into descriptive values.
-- Only the latest record per customer (flag_last = 1) is inserted.

INSERT INTO silver.crm_cust_info (
   cst_id,
   cst_key,
   cst_firstname,
   cst_lastname,
   cst_marital_status,
   cst_gndr,
   cst_create_date
)
SELECT 
   cust_id, 
   cst_key,
   TRIM (cst_firstname) AS cst_firstname,
   TRIM (cst_lastname) AS cst_lastname,
   CASE 
      WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
      WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
      ELSE 'n/a'
   END cst_marital_status,
   CASE 
      WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female' 
      WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male' 
      ELSE 'n/a'
   END cst_gndr,
   cst_create_date
FROM (
   SELECT *,
      ROW_NUMBER() OVER (PARTITION BY cst_id
                        ORDER BY cst_create_date DESC) as flag_last
   FROM bronze.crm_cust_info
   )t
WHERE flag_last = 1;

/*
=========================================================
   AFTER TRANSFORMATION
=========================================================
*/

-- Validate data in the silver layer by checking for duplicates or NULL primary key values.
-- Expectation: No rows should be returned if the data is clean.

-- Check for duplicates or NULL primary key values
SELECT cst_id, COUNT (*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Confirm that the latest record for a specific customer (e.g., cst_id = 29466) has been correctly transformed.
SELECT *
FROM silver.crm_cust_info
WHERE cst_id = 29466;


/*
=========================================================

   CRM PRODUCT INFO TABLE

=========================================================
*/



SELECT prd_id, COUNT (*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;