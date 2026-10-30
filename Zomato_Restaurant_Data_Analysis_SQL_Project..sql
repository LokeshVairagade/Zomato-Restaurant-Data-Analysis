CREATE DATABASE zomato_sql_project;

USE zomato_sql_project;

CREATE TABLE zomato_restaurants (
    restaurant_id INT,
    restaurant_name VARCHAR(255),
    country_code INT,
    city VARCHAR(100),
    address TEXT,
    locality VARCHAR(150),
    locality_verbose VARCHAR(255),
    longitude DECIMAL(10,6),
    latitude DECIMAL(10,6),
    cuisines VARCHAR(500),
    average_cost_for_two INT,
    currency VARCHAR(100),
    has_table_booking VARCHAR(20),
    has_online_delivery VARCHAR(20),
    is_delivering_now VARCHAR(20),
    switch_to_order_menu VARCHAR(20),
    price_range INT,
    aggregate_rating DECIMAL(3,1),
    rating_color VARCHAR(20),
    rating_text VARCHAR(50),
    votes INT
);

select * from zomato_restaurants;

# 1. How many restaurants are in the dataset?
SELECT COUNT(*) AS total_restaurants
FROM zomato_restaurants;

# 2. How many unique cities are covered?
SELECT COUNT(DISTINCT city) AS total_cities
FROM zomato_restaurants;

# 3. Which are the top 10 cities with the most restaurants?
SELECT 
    city,
    COUNT(*) AS restaurant_count
FROM zomato_restaurants
GROUP BY city
ORDER BY restaurant_count DESC
LIMIT 10;

# 4. What is the overall average restaurant rating?
SELECT 
    ROUND(AVG(aggregate_rating), 2) AS average_rating
FROM zomato_restaurants
WHERE aggregate_rating > 0;

# 5. How many restaurants have a rating of 4 or higher?
SELECT COUNT(*) AS high_rated_restaurants
FROM zomato_restaurants
WHERE aggregate_rating >= 4;

# 6. Which are the top 10 most-voted restaurants?
SELECT 
    restaurant_name,
    city,
    aggregate_rating,
    votes
FROM zomato_restaurants
ORDER BY votes DESC
LIMIT 10;

Insight: Identifies restaurants with the highest customer engagement.
7. Which cities have the highest average ratings?
SELECT 
    city,
    COUNT(*) AS restaurant_count,
    ROUND(AVG(aggregate_rating), 2) AS avg_rating
FROM zomato_restaurants
WHERE aggregate_rating > 0
GROUP BY city
HAVING COUNT(*) >= 10
ORDER BY avg_rating DESC
LIMIT 10;

# 8. How many restaurants are in each price range?
SELECT 
    price_range,
    COUNT(*) AS restaurant_count
FROM zomato_restaurants
GROUP BY price_range
ORDER BY price_range;

# 9. Which price range has the highest average rating?
SELECT 
    price_range,
    COUNT(*) AS restaurant_count,
    ROUND(AVG(aggregate_rating), 2) AS avg_rating
FROM zomato_restaurants
WHERE aggregate_rating > 0
GROUP BY price_range
ORDER BY avg_rating DESC;

# 10. Which are the 10 most expensive restaurants?
SELECT 
    restaurant_name,
    city,
    average_cost_for_two,
    aggregate_rating
FROM zomato_restaurants
ORDER BY average_cost_for_two DESC
LIMIT 10;

# 11. How many restaurants offer online delivery?
SELECT 
    has_online_delivery,
    COUNT(*) AS restaurant_count
FROM zomato_restaurants
GROUP BY has_online_delivery;

# 12. Does online delivery affect restaurant ratings?
SELECT 
    has_online_delivery,
    COUNT(*) AS restaurant_count,
    ROUND(AVG(aggregate_rating), 2) AS avg_rating
FROM zomato_restaurants
WHERE aggregate_rating > 0
GROUP BY has_online_delivery;

# 13. How many restaurants offer table booking?
SELECT 
    has_table_booking,
    COUNT(*) AS restaurant_count
FROM zomato_restaurants
GROUP BY has_table_booking;

# 14. What are the most common cuisine combinations?
SELECT 
    cuisines,
    COUNT(*) AS restaurant_count
FROM zomato_restaurants
WHERE cuisines IS NOT NULL
GROUP BY cuisines
ORDER BY restaurant_count DESC
LIMIT 10;

# 15. What is the highest-rated restaurant in each city?
WITH ranked AS (
    SELECT
        city,
        restaurant_name,
        aggregate_rating,
        ROW_NUMBER() OVER (
            PARTITION BY city
            ORDER BY aggregate_rating DESC
        ) AS rn
    FROM zomato_restaurants
    WHERE aggregate_rating > 0
)
SELECT city, restaurant_name, aggregate_rating
FROM ranked
WHERE rn = 1;

# 16. Which cities have more than 100 restaurants and an average rating of 4+?
SELECT
    city,
    COUNT(*) AS restaurant_count,
    ROUND(AVG(aggregate_rating), 2) AS avg_rating
FROM zomato_restaurants
WHERE aggregate_rating > 0
GROUP BY city
HAVING COUNT(*) > 100;

# 17. Which restaurants have a rating of 4+ and above-average votes?
SELECT 
    restaurant_name,
    city,
    aggregate_rating,
    votes
FROM zomato_restaurants
WHERE aggregate_rating >= 4
  AND votes > (
      SELECT AVG(votes)
      FROM zomato_restaurants
  )
ORDER BY votes DESC;

# 18. What are the top 3 restaurants in each city?
WITH ranked_restaurants AS (
    SELECT
        restaurant_name,
        city,
        aggregate_rating,
        votes,
        ROW_NUMBER() OVER (
            PARTITION BY city
            ORDER BY aggregate_rating DESC, votes DESC
        ) AS city_rank
    FROM zomato_restaurants
    WHERE aggregate_rating > 0
)
SELECT
    city,
    restaurant_name,
    aggregate_rating,
    votes,
    city_rank
FROM ranked_restaurants
WHERE city_rank <= 3
ORDER BY city, city_rank;

# 19. Which cities have many restaurants but relatively low ratings?
SELECT 
    city,
    COUNT(*) AS restaurant_count,
    ROUND(AVG(aggregate_rating), 2) AS avg_rating
FROM zomato_restaurants
WHERE aggregate_rating > 0
GROUP BY city
HAVING COUNT(*) > 100
   AND AVG(aggregate_rating) < 3.5
ORDER BY restaurant_count DESC;

# 20. Which cities are the top-performing restaurant markets?
SELECT 
    city,
    COUNT(*) AS restaurant_count,
    ROUND(AVG(aggregate_rating), 2) AS avg_rating,
    SUM(votes) AS total_votes,
    ROUND(AVG(average_cost_for_two), 2) AS avg_cost
FROM zomato_restaurants
WHERE aggregate_rating > 0
GROUP BY city
HAVING COUNT(*) >= 10
ORDER BY avg_rating DESC, total_votes DESC
LIMIT 10;
