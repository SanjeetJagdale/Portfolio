/*	Query Set 1 - Easy */

/* Q1: Who is the senior most employee based on job title? */

SELECT first_name,
       last_name,
       title,
       levels
FROM employee 
ORDER BY 4 DESC
LIMIT 1;

/* Q2: Which countries have the most Invoices? */

SELECT billing_country,
       COUNT(total)
FROM invoice 
GROUP BY 1
ORDER BY 2 DESC;

/* Q3: What are top 3 values of total invoice? */

SELECT total
FROM invoice
ORDER BY 1 DESC
LIMIT 3;

/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

SELECT billing_city , 
       Sum(total) as invoice_totals
FROM invoice
GROUP BY 1 
ORDER BY 2 DESC
LIMIT 1;

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

SELECT c.customer_id,
       c.first_name,
       c.last_name,
       SUM(i.total) as total_spending
FROM customer c
       JOIN invoice i 
          ON c.customer_id = i.customer_id
GROUP BY 1,
         2,
		 3
ORDER BY 4 DESC
LIMIT 1;


/* Query Set 2 - Moderate */

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

SELECT c.email,
       c.first_name,
       c.last_name
FROM customer c
       JOIN invoice i 
          ON c.customer_id = i.customer_id
	   JOIN invoice_line il
          ON i.invoice_id = il.invoice_id
       JOIN track t
          ON il.track_id = t.track_id
	   JOIN genre g 
		  ON t.genre_id = g.genre_id
WHERE g.name = "Rock" 
GROUP BY 1,
         2,
         3
ORDER BY 1;

/* Method 2 */

SELECT c.email,
       c.first_name,
       c.last_name
FROM customer c
       JOIN invoice i 
          ON c.customer_id = i.customer_id
	   JOIN invoice_line il
          ON i.invoice_id = il.invoice_id
WHERE track_id IN ( SELECT track_id 
                    FROM track t
	                     JOIN genre g 
                           ON t.genre_id = g.genre_id
	                WHERE g.name = "Rock" )
GROUP BY 1,
         2,
         3
ORDER BY 1;

/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

SELECT a.artist_id,
       a.name,
       COUNT(a.artist_id) as total_track_count
FROM track t
      LEFT JOIN album aa
         ON t.album_id = aa.album_id
	  LEFT JOIN artist a
         ON aa.artist_id = a.artist_id
      LEFT JOIN genre g
         ON t.genre_id = g.genre_id
WHERE g.name = "Rock"
GROUP BY 1,
		 2
ORDER BY 3 DESC 
LIMIT 10;
	  
/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

SELECT name,
	   milliseconds
FROM track 
WHERE milliseconds > ( SELECT AVG(milliseconds) as avg_track_length
                       FROM track )
ORDER BY 2 DESC;

/* Query Set 3 - Advance */

/* Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */

WITH most_selling_artist as(
    SELECT a.artist_id,
           a.name,
           SUM(il.unit_price * il.quantity) as total_spent
    FROM invoice_line il
       JOIN track t 
          ON t.track_id = il.track_id
	   JOIN album aa
          ON aa.album_id = t.album_id
	   JOIN artist a 
          ON a.artist_id = aa.artist_id
    GROUP BY 1,
		     2
    ORDER BY 3 DESC
    LIMIT 1 )
SELECT  c.customer_id,
        c.first_name,
		c.last_name,
        msb.artist_id,
        SUM(il.unit_price * il.quantity) as amount_spent 
FROM customer c
       JOIN invoice i 
         ON c.customer_id = i.customer_id
	   JOIN invoice_line il
		 ON i.invoice_id = il.invoice_id
	   JOIN track t 
         ON t.track_id = il.track_id
	   JOIN album aa
		 ON aa.album_id = t.album_id
	   JOIN most_selling_artist msb
         ON msb.artist_id = aa.artist_id
GROUP BY 1,
         2,
         3,
         4
ORDER BY 5 DESC;

/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

WITH popular_genre as(
   SELECT COUNT(il.quantity) as purchases,
       c.country,
	   g.name,
	   g.genre_id,
       ROW_NUMBER() OVER(PARTITION BY c.country ORDER BY COUNT(il.quantity) DESC) as ROWNo
   FROM invoice_line il
       JOIN invoice i 
          ON il.invoice_id = i.invoice_id
	   JOIN customer c
          ON i.customer_id = c.customer_id
	   JOIN track t 
          ON il.track_id = t.track_id
	   JOIN genre g
          ON t.genre_id = g.genre_id
   GROUP BY 2,
            3,
            4
   ORDER BY 2 ASC,
            1 DESC )
SELECT * 
FROM popular_genre 
WHERE ROWNo = 1;

/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

WITH high_spent_customer AS (
SELECT c.country,
       c.first_name,
       c.last_name,
       SUM(i.total) as total_spending,
       ROW_NUMBER() OVER(PARTITION BY c.country ORDER BY SUM(i.total) ) as ROWNo
FROM customer c 
       JOIN invoice i 
          ON c.customer_id = i.customer_id
GROUP BY 1,
         2,
         3
ORDER BY 4 ASC,
		 5 DESC )
SELECT *
FROM high_spent_customer
WHERE ROWNo = 1;

