-- Problem Statements
-- 1. Fetch all the paintings which are not displayed on any museums?
SELECT DISTINCT work_id, name 
FROM work 
WHERE museum_id IS NULL;

-- 2. Are there any museums without any paintings?
SELECT DISTINCT m.museum_id 
FROM museum AS m 
LEFT JOIN work AS w ON m.museum_id = w.museum_id 
WHERE w.work_id IS NULL;

-- 3. How many paintings have an asking price of more than their regular price?
SELECT COUNT(DISTINCT work_id) 
FROM product_size 
WHERE sale_price > regular_price;

-- 4. Identify the paintings whose asking price is less than 50% of its regular price?
SELECT DISTINCT work_id 
FROM product_size 
WHERE sale_price < (regular_price * 0.50);

-- 5. Which canva size costs the most?
WITH cte AS (
    SELECT DISTINCT c.width * IFNULL(c.height, 1) AS size, 
           w.sale_price, 
           (c.width * IFNULL(c.height, 1)) * w.sale_price AS cost
    FROM canvas_size AS c 
    LEFT JOIN product_size AS w ON c.size_id = w.size_id
)
SELECT size 
FROM cte 
WHERE cost = (SELECT MAX(cost) FROM cte);


-- 6. Delete duplicate records from work, product_size, subject and image_link tables?
CREATE TEMPORARY TABLE quries.temp_1 AS
WITH cte AS (
    SELECT *, 
           ROW_NUMBER() OVER(PARTITION BY work_id, size_id) AS rn 
    FROM quries.product_size
) 
SELECT work_id, size_id, sale_price, regular_price 
FROM cte 
WHERE rn > 1;

DELETE FROM quries.product_size 
WHERE work_id IN (
    SELECT work_id 
    FROM (
        SELECT *, 
               ROW_NUMBER() OVER(PARTITION BY work_id, size_id) AS rn 
        FROM quries.product_size
    ) AS ala 
    WHERE rn > 1
);

INSERT INTO quries.product_size
SELECT * FROM quries.temp_1;

DROP TABLE quries.temp_1;



CREATE TEMPORARY TABLE quries.temp_2 AS
WITH cte AS (
    SELECT *, 
           ROW_NUMBER() OVER(PARTITION BY work_id) AS rn 
    FROM quries.work
) 
SELECT work_id, name, artist_id, style, museum_id 
FROM cte 
WHERE rn > 1;

DELETE FROM quries.work 
WHERE work_id IN (
    SELECT work_id 
    FROM (
        SELECT *, 
               ROW_NUMBER() OVER(PARTITION BY work_id) AS rn 
        FROM quries.work
    ) AS ala 
    WHERE rn > 1
);

INSERT INTO quries.work 
SELECT * FROM quries.temp_2;

DROP TABLE quries.temp_2;



CREATE TEMPORARY TABLE quries.temp_3 AS
WITH cte AS (
    SELECT *, 
           ROW_NUMBER() OVER(PARTITION BY work_id, subject) AS rn 
    FROM quries.subject
) 
SELECT work_id, subject 
FROM cte 
WHERE rn > 1;

DELETE FROM quries.subject 
WHERE work_id IN (
    SELECT work_id 
    FROM (
        SELECT *, 
               ROW_NUMBER() OVER(PARTITION BY work_id, subject) AS rn 
        FROM quries.subject
    ) AS ala 
    WHERE rn > 1
);

INSERT INTO quries.subject
SELECT * FROM quries.temp_3;

DROP TABLE quries.temp_3;

CREATE TEMPORARY TABLE quries.temp_4 AS
WITH cte AS (
    SELECT *, 
           ROW_NUMBER() OVER(PARTITION BY work_id, url, thumbnail_small_url, thumbnail_large_url) AS rn 
    FROM quries.image_link
) 
SELECT work_id, url, thumbnail_small_url, thumbnail_large_url 
FROM cte 
WHERE rn > 1;

DELETE FROM quries.image_link 
WHERE work_id IN (
    SELECT work_id 
    FROM (
        SELECT *, 
               ROW_NUMBER() OVER(PARTITION BY work_id, url, thumbnail_small_url, thumbnail_large_url) AS rn 
        FROM quries.image_link
    ) AS ala 
    WHERE rn > 1
);

INSERT INTO quries.image_link
SELECT * FROM quries.temp_4;

DROP TABLE quries.temp_4;


-- 7. Identify the museums with invalid city information in the given dataset?
SELECT name FROM museum WHERE TRIM(city) REGEXP '^[0-9]+$';

