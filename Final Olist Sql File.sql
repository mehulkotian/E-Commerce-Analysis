use e_commerce_olist_excelr;

-- KPI 1 :- Weekday Vs Weekend (order_purchase_timestamp) Payment Statistics

Select weat.duration, concat(round(weat.tot_pay / (Select sum(payment_value) from olist_order_payments_dataset) * 100, 2), '%') as percentage_payment_values
from (Select dist.duration, sum(invoice.payment_value) as tot_pay
from olist_order_payments_dataset as invoice JOIN
(Select distinct order_id, 
case
when WEEKDAY(order_purchase_timestamp) in (5,6) then "Weekend"
else "Weekday"
end as duration
from olist_orders_dataset) as dist on dist.order_id = invoice.order_id
group by dist.duration) as weat;


-- KPI 2 :- Number of Orders with review score 5 and payment type as credit card.

Select COUNT(invoice.order_id) as All_Orders from olist_order_payments_dataset invoice
INNER JOIN olist_order_reviews_dataset r on invoice.order_id = r.order_id
where r.review_score = 5
and invoice.payment_type = 'credit_card';


-- KPI 3 :- Average number of days taken for order_delivered_customer_date for pet_shop

Select pro.product_category_name, round(avg(datediff(or1.order_delivered_customer_date, or1.order_purchase_timestamp))) as average_deliv_days
from olist_orders_dataset or1 JOIN
(Select product_id, order_id, product_category_name from olist_products_dataset
JOIN olist_order_items_dataset using (product_id)) as pro
on or1.order_id = pro.order_id
where pro.product_category_name = "Pet_shop"
group by pro.product_category_name;


-- KPI 4 :- Average price and payment values from customers of sao paulo city

-- Step 1: Get orders from customers in Sao Paulo
Create temporary table saopaulo_ord as
Select ord.order_id
from olist_orders_dataset ord
JOIN olist_customers_dataset cust on ord.customer_id = cust.customer_id
where cust.customer_city = 'Sao Paulo';

-- Step 2: Calculate averages using the temporary table
Select avg(item.price) as avg_order_item_price, 
avg(pmt.payment_value) as avg_payment_value
from olist_order_items_dataset item
JOIN saopaulo_ord spo on item.order_id = spo.order_id
JOIN olist_order_payments_dataset pmt on spo.order_id = pmt.order_id;


-- KPI 5 :- Relationship between shipping days (order_delivered_customer_date - order_purchase_timestamp) Vs review scores.

Select re.review_score, round(avg(datediff(or1.order_delivered_customer_date, or1.order_purchase_timestamp)), 0) as Average_shipp_date
from olist_orders_dataset as or1
JOIN olist_order_reviews_dataset as re on re.order_id = or1.order_id
group by re.review_score order by re.review_score ;