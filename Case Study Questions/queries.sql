SELECT * FROM pizza_runner.customer_orders;
SELECT * FROM pizza_runner.pizza_names;
SELECT * FROM pizza_runner.pizza_recipes;
SELECT * FROM pizza_runner.pizza_toppings;
SELECT * FROM pizza_runner.runners;
SELECT * FROM pizza_runner.runner_orders;

-- How many successful orders were delivered by each runner?
SELECT runner_id, COUNT(order_id)AS Successful_Orders
FROM pizza_runner.runner_orders
WHERE cancellation NOT IN ('Restaurant Cancellation', 'Customer Cancellation')
GROUP BY runner_id;

-- How many of each type of pizza was delivered?
SELECT p.pizza_id, p.pizza_name, COUNT(p.pizza_id)AS pizza_count
FROM pizza_names p JOIN customer_orders c 
ON p.pizza_id = c.pizza_id
GROUP BY p.pizza_id;

-- How many Vegetarian and Meatlovers were ordered by each customer?
SELECT c.customer_id,
SUM(CASE WHEN p.pizza_name ='Meatlovers' THEN 1 ELSE 0 END)AS MEATLOVERS_PIZZA_COUNT,
SUM(CASE WHEN p.pizza_name ='Vegetarian' THEN 1 ELSE 0 END)AS VEGETARIAN_PIZZA_COUNT
FROM customer_orders c JOIN pizza_names p 
ON c.pizza_id = p.pizza_id
GROUP BY c.customer_id;


-- What was the maximum number of pizzas delivered in a single order?
SELECT MAX(a.CP)AS Max_Pizza_Delivered
FROM    (SELECT order_id, 
	COUNT(pizza_id) OVER(PARTITION BY order_id)AS CP 
	FROM customer_orders)a;


-- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT c.customer_id, 
SUM(CASE WHEN (exclusions IS NOT NULL AND exclusions != 0) 
    OR (extras IS NOT NULL AND extras != 0) THEN 1
        ELSE 0 END )AS At_least_One_Change,
SUM(CASE WHEN (exclusions IS NULL OR exclusions = 0) 
    AND (extras IS NULL OR extras = 0) THEN 1
        ELSE 0 END ) AS No_Change
FROM customer_orders c
JOIN runner_orders r
ON c.order_id = r.order_id
WHERE r.distance != 0
GROUP BY c.customer_id;

-- How many pizzas were delivered that had both exclusions and extras?
SELECT c.customer_id,
SUM(CASE WHEN (c.exclusions IS NOT NULL AND c.exclusions !=0) 
AND (c.extras IS NOT NULL AND c.extras !=0) THEN 1 ELSE 0 END)AS Both_exclusion_extra
FROM customer_orders c
JOIN runner_orders r
ON c.order_id = r.order_id
WHERE r.distance != 0
GROUP BY c.customer_id
ORDER BY Both_exclusion_extra DESC;

-- What was the total volume of pizzas ordered for each hour of the day?
SELECT HOUR(order_time)as hour_time,
COUNT(order_id)AS Pizzas_Ordered
FROM customer_orders
GROUP BY hour_time
ORDER BY hour_time;

-- What was the volume of orders for each day of the week?
SELECT dayname(order_time)as day, COUNT(order_id)as Pizzas_ordered
FROM customer_orders
GROUP BY day
ORDER BY Pizzas_ordered DESC;


-- B. Runner and Customer Experience
-- How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT WEEK(registration_date) AS RegistrationWeek, COUNT(runner_id) AS RunnerRegistrated
FROM runners
GROUP BY RegistrationWeek;

-- What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
SELECT r.runner_id, ROUND(AVG(timestampdiff(MINUTE, c.order_time, r.pickup_time)),2)AS Pickup_Duration
FROM runner_orders r JOIN customer_orders c ON c.order_id = r.order_id
GROUP BY r.runner_id;

select A.runner_id, (avg(datediff(minute,B.order_time, A.pickup_time))) as minutes
 from runner_orders A
 join customer_orders B
 on A.order_id=B.order_id
 where cancellation=' '
 group by runner_id;

-- Is there any relationship between the number of pizzas and how long the order takes to prepare?
WITH Pizza_Count AS
(SELECT c.order_id, COUNT(c.order_id) AS PizzaCount, 
ROUND((TIMESTAMPDIFF(MINUTE, c.order_time, r.pickup_time))) AS Avgtime
FROM customer_orders AS c
JOIN runner_orders AS r
ON c.order_id = r.order_id
WHERE r.distance <> 0 
GROUP BY c.order_id)
SELECT PizzaCount, Avgtime
FROM Pizza_Count
GROUP BY PizzaCount;

