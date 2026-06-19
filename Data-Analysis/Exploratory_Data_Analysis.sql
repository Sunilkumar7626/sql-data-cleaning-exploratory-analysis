# Exploratory Data Analysis (EDA) of Global Layoffs Dataset Using SQL

## Project Overview

# This project performs Exploratory Data Analysis (EDA) on a cleaned layoffs dataset using MySQL. The objective is to uncover trends related to company layoffs, industries affected, yearly patterns, funding levels, and ranking companies based on layoffs.

#  Dataset Table Used: layoffs_staging3


---

# 1. Initial Data Exploration

### View Dataset

SELECT *
FROM layoffs_staging3;


### Find Maximum Layoffs and Layoff Percentage


SELECT
    MAX(total_laid_off) AS max_laid_off,
    MAX(percentage_laid_off) AS max_percentage_laid_off
FROM layoffs_staging3;


---

# 2. Companies with 100% Workforce Layoffs

### Sort by Number of Employees Laid Off


SELECT *
FROM layoffs_staging3
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;


### Sort by Funding Raised


SELECT *
FROM layoffs_staging3
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;


---

# 3. Duplicate Row Removal

### Create Temporary Table with Row Numbers


CREATE TABLE layoffs_staging3 AS
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
FROM layoffs_staging2;


### Identify Duplicate Records


SELECT *
FROM layoffs_staging3
WHERE row_num > 1;


### Delete Duplicate Records


DELETE
FROM layoffs_staging3
WHERE row_num > 1;


### Remove Helper Column


ALTER TABLE layoffs_staging3
DROP COLUMN row_num;


---

# 4. Total Layoffs by Company

### Which Companies Laid Off the Most Employees?


SELECT
    company,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging3
GROUP BY company
ORDER BY total_layoffs DESC;


---

# 5. Date Range of Dataset


SELECT
    MIN(`date`) AS earliest_date,
    MAX(`date`) AS latest_date
FROM layoffs_staging3;

---

# 6. Total Layoffs by Industry


SELECT
    industry,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging3
GROUP BY industry
ORDER BY total_layoffs DESC;


---

# 7. Daily Layoff Trends


SELECT
    `date`,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging3
GROUP BY `date`
ORDER BY `date` DESC;


---

# 8. Yearly Layoff Trends


SELECT
    YEAR(`date`) AS layoff_year,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging3
GROUP BY layoff_year
ORDER BY layoff_year;


---

# 9. Layoffs by Company Stage


SELECT
    stage,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging3
GROUP BY stage
ORDER BY total_layoffs DESC;


---

# 10. Average Layoff Percentage by Company


SELECT
    company,
    AVG(percentage_laid_off) AS avg_layoff_percentage
FROM layoffs_staging3
GROUP BY company
ORDER BY avg_layoff_percentage DESC;

---

# 11. Monthly Layoff Trends

### Total Layoffs Per Month


SELECT
    DATE_FORMAT(`date`, '%Y-%m') AS month_date,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging3
WHERE `date` IS NOT NULL
GROUP BY month_date
ORDER BY month_date;

---

# 12. Rolling (Cumulative) Layoff Total


WITH Monthly_Layoffs AS
(
    SELECT
        DATE_FORMAT(`date`, '%Y-%m') AS month_date,
        SUM(total_laid_off) AS total_layoffs
    FROM layoffs_staging3
    WHERE `date` IS NOT NULL
    GROUP BY month_date
)

SELECT
    month_date,
    total_layoffs,
    SUM(total_layoffs)
        OVER (ORDER BY month_date) AS rolling_total
FROM Monthly_Layoffs;


---

# 13. Company Layoffs by Year


SELECT
    company,
    YEAR(`date`) AS layoff_year,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging3
GROUP BY company, layoff_year
ORDER BY company;


---

# 14. Ranking Companies by Layoffs Each Year

### Top Companies Responsible for the Most Layoffs Per Year


WITH Company_Year AS
(
    SELECT
        company,
        YEAR(`date`) AS layoff_year,
        SUM(total_laid_off) AS total_layoffs
    FROM layoffs_staging3
    GROUP BY company, layoff_year
),

Company_Year_Rank AS
(
    SELECT *,
           DENSE_RANK() OVER (
               PARTITION BY layoff_year
               ORDER BY total_layoffs DESC
           ) AS ranking
    FROM Company_Year
    WHERE layoff_year IS NOT NULL
)

SELECT *
FROM Company_Year_Rank
WHERE ranking <= 5
ORDER BY layoff_year, ranking;


---

# Key Business Questions Answered

#1. Which companies laid off the most employees?
#2. Which industries were impacted the most?
#3. Which startup stages experienced the largest workforce reductions?
#4. How did layoffs evolve over time?
#5. What months experienced the highest layoffs?
#6. Which companies completely shut down operations (100% layoffs)?
#7. Which companies ranked among the top layoff contributors each year?
#8. What is the cumulative trend of layoffs throughout the dataset period?

---

# Skills Demonstrated

#Data Cleaning
# Duplicate Removal
# Common Table Expressions (CTEs)
#Window Functions
# DENSE_RANK()
# ROW_NUMBER()
# Aggregate Functions
# Date Manipulation
#  Trend Analysis
# Rolling Totals
#  Business Intelligence Reporting
#  Exploratory Data Analysis (EDA)
#  MySQL

