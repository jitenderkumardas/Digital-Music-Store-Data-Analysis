# 🎵 Digital Music Store Data Analysis (SQL)

## 📌 Project Overview

This project performs an in-depth data analysis of a digital music store's database to uncover actionable business intelligence regarding consumer habits, employee hierarchies, and global revenue distribution. By writing complex SQL queries, the project identifies top-performing regions, VIP customers, and leading music genres to guide future marketing budgets and storefront optimization strategies. The final insights bridge the gap between technical database management and strategic executive decision-making.

## 📂 Repository Structure

```text
├── README.md                 <-- Main project homepage with business insights
├── data/
│   ├── music_store.sql        <-- SQLite/PostgreSQL database source file (restore it)
│   └── schema_diagram.png    <-- Entity Relationship Diagram (ERD)
├── sql_queries/
│   ├── 01_easy_queries.sql   <-- Basic aggregations and structural sorting
│   ├── 02_moderate_queries.sql <-- Multi-table joins and subqueries
│   └── 03_advanced_queries.sql <-- CTEs and analytical window functions
└── presentation/
    └── music_store_insights.pdf <-- Executive summary & business recommendations
```

## 📊 Database Schema

This entity-relationship diagram maps out how customers, invoices, tracks, and artists interact across the digital ecosystem.


## 🛠️ Tech Stack & Tools

* **SQL Dialect:** PostgreSQL / SQLite (Standard ANSI SQL compatible)
* **Database Client:** pgAdmin / DBeaver

## 🔍 Key Business Questions & SQL Solutions

### Q1: Who is the most senior employee based on job title?

To find our organizational anchor point, we sort the employee database by their corporate ranking levels in descending order. Retrieving the top single row isolates the individual holding the highest executive authority in the operational hierarchy.

```sql
SELECT title, last_name, first_name
FROM employee
ORDER BY levels DESC
LIMIT 1;

```

💡 **Business Insight & Recommendation:**

Understanding the corporate reporting structure ensures clear transparency regarding workflow ownership. Corporate communications, strategic changes, and operational mandates should be routed directly through this office to guarantee seamless top-down execution.

---

### Q2: Which countries have the most invoices?

We aggregate every checkout transaction logged in the invoice table, grouping the transactions by their specific billing country. Sorting the counts from highest to lowest surfaces our highest-density transaction regions.

```sql
SELECT billing_country, COUNT(*) AS invoice_count
FROM invoice
GROUP BY billing_country
ORDER BY invoice_count DESC;

```

💡 **Business Insight & Recommendation:**

Our primary operational frequency is concentrated heavily in a few core global regions. Supply chains, content distribution networks, and digital server resources should prioritize these top-performing infrastructure territories to minimize network latency during peak checkout volumes.

---

### Q3: What are the top 3 values of total invoice?

By applying the `DISTINCT` keyword, we clean the dataset to ensure we are only viewing unique transaction amounts. We then sort the totals from largest to smallest and limit the view to the top 3 items to evaluate historical checkout ceiling thresholds.

```sql
SELECT DISTINCT total
FROM invoice
ORDER BY total DESC
LIMIT 3;

```

💡 **Business Insight & Recommendation:**

Knowing our maximum invoice values gives us a benchmark for typical "whale" cart capacities. These numbers can serve as structural thresholds for setting up free-shipping perks or transaction bonuses to push average shoppers toward larger checkout sizes.

---

### Q4: Which city has the best customers for a promotional Music Festival?

We group all global transactions specifically by their billing city and calculate the absolute sum of all invoice totals. Sorting by the maximum revenue generated and isolating the top row identifies our primary revenue capital.

```sql
SELECT billing_city, SUM(total) AS invoice_total
FROM invoice
GROUP BY billing_city
ORDER BY invoice_total DESC
LIMIT 1;

```

💡 **Business Insight & Recommendation:**

Instead of spreading high-cost marketing budgets thin across an entire country, capital should be focused heavily into this single highest-performing metropolitan center. Anchoring the physical *Digital Music Store Festival* here will maximize high-value local engagement and turn digital users into brand evangelists.

---

### Q5: Who is our absolute best customer by total spending?

Using an `INNER JOIN` allows us to securely map unique customer profile identifiers directly to their full invoice history. We aggregate the aggregate sum of every dollar spent per client account, sorting from largest to smallest to name our top VIP patron.

```sql
SELECT c.customer_id, c.first_name, c.last_name, SUM(i.total) AS total_spent
FROM customer c
INNER JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id
ORDER BY total_spent DESC
LIMIT 1;

```

💡 **Business Insight & Recommendation:**

This user represents the peak tier of our Customer Lifetime Value (CLV) model. VIP users like this should be enrolled in a specialized white-glove loyalty track, featuring early beta access to new platform features and direct, custom promotional rewards to prevent churn.

---

### Q6: Who are the Rock Music listeners? (Ordered alphabetically by email)

We traverse a five-table normalized layout—linking customers to invoices, invoice lines, individual tracks, and their parent genres. Filtering strictly for the 'Rock' value maps out a distinct segment of our user base.

```sql
SELECT DISTINCT c.email, c.first_name, c.last_name, g.name AS genre_name
FROM customer c
INNER JOIN invoice i ON c.customer_id = i.customer_id
INNER JOIN invoice_line il ON i.invoice_id = il.invoice_id
INNER JOIN track t ON il.track_id = t.track_id
INNER JOIN genre g ON t.genre_id = g.genre_id
WHERE g.name = 'Rock'
ORDER BY c.email ASC;

```

