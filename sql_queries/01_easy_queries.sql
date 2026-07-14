-- Question Set 1 (Easy)
-- Q1: Who is the most senior employee based on job title?

-- Selecting the employee details
SELECT title, last_name, first_name
FROM employee
-- Sorting by levels/seniority (assuming higher levels mean senior, or using hire_date if level isn't explicit)
-- Here we order by levels descending to find the top manager/executive
ORDER BY levels DESC
LIMIT 1;


--Q2: Which countries have the most invoices?

-- Counting the total invoices per country
SELECT billing_country, COUNT(*) AS invoice_count
FROM invoice
-- Grouping by country to aggregate the counts properly
GROUP BY billing_country
-- Sorting from highest to lowest to see the top countries
ORDER BY invoice_count DESC;


--Q3: What are the top 3 values of total invoice?

-- Selecting distinct invoice totals to get unique top amounts
SELECT DISTINCT total
FROM invoice
-- Ordering from largest to smallest value
ORDER BY total DESC
-- Restricting the output to just the top 3 highest values
LIMIT 3;


--Q4: Which city has the best customers? Write a query that returns one city that has the highest sum of invoice totals.

-- Aggregating total revenue by billing city
SELECT billing_city, SUM(total) AS invoice_total
FROM invoice
GROUP BY billing_city
-- Sorting by the maximum sales volume generated
ORDER BY invoice_total DESC
-- Limiting to the single best city for the Music Festival
LIMIT 1;


--Q5: Who is the best customer? Write a query that returns the person who has spent the most money.

-- We use an INNER JOIN here because we only want customers who have matching transaction records in the invoice table.
SELECT c.customer_id, c.first_name, c.last_name, SUM(i.total) AS total_spent
FROM customer c
INNER JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id
ORDER BY total_spent DESC
LIMIT 1;