SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employee;
SELECT * FROM issue_status;
SELECT * FROM members;
SELECT * FROM return_status;


-- Project Task

--Task 1. Create a New Book Record -- "978-1-60129-456-2', 
--'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')

INSERT INTO books 
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');



-- Task 2: Update an Existing Member's Address

UPDATE members 
SET member_address = '124 down st'
where member_id = 'C102';

select * from members;



-- Task 3: Delete a Record from the Issued Status Table 
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

DELETE FROM issue_status WHERE issued_id = 'IS121'; 



-- Task 4: Retrieve All Books Issued by a Specific Employee 
-- Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT * FROM issue_status
WHERE issued_emp_id = 'E101';



-- Task 5: List Members Who Have Issued More Than One Book 
-- Objective: Use GROUP BY to find members who have issued more than one book.

SELECT 
    ist.issued_emp_id,
     e.emp_name
FROM issue_status as ist
JOIN employee as e
ON e.emp_id = ist.issued_emp_id
GROUP BY 1, 2
HAVING COUNT(ist.issued_id) > 1;



-- CTAS
-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results 
-- each book and total book_issued_cnt**

create table issued_book_count as
select  b.isbn, iss.issued_book_name,  count(*) as count_of_books_issued
from books as b
join issue_status as iss
on b.isbn = iss.issued_book_isbn
group by 1,2;

SELECT * from issued_book_count;



-- Task 7. Retrieve All Books in a Specific Category:

select category from books group by category; -- total categories

select * from books where category = 'Children';



-- Task 8: Find Total Rental Income by Category:
select category, sum(rental_price) as total_rental_income 
from books 
group by 1
order by 2 desc;



--Task 8.1. List Members Who Registered in the Last 180 Days:

select * from members 
where reg_date >= CURRENT_DATE - interval '180 days';



-- task 10 List Employees with Their Branch Manager's Name and their branch details:

SELECT 
    e1.*,
    b.manager_id,
    e2.emp_name as manager
FROM employee as e1
JOIN  
branch as b
ON b.branch_id = e1.branch_id
JOIN
employee as e2
ON b.manager_id = e2.emp_id;



-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold 7USD:

create table books_price_above_7 as
(select * from books where rental_price > 7);

select * from books_price_above_7;



-- Task 12: Retrieve the List of Books Not Yet Returned

SELECT 
DISTINCT ist.issued_book_name
FROM issue_status as ist
LEFT JOIN
return_status as rs
ON ist.issued_id = rs.issued_id
WHERE rs.return_id IS NULL;

select * from issue_status;

















































