/* 
------------------------------------------------------------------------------------------------------------------------------------------
                                                 Customer Report
-------------------------------------------------------------------------------------------------------------------------------------------
purpose:
      - This report consolidates key customer metrics and behaviours
highlights:
      1.gathers essential fields such as names,ages and transaction details.
      2.segment customers into categories(vip,regular,new) and age groups.
      3.aggregates customer level metrics:
        -total orders 
        -total sales
        -total quantity purchased
        -total products 
        -lifespan(in months)
      4.calculate valuable KPIs :
        -recency (months since last order)
        -average order values
        -average monthly spend
 -----------------------------------------------------------------------------------------------------------------------------------------
 */
 create view gold.report_customers as
 with base_query as (
 -- base query:retrive core columns from tables
 select 
 f.order_number,
 f.product_key,
 f.order_date,
 f.sales,
 f.quantity,
c.customer_key,
c.customer_number,
concat(first_name,' ',last_name) customer_name,
timestampdiff(year,c.birth_date,curdate()) age
from gold.fact_sales f
left join gold.dim_customers c
on f.customer_key=c.customer_key
where order_date is not null),
customer_agg as (
-- customer aggregation :summarizes key metrics at the customer level
select 
customer_key,
customer_number,
customer_name,
age,
count(distinct order_number) as total_orders,
sum(sales) as total_sales,
sum(quantity) as total_quantity,
count(distinct product_key) as total_products,
max(order_date) as last_order,
timestampdiff(month,min(order_date),max(order_date)) as lifespan
from base_query
where customer_key is not null
group by customer_key,
customer_number,
customer_name,age)
select
customer_key,
customer_number,
customer_name,
age,
case when age < 20 then 'under 20'
     when age between 20 and 50 then'20-50'
     else 'above 50'
end as age_group,     
case when lifespan>=12 and total_sales>5000 then 'vip'
    when lifespan>=12 and total_sales<=5000 then 'regular'
    else 'new'
end as customer_segment,
total_orders,
total_sales,
-- average order value
case when total_orders=0 then 0
    else round(total_sales/total_orders)
end as avg_order_value,
total_quantity,
total_products,
last_order,
timestampdiff(month,last_order,curdate()) as recency,
lifespan,
-- averge monthly spend
case when lifespan=0 then total_sales
     else round(total_sales/lifespan)
end as average_monthly_spend     
from customer_agg;
/*
-----------------------------------------------------------------------------------------------------------------------------------------
                                                     Product Report
-----------------------------------------------------------------------------------------------------------------------------------------
purpose:
	 - This report consolidates key product metrics and behaviours
highlights:
      1.gathers essential fields such as product names,category,sub-category and cost.
      2.segment products by revenue to identify high-performers,mid-range,low-performers.
      3.aggregates product level metrics:
        -total orders 
        -total sales
        -total quantity sold
        -total customers 
        -lifespan(in months)
      4.calculate valuable KPIs :
        -recency (months since last sale)
        -average order revenue
        -average monthly revenue    
-----------------------------------------------------------------------------------------------------------------------------------------
*/
create view gold.report_product as
 with base_query as (
 -- base query:retrive core columns from tables
 select 
 f.order_number,
 f.customer_key,
 f.order_date,
 f.sales,
 f.quantity,
 p.product_key,
 p.product_name,
 p.category,
 p.subcategory,
 p.cost
from gold.fact_sales f
left join gold.dim_products p
on f.product_key=p.product_key
where order_date is not null),
product_agg as (
-- product aggregation:summarize key metrics at product level
select
product_key,
product_name,
category,
subcategory,
cost,
count(distinct order_number) as total_orders,
sum(sales) as total_sales,
sum(quantity) as total_quantity,
count(distinct customer_key) as total_customers,
max(order_date) as last_order,
timestampdiff(month,min(order_date),max(order_date)) as lifespan,
round(avg(sales/nullif(quantity,0)),1) as avg_selling_price
from base_query
group by product_key,
product_name,
category,
subcategory,
cost)
-- final query:combine all product results into one output
select 
product_key,
product_name,
category,
subcategory,
cost,
total_orders,
total_sales,
total_quantity,
total_customers,
case when total_sales>50000 then 'high-performer'
     when total_sales>=10000 then 'mid-range'
     else 'low-performer'
