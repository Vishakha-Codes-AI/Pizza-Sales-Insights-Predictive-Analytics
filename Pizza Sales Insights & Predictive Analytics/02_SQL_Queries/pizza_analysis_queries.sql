create database pizza_sales;       -- create new database pizza_sales
 
use pizza_sales;                   -- active/use pizza_sales database  

select * from order_details;       -- show order_details table  records 
select * from orders;              -- show orders table records  
select * from pizza_types ;        -- show pizza_types table records 
select * from pizzas;              -- show pizzas table records 

alter table orders modify  column  date date ;               -- convert datatype of  date column into  DATE 
alter table orders modify  column  time time ;               -- convert datatype of time column into TIME
 
alter table pizzas change column  pizza_type_id pizza_type_id varchar(20) ;              -- change pizza_type_id  datatype into VARCHAR(20) 
alter table pizzas change column  pizza_id pizza_id varchar(20) ;                        -- change pizza_id  datatype into VARCHAR(20)
 
alter table pizza_types modify column   name varchar(50) ;                      -- convert datatype of name column into varchar(50)
alter table pizza_types modify column   category varchar(20) ;                  -- convert datatype of category column into varchar(50)
alter table pizza_types modify column   ingredients varchar(100) ;              -- convert datatype of ingredients column into varchar(50)
alter table pizzas modify column  size varchar(5) ;                             -- convert datatype of size column into varchar(50)
alter table order_details modify  column pizza_id varchar(20) ;                 -- convert datatype of pizza_id column into varchar(50)


SELECT time ,DATE_FORMAT(date,'%d-%m-%y') AS date                           -- display  date in custom format (DD-MM-YY)
FROM orders ;                                                        

alter table order_details add primary key (order_details_id);                  -- set order_details_id  as primary key
alter table orders add primary key (order_id);                                 -- set order_id  as primary key
alter table pizza_types add primary key (pizza_type_id);                       -- set pizza_type_id  as primary key
alter table pizzas  add primary key (pizza_id);                                -- set pizza_id  as primary key


ALTER TABLE order_details                                                    -- set  order_details as foreign key refrence from orders table
ADD FOREIGN KEY (order_id) REFERENCES orders(order_id);  
ALTER TABLE pizzas                                                           -- set  pizza_type_id as foreign key refrence from pizza_types table
ADD FOREIGN KEY (pizza_type_id) REFERENCES pizza_types(pizza_type_id);  


desc pizza_types;                      -- show  structure pizza_types 
desc pizzas;                           -- show  structure pizzas
desc order_details;                    -- show  structure order_details
desc orders;                           -- show  structure orders


-- 1. Retrieve the total number of orders placed.

SELECT 
    COUNT(order_details_id) AS total_order            -- Counts the grand total of orders
  FROM 
      order_details;                                  -- Main transactions table
  

-- 2.Calculate the total revenue generated from pizza sales.

SELECT 
    SUM(o.quantity * p.price) AS total_pizza_revenue  -- Multiplies quantity by price and sums up the total revenue
    FROM 
      order_details o                                 -- Primary transaction table (aliased as 'o')
  INNER JOIN  
    pizzas p                                          -- Product lookup table containing prices (aliased as 'p')
   ON 
     o.pizza_id = p.pizza_id;                         -- Matching key to connect both tables
  
-- 3. Identify the highest-priced pizza.

SELECT 
     pt.name, p.price                                         -- Selects pizza name and its price
FROM 
    pizza_types pt                                            -- Main table with pizza names and details
INNER JOIN 
     pizzas p ON pt.pizza_type_id = p.pizza_type_id           -- Product table containing price data
   ORDER BY price DESC                                        -- Sorts from highest to lowest price
LIMIT 1;                                                      -- Fetches only the single most expensive item


-- 4. Identify the most common pizza size ordered.

SELECT 
   size, COUNT(*) AS OrderCount                 -- Selects pizza size and total orders for each size
FROM 
    order_details od                            -- Transaction table containing order details
INNER JOIN 
    pizzas p ON od.pizza_id = p.pizza_id        -- Product table containing size details
GROUP BY size                                   -- Groups the final count by pizza size
ORDER BY OrderCount DESC                        -- Sorts from highest to lowest order volume
LIMIT 1;                                        -- Fetches only the single most popular size


-- 5.List the top 5 most ordered pizza types along with their quantities.

SELECT 
   pt.name, p.pizza_type_id, COUNT(*) AS Quantity                -- Selects pizza name, ID, and total quantity sold
FROM 
    pizzas p                                                     -- Product table containing pizza type IDs
INNER JOIN 
      pizza_types pt ON p.pizza_type_id = pt.pizza_type_id       -- Lookup table containing actual pizza names
INNER JOIN 
      order_details od ON od.pizza_id = p.pizza_id               -- Transaction table containing order details
GROUP BY pt.name, p.pizza_type_id                                -- Groups the total count by name and ID
ORDER BY Quantity DESC                                           -- Sorts from highest to lowest quantity sold
LIMIT 5;                                                         -- Fetches only the top 5 best-selling pizzas


-- 6. Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
   pt.category, SUM(od.quantity) AS total_quantity                -- Selects pizza category and total quantities sold
    FROM 
    order_details od                                              -- Transaction table containing order details
    INNER JOIN 
    pizzas p ON od.pizza_id = p.pizza_id                          -- Product table to link pizza IDs
    INNER JOIN 
   pizza_types pt ON p.pizza_type_id = pt.pizza_type_id           -- Lookup table containing the category names
  GROUP BY pt.category                                            -- Groups the total quantities by each pizza category
ORDER BY total_quantity ASC;                                      -- Sorts from lowest to highest sales volume (ASC)


