# Analysis

This is my analysis on the global video game sales dataset. This project is designed to answer a few questions (from Kaggle):

**1. Game Research & Evaluation:**
With columns such as 'Game Title', 'Genre' and 'Review', you can research on particular games or genres that interest you. You can evaluate a game based on its review scores, delving into what makes a top-rated game.

**2. Publisher Analysis:**
The 'Publisher' column lets you track which publishers are behind the most successful games in terms of sales and reviews. This analysis could be useful for people interested in business trends in gaming industry or trying to identify potential innovative publishers.

**3. Regional Market Trend Identification:**
You can use data from columns like ‘North America’, ‘Europe’, ‘Japan’ and ‘Rest of World’ to study regional market trends for certain genres or platforms; it might enable one to recognize patterns over time or cultural preferences with regard to video games.

**4. Global Sales Analysis:**
Using the 'Global' column, you could observe which games have been globally successful, going beyond regional preferences by genre or platform.

**5. Platform Insight:**
The platform on which a particular game is available is another significant factor (e.g., PC, PS4, Xbox). By utilizing the data contained in this dataset regarding platforms, one may learn how platform choice impacts global sales as well as discern any correlation between preferred platform types among specific regions.

The **Data Dictionary** is as follows:
| Column Name   | Description                                                                                           |
|---------------|-------------------------------------------------------------------------------------------------------|
| Rank          | The rank of the video game based on global sales volume. (Numerical)                                  |
| Game Title    | The name of the video game. (String)                                                                 |
| Platform      | The platform on which the game is available, such as PC, PS4, Xbox One, etc. (Categorical)             |
| Year          | The year in which the game was released. (Date)                                                       |
| Genre         | The genre of the game, such as action, adventure, racing, etc. (Categorical)                            |
| Publisher     | The company that published the game. (String)                                                         |
| North America | The number of units sold in North America, in millions. (Numerical)                                   |
| Europe        | The number of units sold in Europe, in millions. (Numerical)                                          |
| Japan         | The number of units sold in Japan, in millions. (Numerical)                                           |
| Rest of World | The number of units sold in the rest of the world, excluding North America, Europe, and Japan, in millions. (Numerical) |
| Global        | The total number of units sold worldwide, in millions. (Numerical)                                     |
| Review        | The review score of the game, on a scale of 1 to 10. (Numerical)                                       |

### Exploring the Dataset


First, we look at the first 10 listings of the dataset.


```SQL
SELECT 
*
FROM 
sales
LIMIT 10;
```
This table shows the 

| index | Rank | Game Title               | Platform | Year  | Genre       | Publisher | North America | Europe | Japan | Rest of World | Global | Review |
|-------|------|--------------------------|----------|-------|-------------|-----------|---------------|--------|-------|---------------|--------|--------|
| 0     | 1    | Wii Sports               | Wii      | 2006.0| Sports      | Nintendo  | 40.43         | 28.39  | 3.77  | 8.54          | 81.12  | 76.28  |
| 1     | 2    | Super Mario Bros.        | NES      | 1985.0| Platform    | Nintendo  | 29.08         | 3.58   | 6.81  | 0.77          | 40.24  | 91     |
| 2     | 3    | Mario Kart Wii           | Wii      | 2008.0| Racing      | Nintendo  | 14.5          | 12.22  | 3.63  | 3.21          | 33.55  | 82.07  |
| 3     | 4    | Wii Sports Resort        | Wii      | 2009.0| Sports      | Nintendo  | 14.82         | 10.51  | 3.18  | 3.01          | 31.52  | 82.65  |
| 4     | 5    | Tetris                   | GB       | 1989.0| Puzzle      | Nintendo  | 23.2          | 2.26   | 4.22  | 0.58          | 30.26  | 88     |
| 5     | 6    | New Super Mario Bros.    | DS       | 2006.0| Platform    | Nintendo  | 10.85         | 8.87   | 6.48  | 2.88          | 29.08  | 90     |
| 6     | 7    | Wii Play                 | Wii      | 2006.0| Misc        | Nintendo  | 13.83         | 9.11   | 2.93  | 2.84          | 28.71  | 61.64  |
| 7     | 8    | Duck Hunt                | NES      | 1984.0| Shooter     | Nintendo  | 26.93         | 0.63   | 0.28  | 0.47          | 28.31  | 84     |
| 8     | 9    | New Super Mario Bros. Wii| Wii     | 2009.0| Platform    | Nintendo  | 13.35         | 6.48   | 4.66  | 2.25          | 26.75  | 88.18  |
| 9     | 10   | Nintendogs               | DS       | 2005.0| Simulation  | Nintendo  | 9.02          | 10.81  | 1.93  | 2.73          | 24.5   | 85     |


