/* =============================================================
     customer segmentation
     1- RFM segmentation
==============================================================*/
with rfm as
(
select 
    customer_id,
    max(invoice_date) as last_purchase_date,
    min(invoice_date) as first_purchase_date,
    TIMESTAMPDIFF(month,  max(invoice_date),'2012-01-01') as recency_months,
    count(distinct invoice_no) as frequency,
    round(sum(unit_price * quantity),2) as monetary_value
from online_retail_transaction.online_retail_cleaned
where invoice_no not like 'C%'
group by customer_id
order by monetary_value desc)

select
    customer_id,
    last_purchase_date,
    first_purchase_date,
    recency_months,
    frequency,
    monetary_value,
    case
        when recency_months <= 1 and frequency >= 5 and monetary_value >= 100 then 'Champions'
        when recency_months <= 3 and frequency >= 3 and monetary_value >= 50 then 'Loyal Customers'
        when recency_months <= 6 and frequency >= 2 and monetary_value >= 20 then 'Potential Loyalists'
        when recency_months > 6 and frequency < 2 and monetary_value < 20 then 'At Risk'
        else 'Others'
    end as segment
from rfm
order by monetary_value desc;

