-- change overtime
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