We can clean the dataset, check null values and duplicates through a sequence of SQL commands as listed below:

```SQL

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
```


After the cleaning process, we can start our initial analysis.

## Initial Analysis into feature distribution for categorical variables

First, we look at the distribution of the platforms.


```SQL
SELECT
Platform,
COUNT(*) AS Total_Count
FROM sales
GROUP BY 
Platform
ORDER BY 
COUNT(*) DESC;
```

**Results:**

| Platform | Total Count |
|----------|-------------|
| PS2      | 372         |
| PS       | 223         |
| X360     | 219         |
| PS3      | 202         |
| Wii      | 161         |
| DS       | 149         |
| GBA      | 75          |
| XB       | 72          |
| PC       | 71          |
| PSP      | 63          |
| NES      | 60          |
| N64      | 57          |
| GC       | 55          |
| GB       | 48          |
| SNES     | 41          |
| 3DS      | 15          |
| GEN      | 11          |
| DC       | 6           |
| SAT      | 3           |
| WiiU     | 2           |
| SCD      | 1           |
| PSV      | 1           |


We can see that PS2 has the highest count. This means this dataset must be quite old - PS2 is the latest generation of playstation and was released in Year 2000. To confirm, we can look at the distribution of years.

```SQL
SELECT
NewYear,
COUNT(*) AS Total_Count
FROM sales
GROUP BY 
NewYear
ORDER BY
NewYear DESC;
```

**Result:**

| NewYear | Total_Count |
|---------|----------|
| 2012    | 60       |
| 2011    | 100      |
| 2010    | 130      |
| 2009    | 131      |
| 2008    | 184      |
| 2007    | 157      |
| 2006    | 103      |
| 2005    | 105      |
| 2004    | 122      |
| 2003    | 114      |
| 2002    | 110      |
| 2001    | 91       |
| 2000    | 67       |
| 1999    | 66       |
| 1998    | 81       |
| 1997    | 54       |
| 1996    | 47       |
| 1995    | 22       |
| 1994    | 21       |
| 1993    | 12       |
| 1992    | 20       |
| 1991    | 10       |
| 1990    | 13       |
| 1989    | 9        |
| 1988    | 9        |
| 1987    | 7        |
| 1986    | 12       |
| 1985    | 6        |
| 1984    | 9        |
| 1983    | 6        |
|         | 29       |

The dataset spans from 1983 to 2012, with most counts between 2002 and 2012. There are 29 null values.

Let's take a look at the distribution for Genres.
```SQL
# We can also look at the distribution of Genres
SELECT
Genre,
COUNT(*) as Total_Count
FROM sales
GROUP BY 
Genre
ORDER BY
COUNT(*) DESC;
```

Result:

| Genre         | Total_Count |
|---------------|-------------|
| Sports        | 308         |
| Action        | 275         |
| Shooter       | 206         |
| Platform      | 188         |
| Racing        | 186         |
| Role-Playing  | 173         |
| Misc          | 159         |
| Fighting      | 126         |
| Adventure     | 110         |
| Simulation    | 92          |
| Puzzle        | 44          |
| Strategy      | 40          |

Sports have the highest count of games, with Action games closely behind.

Lastly, we can look at the publisher with the most games.

```SQL
SELECT
NewPublisher,
COUNT(*) as Total_Count
FROM sales
GROUP BY 
NewPublisher
ORDER BY
COUNT(*) DESC;
```

**Results:**

| NewPublisher                          | Total Count |
|----------------------------------------|-------------|
| Electronic Arts                       | 341         |
| Nintendo                              | 296         |
| Sony Computer Entertainment           | 156         |
| Activision                            | 141         |
| Ubisoft                               | 93          |
| THQ                                   | 89          |
| Sega                                  | 81          |
| Take-Two Interactive                  | 75          |
| Capcom                                | 63          |
| Konami Digital Entertainment          | 53          |
| Microsoft Game Studios                | 47          |
| Namco Bandai Games                    | 40          |
| Square Enix                           | 33          |
| LucasArts                             | 32          |
| Atari                                 | 28          |
| Eidos Interactive                     | 25          |
| Disney Interactive Studios            | 24          |
| Acclaim Entertainment                 | 21          |
| Warner Bros. Interactive Entertainment | 19          |
| Midway Games                           | 17          |

