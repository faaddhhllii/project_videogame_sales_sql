SELECT * FROM game_sales gs ;

-- Preprocessing data

-- checking column title
SELECT 
	*
FROM game_sales gs 
WHERE title IS NULL OR title = '';

-- checking column console
SELECT 
	*
FROM game_sales gs 
WHERE console IS NULL OR console = '';

-- checking column genre
SELECT 
	*
FROM game_sales gs 
WHERE genre IS NULL OR genre = '';

-- checking column publisher
SELECT 
	*
FROM game_sales gs 
WHERE publisher IS NULL OR publisher = '' OR publisher = 'Unknown';

-- checking column developer and handling missing values
SELECT 
	*
FROM game_sales gs 
WHERE developer IS NULL OR developer = '';

DELETE FROM game_sales 
WHERE developer = '';

-- checking column critic_score and handling missing VALUES 
SELECT 
	*
FROM game_sales gs 
WHERE critic_score IS NULL;

UPDATE game_sales 
SET critic_score = 0
WHERE critic_score IS NULL;

-- checking column na_sales and handling missing values
SELECT 
	*
FROM game_sales 
WHERE na_sales IS NULL;

UPDATE game_sales 
SET na_sales = 0
WHERE na_sales IS NULL;

-- checking column jp_sales and handle missing values
SELECT 
	*
FROM game_sales gs 
WHERE jp_sales IS NULL;

UPDATE game_sales 
SET jp_sales = 0
WHERE jp_sales IS NULL;

-- checking column pal_sales and handling missing values
SELECT 
	*
FROM game_sales gs 
WHERE pal_sales IS NULL;

UPDATE game_sales 
SET pal_sales = 0
WHERE pal_sales IS NULL;

-- checking column other sales and handling missing VALUES 
SELECT 
	*
FROM game_sales gs 
WHERE other_sales IS NULL;

UPDATE game_sales 
SET other_sales = 0
WHERE other_sales IS NULL;

-- checking column total sales and handling missing values 
SELECT 
	*
FROM game_sales gs 
WHERE total_sales IS NULL;

DELETE FROM game_sales 
WHERE total_sales IS NULL;

-- checking release date and handling missing VALUES 
SELECT 
	*
FROM game_sales gs 
WHERE release_date IS NULL;

DELETE FROM game_sales 
WHERE release_date IS NULL;

-- checking last upfate and handling missing values 
SELECT 
	*
FROM game_sales gs 
WHERE last_update IS NULL;

UPDATE game_sales 
SET last_update = release_date 
WHERE last_update IS NULL;

-- checking duplicate data
SELECT *, COUNT(*) AS duplicate_count
FROM game_sales
GROUP BY img, title, console, genre, publisher, developer, critic_score, 
         total_sales, na_sales, jp_sales, pal_sales, other_sales, 
         release_date, last_update
HAVING COUNT(*) > 1;

-- Data analysis
-- 1. what are the 10 games with the highest total sales
SELECT 
	*
FROM game_sales gs 
GROUP BY title, total_sales 
ORDER BY total_sales DESC 
LIMIT 10;

-- 2. the game genre that has the highest sales
SELECT 
	genre ,
	ROUND(SUM(total_sales), 2) AS total_sales
FROM game_sales gs 
GROUP BY genre  
ORDER BY 2 DESC;

-- 3. Which console platform has the highest total sales
SELECT 
	console,
	COUNT(*) AS total
FROM game_sales gs
GROUP BY 1
ORDER BY 2 DESC;

-- 4. What games are the best sellers in each genre
WITH ranking_game AS
(
SELECT 
	title,
	genre,
	total_sales ,
	RANK() OVER(PARTITION BY genre ORDER BY total_sales DESC) AS ranking
FROM game_sales gs
)
SELECT
	*
FROM ranking_game
WHERE ranking = 1
ORDER BY 3 DESC;

-- 5. Game sales trends from year to year
SELECT 
	YEAR (release_date) AS release_year,
	ROUND(SUM(total_sales), 2) AS total_sales
FROM game_sales gs 
GROUP BY 1
ORDER BY 1 ASC;

-- 6. In which regions do video games sell better (North American, Japanese, Europe/Africa, Other)?
SELECT 'North American' AS region, SUM(na_sales) AS total_sales FROM game_sales
UNION ALL
SELECT 'Japanese', SUM(jp_sales) FROM game_sales
UNION ALL
SELECT 'Europe/Africa', SUM(pal_sales) FROM game_sales
UNION ALL
SELECT 'Other', SUM(other_sales) FROM game_sales
ORDER BY total_sales DESC;

-- 7. Genres that are more popular in one region than others
SELECT 
	genre,
	SUM(na_sales) AS na_sales,
	SUM(jp_sales) AS jp_sales,
	SUM(pal_sales) AS pal_sales,
	SUM(other_sales) AS other_sales
FROM game_sales gs
GROUP BY 1;

-- 8. Average game sales in each region
SELECT 'North American' AS region , AVG(na_sales) AS avg_total_sales FROM game_sales
UNION ALL
SELECT 'Japanese' , AVG(jp_sales) FROM game_sales
UNION ALL
SELECT 'Europe/Africa' , AVG(pal_sales) FROM game_sales
UNION ALL
SELECT 'Other' , AVG(other_sales) FROM game_sales 
ORDER BY avg_total_sales DESC;

-- 9. publisher with the highest sales in each region
WITH sales_by_publisher AS (
    SELECT 
        publisher,
        SUM(na_sales) AS total_na_sales,
        SUM(jp_sales) AS total_jp_sales,
        SUM(pal_sales) AS total_pal_sales,
        SUM(other_sales) AS total_other_sales
    FROM game_sales
    GROUP BY publisher
)
SELECT 
    'North America' AS region, 
    publisher, 
    total_na_sales AS total_sales 
FROM sales_by_publisher
WHERE total_na_sales = (SELECT MAX(total_na_sales) FROM sales_by_publisher)
UNION ALL
SELECT 
    'Japan' AS region, 
    publisher, 
    total_jp_sales AS total_sales 
FROM sales_by_publisher
WHERE total_jp_sales = (SELECT MAX(total_jp_sales) FROM sales_by_publisher)
UNION ALL
SELECT 
    'Europe & Africa' AS region, 
    publisher, 
    total_pal_sales AS total_sales 
FROM sales_by_publisher
WHERE total_pal_sales = (SELECT MAX(total_pal_sales) FROM sales_by_publisher)
UNION ALL
SELECT 
    'Other Regions' AS region, 
    publisher, 
    total_other_sales AS total_sales 
FROM sales_by_publisher
WHERE total_other_sales = (SELECT MAX(total_other_sales) FROM sales_by_publisher);

-- 10. Which developer has the highest average critique score?
SELECT 
	developer,
	AVG(critic_score)  
FROM game_sales gs 
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

-- 11. Which publisher releases the most games
SELECT 
	publisher,
	COUNT(*) AS total_game
FROM game_sales gs 
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;


-- 12. How is sales distributed based on publisher
SELECT 
	publisher,
	SUM(total_sales)
FROM game_sales gs 
GROUP BY 1
ORDER BY 2 DESC 
LIMIT 10;

-- 13. Is there a relationship between critic scores and total sales
SELECT 
	critic_score,
	total_sales
FROM game_sales gs 
GROUP BY 1, 2
ORDER BY 1 DESC;

-- 14. Which genres have the highest average critic scores?
SELECT 
	genre,
	AVG(critic_score) AS avg_critic_score
FROM game_sales
GROUP BY 1
ORDER BY avg_critic_score DESC;




