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
