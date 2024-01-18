/* This project is to look at Global Video Game Sales, and do some exploratory data analysis.

Dataset from Kaggle:
https://www.kaggle.com/datasets/thedevastator/global-video-game-sales-and-reviews

We have created a new schema called video_game_sales, and imported the data.

This project will address several questions:
1. Game Research & Evaluation:
2. Publisher Analysis:
3. Regional Market Trend Identification:
4. Global Sales Analysis:
5. Platform Insight:

More information about these points can be found in the markdown document.

*/
USE video_game_sales;

# Check the table is imported correctly
SELECT 
*
from 
sales

limit 10;

# Year is imported as text, had errors when importing as numeric column.
# Let's add a new column and drop existing one later.

ALTER TABLE sales
ADD COLUMN NewYear INT;

# Fix the whitespaces in the data
UPDATE sales
SET NewYear = NULLIF(TRIM(Year), '') + 0;

# Check result
-- Check rows where NewYear is NULL after the update
SELECT *
FROM sales
WHERE NewYear IS NULL;

# NewYear is properly set to integers with null values, from 'schemas' information.
ALTER TABLE sales
DROP COLUMN Year;

# Sanity check the table.
SELECT *
FROM
sales
LIMIT 10;

# Let's take a look at null values for each column
SELECT *
FROM sales
WHERE 
Publisher IS NULL;

/* 
Since I've seen empty spots previously in Publisher, there must be white space instead of null values.
We should alter the table so that white spaces are changed to null values.
*/

# Check for null values in text columns
SELECT *
FROM sales
WHERE NULLIF(TRIM(Publisher), '') IS NULL;

SELECT *
FROM sales
WHERE NULLIF(TRIM('Game Title'), '') IS NULL;

SELECT *
FROM sales
WHERE NULLIF(TRIM(Genre), '') IS NULL;

# Only publishers have null values
# Adjust table by creating new column
ALTER TABLE sales
ADD COLUMN NewPublisher VARCHAR(255);

# Update column with edited values
UPDATE sales
SET NewPublisher = NULLIF(TRIM(Publisher),'');

# Drop Original Column
ALTER TABLE sales
DROP COLUMN Publisher;

# Check table
SELECT *
FROM sales
WHERE NewPublisher IS NULL;

# Check Null values for numeric columns
SELECT *
FROM sales
WHERE `North America` IS NULL
OR `Europe` IS NULL
OR `Japan` IS NULL
OR `Rest Of World` IS NULL
OR `Global` IS NULL
OR `Review` IS NULL;

# Checks
SELECT * 
FROM sales
LIMIT 10;

# Let's do a quick check for duplicates
SELECT 
`Game Title`, Platform, Genre, `North America`, Europe, Japan, `Rest of World`, Global, Review, NewYear, NewPublisher
FROM sales
GROUP BY
`Game Title`, Platform, Genre, `North America`, Europe, Japan, `Rest of World`, Global, Review, NewYear, NewPublisher
HAVING 
COUNT(*) > 1; 

/* No duplicates, we can proceed to do our analysis now.
To get a feel of the dataset, let's take a look at the distribution of certain columns.
First, we will look the platforms.

*/

SELECT
Platform,
COUNT(*) AS Total_Count
FROM sales
GROUP BY 
Platform
ORDER BY 
COUNT(*) DESC;

# Now, we can check the years.
SELECT
NewYear,
COUNT(*)
FROM sales
GROUP BY 
NewYear
ORDER BY
NewYear DESC;

# We can see the latest year is 2012. 

# We can also look at the distribution of Genres
SELECT
Genre,
COUNT(*) as Total_Count
FROM sales
GROUP BY 
Genre
ORDER BY
COUNT(*) DESC;

# Lastly, we can look at the distribution of publishers
SELECT
NewPublisher,
COUNT(*) as Total_Count
FROM sales
GROUP BY 
NewPublisher
ORDER BY
COUNT(*) DESC
Limit 20;

