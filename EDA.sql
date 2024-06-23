SELECT *
FROM layoffs_staging2;

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

-- Companies that laid off all their employees
SELECT * 
FROM layoffs_staging2
WHERE percentage_laid_off=1;

-- Companies that laid off all their employees in India
SELECT * 
FROM layoffs_staging2
WHERE percentage_laid_off=1 and country="India";

-- Companies that laid off all their employees in India ordered by their fundings
SELECT * 
FROM layoffs_staging2
WHERE percentage_laid_off=1
ORDER BY funds_raised_millions desc;

SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Dates ranges from March 2020 to March 2023, that is when the pandemic started 
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- We can observe that USA, India and Netherlands have had the highest lay offs
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY YEAR(`date`) DESC;

SELECT company, AVG(percentage_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Rolling sum of the layoffs for each month of the year from 2020 to 2023
WITH rollingSumTotal AS
(
SELECT substring(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off) AS sumTotal
FROM layoffs_staging2
WHERE substring(`date`, 1, 7) IS NOT NULL
GROUP BY `MONTH`
)
SELECT `MONTH`, sumTotal,
SUM(sumTotal) OVER(ORDER BY `MONTH`) AS rollingSum
FROM rollingSumTotal;

-- Ranking the companies as per their total laid off, for each year
-- Here I have queried the top 5 companies for each company
WITH companyYear(company, years, sumTotal) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), companyYearRank AS
(SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY sumTotal DESC) AS companyRank
FROM companyYear
WHERE years IS NOT NULL
)
SELECT * FROM companyYearRank
WHERE companyRank<=5;