EA has made the most games, with Nintendo coming second. This is quite expected as EA is arguably the largest game developing company. 

After we have looked at the distribution for our categorical variables, we can briefly look at the distributions for the reviews in different markets.

## Initial analysis into numeric variables

Let's create a table of all our summary statistics in one table. This will allow us to compare easily from one market to the next.

```SQL
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
```

**Results:**

| Market         | Mean                  | STD                   | Most_Sales | Total_Sales          |
|----------------|-----------------------|-----------------------|------------|----------------------|
| North America  | 1.2587886733088618    | 1.956046988871156     | 40.43      | 2400.5099999999993  |
| Europe         | 0.7066754063974823    | 1.1486026991530232    | 28.39      | 1347.6299999999987  |
| Japan          | 0.3174934452018859    | 0.7247551776092769    | 7.2        | 605.4599999999964   |
| Rest of World  | 0.20647089669638047   | 0.3430032916278259    | 8.54       | 393.73999999999756  |
| Global         | 2.4892396434189874    | 3.5622250782140137    | 81.12      | 4746.980000000009   |


**Insights:**
- We can see that North America accounts for over half of the world sales, in terms of total sales, mean sales and most sales.
- Europe is the second largest market, with Japan following.

Lastly, we can take a look at the Review column. This may be our target column in much of this analysis.

```SQL
SELECT
AVG(review) as Mean,
STDDEV(review) AS Standard_Deviation,
MIN(review) as Minimum,
MAX(review) as Maximum
FROM sales;
```

**Results:**

| Mean                | Standard Deviation   | Minimum | Maximum |
|---------------------|-----------------------|---------|---------|
| 79.03897745149453   | 10.614115382940096   | 30.5    | 97      |

**Insights:**
- Average rating at 79.
- Max rating at 97, min at 30.5.
- Standard deviation at 10.6
- Keep these numbers in mind as we do our analysis. This is for the total dataset, and we can see how much different features affect this.


## Part 1: Looking into best games
Looking back at our core question:

**1. Game Research & Evaluation:**
With columns such as 'Game Title', 'Genre' and 'Review', you can research on particular games or genres that interest you. You can evaluate a game based on its review scores, delving into what makes a top-rated game.

First, we can take a look at the top 5 games per genre.

```SQL
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
```

**Results:**

