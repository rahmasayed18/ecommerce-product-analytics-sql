/* =============================================================
     customer segmentation
     2- demographics segmentation
==============================================================*/

select 
    country,
    count(distinct customer_id) total_customers,
    count(distinct invoice_no) as total_invoices,
    sum(quantity)   as total_quantity,
    round(sum(unit_price),2) as total_sales,
    round(sum(unit_price) / count(distinct customer_id),2) avg_sales_per_customer,
    round(count(distinct invoice_no) / count(distinct customer_id),2) avg_orders_per_customer,
    round(avg(unit_price),2) as average_unit_price,
    round(avg(quantity),2)   as average_quantity,
    round(100 *count(distinct customer_id) / 
        (select count(distinct customer_id) 
        from online_retail_transaction.online_retail_cleaned),2) customer_percentage,
    round(100 *sum(unit_price) / 
        (select sum(unit_price) 
        from online_retail_transaction.online_retail_cleaned),2) revenue_share
from online_retail_transaction.online_retail_cleaned
group by  country
order by total_sales desc;
