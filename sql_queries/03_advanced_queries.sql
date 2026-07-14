-- Question Set 3 (Advance)

-- Q1. Find how much amount spent by each customer on artists? Return customer name, artist name and total spent.
-- To calculate spending per artist, we multiply UnitPrice by Quantity from the invoice_line table.
SELECT 
    c.first_name || ' ' || c.last_name AS customer_name, 
    art.name AS artist_name, 
    SUM(il.unit_price * il.quantity) AS total_spent
FROM customer c
INNER JOIN invoice i ON c.customer_id = i.customer_id
INNER JOIN invoice_line il ON i.invoice_id = il.invoice_id
INNER JOIN track t ON il.track_id = t.track_id
INNER JOIN album alb ON t.album_id = alb.album_id
INNER JOIN artist art ON alb.artist_id = art.artist_id
GROUP BY c.customer_id, art.artist_id
ORDER BY total_spent DESC;

-- Q2. Find out the most popular music Genre for each country (highest purchases). 
-- If the maximum number of purchases is shared, return all Genres.
-- We use a Common Table Expression (CTE) to find the purchase counts, and DENSE_RANK() to handle ties cleanly.
WITH popular_genre AS (
    SELECT 
        c.country, 
        g.name AS genre_name, 
        COUNT(il.quantity) AS purchases,
        -- DENSE_RANK() ranks rows inside each country partition. 
        -- Rank 1 will be assigned to the genre(s) with the highest total purchases.
        -- If two genres tie for first, both receive Rank 1, satisfying the edge case.
        DENSE_RANK() OVER(PARTITION BY c.country ORDER BY COUNT(il.quantity) DESC) AS rank_num
    FROM customer c
    INNER JOIN invoice i ON c.customer_id = i.customer_id
    INNER JOIN invoice_line il ON i.invoice_id = il.invoice_id
    INNER JOIN track t ON il.track_id = t.track_id
    INNER JOIN genre g ON t.genre_id = g.genre_id
    GROUP BY c.country, g.genre_id
)
-- Filtering out any genres that didn't achieve the #1 spot in their respective country
SELECT country, genre_name, purchases
FROM popular_genre
WHERE rank_num = 1;


-- Q3. Write a query that determines the customer that has spent the most on music for each country. 
-- Write a query that returns the country along with the top customer and how much they spent. 
-- For countries where the top amount spent is shared, provide all customers who spent this amount.

with customer_with_country as(
				select customer.customer_id, first_name, last_name, billing_country, SUM(total) as total_spending,
				Row_number() over (partition by billing_country order by sum(total) desc) as RowNo
				from invoice
				join customer on customer.customer_id = invoice.customer_id
				group by 1,2,3,4
				order by 4 asc, 5 desc)

select * from customer_with_country where RowNo = 1