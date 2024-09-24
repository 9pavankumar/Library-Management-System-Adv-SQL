-- Library System Management SQL Project

SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM return_status;
SELECT * FROM members;

-- Project TASK    

--### Advanced SQL Operations

"""Task 13: Identify Members with Overdue Books
Write a query to identify members who have overdue books 
(assume a 30-day return period). Display the member's name, 
book title, issue date, and days overdue."""

SELECT m.member_name, iss.issued_date, bk.book_title,
current_date- iss.issued_date   as overdue_days
FROM issued_status AS iss
join members as m
on iss.issued_member_id = m.member_id
join books as bk
on bk.isbn = iss.issued_book_isbn
Left JOIN return_status AS rss
ON iss.issued_id = rss.issued_id  
where rss.return_date is null
and (current_date - iss.issued_date) > 30
order by 4;


"""
Task 14: Update Book Status on Return
Write a query to update the status of books in the books table
to "Yes" when they are returned (based on entries in the
return_status table)."""

create or replace PROCEDURE add_return_status(e_return_id varchar(10), e_issued_id VARCHAR(30),  e_book_quality varchar(15))
LANGUAGE plpgsql
AS $$ 
DECLARE
	v_book_name varchar(80);
	v_isbn varchar(50);
BEGIN
	--TOTAL MAIN CODE
	insert into return_status(return_id, issued_id, return_date, book_quality)
	VALUES(e_return_id, e_issued_id, current_date, e_book_quality);

	SELECT issued_book_isbn, issued_book_name 
	INTO v_isbn, v_book_name  
	from issued_status
	where issued_id = e_issued_id;

	UPDATE books
	SET status = 'yes'
	where isbn = v_isbn;

	RAISE NOTICE 'thank you for returning the book: %', v_book_name;
END; $$

call add_return_status('RS136', 'IS135', 'good');

select * from books where isbn ='978-0-307-58837-1';
SELECT * FROM issued_status where issued_book_isbn = '978-0-307-58837-1' ;
UPDATE books SET status = 'no' where isbn = '978-0-307-58837-1';
select * from return_status where issued_id = 'IS135';



"""
Task 15: Branch Performance Report
Create a query that generates a performance report for each branch,
showing the number of books issued, the number of books returned,
and the total revenue generated from book rentals.
"""


create table Branches_Performance_Report as (
SELECT e.branch_id, sum(bk.rental_price) as revenue, count(iss.issued_id) as no_of_books_issued_status, 
count(rts.return_id) as no_of_books_return_status
from issued_status as iss
left join return_status as rts
ON rts.issued_id = iss.issued_id
JOIN books as bk
ON bk.isbn = iss.issued_book_isbn
JOIN employees as e
on e.emp_id = iss.issued_emp_id
group by 1
order by 2 desc);

SELECT * FROM Branches_Performance_Report;



"""
Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table 
active_members containing members who have issued at least one book 
in the last 6 months.
"""


create table Active_Members as
(SELECT distinct(M.member_name)
from issued_status as iss
JOIN books as bk
ON bk.isbn = iss.issued_book_isbn
JOIN members as m
on iss.issued_member_id = m.member_id 
where iss.issued_date > current_date - interval '180 days' );

select * from Active_Members;
-- drop table active_members;



"""
Task 17: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed 
the most book issues. Display the employee name, number of books processed, 
and their branch.
"""


select e.emp_name,  count(iss.issued_id) as no_of_books_processed,
b.*
from employees as e
join issued_status as iss
ON iss.issued_emp_id = e.emp_id
join branch as b
on b.branch_id = e.branch_id
group by 1, 3
order by 2 desc
LIMIT 3;


"""
Task 18: Identify Members Issuing High-Risk Books
Write a query to identify members who have issued books 
more than twice with the status "damaged" in the books table. 
Display the member name, book title, and the number of times they've 
issued damaged books.    
"""

select m.member_name, iss.issued_book_name, rts.book_quality, count(rts.book_quality)
from members as m
join issued_status as iss
ON m.member_id = iss.issued_member_id 
left join return_status as rts
on rts.issued_id = iss.issued_id
where book_quality = 'Damaged'
group by 1,2,3;

"""
Task 19: Stored Procedure
Objective: Create a stored procedure to manage the status of books
in a library system.
Description: Write a stored procedure that updates the status of 
			a book based on its issuance or return. Specifically:
    If a book is issued, the status should change to 'no'.
    If a book is returned, the status should change to 'yes'.
"""


create or REPLACE procedure 
	book_status(e_issued_id varchar(10), e_issued_member_id varchar(30),
							e_issued_book_isbn varchar(50), e_issued_emp_id varchar(10))
LANGUAGE plpgsql
AS $$
declare --all variables are here is declared
	v_status VARCHAR(10);

begin
	select status INTO v_status
	from books
	where isbn = e_issued_book_isbn ;
	
	if v_status = 'yes' THEN
			Insert into issued_status(issued_id,  issued_member_id, issued_date, issued_book_isbn, issued_emp_id )
			VALUES(e_issued_id, e_issued_member_id, current_date, e_issued_book_isbn, e_issued_emp_id);
			UPDATE books SET status = 'no' where isbn = e_issued_book_isbn;
			RAISE NOTICE 'book records added successfully: %', e_issued_book_isbn;
	else
			RAISE NOTICE 'book records are not available: %', e_issued_book_isbn;
	end if;
end; $$

call book_status('IS155','C108', '78-0-7432-7357-1', 'E104' ); --status is no
call book_status('IS162','C108', '978-0-393-05081-8', 'E104' ); --status is YES

--TESTING
select * from books where isbn ='978-0-393-05081-8';
SELECT * FROM issued_status where issued_book_isbn ='978-0-393-05081-8';
select * from return_status where issued_id = 'IS135';


"""
Task 20: Create Table As Select (CTAS)
Objective: Create a CTAS (Create Table As Select) query to
identify overdue books and calculate fines.

Description: Write a CTAS query to create a new table that
lists each member and the books they have issued but not returned
within 30 days. The table should include:
    The number of overdue books.
    The total fines, with each day's fine calculated at $0.50.
    The number of books issued by each member.
    The resulting table should show:
    Member ID
    Number of overdue books
    Total fines

"""


-- Drop the table if it exists
DROP TABLE IF EXISTS overdue_books;

-- Create the new table using CTAS
CREATE TABLE overdue_books AS
SELECT m.member_id, COUNT(iss.issued_id) AS no_of_overdue_books,
    SUM(0.50* (EXTRACT(DAY FROM CURRENT_DATE) - EXTRACT(DAY FROM iss.issued_date)) - 30) AS total_fines
FROM members AS m
JOIN issued_status AS iss
    ON m.member_id = iss.issued_member_id
LEFT JOIN return_status AS rts 
    ON iss.issued_id = rts.issued_id
WHERE rts.return_id IS NULL  -- Book is not returned
  AND 
(iss.issued_date > current_date - interval '30 days')  
GROUP BY m.member_id;

SELECT * from overdue_books;
