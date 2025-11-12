-- Task 1: find all customers from the USA
SELECT
  FirstName,
  LastName,
  Country
FROM
  customers
WHERE
  Country = 'USA';

-- Task 2: Find tracks of specific artist (AC/DC here) 
SELECT
  t.Name AS TrackName
FROM
  artists AS a
JOIN
  albums AS al ON a.ArtistId = al.ArtistId
JOIN
  tracks AS t ON al.AlbumId = t.AlbumId
WHERE
  a.Name = 'AC/DC';
  
  
-- Task 3: Find the top 5 best-selling genres by revenue

-- Select the 'Name' column from the 'genres' table and rename it 'Genre' for the output.
SELECT
  g.Name AS Genre,
  
  -- Calculate total revenue: multiply price by quantity for each track,
  -- then sum all these values for each genre.
  SUM(il.UnitPrice * il.Quantity) AS TotalRevenue

-- Tell the query to start with the 'genres' table, giving it the short alias 'g'.
FROM
  genres AS g

-- Connect 'genres' (g) to 'tracks' (t) using their common ID column.
JOIN
  tracks AS t ON g.GenreId = t.GenreId
  
-- Connect 'tracks' (t) to 'invoice_lines' (il) using their common ID column.
-- This is how we link a genre to an actual sale.
JOIN
  invoice_items AS il ON t.TrackId = il.TrackId

-- Group all the rows into "buckets" based on their genre name.
-- The SUM() function will now calculate a total for each of these buckets.
GROUP BY
  g.Name

-- Sort the final list of genres from highest revenue (DESC) to lowest.
ORDER BY
  TotalRevenue DESC

-- Only show the first 5 rows from the sorted list.
LIMIT 5;



-- Task 4: Find the sales support agent with the most total sales

-- Select the employee's first and last name
SELECT
  e.FirstName,
  e.LastName,
  
  -- Sum all the 'Total' amounts from their customers' invoices
  SUM(i.Total) AS TotalSales

-- Start with the 'employees' table, alias 'e'
FROM
  employees AS e

-- Connect 'employees' (e) to 'customers' (c)
-- The link is the employee's ID on their customer's 'SupportRepId'
JOIN
  customers AS c ON e.EmployeeId = c.SupportRepId
  
-- Connect 'customers' (c) to 'invoices' (i)
JOIN
  invoices AS i ON c.CustomerId = i.CustomerId

-- Group the sales by employee
GROUP BY
  e.EmployeeId -- Grouping by ID is safer than name

-- Sort from highest sales (DESC) to lowest
ORDER BY
  TotalSales DESC

-- Only show the top 1
LIMIT 1;





-- Task 5: Find the name of every track that has never been purchased

-- Select the name of the track
SELECT
  t.Name
  
-- Start with the 'tracks' table, as we want a list of ALL tracks
FROM
  tracks AS t
  
-- LEFT JOIN 'invoice_items'. This keeps ALL tracks,
-- even if they have no match in the sales table.
LEFT JOIN
  invoice_items AS ii ON t.TrackId = ii.TrackId
  
-- Now, filter for only the rows where the sales record (ii.InvoiceId)
-- IS NULL. This means no sale was ever found for that track.
WHERE
  ii.InvoiceId IS NULL;
  
  
  
-- Task 6: Find the most valuable customer in each country

-- Step 1: Define a CTE (a temporary table) to get total spending for each customer
WITH CustomerSpending AS (
  SELECT
    c.CustomerId,
    c.FirstName,
    c.LastName,
    c.Country,
    SUM(i.Total) AS TotalSpending
  FROM
    customers AS c
  JOIN
    invoices AS i ON c.CustomerId = i.CustomerId
  GROUP BY
    c.CustomerId, c.FirstName, c.LastName, c.Country
),

-- Step 2: Create a second CTE to rank those customers WITHIN their country
RankedSpending AS (
  SELECT
    CustomerId,
    FirstName,
    LastName,
    Country,
    TotalSpending,
    -- This is the Window Function:
    -- It ranks customers (1st, 2nd, 3rd...)
    -- "PARTITION BY Country" restarts the rank for each new country
    -- "ORDER BY TotalSpending DESC" sets 1st place as the highest spender
    RANK() OVER (PARTITION BY Country ORDER BY TotalSpending DESC) AS CountryRank
  FROM
    CustomerSpending
)

-- Step 3: Select from your ranked table, only showing the #1 ranked customer
SELECT
  Country,
  FirstName,
  LastName,
  TotalSpending
FROM
  RankedSpending
WHERE
  CountryRank = 1;