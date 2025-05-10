select * from issued_status

/* task: identify members with overdue books
assume return period is 30 days
write a query to return member_name, member_id, book title, issue date and days overdue
*/


select i.issued_member_id, i.issued_book_name, m.member_name, i.issued_date , (Current_Date - i.issued_date) as overdue_days from
issued_status i
join members m 
on i.issued_member_id = m.member_id 
left join return_status r
on i.issued_id = r.issued_id
where r.return_date is Null
and (Current_Date - i.issued_date)>30
order by 1;

/* Update book status on return.
Update the return status in the books table to 'Yes' when a book is returned based on the return_status table.
*/


-- stored procedure

create or replace procedure add_return_records(p_return_id varchar(20),p_issued_id varchar(20))
language plpgsql
as $$
declare 
v_isbn varchar(50); v_book_name varchar(80);
begin
-- inserting into returns based on user input
	insert into return_status(return_id, issued_id, return_date)
	values 
	( LEFT(p_return_id, 10), LEFT(p_issued_id, 10),current_date);

	select issued_book_isbn, issued_book_name 
	into v_isbn, v_book_name
	from issued_status
	where issued_id = p_issued_id;

	update books
	set status = 'yes'
	where isbn = v_isbn;

	raise notice 'thanks for returning the book, %', v_book_name;

end;
$$

call add_return_records('RS138','IS135');

select * from books
where issued_id = 'IS135';

/* branch performance report
Create a query that creates a performance query for each branch, showing the number of books issued, number of books returned, total revenue from book rentals
*/

with rent_price as(
select i.issued_id as book_issue_id,b.book_title, i.issued_book_isbn, i.issued_emp_id, r.return_id as return_flag, b.rental_price as price, e.branch_id as branch  from issued_status i
left join employees e
on i.issued_emp_id = e.emp_id
join books b
on i.issued_book_isbn = b.isbn
left join return_status r
on i.issued_id = r.issued_id
)

select branch, count(book_issue_id) as books_issued, count(return_flag) as books_returned,sum(price) as revenue_from_books from rent_price
group by 1;


-- write a query to find the active members.
-- who have issued books in the last six months



select i.issued_member_id, m.member_name, i.issued_date 
from issued_status i
join members m
on i.issued_member_id = m.member_id 
where  ((extract(Year from Age(Current_date, i.issued_date))*12)+extract(Month from Age(Current_date, i.issued_date)))<15;


-- employees with most books issued


select i.issued_emp_id, e.emp_name as name_of_emp, count(i.issued_emp_id) as books_issued, e.branch_id
from issued_status i
join employees e
on e.emp_id = i.issued_emp_id
group by i.issued_emp_id, e.emp_name, e.branch_id
order by 3 desc;

/* Write a stored procedure that updates the status of a book in the library based on its issuance. 
The procedure should function as follows: The stored procedure should take the book_id as an input parameter. 
The procedure should first check if the book is available (status = 'yes'). If the book is available, it should be issued, and the status in the books table should be updated to 'no'. 
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.
*/


create or replace procedure issue_book(p_issued_id varchar(20), p_issued_member_id varchar(20), p_issued_book_isbn varchar(50), p_issued_emp_id varchar(50))
language plpgsql
as $$
declare v_status varchar(10);
begin

select status
into v_status
from books 
where isbn = p_issued_book_isbn;

if v_status = 'yes' then
	insert into issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
	values
	(p_issued_id, p_issued_member_id, current_date, p_issued_book_isbn, p_issued_emp_id );
	update books
	set status= 'no'
	where isbn = p_issued_book_isbn;
	
	raise notice 'Book record added successfully for book isbn: %', p_issued_book_isbn;

else 
	raise notice 'Book requested is unavailable for book isbn: %', p_issued_book_isbn;

end if;

end;
$$

-- testing the function
CALL issue_book('IS157', 'C106', '978-0-330-25864-8', 'E104');

CALL issue_book('IS156', 'C108', '978-0-375-41398-8', 'E104');

SELECT * FROM books
WHERE isbn = '978-0-330-25864-8'

/* Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 
30 days. 
The table should include: The number of overdue books. 
The total fines, with each day's fine calculated at $0.50. The number of books issued by each member.
*/

select m.member_id, m.member_name, count(*) as no_books_overdue, Sum((((r.return_date - i.issued_date)-30) * 0.50)) as total_fines from return_status r
join issued_status i
on r.issued_id = i.issued_id
join members m
on i.issued_member_id = m.member_id
where (r.return_date - i.issued_date) > 30
group by 1,2;


select r.return_date, i.issued_date, (r.return_date-i.issued_date) from return_status r
join issued_status i
on r.issued_id = i.issued_id;
