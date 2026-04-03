/* =============================================================
     customer segmentation
     3- high vs low value customers
==============================================================*/
with customer_spending as
(
select 
    customer_id,
    country,
    count(invoice_no) total_invoices,
    sum(quantity) total_quantity,
    round(sum(unit_price * quantity),2) total_spent,
    round(sum(unit_price * quantity) / count(invoice_no),2) average_order_value,
    case
        when sum(unit_price * quantity) >= 1000 then 'High Value Customer'
        when sum(unit_price * quantity) < 1000 then 'Low Value Customer'
        else 'Unknown'
    end as customer_type
from online_retail_transaction.online_retail_cleaned
group by customer_id, country
order by total_spent desc
), country_segmentation as
(
select
    customer_type,
    country,
    count(customer_type) no_of_customer_type,
    sum(total_invoices) as total_invoices,
    sum(total_quantity) as total_quantity,
    round(sum(total_spent),2) as total_spent
from customer_spending
group by customer_type, country
order by total_spent desc
), country_pivot as
(
select
    country,
    max(case 
            when customer_type = 'High Value Customer' 
            then no_of_customer_type else 0 end)  high_value_customers,
    sum(case
             when customer_type = 'High Value Customer' 
             then total_invoices else 0 end) as high_value_invoices,
    sum(case
            when customer_type = 'High Value Customer' 
            then total_quantity else 0 end) as high_value_quantity,
    round(sum(case 
                when customer_type = 'High Value Customer' 
                then total_spent else 0 end),2) as high_value_sales,
    max(case 
            when customer_type = 'Low Value Customer' 
            then no_of_customer_type else 0 end) as low_value_customers,
    sum(case
             when customer_type = 'Low Value Customer' 
             then total_invoices else 0 end) as low_value_invoices,
    sum(case
             when customer_type = 'Low Value Customer' 
             then total_quantity else 0 end) as low_value_quantity,
    round(sum(case
                 when customer_type = 'Low Value Customer'
                  then total_spent else 0 end),2) as low_value_sales
from country_segmentation
group by country
)
select
    country,
    high_value_customers,
    low_value_customers,
    high_value_customers + low_value_customers as total_customers,
    concat(round(high_value_customers / 
        (high_value_customers + low_value_customers) * 100, 2), ' %') as high_value_percentage,
    high_value_invoices,
    high_value_quantity,
    high_value_sales,
    concat(round(low_value_customers /
        (high_value_customers + low_value_customers) * 100, 2), ' %') as low_value_percentage,
    low_value_invoices,
    low_value_quantity,
    low_value_sales
from country_pivot
order by total_customers desc;