| Genre       | Game Title                                        | Review | Platform | NewPublisher                       | Ranking |
|-------------|--------------------------------------------------|--------|----------|-----------------------------------|---------|
| Action      | Batman: Arkham Asylum                             | 96.09  | PS3      | Eidos Interactive                 | 1       |
| Action      | Resident Evil 4                                   | 95.83  | GC       | Capcom                            | 2       |
| Action      | Resident Evil 4                                   | 95.77  | PS2      | Capcom                            | 3       |
| Action      | Grand Theft Auto: San Andreas                    | 95.08  | PS2      | Take-Two Interactive              | 4       |
| Action      | Metal Gear Solid 2: Sons of Liberty              | 95.04  | PS2      | Konami Digital Entertainment      | 5       |
| Adventure   | The Legend of Zelda: Ocarina of Time             | 97     | N64      | Nintendo                          | 1       |
| Adventure   | The Legend of Zelda: Twilight Princess           | 95     | GC       | Nintendo                          | 2       |
| Adventure   | The Legend of Zelda: Twilight Princess           | 94.58  | Wii      | Nintendo                          | 3       |
| Adventure   | The Legend of Zelda: The Wind Waker              | 94.43  | GC       | Nintendo                          | 4       |
| Adventure   | The Legend of Zelda: A Link to the Past          | 94     | SNES     | Nintendo                          | 5       |
| Adventure   | Super Metroid                                     | 94     | SNES     | Nintendo                          | 5       |
| Fighting    | Tekken 3                                          | 96.3   | PS       | Sony Computer Entertainment       | 1       |
| Fighting    | Super Smash Bros. Melee                           | 93     | GC       | Nintendo                          | 2       |
| Fighting    | Super Smash Bros. Brawl                           | 93     | Wii      | Nintendo                          | 2       |
| Fighting    | Virtua Fighter 2                                  | 92.5   | SAT      | Sega                              | 4       |
| Fighting    | Street Fighter II: The World Warrior             | 92     | SNES     | Capcom                            | 5       |
| Misc        | Rock Band 2                                       | 92.25  | X360     | Electronic Arts                   | 1       |
| Misc        | Guitar Hero                                       | 91.96  | PS2      | RedOctane                         | 2       |
| Misc        | Rock Band 2                                       | 91.5   | PS3      | MTV Games                         | 3       |
| Misc        | Rock Band                                         | 91.23  | PS3      | Electronic Arts                   | 4       |
| Misc        | Guitar Hero II                                    | 90     | X360     | Activision                        | 5       |
| Misc        | Guitar Hero II                                    | 90     | PS2      | RedOctane                         | 5       |
| Platform    | Super Mario World                                 | 94     | SNES     | Nintendo                          | 1       |
| Platform    | Super Mario All-Stars                             | 93     | SNES     | Nintendo                          | 2       |
| Platform    | Super Mario 64                                    | 93     | N64      | Nintendo                          | 2       |
| Platform    | Super Mario Bros. 3                               | 93     | NES      | Nintendo                          | 2       |
| Platform    | Super Mario World: Super Mario Advance 2          | 93     | GBA      | Nintendo                          | 2       |
| Platform    | Super Mario Bros. Deluxe                          | 93     | GB       | Nintendo                          | 2       |
| Puzzle      | Super Puyo Puyo                                   | 94     | SNES     | Banpresto                         | 1       |
| Puzzle      | Tetris DX                                         | 90     | GB       | Nintendo                          | 2       |
| Puzzle      | Tetris                                            | 88     | GB       | Nintendo                          | 3       |
| Puzzle      | Lumines: Puzzle Fusion                            | 87     | PSP      | Ubisoft                           | 4       |
| Puzzle      | Tetris                                            | 86     | NES      | Nintendo                          | 5       |
| Puzzle      | Super Monkey Ball 2                               | 86     | GC       | Atari                             | 5       |
| Racing      | Gran Turismo 3: A-Spec                            | 94.47  | PS2      | Sony Computer Entertainment       | 1       |
| Racing      | Burnout Revenge                                   | 93.32  | PS2      | Electronic Arts                   | 2       |
| Racing      | Burnout 3: Takedown                               | 93.32  | PS2      | Electronic Arts                   | 2       |
| Racing      | Burnout 3: Takedown                               | 92.97  | XB       | Electronic Arts                   | 4       |
| Racing      | Gran Turismo 2                                    | 92.42  | PS       | Sony Computer Entertainment       | 5       |
| Role-Playing | Mass Effect 2                                     | 95.69  | X360     | Electronic Arts                   | 1       |
| Role-Playing | The Elder Scrolls IV: Oblivion                    | 94     | X360     | Take-Two Interactive              | 2       |
| Role-Playing | Super Mario RPG: Legend of the Seven Stars       | 94     | SNES     | Nintendo                          | 2       |
| Role-Playing | Mass Effect 2                                     | 

**Insights:**
- Most of the genres are dominated by one series of games - either the same game but different systems, i.e. for ps2 and XB, or by games of similar nature, i.e. Super Mario games for platformers.
- Highest rated puzzle games only from 94 to 86, which is not many points over the mean of 79.
- Most frequent publisher is EA and Nintendo, which is not surprising. However, it is interesting to see if they are well represented in the top counts, given they produce the most games.


Let's compare EA and Nintendo percentage of total games versus their percentage total in the top 5 games.

```SQL
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
```

**Results:**

