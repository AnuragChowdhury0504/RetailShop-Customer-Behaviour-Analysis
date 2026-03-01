select * from customer limit 20

--1. Top 5 highest average items purchased based on review ratings.
select item_purchased, ROUND(AVG(review_rating::numeric),2) as avg_review_rating_order 
from customer
group by item_purchased
order by avg_review_rating_order desc
limit 5;

--2. Revenue earned from male and female customers.
select gender, SUM(purchase_amount) as total_revenue from customer
group by gender;

--3. Customer purchased more than average after availing discounts.
select customer_id,purchase_amount 
from customer 
where discount_applied='Yes' and purchase_amount >= 
(select AVG(purchase_amount) from customer) 
limit 10; 

--4. Compare the average amount of purchasing between the standard and express shipping.
select shipping_type, ROUND(AVG(purchase_amount),2) from customer
where shipping_type in ('Express','Standard')
group by shipping_type;

--5. Do subscriber spending more? Compare average spend and total revenue earned between non-subscriber and subscriber.
select subscription_status, COUNT(purchase_amount) as available_customer,
ROUND(AVG(purchase_amount),2) as average_spend, ROUND(SUM(purchase_amount),2) as total_revenue
from customer
group by subscription_status
order by total_revenue,average_spend desc;

--6. Which 5 products have the highest percentage of purchases with discount applied.
select item_purchased,
ROUND(100 * SUM(CASE WHEN discount_applied='Yes' THEN 1 ELSE 0 END)/ COUNT(*),2) as purchasing_rate_with_discount
from customer
group by item_purchased
order by purchasing_rate_with_discount desc
limit 5;

/*7. Segment customers into New, Returning and loyal based on 
     their total  number of purchases, also show the count of each segment*/
--Creating temporary table named customer_type and putting the data in a column named customer_segment
with customer_type as (
select  customer_id,previous_purchases,
CASE WHEN previous_purchases = 1 THEN 'New'
     WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
     Else  'Loyal' END AS customer_segment from customer)

	 
select customer_segment, COUNT(*) AS number_of_segmented_customer
from customer_type
group by customer_segment
order by number_of_segmented_customer desc;

--8. What are the top 5 most purchased products within each category.
with item_count_per_category as ( 
select category,item_purchased,count(customer_id)
as total_purchases, 
ROW_NUMBER() over(partition by category order by count(customer_id) desc) 
as item_rank from customer
group by category,item_purchased)

select item_rank,category,item_purchased,total_purchases
from item_count_per_category
where item_rank<=3;

--9. Customers who are repeated buyers (have more previous_purchase>5 ) also likely to subscribe?
select subscription_status,count(customer_id) as repeated_buyer from customer
where previous_purchases>5
group by subscription_status

--10.What is revenue contribution of each age group.
select age_group,sum(purchase_amount) as generated_revenue
from customer
group by age_group
order by generated_revenue desc;