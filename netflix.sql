--Netflix  Project

DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
  show_id VARCHAR(6),
  type VARCHAR(10),
  title VARCHAR(250),
  director VARCHAR(550),
  casts VARCHAR(1050),
  country VARCHAR(550),
  date_added VARCHAR(55),
  release_year INT,
  rating VARCHAR(15),
  duration VARCHAR(15),
  listed_in VARCHAR(250),
  description VARCHAR(550)
);

SELECT * FROM netflix;

SELECT
COUNT(*) AS table_content
FROM netflix;

SELECT DISTINCT type
FROM netflix;

--1. Count the Number of Movies vs TV Shows
SELECT type,COUNT(*) 
FROM netflix
GROUP BY type;

--2. Find the Most Common Rating for Movies and TV Shows

SELECT type, rating
FROM (
    SELECT
        type,
        rating,
        COUNT(*) AS rating_count,
        RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
    FROM netflix
    GROUP BY type, rating
) AS t1
WHERE ranking = 1;

--3. List All Movies Released in a Specific Year (e.g., 2020)
SELECT * 
FROM netflix
WHERE 
    type= 'Movie'
	AND
    release_year=2020;

--4. Find the Top 5 Countries with the Most Content on Netflix
SELECT
     TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS new_country,
     COUNT(show_id) AS total_content
FROM netflix
GROUP BY 1
ORDER BY total_content DESC
LIMIT 5;


--5. Identify the Longest Movie
SELECT title, duration 
FROM netflix
WHERE type= 'Movie'
 AND duration IS NOT NULL
ORDER BY CAST(SPLIT_PART(duration, ' ', 1) AS INT) DESC
LIMIT 1;


--6. Find Content Added in the Last 5 Years
SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years'

--7. Find All Movies/TV Shows by Director 'Rohit Shetty'
SELECT *
FROM netflix
WHERE director ILIKE '%Rohit Shetty%'

--8. List All TV Shows with More Than 5 Seasons
SELECT title, 
       duration
FROM netflix
WHERE type= 'TV Show' 
      AND
	  CAST(SPLIT_PART(duration,' ',1) AS INT) >5

--9. Count the Number of Content Items in Each Genre
SELECT 
      UNNEST(STRING_TO_ARRAY(listed_in,',')) AS genre,
      COUNT(show_id) AS total_content
FROM netflix
GROUP BY 1

--10. List All Movies that are Documentaries
SELECT * 
FROM netflix
WHERE type='Movie'
      AND
	  listed_in LIKE '%Documentaries%'


--11. Find How Many Movies Actor 'Shah Rukh Khan' Appeared in the Last 10 Years
SELECT COUNT(*) AS total_movies
FROM netflix 
WHERE type='Movie'
      AND casts ILIKE '%Shah Rukh Khan%'
      AND release_year >EXTRACT(YEAR FROM CURRENT_DATE)-10

--12. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
SELECT COUNT(show_id) AS total_movies,
       UNNEST(STRING_TO_ARRAY(casts,',')) AS actor
FROM netflix
WHERE country ILIKE '%India%'
      AND type='Movie'
GROUP BY actor
ORDER BY total_movies DESC 
LIMIT 10;

--13. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
WITH new_table
AS
(
SELECT show_id,
       title,
	   description,
       CASE
	   WHEN description ILIKE '%Kill%' OR
            description ILIKE '%Violence%' THEN 'Violence Related'
			ELSE 'Others'
	   END category
FROM netflix
)
SELECT category, 
       COUNT(*) AS total_content
FROM new_table
GROUP BY category
