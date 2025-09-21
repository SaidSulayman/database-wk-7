-- Create a temporary numbers table to help with the split (or use a recursive CTE)
WITH numbers AS (
    SELECT 1 as n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
)
SELECT 
    OrderID,
    CustomerName,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(Products, ',', n), ',', -1)) as Product
FROM ProductDetail
JOIN numbers
    ON CHAR_LENGTH(Products) - CHAR_LENGTH(REPLACE(Products, ',', '')) >= n - 1
ORDER BY OrderID, Product;

WITH RECURSIVE split_products AS (
    SELECT 
        OrderID,
        CustomerName,
        Products,
        TRIM(SUBSTRING_INDEX(Products, ',', 1)) as Product,
        TRIM(SUBSTRING_INDEX(Products, ',', -1*(CHAR_LENGTH(Products) - CHAR_LENGTH(REPLACE(Products, ',', ''))))) as remaining
    FROM ProductDetail
    
    UNION ALL
    
    SELECT 
        OrderID,
        CustomerName,
        remaining as Products,
        TRIM(SUBSTRING_INDEX(remaining, ',', 1)) as Product,
        TRIM(SUBSTRING_INDEX(remaining, ',', -1*(CHAR_LENGTH(remaining) - CHAR_LENGTH(REPLACE(remaining, ',', ''))))) as remaining
    FROM split_products
    WHERE remaining LIKE '%,%'
)

SELECT 
    OrderID,
    CustomerName,
    CASE 
        WHEN Product LIKE '%,%' THEN TRIM(SUBSTRING_INDEX(Product, ',', -1))
        ELSE Product
    END as Product
FROM split_products
ORDER BY OrderID, Product;

OrderID	CustomerName	Product
101	John Doe	Laptop
101	John Doe	Mouse
102	Jane Smith	Keyboard
102	Jane Smith	Mouse
102	Jane Smith	Tablet
103	Emily Clark	Phone

-- Create Orders table with Customer information
CREATE TABLE Orders AS
SELECT DISTINCT OrderID, CustomerName
FROM OrderDetails
ORDER BY OrderID;

-- Create OrderItems table with product details
CREATE TABLE OrderItems AS
SELECT OrderID, Product, Quantity
FROM OrderDetails
ORDER BY OrderID, Product;

OrderID	CustomerName
101	John Doe
102	Jane Smith
103	Emily Clark

OrderID	Product	Quantity
101	Laptop	2
101	Mouse	1
102	Keyboard	1
102	Mouse	2
102	Tablet	3
103	Phone	1













