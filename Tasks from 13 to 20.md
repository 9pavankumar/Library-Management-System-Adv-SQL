# Library-Management-System-Adv-SQL



 **Library System Management SQL TASKS** :

---

#### Display Tables:
```sql
SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM return_status;
SELECT * FROM members;
```

---

### Project Tasks

---

#### **Task 13: Identify Members with Overdue Books**
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's name, book title, issue date, and days overdue.
```sql
SELECT m.member_name, iss.issued_date, bk.book_title,
current_date - iss.issued_date AS overdue_days
FROM issued_status AS iss
JOIN members AS m
ON iss.issued_member_id = m.member_id
JOIN books AS bk
ON bk.isbn = iss.issued_book_isbn
LEFT JOIN return_status AS rss
ON iss.issued_id = rss.issued_id  
WHERE rss.return_date IS NULL
AND (current_date - iss.issued_date) > 30
ORDER BY 4;
```

---

#### **Task 14: Update Book Status on Return**
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).
```sql
CREATE OR REPLACE PROCEDURE add_return_status(e_return_id VARCHAR(10), e_issued_id VARCHAR(30),  e_book_quality VARCHAR(15))
LANGUAGE plpgsql
AS $$ 
DECLARE
	v_book_name VARCHAR(80);
	v_isbn VARCHAR(50);
BEGIN
	-- Insert new return status into the return_status table
	INSERT INTO return_status(return_id, issued_id, return_date, book_quality)
	VALUES(e_return_id, e_issued_id, CURRENT_DATE, e_book_quality);

	-- Retrieve book details based on issued status
	SELECT issued_book_isbn, issued_book_name 
	INTO v_isbn, v_book_name  
	FROM issued_status
	WHERE issued_id = e_issued_id;

	-- Update the book's status to 'yes' in the books table
	UPDATE books
	SET status = 'yes'
	WHERE isbn = v_isbn;

	-- Notification after book is returned
	RAISE NOTICE 'Thank you for returning the book: %', v_book_name;
END; $$

-- Call the stored procedure to update book status
CALL add_return_status('RS136', 'IS135', 'good');

-- Verifying the changes
SELECT * FROM books WHERE isbn = '978-0-307-58837-1';
SELECT * FROM issued_status WHERE issued_book_isbn = '978-0-307-58837-1';
UPDATE books SET status = 'no' WHERE isbn = '978-0-307-58837-1';
SELECT * FROM return_status WHERE issued_id = 'IS135';
```

---

#### **Task 15: Branch Performance Report**
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.
```sql
CREATE TABLE Branches_Performance_Report AS (
SELECT e.branch_id, SUM(bk.rental_price) AS revenue, COUNT(iss.issued_id) AS no_of_books_issued_status, 
COUNT(rts.return_id) AS no_of_books_return_status
FROM issued_status AS iss
LEFT JOIN return_status AS rts
ON rts.issued_id = iss.issued_id
JOIN books AS bk
ON bk.isbn = iss.issued_book_isbn
JOIN employees AS e
ON e.emp_id = iss.issued_emp_id
GROUP BY 1
ORDER BY 2 DESC);

-- View the performance report
SELECT * FROM Branches_Performance_Report;
```

---

#### **Task 16: CTAS: Create a Table of Active Members**
Use the `CREATE TABLE AS (CTAS)` statement to create a new table `active_members` containing members who have issued at least one book in the last 6 months.
```sql
CREATE TABLE Active_Members AS
(SELECT DISTINCT(m.member_name)
FROM issued_status AS iss
JOIN books AS bk
ON bk.isbn = iss.issued_book_isbn
JOIN members AS m
ON iss.issued_member_id = m.member_id 
WHERE iss.issued_date > CURRENT_DATE - INTERVAL '180 days');

-- View the list of active members
SELECT * FROM Active_Members;

-- Drop the table after use
DROP TABLE active_members;
```

---

#### **Task 17: Find Employees with the Most Book Issues Processed**
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.
```sql
SELECT e.emp_name,  COUNT(iss.issued_id) AS no_of_books_processed, b.*
FROM employees AS e
JOIN issued_status AS iss
ON iss.issued_emp_id = e.emp_id
JOIN branch AS b
ON b.branch_id = e.branch_id
GROUP BY 1, 3
ORDER BY 2 DESC
LIMIT 3;
```

---

#### **Task 18: Identify Members Issuing High-Risk Books**
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. Display the member name, book title, and the number of times they've issued damaged books.
```sql
SELECT m.member_name, iss.issued_book_name, rts.book_quality, COUNT(rts.book_quality)
FROM members AS m
JOIN issued_status AS iss
ON m.member_id = iss.issued_member_id 
LEFT JOIN return_status AS rts
ON rts.issued_id = iss.issued_id
WHERE book_quality = 'Damaged'
GROUP BY 1, 2, 3;

```

---

#### **Task 19: Stored Procedure**
Create a stored procedure to manage the status of books in a library system.
```sql
CREATE OR REPLACE PROCEDURE book_status(e_issued_id VARCHAR(10), e_issued_member_id VARCHAR(30),
                                        e_issued_book_isbn VARCHAR(50), e_issued_emp_id VARCHAR(10))
LANGUAGE plpgsql
AS $$
DECLARE -- Declare variables
	v_status VARCHAR(10);

BEGIN
	-- Fetch the current status of the book
	SELECT status INTO v_status
	FROM books
	WHERE isbn = e_issued_book_isbn;
	
	-- If the book is available (status = 'yes'), issue the book and update the status
	IF v_status = 'yes' THEN
		INSERT INTO issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
		VALUES(e_issued_id, e_issued_member_id, CURRENT_DATE, e_issued_book_isbn, e_issued_emp_id);
		UPDATE books SET status = 'no' WHERE isbn = e_issued_book_isbn;
		RAISE NOTICE 'Book records added successfully: %', e_issued_book_isbn;
	ELSE
		RAISE NOTICE 'Book records are not available: %', e_issued_book_isbn;
	END IF;
END; $$

-- Calling the stored procedure
CALL book_status('IS155','C108', '78-0-7432-7357-1', 'E104'); --status is no
CALL book_status('IS162','C108', '978-0-393-05081-8', 'E104'); --status is YES

-- Testing the status updates
SELECT * FROM books WHERE isbn ='978-0-393-05081-8';
SELECT * FROM issued_status WHERE issued_book_isbn ='978-0-393-05081-8';
SELECT * FROM return_status WHERE issued_id = 'IS135';

```

---

#### **Task 20: Create Table As Select (CTAS)**
Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days, and calculate fines.
```sql
-- Drop the table if it exists
DROP TABLE IF EXISTS overdue_books;

-- Create the new table using CTAS
CREATE TABLE overdue_books AS
SELECT m.member_id, COUNT(iss.issued_id) AS no_of_overdue_books,
    SUM(0.50 * (EXTRACT(DAY FROM CURRENT_DATE - iss.issued_date) - 30)) AS total_fines
FROM members AS m
JOIN issued_status AS iss
    ON m.member_id = iss.issued_member_id
LEFT JOIN return_status AS rts 
    ON iss.issued_id = rts.issued_id
WHERE rts.return_id IS NULL  -- Book is not returned
  AND EXTRACT(DAY FROM CURRENT_DATE - iss.issued_date) > 30 -- More than 30 days have passed
GROUP BY m.member_id;

-- Viewing the overdue books and fines
SELECT * FROM overdue_books;
``` 

---
