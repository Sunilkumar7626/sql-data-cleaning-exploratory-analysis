/*
=========================================================
PROJECT: Data Cleaning in SQL
DATASET: Layoffs Dataset
AUTHOR: Your Name
TOOLS USED: MySQL

OBJECTIVE:
Clean raw layoffs data for analysis and visualization by:
1. Removing duplicate records
2. Standardizing inconsistent text values
3. Handling null and blank values
4. Fixing date formats
5. Removing unnecessary rows and columns
=========================================================
*/

-- =====================================================
-- STEP 0: Inspect Raw Data
-- =====================================================

SELECT *
FROM layoffs;


-- =====================================================
-- STEP 1: Create Staging Table
-- (Work on a copy to preserve raw data)
-- =====================================================

CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT INTO layoffs_staging
SELECT *
FROM layoffs;


-- =====================================================
-- STEP 2: Identify Duplicate Records
-- =====================================================

WITH duplicates_cte AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY company,
                            location,
                            industry,
                            total_laid_off,
                            percentage_laid_off,
                            `date`,
                            stage,
                            country,
                            funds_raised_millions
           ) AS row_num
    FROM layoffs_staging
)
SELECT *
FROM duplicates_cte
WHERE row_num > 1;


-- =====================================================
-- STEP 3: Create New Staging Table with Row Numbers
-- =====================================================

CREATE TABLE layoffs_staging2 (
    company TEXT,
    location TEXT,
    industry TEXT,
    total_laid_off INT DEFAULT NULL,
    percentage_laid_off TEXT,
    `date` TEXT,
    stage TEXT,
    country TEXT,
    funds_raised_millions INT DEFAULT NULL,
    row_num INT
);

INSERT INTO layoffs_staging2
SELECT *,
       ROW_NUMBER() OVER (
           PARTITION BY company,
                        location,
                        industry,
                        total_laid_off,
                        percentage_laid_off,
                        `date`,
                        stage,
                        country,
                        funds_raised_millions
       ) AS row_num
FROM layoffs_staging;


-- =====================================================
-- STEP 4: Remove Duplicates
-- =====================================================

DELETE
FROM layoffs_staging2
WHERE row_num > 1;


-- =====================================================
-- STEP 5: Standardize Company Names
-- =====================================================

UPDATE layoffs_staging2
SET company = TRIM(company);


-- =====================================================
-- STEP 6: Standardize Industry Values
-- =====================================================

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY industry;

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';


-- =====================================================
-- STEP 7: Standardize Country Names
-- =====================================================

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY country;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';


-- =====================================================
-- STEP 8: Convert Date Format
-- =====================================================

SELECT `date`,
       STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;


-- =====================================================
-- STEP 9: Handle Blank Industry Values
-- =====================================================

UPDATE layoffs_staging2
SET industry = NULL
WHERE TRIM(industry) = '';


-- =====================================================
-- STEP 10: Fill Missing Industry Values
-- Using self join based on company name
-- =====================================================

SELECT t1.company,
       t1.industry AS missing_industry,
       t2.industry AS existing_industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
     ON t1.company = t2.company
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
     ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;


-- =====================================================
-- STEP 11: Identify Useless Rows
-- Rows with no layoff information
-- =====================================================

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;


-- =====================================================
-- STEP 12: Remove Useless Rows
-- =====================================================

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;


-- =====================================================
-- STEP 13: Drop Helper Column
-- =====================================================

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;


-- =====================================================
-- FINAL CLEANED DATASET
-- =====================================================

SELECT *
FROM layoffs_staging2;
