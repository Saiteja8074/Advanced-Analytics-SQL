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