# We can move onto looking at statistics for numeric columns.
# Let's create a table of our summary stats
SELECT
'North America' AS Market,
AVG(`North America`) AS Mean,
STDDEV(`North America`) AS STD,
MAX(`North America`) AS Most_Sales,
SUM(`North America`) AS Total_Sales
FROM 
sales 

UNION ALL

SELECT
'Europe' AS Market,
AVG(`Europe`) AS Mean,
STDDEV(`Europe`) AS STD,
MAX(`Europe`) AS Most_Sales,
SUM(`Europe`) AS Total_Sales
FROM 
sales

UNION ALL

SELECT
'Japan' AS Market,
AVG(`Japan`) AS Mean,
STDDEV(`Japan`) AS STD,
MAX(`Japan`) AS Most_Sales,
SUM(`Japan`) AS Total_Sales
FROM 
sales

UNION ALL
SELECT
'Rest of World' AS Market,
AVG(`Rest of World`) AS Mean,
STDDEV(`Rest of World`) AS STD,
MAX(`Rest of World`) AS Most_Sales,
SUM(`Rest of World`) AS Total_Sales
FROM sales

UNION ALL

SELECT
'Global' AS Market,
AVG(`Global`) AS Mean,
STDDEV(`Global`) AS STD,
MAX(`Global`) AS Most_Sales,
SUM(`Global`) AS Total_Sales
FROM sales;

# Lastly, we can analyze the review column. This may be our target column for a lot of our analysis.

SELECT
AVG(review) as Mean,
STDDEV(review) AS Standard_Deviation,
MIN(review) as Minimum,
MAX(review) as Maximum
FROM sales;

# After all our initial exploration, we can begin to answer our questions.
# 1. With columns such as 'Game Title', 'Genre' and 'Review', you can research on particular games or genres that interest you. 
#    You can evaluate a game based on its review scores, delving into what makes a top-rated game.

# First, let's take a look at the top 5 games per genre.

WITH RankGames AS 
	(SELECT
	RANK() OVER (PARTITION BY Genre ORDER BY Review DESC) AS Ranking,
	`Game Title`,
	Review,
    Genre,
    Platform,
    NewPublisher
	FROM
	sales)
SELECT 
Genre,
`Game Title`, 
Review,
Platform,
NewPublisher,
Ranking
FROM
RankGames
WHERE 
Ranking < 6;

# Let's compare the percentage count of the publisher, compared to their prevalence in the top 5

# First, to calculate the percent count per publisher in total
SELECT
NewPublisher,
Count(*) AS Games,
SUM(COUNT(*)) OVER () AS Total_Games, 
COUNT(*)/ SUM(COUNT(*)) OVER () * 100 as Percent_Total
FROM sales
GROUP BY 
NewPublisher
ORDER BY
COUNT(*) DESC;

# Calculate the percent prevalence per publisher in the top 5, create table to simplify queries
CREATE TABLE Top_Percent AS
SELECT
A.NewPublisher,
Count(*) AS Games_Top,
SUM(COUNT(*)) OVER () AS Total_Top_Games,
COUNT(*)/ SUM(COUNT(*)) OVER () * 100 as Percent_Top_Total
FROM
(
WITH RankGames AS 
	(SELECT
	RANK() OVER (PARTITION BY Genre ORDER BY Review DESC) AS Ranking,
	`Game Title`,
	Review,
    Genre,
    Platform,
    NewPublisher
	FROM
	sales)
SELECT 
Genre,
`Game Title`, 
Review,
Platform,
NewPublisher,
Ranking
FROM
RankGames
WHERE 
Ranking < 6
) AS A
GROUP BY 
A.NewPublisher
ORDER BY
Percent_Top_Total DESC;