| NewPublisher                  | Games_Top | Total_Top_Games | Percent_Top_Total | Games | Total_Games | Percent_Total |
|-------------------------------|-------------|------------------|-------------------|-------|-------------|---------------|
| Electronic Arts               | 13          | 67               | 19.40%            | 341   | 1907        | 17.88%        |
| Nintendo                      | 22          | 67               | 32.84%            | 296   | 1907        | 15.52%        |
| Sony Computer Entertainment  | 3           | 67               | 4.48%             | 156   | 1907        | 8.18%         |
| Activision                    | 4           | 67               | 5.97%             | 141   | 1907        | 7.39%         |
| Ubisoft                       | 1           | 67               | 1.49%             | 93    | 1907        | 4.88%         |
| Sega                          | 2           | 67               | 2.99%             | 81    | 1907        | 4.25%         |
| Take-Two Interactive          | 3           | 67               | 4.48%             | 75    | 1907        | 3.93%         |
| Capcom                        | 3           | 67               | 4.48%             | 63    | 1907        | 3.30%         |
| Konami Digital Entertainment  | 2           | 67               | 2.99%             | 53    | 1907        | 2.78%         |
| Microsoft Game Studios        | 3           | 67               | 4.48%             | 47    | 1907        | 2.46%         |
| Square Enix                   | 1           | 67               | 1.49%             | 33    | 1907        | 1.73%         |
| LucasArts                     | 1           | 67               | 1.49%             | 32    | 1907        | 1.68%         |
| Atari                         | 1           | 67               | 1.49%             | 28    | 1907        | 1.47%         |
| Eidos Interactive              | 1           | 67               | 1.49%             | 25    | 1907        | 1.31%         |
| Bethesda Softworks            | 1           | 67               | 1.49%             | 16    | 1907        | 0.84%         |
| Vivendi Games                  | 1           | 67               | 1.49%             | 8     | 1907        | 0.42%         |
| MTV Games                      | 1           | 67               | 1.49%             | 7     | 1907        | 0.37%         |
| RedOctane                      | 2           | 67               | 2.99%             | 3     | 1907        | 0.16%         |
| Valve Software                 | 1           | 67               | 1.49%             | 2     | 1907        | 0.10%         |
| Banpresto                      | 1           | 67               | 1.49%             | 1     | 1907        | 0.05%         |


**Insights**
- EA has a larger percentage in the top 5 than in total (19.40% vs 17.88%).
- Nintendo also has much larger percentage in the top 5 than in total (32.84% vs 15.52%).
- Sony, Activision has a lower percentage in top 5 compared to total.

Does this mean we should buy exclusively from EA or Nintendo? Is every EA or Nintendo game good? Most likely not. To investigate, we can look at games from these two companies.

```SQL
# Look at reviews for games from EA
SELECT
`Game Title`,
Review,
`Global`
FROM
sales
WHERE
NewPublisher = 'Electronic Arts'
AND
`Global` > 0.5
ORDER BY
Review ASC
LIMIT 10
;
```

**Results:**

| Game Title                              | Review | Global |
|-----------------------------------------|--------|--------|
| The Simpsons Skateboarding             | 37.58  | 1.52   |
| The Sims 2: Pets                       | 46.83  | 2.05   |
| The Sims 3                             | 56.00  | 1.16   |
| The Simpsons Game                      | 57.75  | 1.01   |
| The Lost World: Jurassic Park           | 59.67  | 1.02   |
| Harry Potter and the Sorcerer's Stone  | 60.00  | 1.69   |
| NBA Live 07                            | 60.69  | 1.30   |
| The Simpsons: Road Rage                | 61.61  | 1.05   |
| Harry Potter and the Sorcerer's Stone  | 62.00  | 3.73   |
| The Simpsons Game                      | 62.83  | 0.97   |

Clearly, there are some poorly reviewed EA games. Let's look at Nintendo games.

```SQL
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
```

**Results:**

| Game Title                               | Review | Global |
|------------------------------------------|--------|--------|
| Baseball                                 | 39.00  | 3.20   |
| Qix                                      | 45.00  | 1.15   |
| Pinball                                  | 46.00  | 1.85   |
| Soccer                                   | 51.00  | 1.96   |
| Pokémon Battle Revolution                | 53.19  | 1.52   |
| Volleyball                               | 54.00  | 2.15   |
| Alleyway                                 | 54.62  | 1.94   |
| Mario Party Advance                      | 56.42  | 0.98   |
| Flash Focus: Vision Training in Minutes a Day | 61.00  | 3.79   |
| Wii Play                                 | 61.64  | 28.71  |

There also seems to be some very poorly reviewed Nintendo games. The decision to just buy Nintendo and EA games seems to be flawed. Let's look at some other metrics to determine which publisher we should buy from.

We will only look at publishers who have made at least 5 games.

```SQL
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
```

