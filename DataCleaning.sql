SELECT * FROM layoffs;

-- Creating a copy of the raw data
CREATE TABLE layoffs_staging LIKE layoffs;

SELECT * FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;

-- 1] Removing Duplicates
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL, 
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER( 
PARTITION BY 
company, location, industry, total_laid_off, percentage_laid_off, 
`date`, stage, country, funds_raised_millions) AS row_no
FROM layoffs_staging;

SELECT * FROM layoffs_staging2 WHERE row_num > 1;

DELETE FROM layoffs_staging2 WHERE row_num > 1;

-- 2] Standardizing the data

-- Trimming whitespaces
SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = trim(company);

-- Setting Crypto and Cryptocurrency industry as Crypto
SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Setting distinct countries 
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
WHERE country LIKE 'United States%';

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- Updating the data type of 'date' column as date type
SELECT `date`
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2 
MODIFY COLUMN `date` DATE; 

describe layoffs_staging2;

-- 3] Handling null values or blank values

-- handling industry null or blank values
SELECT DISTINCT industry 
FROM layoffs_staging2
WHERE industry IS NULL 
OR industry='';

SELECT lt1.industry, lt2.industry
FROM layoffs_staging2 lt1
JOIN layoffs_staging2 lt2
	ON lt1.company = lt2.company
	AND lt1.location = lt2.location
WHERE (lt1.industry IS NULL)
AND (lt2.industry IS NOT NULL);

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

UPDATE layoffs_staging2 lt1
JOIN layoffs_staging2 lt2
	ON lt1.company = lt2.company
SET lt1.industry = lt2.industry
WHERE lt1.industry IS NULL
AND lt2.industry IS NOT NULL;

-- deleting data where total_laid_off and percentage_laid_off are null
SELECT * FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL; 

DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL; 

-- deleting the row_num column
SELECT * FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;