# Now, we can join the two tables together
SELECT
Top_Percent.*,
Total_Percent.Games,
Total_Percent.Total_Games,
Total_Percent.Percent_Total
FROM
Top_Percent
JOIN
(
	SELECT
	NewPublisher,
	Count(*) AS Games,
	SUM(COUNT(*)) OVER () AS Total_Games, 
	COUNT(*)/ SUM(COUNT(*)) OVER () * 100 as Percent_Total
	FROM sales
	GROUP BY 
	NewPublisher
	ORDER BY
	COUNT(*) DESC
) AS Total_Percent
ON
Top_Percent.NewPublisher = Total_Percent.NewPublisher;

# Look at reviews for games from Nintendo
SELECT
`Game Title`,
Review,
`Global`
FROM
sales
WHERE
NewPublisher = 'Nintendo'
AND
`Global` > 0.5
ORDER BY
Review ASC
LIMIT 10
;

# Look at summary statistics per publisher, with more than 5 games
SELECT
NewPublisher,
ROUND(AVG(Review), 2) AS Average_Review,
ROUND(STDDEV(Review), 2) AS STD_Review,
ROUND(SUM(Global), 2) AS Sum_Global_Sales,
COUNT(*) AS Number_Of_Games,
RANK() OVER (ORDER BY Avg(Review) DESC) AS `Rank`
FROM sales
GROUP BY NewPublisher
HAVING COUNT(*) > 5
ORDER BY Average_Review DESC
LIMIT 20;

# Look at games from MTV or Square
SELECT
NewPublisher,
`Game Title`,
Review,
Genre
FROM sales
WHERE NewPublisher = 'MTV Games'
OR NewPublisher = 'Square'
ORDER BY NewPublisher, Review DESC;

# Take a big picture view of Sports games
SELECT
NewPublisher,
`Game Title`,
`Global`,
Review,
NewYear
FROM sales
WHERE Genre = 'Sports'
ORDER BY `Global` DESC
LIMIT 20;

# Look into deeper statistics in sports
SELECT
Genre,
AVG(Review) AS Average,
Min(Review) AS Minimum,
Max(Review) AS Maximum,
STDDEV(Review) AS Standard_Deviation,
COUNT(*) AS Games_In_Genre
FROM sales
GROUP BY Genre

UNION ALL

SELECT
'Average' AS GENRE,
AVG(Review) AS Average,
Min(Review) AS Minimum,
Max(Review) AS Maximum,
STDDEV(Review) AS Standard_Deviation,
COUNT(*) AS Games_In_Genre
FROM sales

ORDER BY
AVERAGE DESC;

# Best reviewed sports games
SELECT
NewPublisher,
`Game Title`,
`Global`,
Review,
NewYear
FROM sales
WHERE Genre = 'Sports'
ORDER BY `Review` DESC
LIMIT 20;

# Average review per year in sports
SELECT
NewYear,
ROUND(AVG(Review), 2) AS Average,
ROUND(SUM(Global), 2),
COUNT(*) AS Number_of_Games 
FROM sales
WHERE Genre = 'Sports'
GROUP BY NewYear
ORDER BY NewYear;

# Filtering for all European Football games
SELECT
`Game Title`,
`Global`,
NewPublisher,
NewYear,
Review
FROM sales
WHERE `Game Title` REGEXP '.*SOCCER.*'
ORDER BY Review DESC;

# Find averages, sums for each publisher who makes soccer games
SELECT
A.NewPublisher,
COUNT(*) AS Total_Games,
AVG(Review) AS Average_Review,
AVG(Global) AS Average_Global_Sales,
MAX(Global) AS Highest_Global_Sales,
MAX(Review) AS Best_Review,
MIN(Review) AS Lowest_Review
FROM
(
	SELECT
	`Game Title`,
	`Global`,
	NewPublisher,
	NewYear,
	Review
	FROM sales
	WHERE `Game Title` REGEXP '.*SOCCER.*'
	ORDER BY Review DESC
) AS A
GROUP BY A.NewPublisher;