-- What was the average distance travelled for each customer?
WITH Avg_Distance AS (
SELECT c.customer_id, ROUND(AVG(r.distance),1)AS AvgDistance
FROM customer_orders c JOIN runner_orders r
ON c.order_id = r.order_id
WHERE r.distance != 0
GROUP BY c.customer_id)
SELECT * FROM Avg_Distance;

SELECT *
FROM 
(SELECT c.customer_id, ROUND(avg(r.distance),2) AS Avg_Distance
FROM customer_orders c JOIN runner_orders r 
ON c.order_id = r.runner_id
WHERE r.distance <> 0
GROUP BY c.customer_id)a;

-- What was the difference between the longest and shortest delivery times for all orders?
WITH TIME_DIFF AS
( SELECT c.order_id, c.order_time, r.pickup_time, 
TIMESTAMPDIFF(MINUTE, c.order_time, r.pickup_time) AS TimeDiff
FROM customer_orders AS c
JOIN runner_orders AS r
ON c.order_id = r.order_id
where distance <> 0
GROUP BY c.order_id, c.order_time, r.pickup_time)

SELECT MAX(TimeDiff) - MIN(TimeDiff) AS DifferenceTime FROM TIME_DIFF;

-- What was the average speed for each runner for each delivery and do you notice any trend for these values?
WITH AVG_SPEED AS 
( SELECT runner_id, order_id, 
ROUND(distance *60/duration,1) AS speed_in_KMPH
FROM runner_orders
WHERE distance != 0
GROUP BY runner_id, order_id)

-- What is the successful delivery percentage for each runner?
WITH SUCCESS AS
( select runner_id, SUM(CASE WHEN distance != 0 THEN 1 else 0 end) as SUCCESS_ORDERS, 
COUNT(order_id) AS TotalOrders
FROM runner_orders
GROUP BY runner_id)

SELECT runner_id, ROUND((SUCCESS_ORDERS/TotalOrders)*100) AS Successful_percentage 
FROM SUCCESS
ORDER BY runner_id;

-- C. Ingredient Optimisation
-- What are the standard ingredients for each pizza?
-- Normalize Pizza Recipe table
drop table if exists pizza_recipes1;
create table pizzarunner.pizza_recipes1 
(
 pizza_id int,
    toppings int);
insert into pizzarunner.pizza_recipes1
(pizza_id, toppings) 
values
(1,1),
(1,2),
(1,3),
(1,4),
(1,5),
(1,6),
(1,8),
(1,10),
(2,4),
(2,6),
(2,7),
(2,9),
(2,11),
(2,12);

with cte as (
select p3.pizza_name,p1.pizza_id, p2.topping_name
from pizza_runner.pizza_recipes p1
inner join pizza_runner.pizza_toppings p2
on p1.toppings = p2.topping_id
inner join pizza_runner.pizza_names p3
on p3.pizza_id = p1.pizza_id
order by pizza_name, p1.pizza_id)
select pizza_name, group_concat(topping_name) as StandardToppings
from cte
group by pizza_name;

-- What was the most commonly added extra?
drop table if exists numbers;
CREATE TABLE numbers (
  num INT PRIMARY KEY
);
INSERT INTO numbers VALUES
( 1 ), ( 2 ), ( 3 ), ( 4 ), ( 5 ), ( 6 ), ( 7 ), ( 8 ), ( 9 ), ( 10 ),( 11 ), ( 12 ), ( 13 ), ( 14 );
with cte as (SELECT n.num, SUBSTRING_INDEX(SUBSTRING_INDEX(all_tags, ',', num), ',', -1) as one_tag
FROM (
  SELECT
    GROUP_CONCAT(extras SEPARATOR ',') AS all_tags,
    LENGTH(GROUP_CONCAT(extras SEPARATOR ',')) - LENGTH(REPLACE(GROUP_CONCAT(extras SEPARATOR ','), ',', '')) + 1 AS count_tags
  FROM pizzarunner.customer_orders1
) t
JOIN numbers n
ON n.num <= t.count_tags)
select one_tag as Extras,pizza_toppings.topping_name as ExtraTopping, count(one_tag) as Occurrencecount
from cte
inner join pizzarunner.pizza_toppings
on pizza_toppings.topping_id = cte.one_tag
where one_tag != 0
group by one_tag;