**Results:**
| NewPublisher                               | Average_Review | STD_Review | Sum_Global_Sales | Number_Of_Games | Rank |
|--------------------------------------------|-----------------|------------|-------------------|------------------|------|
| MTV Games                                  | 86.17           | 3.2        | 11.39             | 7                | 1    |
| Square                                     | 85.4            | 6.72       | 38.5              | 16               | 2    |
| Enix Corporation                           | 84.55           | 3.85       | 20.72             | 8                | 3    |
| Virgin Interactive                         | 83.96           | 5.27       | 29.29             | 12               | 4    |
| Codemasters                                | 83.51           | 4.83       | 17.95             | 15               | 5    |
| Take-Two Interactive                       | 83.43           | 9.95       | 208.42            | 75               | 6    |
| Square Enix                                | 83.02           | 6.66       | 64.59             | 33               | 7    |
| Microsoft Game Studios                     | 82.58           | 9.87       | 169.73            | 47               | 8    |
| Eidos Interactive                          | 82.34           | 8.96       | 56.25             | 25               | 9    |
| Capcom                                     | 82              | 7.44       | 114.33            | 63               | 10   |
| GT Interactive                             | 81.69           | 6.57       | 17.87             | 8                | 11   |
| Nintendo                                   | 81.62           | 9          | 1448.84           | 296              | 12   |
| Sony Computer Entertainment                | 81.3            | 8.22       | 377.61            | 156              | 13   |
| Warner Bros. Interactive Entertainment     | 80.67           | 8.62       | 34.41             | 19               | 14   |
| LucasArts                                  | 80.59           | 5.31       | 61.11             | 32               | 15   |
| Bethesda Softworks                         | 80.54           | 16.79      | 37.16             | 16               | 16   |
| Electronic Arts                            | 79.75           | 7.95       | 633.36            | 341              | 17   |
| Activision                                 | 79.74           | 9.92       | 371.42            | 141              | 18   |
| Konami Digital Entertainment               | 79.71           | 9.85       | 107.67            | 53               | 19   |
| Sega                                       | 79.41           | 8.95       | 122.67            | 81               | 20   |

**Insights:**
- Nintendo and EA are ranked 12th and 17th respectively.
- Nintendo and EA create the most games and have the highest sum of global sales.

It seems like purchasing just Nintendo and EA games is not the best idea. With the average review being at 79, Nintendo and EA are only a few percentage points higher than the mean.

How about from the top of the category - MTV games or Square?

```SQL
# Look at games from MTV or Square
SELECT
NewPublisher,
`Game Title`,
Review,
Genre
FROM sales
WHERE NewPublisher = 'MTV Games'
OR NewPublisher = 'Square'
ORDER BY NewPublisher, Review DESC 
```

**Results:**
| NewPublisher | Game Title               | Review | Genre        |
|--------------|--------------------------|--------|--------------|
| MTV Games    | Rock Band 2              | 91.5   | Misc         |
| MTV Games    | Rock Band 2              | 88     | Misc         |
| MTV Games    | The Beatles: Rock Band   | 87     | Misc         |
| MTV Games    | Dance Central            | 86.55  | Misc         |
| MTV Games    | The Beatles: Rock Band   | 85     | Misc         |
| MTV Games    | The Beatles: Rock Band   | 85     | Misc         |
| MTV Games    | Rock Band                | 80.13 | Misc         |
| Square       | Chrono Cross             | 92.18 | Role-Playing |
| Square       | Final Fantasy Tactics    | 92     | Role-Playing |
| Square       | Secret of Mana           | 92     | Role-Playing |
| Square       | Chrono Trigger           | 91.98 | Role-Playing |
| Square       | Xenogears                | 90.94 | Role-Playing |
| Square       | Final Fantasy III        | 90     | Role-Playing |
| Square       | Final Fantasy II         | 90     | Role-Playing |
| Square       | Final Fantasy VIII       | 89.17 | Role-Playing |
| Square       | Final Fantasy V          | 87     | Role-Playing |
| Square       | Parasite Eve             | 85     | Role-Playing |
| Square       | Final Fantasy IX         | 83     | Role-Playing |
| Square       | Final Fantasy III        | 82     | Role-Playing |
| Square       | Brave Fencer Musashi     | 79.67 | Role-Playing |
| Square       | SaGa Frontier 2          | 75     | Role-Playing |
| Square       | The Final Fantasy Legend | 74     | Role-Playing |
| Square       | Legend of Mana           | 72.46 | Role-Playing |

**Insights:**
- All the games are of the same genre.
- If you enjoy those genres, it can be a good idea to pick games from these two publishers. Only 4 games are below the average per review.

Stepping away from publishers, let's take a deeper dive into one of the genres - sports.

```SQL
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
```

