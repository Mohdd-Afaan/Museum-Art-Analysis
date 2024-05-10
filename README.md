SQL Project: Museum Art Analysis

Project Overview:
Performed comprehensive analysis on museum art datasets to derive insights into paintings, museums, artists, and their attributes.

Queries and Achievements:

Painting-Museum Associations:
Identified paintings not displayed in any museums.
Queryed using straightforward SQL to extract relevant data.

Museum Inventory:
Investigated museums without any paintings.
Utilized LEFT JOIN to identify museums lacking artwork.

Price Discrepancy Analysis:
Calculated count of paintings with sale prices exceeding regular prices.
Identified paintings with sale prices less than 50% of regular prices.

Canvas Cost Evaluation:
Determined canvas size with the highest cost.
Utilized CTE to calculate costs for each canvas size.

Data Cleansing:
Implemented SQL queries to remove duplicate records from various tables.
Employed temporary tables and window functions for efficient data cleansing.

Quality Assurance:
Identified museums with invalid city information.
Applied regular expressions to detect numeric characters in city names.

Subject Popularity:
Ranked top painting subjects based on total regular prices of associated paintings.
Presented top 10 subjects using GROUP BY and ORDER BY clauses.

Operational Analysis:
Identified museums open on both Sunday and Monday.
Counted museums open every single day of the week.

Museum Ranking:
Identified top 5 museums based on the number of paintings.
Used COUNT() and ORDER BY to rank museums.

Artist Ranking:
Identified top 5 artists based on the number of paintings.
Utilized COUNT() and ORDER BY to rank artists.

Operational Efficiency:
Determined museum with the longest opening hours.
Employed time calculations and aggregation functions.

Style Analysis:
Identified museum with the most paintings in the most popular style.
Utilized GROUP BY and ORDER BY for style analysis.

International Reach:
Identified artists with paintings displayed in multiple countries.
Used window functions to rank artists based on international exposure.
