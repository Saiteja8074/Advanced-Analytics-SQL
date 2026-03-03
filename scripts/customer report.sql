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
