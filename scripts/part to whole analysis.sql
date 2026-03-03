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
