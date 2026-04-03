/*-----------------------------------------
     Product Sales Pareto Analysis
     (To be updated later)
------------------------------------------------*/
drop view if exists online_retail_transaction.vw_pareto_analysis;
create view online_retail_transaction.vw_pareto_analysis as
with sales_data as
(
    select
        description product,
        count(quantity) as total_quantity,
        round(sum(unit_price * quantity), 2) as total_sales
    from
        online_retail_transaction.online_retail_cleaned
    group by customer_id, description
), grand_total as
(
    select
        sum(total_sales) as grand_total_sales
    from sales_data
), ranked_sales as
(
    select 
        product,
        total_quantity,
        total_sales,
        concat(round(total_sales * 100.0 / (select grand_total_sales from grand_total), 2), ' %') as sales_percentage,
        round(sum(total_sales) over (order by total_sales desc), 2) as cumulative_sales,
        concat(round(sum(total_sales) over (order by total_sales desc) * 100.0 / 
        (select grand_total_sales from grand_total), 2), ' %') as cumulative_percentage  
    from sales_data
    order by total_sales desc
)

select *
from ranked_sales
where cumulative_percentage <= 80
order by total_sales desc;