-- What was the most common exclusion?
drop table if exists numbers;
CREATE TABLE numbers (
  num INT PRIMARY KEY
);
INSERT INTO numbers VALUES
    ( 1 ), ( 2 ), ( 3 ), ( 4 ), ( 5 ), ( 6 ), ( 7 ), ( 8 ), ( 9 ), ( 10 ),( 11 ), ( 12 ), ( 13 ), ( 14 );
with cte as (SELECT n.num, SUBSTRING_INDEX(SUBSTRING_INDEX(all_tags, ',', num), ',', -1) as one_tag
FROM (
  SELECT
    GROUP_CONCAT(exclusions SEPARATOR ',') AS all_tags,
    LENGTH(GROUP_CONCAT(exclusions SEPARATOR ',')) - LENGTH(REPLACE(GROUP_CONCAT(exclusions SEPARATOR ','), ',', '')) + 1 AS count_tags
  FROM pizzarunner.customer_orders
) t
JOIN numbers n
ON n.num <= t.count_tags)
select one_tag as Exclusions,pizza_toppings.topping_name as ExclusionTopping, count(one_tag) as Occurrencecount
from cte
inner join pizzarunner.pizza_toppings
on pizza_toppings.topping_id = cte.one_tag
where one_tag != 0
group by one_tag
order by Occurrencecount desc;




-- Generate an order item for each record in the customers_orders table in the format of one of the following:
-- Meat Lovers
-- Meat Lovers - Exclude Beef
-- Meat Lovers - Extra Bacon
-- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
-- Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
-- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
-- What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
select customer_orders1.order_id, customer_orders1.pizza_id, pizza_names.pizza_name, customer_orders1.exclusions, customer_orders1.extras, 
case
when customer_orders1.pizza_id = 1 and (exclusions is null or exclusions=0) and (extras is null or extras=0) then 'Meat Lovers'
when customer_orders1.pizza_id = 2 and (exclusions is null or exclusions=0) and (extras is null or extras=0) then 'Veg Lovers'
when customer_orders1.pizza_id = 2 and (exclusions =4 ) and (extras is null or extras=0) then 'Veg Lovers - Exclude Cheese'
when customer_orders1.pizza_id = 1 and (exclusions =4 ) and (extras is null or extras=0) then 'Meat Lovers - Exclude Cheese'
when customer_orders1.pizza_id=1 and (exclusions like '%3%' or exclusions =3) and (extras is null or extras=0) then 'Meat Lovers - Exclude Beef'
when customer_orders1.pizza_id =1 and (exclusions is null or exclusions=0) and (extras like '%1%' or extras =1) then 'Meat Lovers - Extra Bacon'
when customer_orders1.pizza_id=1 and (exclusions like '1, 4' ) and (extras like '6, 9') then 'Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers'
when customer_orders1.pizza_id=1 and (exclusions like '2, 6' ) and (extras like '1, 4') then 'Meat Lovers - Exclude BBQ Sauce,Mushroom - Extra Bacon, Cheese'
when customer_orders1.pizza_id=1 and (exclusions =4) and (extras like '1, 5') then 'Meat Lovers - Exclude Cheese - Extra Bacon, Chicken'
end as OrderItem
from customer_orders1
inner join pizza_names
on pizza_names.pizza_id = customer_orders1.pizza_id;


-- D. Pricing and Ratings
-- If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes 
how much money has Pizza Runner made so far if there are no delivery fees?
   select sum(case 
when c.pizza_id = 1 then 12
else 10
end) as TotalAmount
from runner_orders1 as r
inner join customer_orders1 as c
on c.order_id = r.order_id
where r.distance is not null;

-- What if there was an additional $1 charge for any pizza extras?
-- Add cheese is $1 extra
set @basecost = 138;
select (LENGTH(group_concat(extras)) - LENGTH(REPLACE(group_concat(extras), ',', '')) + 1) + @basecost as Total
from customer_orders1
inner join runner_orders1
on customer_orders1.order_id = runner_orders1.order_id
where extras is not null and extras !=0 and distance is not null;

/*The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, 
how would you design an additional table for this new dataset - 
generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
Using your newly generated table - 
can you join all of the information together to form a table which has the following information for successful deliveries?
customer_id
order_id
runner_id
rating
order_time
pickup_time
Time between order and pickup
Delivery duration
Average speed
Total number of pizzas*/
set @pizzaamountearned = 138;
select @pizzaamountearned - (sum(distance))*0.3 as Finalamount
from runner_orders1;

/*If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?
set @pizzaamountearned = 138;
select @pizzaamountearned - (sum(distance))*0.3 as Finalamount
from runner_orders1;