-- 7. Determine the distribution of orders by hour of the day.

SELECT 
    CONCAT(HOUR(`time`), ' hour') AS order_hour,            -- Formats the order hour (e.g., '13 hour')
    COUNT(order_id) AS total_orders                         -- Counts total orders for each hour block
    FROM 
    orders                                                  -- Main table containing order timestamps
    GROUP BY order_hour                                     -- Groups the order counts by each specific hour
ORDER BY order_hour;                                        -- Sorts sequentially from the start of the day


-- 8. Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    pt.category, COUNT(p.pizza_id) AS total_pizzas             -- Selects pizza category and counts total pizza variants
    FROM
    pizzas p                                                   -- Product table containing all unique pizza options
    JOIN 
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id       -- Lookup table containing the category names
    GROUP BY pt.category                                       -- Groups the pizza counts by each category
ORDER BY total_pizzas DESC;                                    -- Sorts from highest to lowest product count

-- 9. Group the orders by date and calculate the average number of pizzas ordered per day.
 SELECT 
     AVG(daily_total) AS avg_pizzas_per_day            -- Calculates the final average of pizzas sold per day
FROM (
    SELECT 
        o.date,                                        -- Selects the unique order date
        SUM(od.quantity) AS daily_total                -- Sums total pizzas sold on that date
    FROM orders o                                      -- Main table with order dates
    JOIN order_details od                              -- Links order dates with quantities sold
        ON o.order_id = od.order_id
    GROUP BY o.date                                    -- Groups total quantities by each date
) AS daily_orders;                                     -- Named subquery table to calculate the final average



-- 10.Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pt.name AS pizza_type,                                 -- Selects the actual name of the pizza
    SUM(od.quantity * p.price) AS revenue                  -- Multiplies quantity by price and sums up the total revenue
FROM order_details od                                      -- Transaction table containing order details
JOIN pizzas p                                              -- Links pizza IDs to get individual prices
    ON od.pizza_id = p.pizza_id
    JOIN pizza_types pt                                    -- Links pizza type IDs to get actual names
    ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name                                           -- Groups the total revenue calculation by each pizza name
ORDER BY revenue DESC                                      -- Sorts the revenue from highest to lowest
LIMIT 3;                                                   -- Fetches only the top 3 highest-earning pizzas


-- 11.Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pt.name AS pizza_name,                                                      -- Selects the unique name of the pizza
    CONCAT(
        ROUND(                                      
            SUM(od.quantity * p.price) * 100.0 /                                -- Calculates current pizza revenue multiplied by 100
            (SELECT SUM(od2.quantity * p2.price)                                -- Subquery: Calculates the grand total revenue of all pizzas combined
             FROM order_details od2
             JOIN pizzas p2 ON od2.pizza_id = p2.pizza_id), 
            2-- Rounds the calculated percentage value to 2 decimal places
        ), 
       '%'                                                                       -- Appends the '%' symbol to the final percentage value
    ) AS revenue_percentage
FROM order_details od                                                            -- Transaction table containing order details
JOIN pizzas p                                                                    -- Links pizza IDs to get product pricing
    ON od.pizza_id = p.pizza_id
JOIN pizza_types pt                                                              -- Links pizza type IDs to fetch the actual names
    ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name                                                                 -- Groups calculations by each specific pizza name
ORDER BY revenue_percentage DESC;                                                -- Sorts percentage values from highest to lowest contribution



-- 12. Analyze the cumulative revenue generated over time.

SELECT                                                                            -- Selects the date from the subquery
    daily.date,                                                                   -- Calculates the running total (cumulative) revenue over time
    SUM(daily_revenue) OVER (ORDER BY daily.date) AS cumulative_revenue
FROM (
    SELECT                                                                        -- Selects the unique order date
        o.date,                                                                   -- Calculates total revenue generated for each specific day
        SUM(od.quantity * p.price) AS daily_revenue
    FROM orders o                                                                 -- Main table containing order dates
    JOIN order_details od                                                         -- Links orders with quantity data
        ON o.order_id = od.order_id
    JOIN pizzas p                                                                 -- Links data to get individual pizza prices
        ON od.pizza_id = p.pizza_id
    GROUP BY date                                                                 -- Groups daily revenue calculations by date
) AS daily                                                                        -- Temporary table alias for the subquery
ORDER BY daily.date;                                                              -- Sorts the final cumulative report chronologically
    
    
-- 13. Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT                                    
    category, pizza_name, revenue                                 -- Selects category, pizza name, and revenue from the ranked subquery
FROM (
    SELECT 
        pt.category, pt.name AS pizza_name,                       -- Selects the pizza category and individual name
        SUM(od.quantity * p.price) AS revenue,                    -- Multiplies quantity by price to get total revenue per pizza
         RANK() OVER (                                            -- Creates ranks within each category based on revenue
             PARTITION BY pt.category                             -- Splits the ranking blocks dynamically by pizza category
             ORDER BY SUM(od.quantity * p.price) DESC             -- Orders the ranking from highest to lowest revenue
        ) AS rank_in_category
    FROM order_details od                                         -- Main transaction details table
    JOIN pizzas p                                                 -- Links data to fetch individual pizza prices
        ON od.pizza_id = p.pizza_id
    JOIN pizza_types pt                                           -- Links data to fetch pizza names and categories
        ON p.pizza_type_id = pt.pizza_type_id
    GROUP BY pt.category, pt.name                                 -- Groups metrics by both category and pizza name
) ranked                                                          -- Name given to the temporary subquery output
WHERE rank_in_category <= 3                                       -- Filters to keep only the top 3 items for each category
ORDER BY category, rank_in_category;                              -- Sorts final output by category name and then by rank sequence


    




