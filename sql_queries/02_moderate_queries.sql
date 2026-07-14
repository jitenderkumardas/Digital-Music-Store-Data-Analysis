-- Question Set 2 (Moderate)
-- Q1: Return the email, first name, last name, & Genre of all Rock Music listeners. Order alphabetically by email.

-- We need to link customers to their track purchases and filter by 'Rock' genre.
-- Using INNER JOINs sequentially to jump from Customer -> Invoice -> InvoiceLine -> Track -> Genre
SELECT DISTINCT c.email, c.first_name, c.last_name, g.name AS genre_name
FROM customer c
INNER JOIN invoice i ON c.customer_id = i.customer_id
INNER JOIN invoice_line il ON i.invoice_id = il.invoice_id
INNER JOIN track t ON il.track_id = t.track_id
INNER JOIN genre g ON t.genre_id = g.genre_id
-- Filtering exclusively for Rock music
WHERE g.name = 'Rock'
-- Sorting alphabetically by email as requested
ORDER BY c.email ASC;

-- Q2: Let's invite the artists who have written the most rock music.
-- Return the Artist name and total track count of the top 10 rock bands.

-- Jumping from Artist -> Album -> Track -> Genre to aggregate track counts
SELECT art.artist_id, art.name, COUNT(t.track_id) AS total_songs
FROM artist art
INNER JOIN album alb ON art.artist_id = alb.artist_id
INNER JOIN track t ON alb.album_id = t.album_id
INNER JOIN genre g ON t.genre_id = g.genre_id
WHERE g.name = 'Rock'
GROUP BY art.artist_id
ORDER BY total_songs DESC
LIMIT 10;


-- Q3: Return all the track names that have a song length longer than the average song length.

-- Using a Subquery in the WHERE clause to dynamically compute the overall average track duration.
SELECT name, milliseconds
FROM track
WHERE milliseconds > (
    -- Subquery calculates a single scalar value representing the absolute average song length
    SELECT AVG(milliseconds) 
    FROM track
)
-- Displaying the longest songs first
ORDER BY milliseconds DESC;