💡 **Business Insight & Recommendation:**

This query generates a targeted, clean subscriber mailing list for genre-specific marketing campaigns. When legendary rock catalog deals or exclusive modern rock tracks drop on the platform, this segment can be directly targeted to maximize email click-through rates.

---

### Q7: Who are our top 10 Rock artists by total song volume?

We map the artists table through albums and tracks down to the genre table. We filter down to 'Rock' tracks and count the active track IDs to rank which musical groups hold the largest content footprint on our store.

```sql
SELECT art.artist_id, art.name, COUNT(t.track_id) AS total_songs
FROM artist art
INNER JOIN album alb ON art.artist_id = alb.artist_id
INNER JOIN track t ON alb.album_id = t.album_id
INNER JOIN genre g ON t.genre_id = g.genre_id
WHERE g.name = 'Rock'
GROUP BY art.artist_id
ORDER BY total_songs DESC
LIMIT 10;

```

💡 **Business Insight & Recommendation:**

These 10 bands dictate the supply side of our most popular genre. The store should protect these partnerships, design dedicated landing collections for their catalogs, and secure co-exclusive track distributions to ensure sustainable content superiority over rival streaming platforms.

---

### Q8: Which track names have a song length longer than the global average?

We leverage an independent scalar subquery to find the exact database mean for all song lengths (`AVG(milliseconds)`). The main query then evaluates all tracks against this live benchmark, pulling only the entries that exceed it.

```sql
SELECT name, milliseconds
FROM track
WHERE milliseconds > (
    SELECT AVG(milliseconds) 
    FROM track
)
ORDER BY milliseconds DESC;

```

💡 **Business Insight & Recommendation:**

Songs exceeding the average duration represent deep cuts, live orchestrations, or conceptual progressive tracks. Knowing this distribution allows content teams to fine-tune automated playlist algorithms, ensuring long tracks don't disrupt regular background streaming sessions for standard mobile listeners.

---

### Q9: How much total amount has each customer spent on individual artists?

We cross-reference customer records against the individual items listed on their receipts (`unit_price * quantity`), routing all the way back up to the album creators. The output charts specific spending preferences on an individual artist basis.

```sql
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

```

💡 **Business Insight & Recommendation:**

This query lets us trace exact user-to-artist revenue affinity. If a customer is flagged as a high-tier spender for a specific artist, the system can deploy automated browser notifications the exact second that artist announces new merchandise, concert tours, or vinyl re-releases.

---

### Q10: What is the most popular music genre for each country?

We implement a Common Table Expression (CTE) to aggregate genre sales quantities by nation, using the window function `DENSE_RANK() OVER (PARTITION BY c.country ORDER BY COUNT(il.quantity) DESC)`. This creates a flexible ranking mechanism that captures any regional genre ties cleanly.

```sql
WITH popular_genre AS (
    SELECT 
        c.country, 
        g.name AS genre_name, 
        COUNT(il.quantity) AS purchases,
        DENSE_RANK() OVER(PARTITION BY c.country ORDER BY COUNT(il.quantity) DESC) AS rank_num
    FROM customer c
    INNER JOIN invoice i ON c.customer_id = i.customer_id
    INNER JOIN invoice_line il ON i.invoice_id = il.invoice_id
    INNER JOIN track t ON il.track_id = t.track_id
    INNER JOIN genre g ON t.genre_id = g.genre_id
    GROUP BY c.country, g.genre_id
)
SELECT country, genre_name, purchases
FROM popular_genre
WHERE rank_num = 1;

```

💡 **Business Insight & Recommendation:**

Consumer tastes vary noticeably across different international markets. Standardizing a single, static universal application homepage hurts local checkout conversions. Instead, homepages should dynamically adjust their featured banners and recommended music sections based on the top local genres surfaced by this query.

---

### Q11: Who is the top-spending customer in each country?

Similar to our genre deep-dive, we isolate top spenders across separate national lines by partitioning our window by `billing_country`. Applying `DENSE_RANK() = 1` filters out everyone except the peak-spending customer per country.

```sql
WITH customer_spending_by_country AS (
    SELECT 
        c.customer_id, c.first_name, c.last_name,
        i.billing_country AS country,
        SUM(i.total) AS total_spent,
        DENSE_RANK() OVER(PARTITION BY i.billing_country ORDER BY SUM(i.total) DESC) AS rank_num
    FROM customer c
    INNER JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY c.customer_id, i.billing_country
)
SELECT country, first_name, last_name, total_spent
FROM customer_spending_by_country
WHERE rank_num = 1
ORDER BY country ASC;

```

💡 **Business Insight & Recommendation:**

This dataset serves as the backbone for localized VIP retention strategies. Regional marketing divisions can target these specific international high-rollers with custom perks, specialized billing support, and exclusive rewards tailored to keep our most valuable local accounts engaged.

---

## 📈 Key Findings & Summary of Insights

* **The Rock Domination Factor:** Across global metrics, Rock music ranks as our core revenue anchor, generating the largest total volume of track and artist engagement.


* **Dynamic Regional Variations:** While Rock holds the global crown, secondary listening preferences fluctuate across international lines. Utilizing partitioned rank metrics handles multi-genre ties seamlessly, paving the way for targeted content curation.


* **High-Concentration Market Footprints:** A small number of major cities and top-tier customer accounts drive a large portion of overall store revenue, showing the massive business value of localized promotions and focused VIP customer retention plans.