**Results:**
| NewPublisher                  | Game Title                                     | Global | Review | NewYear |
|-------------------------------|------------------------------------------------|--------|--------|---------|
| Nintendo                      | Wii Sports                                     | 81.12  | 76.28  | 2006    |
| Nintendo                      | Wii Sports Resort                              | 31.52  | 82.65  | 2009    |
| Nintendo                      | Wii Fit                                        | 22.74  | 81.2   | 2007    |
| Nintendo                      | Wii Fit Plus                                   | 21.15  | 80.83  | 2009    |
| Nintendo                      | Mario & Sonic at the Olympic Games             | 7.87   | 74     | 2007    |
| Electronic Arts               | FIFA Soccer 12                                 | 6.32   | 84     | 2011    |
| 505 Games                     | Zumba Fitness                                  | 6.3    | 51     | 2010    |
| Microsoft Game Studios        | Kinect Sports                                  | 5.54   | 76     | 2010    |
| Electronic Arts               | Madden NFL 2004                                | 5.23   | 87     |         |
| Activision                    | Tony Hawk's Pro Skater                        | 5.02   | 89     | 1999    |
| Nintendo                      | Mario & Sonic at the Olympic Games             | 5.01   | 73     | 2008    |
| Electronic Arts               | Madden NFL 06                                 | 4.91   | 85.15  | 2005    |
| Electronic Arts               | FIFA Soccer 11                                 | 4.91   | 86     | 2010    |
| Activision                    | Tony Hawk's Pro Skater 2                      | 4.68   | 92     | 2000    |
| Electronic Arts               | Madden NFL 2005                                | 4.53   | 89     | 2004    |
| Electronic Arts               | Madden NFL 07                                 | 4.49   | 84.48  | 2006    |
| Activision                    | Tony Hawk's Pro Skater 3                      | 4.41   | 84     | 2001    |
| Konami Digital Entertainment  | Winning Eleven: Pro Evolution Soccer 2007     | 4.39   | 86.31  | 2006    |
| Nintendo                      | Mario & Sonic at the Olympic Winter Games      | 4.37   | 78     | 2009    |
| Electronic Arts               | FIFA Soccer 06                                 | 4.21   | 78.73  | 2005    |

**Insights:**
- Seems like Nintendo, EA and Activision dominate this space, in terms of global sales.
- The top global sales are all Nintendo Wii games. However, their ratings are quite low.

Let's look at some deeper statistics in this genre.
```SQL
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
```
**Results:**
| Genre         | Average | Minimum | Maximum | Standard Deviation | Games in Genre |
|---------------|---------|---------|---------|---------------------|-----------------|
| Role-Playing  | 83.91   | 51.08   | 95.69   | 7.75                | 173             |
| Strategy      | 82.44   | 52.00   | 94.75   | 8.45                | 40              |
| Fighting      | 82.21   | 38.15   | 96.30   | 8.08                | 126             |
| Adventure     | 81.48   | 40.00   | 97.00   | 9.71                | 110             |
| Shooter       | 81.08   | 44.00   | 96.36   | 9.48                | 206             |
| *Average*   | 79.04   | 30.50   | 97.00   | 10.61               | 1907            |
| Action        | 78.95   | 40.38   | 96.09   | 10.92               | 275             |
| **Sports**       | 78.84   | 30.50   | 94.50   | 10.04               | 308             |
| Platform      | 78.38   | 34.00   | 94.00   | 11.51               | 188             |
| Racing        | 78.11   | 49.00   | 94.47   | 9.87                | 186             |
| Puzzle        | 74.31   | 37.00   | 94.00   | 12.16               | 44              |
| Simulation    | 73.81   | 44.00   | 90.89   | 11.22               | 92              |
| Misc          | 72.77   | 33.00   | 92.25   | 11.82               | 159             |

**Insights:**
- Sports have a lower than average review rating.
- Sports has the lowest minimum review rating.
- Sports has a relatively high standard deviation, implying there is more variance in the reviews.

Let's take a look at the best reviewed sports games.

```SQL
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
```

