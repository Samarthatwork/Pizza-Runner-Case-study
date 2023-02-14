# :ramen: Case Study #2 - Pizza Runner
![This is an image](https://8weeksqlchallenge.com/images/case-study-designs/2.png)
## INTRODUCTION
> Did you know that over 115 million kilograms of pizza is consumed daily worldwide??? (Well according to Wikipedia anyway…)

Danny was scrolling through his Instagram feed when something really caught his eye - “80s Retro Styling and Pizza Is The Future!”

Danny was sold on the idea, but he knew that pizza alone was not going to help him get seed funding to expand his new Pizza Empire - so he had one more genius idea to combine with it - he was going to Uberize it - and so Pizza Runner was launched!

Danny started by recruiting “runners” to deliver fresh pizza from Pizza Runner Headquarters (otherwise known as Danny’s house) and also maxed out his credit card to pay freelance developers to build a mobile app to accept orders from customers.
## PROBLEM STATEMENT
- Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite. Having this deeper connection with his customers will help him deliver a better and more personalised experience for his loyal customers.

* He plans on using these insights to help him decide whether he should expand the existing customer loyalty program - additionally he needs help to generate some basic datasets so his team can easily inspect the data without needing to use SQL.

+ Danny has provided you with a sample of his overall customer data due to privacy issues - but he hopes that these examples are enough for you to write fully functioning SQL queries to help him answer his questions!

 # **:file_folder: DATASETS**
 Danny has shared with you 3 key datasets for this case study:
   ### **1. RUNNERS**

 <details><summary>
 View Table
 </summary>
The runners table shows the registration_date for each new runner

| runner_id	| | registration_date |
| --------- | | ----------------- |
|    1	     | |     2021-01-01    |
|    2	     | |     2021-01-03    |
|    3	     | |     2021-01-08    |
|    4	     | |     2021-01-15    |

 </details>
    
 ### **2. customer_orders**

 <details><summary>
 View Table
 </summary>
Customer pizza orders are captured in the customer_orders table with 1 row for each individual pizza that is part of the order.

The pizza_id relates to the type of pizza which was ordered whilst the exclusions are the ingredient_id values which should be removed from the pizza and the extras are the ingredient_id values which need to be added to the pizza.

Note that customers can order multiple pizzas in a single order with varying exclusions and extras values even if the pizza is the same type!

The exclusions and extras columns will need to be cleaned up before using them in your queries.

| order_id |	 | customer_id |  | pizza_id |  | exclusions |  | extras |  |     order_time      |
| -------- |  | ----------- |  | -------- |  | ---------- |  | ------ |  | ------------------- |
|    1	    |  |     101	    |  |     1	  	|  |            |  |        |  | 2021-01-01 18:05:02 |
|    2     |  |     101	    |  |     1    |  |            |  |        |  | 2021-01-01 19:00:52 |
|    3     |  |	    102	    |  |     1    |  |            |  |        |  | 2021-01-02 23:51:23 |
|    3	    |  |     102     |	 |     2    |  |            |  |   NaN  |	 | 2021-01-02 23:51:23 |
|    4	    |  |     103	    |  |     1	   |  |     4      |	 |	       |  | 2021-01-04 13:23:46 |
|    4	    |  |     103	    |  |     1	   |  |     4	 	   |  |        |  | 2021-01-04 13:23:46 |
|    4	    |  |     103	    |  |     2	   |  |     4	 	   |  |        |  | 2021-01-04 13:23:46 |
|    5	    |  |     104	    |  |     1	   |  |    null	   |  |   1	   |  | 2021-01-08 21:00:29 |
|    6	    |  |     101	    |  |     2    |	 |    null    |	 |  null  |	 | 2021-01-08 21:03:13 |
|    7	    |  |     105	    |  |     2    |	 |    null    |  |	 1	    |  | 2021-01-08 21:20:29 |
|    8	    |  |     102	    |  |     1    |	 |    null	   |  |  null	 |  | 2021-01-09 23:54:33 |
|    9	    |  |     103	    |  |     1	   |  |     4	     |  |  1, 5	 |  | 2021-01-10 11:22:59 |
|   10	    |  |     104     |	 |     1    |	 |    null	   |  |  null	 |  | 2021-01-11 18:34:49 |
|   10	    |  |     104	    |  |     1    |  |	  2, 6	    |  |  1, 4	 |  | 2021-01-11 18:34:49 |
 
 </details>
 
 ### **3. runner_orders**

 <details><summary>
 View Table
 </summary>
After each orders are received through the system - they are assigned to a runner - however not all orders are fully completed and can be cancelled by the restaurant or the customer.

The pickup_time is the timestamp at which the runner arrives at the Pizza Runner headquarters to pick up the freshly cooked pizzas. The distance and duration fields are related to how far and long the runner had to travel to deliver the order to the respective customer.

There are some known data issues with this table so be careful when using this in your queries - make sure to check the data types for each column in the schema SQL!
  
|  order_id |  | runner_id |  |     pickup_time     |  |	distance   |	 | duration   |	 |      cancellation       |
| --------- |  | --------- |  | ------------------- |  | ---------- |  | ---------- |  | ----------------------- |  
|     1     |	 |     1	    |  | 2021-01-01 18:15:34	|  |    20km	   |  | 32 minutes	|  |                         |
|     2     |	 |     1	    |  | 2021-01-01 19:10:54	|  |    20km    |	 | 27 minutes	|  |                         |
|     3     |  |     1     |	 | 2021-01-03 00:12:37 |	 |    13.4km  |  | 20 mins	   |  |          NaN            |
|     4	    |  |     2     |	 | 2021-01-04 13:53:03 |	 |    23.4	   |  |  40        |  |          NaN            |
|     5	    |  |     3	    |  | 2021-01-08 21:10:57 |	 |    10	     |  |  15        |  |          NaN            |
|     6	    |  |     3	    |  |        null	        |  |    null    |	 |  null      |	 | Restaurant Cancellation |
|     7	    |  |     2     |	 | 2020-01-08 21:30:45	|  |    25km    |	 |  25mins	   |  |          null           |
|     8	    |  |     2     |	 | 2020-01-10 00:15:02	|  |    23.4 km |	 |  15 minute |	 |          null           |
|     9	    |  |     2     |	 |        null	        |  |    null	   |  |  null	     |  |  Customer Cancellation  |
|     10	   |  |     1     |	 | 2020-01-11 18:50:20 |	 |    10km    |	 | 10minutes	 |  |          null           |
 
 </details>
 
  ### **4. pizza_names**

 <details><summary>
 View Table
 </summary>
At the moment - Pizza Runner only has 2 pizzas available the Meat Lovers or Vegetarian!

| pizza_id |  |	pizza_name  |
| -------- |  | ----------- |
|     1    |	 | Meat Lovers |
|     2	   |  | Vegetarian  |
 
 </details>
 
   ### **5. pizza_recipe**

 <details><summary>
 View Table
 </summary>
Each pizza_id has a standard set of toppings which are used as part of the pizza recipe.

| pizza_id |  |	    toppings     |
| -------- |  | ---------------- |
|     1    |	 | 1,2,3,4,5,6,8,10 |
|     2	   |  | 4,6,7,9,11,12    |
 
 </details>
 
 
   ### **6. pizza_toppings**

 <details><summary>
 View Table
 </summary>
This table contains all of the topping_name values with their corresponding topping_id value

| topping_id |	 | topping_name |
| ---------- |  | ------------ |
|     1      |	 |     Bacon    |
|     2	     |  |  BBQ Sauce   |
|     3	     |  |     Beef     |
|     4	     |  |    Cheese    |
|     5	     |  |    Chicken   |
|     6	     |  |   Mushrooms  |
|     7	     |  |   Onions     |
|     8	     |  |  Pepperoni   |
|     9	     |  |  Peppers     |
|    10	     |  |   Salami     |
|    11	     |  |  Tomatoes    |
|    12	     |  | Tomato Sauce |
 
 </details>

 # :speech_balloon: CASE STUDY QUESTIONS
 
  # :speech_balloon: A. Pizza Metrics
  
1. How many pizzas were ordered?
2. How many unique customer orders were made?
3. How many successful orders were delivered by each runner?
4. How many of each type of pizza was delivered?
5. How many Vegetarian and Meatlovers were ordered by each customer?
6. What was the maximum number of pizzas delivered in a single order?
7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
8. How many pizzas were delivered that had both exclusions and extras?
9. What was the total volume of pizzas ordered for each hour of the day?
10. What was the volume of orders for each day of the week?

# :speech_balloon: B. Runner and Customer Experience

1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
4. What was the average distance travelled for each customer?
5. What was the difference between the longest and shortest delivery times for all orders?
6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
7. What is the successful delivery percentage for each runner?

# :speech_balloon: C. Ingredient Optimisation

1. What are the standard ingredients for each pizza?
2. What was the most commonly added extra?
3. What was the most common exclusion?
4. Generate an order item for each record in the customers_orders table in the format of one of the following:
Meat Lovers
Meat Lovers - Exclude Beef
Meat Lovers - Extra Bacon
Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

# :speech_balloon: D. Pricing and Ratings

1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
2. What if there was an additional $1 charge for any pizza extras?
Add cheese is $1 extra
3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
customer_id
order_id
runner_id
rating
order_time
pickup_time
Time between order and pickup
Delivery duration
Average speed
Total number of pizzas
5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?
 
 ## **:dart: INSIGHTS GENERATED**
 1. Ramen was the most favorite dish/ ordered item by all the customers with ordered 8 times.
 2. Customer with Id 'A' ordered the most while Customer with ID 'B' spent the least amount
 3. Customer with Id 'B' visited more in the restaurant i.e., **6 times**.
