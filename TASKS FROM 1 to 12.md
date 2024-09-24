# Library-Management-System-Adv-SQL



![Library_project](https://github.com/najirh/Library-System-Management---P2/blob/main/library.jpg)

 **Library System Management SQL TASKS From 1 to 12** :

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


### Task 1: Create a New Book Record 
Add a new book with the following details:
- ISBN: '978-1-60129-456-2'
- Title: 'To Kill a Mockingbird'
- Category: 'Classic'
- Rental Price: 6.00
- Status: 'yes'
- Author: 'Harper Lee'
- Publisher: 'J.B. Lippincott & Co.'
```sql
INSERT INTO books 
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
```

---

### Task 2: Update an Existing Member's Address
Update the address of the member with member_id = 'C102' to '124 down st'.
```sql
UPDATE members 
SET member_address = '124 down st'
WHERE member_id = 'C102';

-- Retrieve all records from the members table to confirm the update
SELECT * FROM members;
```

---

### Task 3: Delete a Record from the Issued Status Table 
Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
```sql
DELETE FROM issue_status WHERE issued_id = 'IS121'; 
```

---

### Task 4: Retrieve All Books Issued by a Specific Employee 
Objective: Select all books issued by the employee with emp_id = 'E101'.
```sql
SELECT * FROM issue_status
WHERE issued_emp_id = 'E101';
```

---

### Task 5: List Members Who Have Issued More Than One Book 
Objective: Use GROUP BY to find members who have issued more than one book.
```sql
SELECT 
    ist.issued_emp_id,
    e.emp_name
FROM issue_status AS ist
JOIN employee AS e ON e.emp_id = ist.issued_emp_id
GROUP BY 1, 2
HAVING COUNT(ist.issued_id) > 1;
```

---

### Task 6: Create Summary Tables
Using CTAS to generate a new table summarizing the count of issued books for each book.
```sql
CREATE TABLE issued_book_count AS
SELECT  b.isbn, iss.issued_book_name, COUNT(*) AS count_of_books_issued
FROM books AS b
JOIN issue_status AS iss ON b.isbn = iss.issued_book_isbn
GROUP BY 1, 2;

-- Retrieve all records from the issued_book_count table
SELECT * FROM issued_book_count;
```

---

### Task 7: Retrieve All Books in a Specific Category
Retrieve all unique categories from the books table.
```sql
SELECT category FROM books GROUP BY category; -- total categories

-- Retrieve all books that belong to the 'Children' category.
SELECT * FROM books WHERE category = 'Children';
```

---

### Task 8: Find Total Rental Income by Category
Calculate the total rental income for each category of books.
```sql
SELECT category, SUM(rental_price) AS total_rental_income 
FROM books 
GROUP BY 1
ORDER BY 2 DESC;
```

---

### Task 8.1: List Members Who Registered in the Last 180 Days
Retrieve all members who registered in the last 180 days.
```sql
SELECT * FROM members 
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days';
```

---

### Task 10: List Employees with Their Branch Manager's Name and Their Branch Details
```sql
SELECT 
    e1.*,            -- All details of the employee
    b.manager_id,   -- Manager ID from the branch table
    e2.emp_name AS manager  -- Manager's name from the employee table
FROM employee AS e1
JOIN branch AS b ON b.branch_id = e1.branch_id
JOIN employee AS e2 ON b.manager_id = e2.emp_id;
```

---

### Task 11: Create a Table of Books with Rental Price Above a Certain Threshold (7 USD)
Creating a new table for books with rental price greater than 7.
```sql
CREATE TABLE books_price_above_7 AS
SELECT * FROM books WHERE rental_price > 7;

-- Retrieve all records from the books_price_above_7 table
SELECT * FROM books_price_above_7;
```

---

### Task 12: Retrieve the List of Books Not Yet Returned
Retrieve all distinct book names that have not yet been returned.
```sql
SELECT 
DISTINCT ist.issued_book_name
FROM issue_status AS ist
LEFT JOIN return_status AS rs ON ist.issued_id = rs.issued_id
WHERE rs.return_id IS NULL;

-- Retrieve all records from the issue_status table for reference
SELECT * FROM issue_status;
```

---

Let me know if you need any further modifications or additional tasks!
