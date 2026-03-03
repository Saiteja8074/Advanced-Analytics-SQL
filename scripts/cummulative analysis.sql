-- cummulative analysis
-- calculate running total and moving average 
select
month,
total_sales,
sum(total_sales) over (order by month) as running_total,
avg_price,
round(avg(avg_price) over (order by month)) as moving_average
from 
  (SELECT
date_format(order_date,'%Y-%m') AS month,
SUM(sales) AS total_sales,
round(avg(price)) as avg_price
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP By date_format(order_date,'%Y-%m'))t;