-- 8. Fetch the top 10 most famous painting subject
WITH cte AS (
    SELECT s.subject, 
           s.work_id, 
           p.regular_price, 
           p.sale_price, 
           SUM(p.regular_price) OVER (PARTITION BY s.subject) AS top_price
    FROM quries.subject AS s 
    LEFT JOIN quries.product_size AS p
    ON s.work_id = p.work_id
)
SELECT subject, top_price 
FROM cte 
GROUP BY top_price, subject 
ORDER BY top_price DESC 
LIMIT 10;

-- 9. Identify the museums which are open on both Sunday and Monday. Display museum name, city.
WITH cte AS (
    SELECT *  
    FROM quries.museum_hours 
    WHERE day = 'Sunday'
), 
cte2 AS (
    SELECT *  
    FROM quries.museum_hours 
    WHERE day = 'Monday'
)
SELECT m.name, m.city
FROM cte c 
INNER JOIN cte2 c2 ON c.museum_id = c2.museum_id 
INNER JOIN museum m ON c.museum_id = m.museum_id;

-- 10. How many museums are open every single day?
WITH cte AS (
    SELECT museum_id 
    FROM quries.museum_hours 
    GROUP BY museum_id 
    HAVING COUNT(day) = 7
) 
SELECT COUNT(museum_id) AS opens_every_day 
FROM cte;

-- 11. Which are the top 5 most popular museum? (Popularity is defined based on most no of paintings in a museum)
WITH cte AS (
    SELECT museum_id, 
           COUNT(work_id) AS no_of_paintings 
    FROM quries.work 
    WHERE museum_id IS NOT NULL
    GROUP BY museum_id 
    ORDER BY COUNT(work_id) DESC 
    LIMIT 5
)
SELECT c.museum_id, 
       m.name, 
       c.no_of_paintings 
FROM cte AS c 
INNER JOIN quries.museum AS m ON c.museum_id = m.museum_id;

-- 12. Who are the top 5 most popular artist? (Popularity is defined based on most no of paintings done by an artist)
WITH cte AS (
    SELECT artist_id, 
           COUNT(work_id) AS no_of_paintings 
    FROM quries.work 
    WHERE artist_id IS NOT NULL
    GROUP BY artist_id 
    ORDER BY COUNT(artist_id) DESC 
    LIMIT 5
)
SELECT c.artist_id, 
       a.full_name, 
       c.no_of_paintings 
FROM cte AS c 
INNER JOIN quries.artist AS a ON c.artist_id = a.artist_id;

-- 13. Which museum is open for the longest during a day. Dispay museum name, state and hours open and which day?
WITH cte AS (
    SELECT *,
           TIMEDIFF(
               TIME(CONCAT(SUBSTRING(close, 1, 2) + 12, SUBSTRING(close, 3, 3))),
               TIME(
                   CASE
                       WHEN open LIKE '0%' AND open LIKE '%PM' THEN CONCAT(SUBSTRING(open, 1, 2) + 12, SUBSTRING(OPEN, 3, 3))
                       ELSE SUBSTRING(open, 1, 5)
                   END
               )
           ) AS duration
    FROM quries.museum_hours
)
SELECT m.name,
       m.state,
       SUBSTRING(c.duration, 1, 5) AS hours_open,
       c.day
FROM cte AS c
INNER JOIN museum AS m ON c.museum_id = m.museum_id
WHERE duration = (SELECT MAX(duration) FROM cte);


-- 14. Which museum has the most no of most popular painting style?
SELECT w.style, 
       m.name, 
       COUNT(w.work_id) AS no_of_paintings
FROM quries.work AS w
INNER JOIN quries.product_size AS p ON w.work_id = p.work_id
INNER JOIN quries.museum AS m ON w.museum_id = m.museum_id
WHERE w.museum_id IS NOT NULL
GROUP BY w.style, m.name
ORDER BY COUNT(w.work_id) DESC
LIMIT 1;

-- 15. Identify the artists whose paintings are displayed in multiple countries
WITH cte AS (
    SELECT w.artist_id, 
           m.country, 
           RANK() OVER(PARTITION BY artist_id ORDER BY m.country) AS rn
    FROM quries.work AS w
    INNER JOIN quries.museum AS m ON w.museum_id = m.museum_id
    GROUP BY artist_id, country
), 
cte_2 AS (
    SELECT artist_id, 
           SUM(rn) AS no_of_countries 
    FROM cte 
    GROUP BY artist_id
)
SELECT * 
FROM cte_2 
WHERE no_of_countries > 2
ORDER BY no_of_countries DESC;