**Results:**
| NewPublisher                    | Game Title                                      | Global | Review | NewYear |
|----------------------------------|-------------------------------------------------|--------|--------|---------|
| Sega                             | NFL 2K1                                         | 1.09   | 94.5   | 2000    |
| Konami Digital Entertainment     | World Soccer Winning Eleven 7 International   | 2.9    | 92.97  | 2003    |
| Electronic Arts                  | SSX Tricky                                      | 1.73   | 92.54  | 2001    |
| Electronic Arts                  | SSX 3                                           | 1.67   | 92.28  | 2003    |
| Electronic Arts                  | SSX                                             | 1.66   | 92.17  | 2000    |
| Activision                       | Tony Hawk's Pro Skater 2                        | 4.68   | 92     | 2000    |
| Sega                             | NFL 2K                                          | 1.2    | 91.53  | 1999    |
| Electronic Arts                  | NCAA Football 2003                              | 1.44   | 91.36  | 2002    |
| Konami Digital Entertainment     | World Soccer Winning Eleven 8 International   | 3.85   | 90.83  | 2004    |
| Konami Digital Entertainment     | World Soccer Winning Eleven 6 International   | 2.99   | 90.54  | 2002    |
| Sega                             | ESPN NFL 2K5                                    | 1.63   | 90.52  | 2004    |
| Electronic Arts                  | Tiger Woods PGA Tour 2004                       | 1.63   | 90.11  | 2003    |
| Namco Bandai Games               | World Class Track Meet                          | 3.08   | 90     | 1986    |
| Electronic Arts                  | NBA Street V3                                   | 1.06   | 90     | 2005    |
| Nintendo                         | 1080°: TenEighty Snowboarding                  | 2.03   | 89.6   | 1998    |
| Electronic Arts                  | NCAA Football 2005                              | 1.62   | 89.45  | 2004    |
| Electronic Arts                  | NCAA Football 2004                              | 1.67   | 89.45  | 2003    |
| Electronic Arts                  | Tiger Woods PGA Tour 10                         | 1.03   | 89.14  | 2009    |
| Electronic Arts                  | Madden NFL 2005                                 | 4.53   | 89     | 2004    |
| Take-Two Interactive             | NBA 2K11                                       | 2.03   | 89     | 2010    |

**Insights:**
- The number of global sales are much lower for these games compared to the Nintendo Wii games, which topped the global sales. It would be interesting to do a correlation analysis between global sales and reviews.
- Most of the games in the top 20 are released prior to 2005, with only 2 games post 2005. Perhaps, people have started to rate sports games more harshly in the later years.

To investigate the second point, we can look into the average rating per year.

```SQL
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
```

**Results:**

| NewYear | Average | Sum_Global | Number_of_Games |
|---------|---------|------------|------------------|
|         | 79.86   | 11.9       | 5                |
| 1983    | 39      | 3.2        | 1                |
| 1984    | 70      | 6.18       | 2                |
| 1985    | 51      | 1.96       | 1                |
| 1986    | 90      | 3.08       | 1                |
| 1987    | 67      | 3.45       | 2                |
| 1988    | 83.5    | 3.51       | 2                |
| 1989    | 77      | 2.12       | 1                |
| 1990    | 81      | 1.48       | 1                |
| 1991    | 73      | 1          | 1                |
| 1992    | 85      | 2.05       | 1                |
| 1994    | 84.5    | 2.5        | 2                |
| 1995    | 79      | 1.86       | 2                |
| 1996    | 68.4    | 5.36       | 5                |
| 1997    | 79.18   | 15.09      | 11               |
| 1998    | 81.06   | 20.05      | 15               |
| 1999    | 83.82   | 14.69      | 8                |
| 2000    | 81.97   | 25.84      | 17               |
| 2001    | 80.98   | 29.73      | 16               |
| 2002    | 79.11   | 33.6       | 19               |
| 2003    | 85.02   | 24.52      | 15               |
| 2004    | 85.22   | 43.12      | 24               |
| 2005    | 83.58   | 33.77      | 18               |
| 2006    | 80.29   | 107.25     | 15               |
| 2007    | 75.07   | 66.11      | 26               |
| 2008    | 73.78   | 51.2       | 29               |
| 2009    | 77.18   | 95.13      | 25               |
| 2010    | 75.24   | 51.02      | 23               |
| 2011    | 79.02   | 33.14      | 13               |
| 2012    | 74.24   | 9.2        | 7                |


**Insights:**
- There seems to be a golden period from 1997 to 2006, where all reviews were over the average (78.84 in Sports). Most years also had double digit number of games produced too.
- 2007 to 2010 had much lower average reviews as every year had below average reviews, but many more games were produced. The sum of global sales spiked significantly too in this time period.

