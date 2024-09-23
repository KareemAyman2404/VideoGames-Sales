USE newvideogames;

SELECT *
FROM videogames;

/*
Questions from Mavenanalytics to be solved:

1) Which titles sold the most worldwide?

2) Which year had the highest sales? Has the industry grown over time?

3) Do any consoles seem to specialize in a particular genre?

4) What titles are popular in one region but flop in another?

*/

# 1) Which titles sold the most worldwide?

SELECT title, ROUND(SUM(total_sales),2) as total_sales
FROM videogames
GROUP BY title
ORDER BY total_sales DESC
LIMIT 10;

SELECT game_title as `TOP 10 Games By Total Sales` , DENSE_RANK() OVER(ORDER BY total_sales DESC) as Game_Rank
FROM
(SELECT title AS game_title, ROUND(SUM(total_sales),2) AS total_sales
FROM videogames
GROUP BY title
ORDER BY total_sales DESC) t1
ORDER BY Game_Rank ASC
LIMIT 10;

#2) Which year had the highest sales? Has the industry grown over time?

SELECT YEAR(release_date) AS release_year, ROUND(SUM(total_Sales),2) AS total_sales
FROM videogames
GROUP BY release_year
ORDER BY total_sales DESC;

#3) Do any consoles seem to specialize in a particular genre?
SELECT DISTINCT t4.console1 AS Console, t4.genre1 AS Genre, t4.genre_count AS Genre_Count
FROM
(SELECT t3.console AS console1, t3.genre AS genre1, v.console AS console2, v.genre AS genre2,
		t3.genre_count,  MAX(genre_count) OVER(PARTITION BY t3.console) max_count
FROM
(SELECT DISTINCT console, genre, COUNT(genre) as genre_count
FROM videogames v
GROUP BY console, genre
ORDER BY genre_count DESC, console ASC, genre ASC) t3
JOIN videogames v
ON t3.console = v.console AND t3.genre = v.genre
ORDER BY max_count DESC)t4
WHERE genre_count = max_count
ORDER BY t4.genre_count DESC, t4.console1 ASC, t4.genre1 ASC;

#4) What titles are popular in one region but flop in another?
SELECT popularity, COUNT(popularity) pop_count
FROM
(SELECT game_title, 
CASE
WHEN na_sales > jp_sales AND na_sales > pal_sales THEN "Popular in USA"
WHEN jp_sales > na_sales AND jp_sales > pal_sales THEN "Popular in Japan"
WHEN pal_sales > na_sales AND pal_sales > jp_sales THEN "Popular in PAL"
ELSE "Popular in Other regions"
END AS popularity
FROM
(SELECT title game_title, CEIL(SUM(total_sales)) total_sales, CEIL(SUM(na_sales)) na_sales,
		CEIL(SUM(jp_sales)) jp_sales, CEIL(SUM(pal_sales)) pal_sales
FROM videogames
GROUP BY title
ORDER BY SUM(total_sales) DESC) t5) t6
WHERE popularity != "Popular in Other regions"
GROUP BY popularity
ORDER BY pop_count DESC;