end as product_segment,     
last_order,
timestampdiff(month,last_order,curdate()) as recency,
lifespan,
avg_selling_price,
-- average order revenue
case when total_orders=0 then 0
    else total_sales/total_orders
end as average_order_revenue,
-- average monthly revenue
case when lifespan=0 then total_sales
     else total_sales/lifespan
end as avg_monthly_revenue     
from product_agg;
-- ----------------------------------------------------------------------------------------------------------------------------------------


-- change over time
select
year(order_date) as order_year,
month(order_date) as order_month,
sum(sales) as total_sales,
count(distinct customer_id) as total_customer,
sum(quantity) as total_quantity
from gold.fact_sales
where order_date is not null
group by year(order_date),month(order_date)
order by order_year,order_month;

-- cummulative analysis
-- calculate running total and moving average 
select
month,
total_sales,
sum(total_sales) over (order by month) as running_total,
avg_price,
round(avg(avg_price) over (order by month)) as moving_average
from (SELECT
date_format(order_date,'%Y-%m') AS month,
SUM(sales) AS total_sales,
round(avg(price)) as avg_price
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP By date_format(order_date,'%Y-%m'))t;

-- performance analysis
/* analyze yearly performance of products by comparing their sales to both average sales performance of products and previous year's sales*/
with yearly_sales as (
select 
year(f.order_date) as order_year,
p.product_name,
sum(f.sales) as current_sales
from gold.fact_sales f
left join gold.dim_products p
on f.product_key=p.product_key
where order_date is not null
group by year(f.order_date),p.product_name)
select 
order_year,
product_name,
current_sales,
round(avg(current_sales) over (partition by product_name)) as avg_sales,
current_sales-round(avg(current_sales) over (partition by product_name)) as diff_avg,
case when current_sales-round(avg(current_sales) over (partition by product_name)) >0 then 'above avg'
     when current_sales-round(avg(current_sales) over (partition by product_name)) <0 then 'below avg'
     else 'avg'
end as avg_change,
lag(current_sales) over(partition by product_name order by order_year) as py_sales,
current_sales-lag(current_sales) over(partition by product_name order by order_year) as diff_py_sales,
case when current_sales-lag(current_sales) over(partition by product_name order by order_year) > 0 then 'Increase'
     when current_sales-lag(current_sales) over(partition by product_name order by order_year) < 0 then 'Decrease'
     else 'No Change'
end as py_change
from yearly_sales;

-- part to whole analysis
-- which categories contribute more to overall sales
with sales as (
select
category,
sum(sales) as total_sales
from gold.fact_sales f
left join gold.dim_products p
on f.product_key=p.product_key
group by category)
select 
category,
total_sales,
sum(total_sales) over () as overall_sales,
concat(round(total_sales/sum(total_sales) over (),3) * 100,'%') as percentage_sales
from sales;

-- data segmentation
/* segment products into cost ranges and count how many products fall into each segment*/
with product_segment as (
select 
product_key,
product_name,
cost,
case when cost<100 then 'below 100'
     when cost between 100 and 500 then '100-500'
     when cost between 500 and 1000 then '500-1000'
     else 'above 1000'
end as cost_range
from gold.dim_products )
select 
cost_range,
count(product_key) as total_products
from product_segment
group by cost_range
order by total_products desc;

/*
 group customers into three segments based on their spending behaviour:
  - vip: customers with at least 12 months of history and spending more than 5,000.
  - regular: customers with at least 12 months of history but spending 5,000 or less.
  - new:customers with a lifespan less than 12 months
  and find total number of customers by each group 
  */
with cte as (
select 
c.customer_key,
sum(f.sales) as total_sales,
min(order_date) as first_order,
max(order_date) as last_order,
timestampdiff(month,min(order_date),max(order_date)) as lifespan
from gold.fact_sales f
left join gold.dim_customers c
on f.customer_key=c.customer_key
group by customer_key),
cte2 as (
select 
customer_key,
total_sales,
lifespan,
case when lifespan>=12 and total_sales>5000 then 'vip'
    when lifespan>=12 and total_sales<=5000 then 'regular'
    else 'new'
end as customer_segment
from cte)
select
customer_segment,
count(customer_key) as total_customers
from cte2
group by customer_segment
order by total_customers desc;
