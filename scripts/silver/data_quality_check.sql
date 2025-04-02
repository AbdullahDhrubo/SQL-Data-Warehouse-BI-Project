/*-------------------------------------------------------
   BEFORE TRANSFORMATION
--------------------------------------------------------*/

-- Check for nulls or duplicates in the Primary Key
-- Expectation: No result returned if data is clean

-- Retrieve the customer info table
SELECT *
FROM bronze.crm_cust_info
LIMIT 100;

-- Retrive the count of the primary key using GROUP BY
SELECT cst_id, COUNT (*)
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

/*-------------------------------------------------------
   DATA TRANSFORMATION & CLEANSING
--------------------------------------------------------*/

-- Starting with few random checks, for issues
-- Verify the newest record for a specific customer (e.g., cst_id = 29466), notice the cst_create_date
SELECT *
FROM bronze.crm_cust_info
WHERE cst_id = 29466;

/*-------------------------------------------------------
   WINDOW FUNCTION IMPLEMENTATION
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
   Common Table Expression (CTE) IMPLEMENTATION
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

-- Identify records that should be deleted (duplicates, where rn is not 1)
SELECT *
FROM RankedCust
WHERE rn <> 1;

-- Retrieve de-duplicated records (only the newest record per cst_id)
SELECT *
FROM RankedCust
WHERE rn = 1;

-- Check for unwanted spaces in STRING values
