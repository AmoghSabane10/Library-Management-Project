-- library management project

-- creating branch table
CREATE TABLE branch
(
            branch_id VARCHAR(10) PRIMARY KEY,
            manager_id VARCHAR(10),
            branch_address VARCHAR(30),
            contact_no VARCHAR(15)
);

-- Create table "Employee"
CREATE TABLE employees
(
            emp_id VARCHAR(10) PRIMARY KEY,
            emp_name VARCHAR(30),
            position VARCHAR(30),
            salary DECIMAL(10,2),
            branch_id VARCHAR(10),
            FOREIGN KEY (branch_id) REFERENCES  branch(branch_id)
);

-- Create table "Books"
CREATE TABLE books
(
            isbn VARCHAR(50) PRIMARY KEY,
            book_title VARCHAR(80),
            category VARCHAR(30),
            rental_price DECIMAL(10,2),
            status VARCHAR(10),
            author VARCHAR(30),
            publisher VARCHAR(30)
);

-- Create table "Members"
CREATE TABLE members
(
            member_id VARCHAR(10) PRIMARY KEY,
            member_name VARCHAR(30),
            member_address VARCHAR(30),
            reg_date DATE
);

-- Create table "IssueStatus"
CREATE TABLE issued_status
(
            issued_id VARCHAR(10) PRIMARY KEY,
            issued_member_id VARCHAR(30),
            issued_book_name VARCHAR(80),
            issued_date DATE,
            issued_book_isbn VARCHAR(50),
            issued_emp_id VARCHAR(10),
            FOREIGN KEY (issued_member_id) REFERENCES members(member_id),
            FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id),
            FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn) 
);

-- Create table "ReturnStatus"
CREATE TABLE return_status
(
            return_id VARCHAR(10) PRIMARY KEY,
            issued_id VARCHAR(30),
            return_book_name VARCHAR(80),
            return_date DATE,
            return_book_isbn VARCHAR(50),
            FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
);


-- inserting into return table
INSERT INTO return_status(return_id, issued_id, return_date) 
VALUES
('RS101', 'IS101', '2023-06-06'),
('RS102', 'IS105', '2023-06-07'),
('RS103', 'IS103', '2023-08-07'),
('RS104', 'IS106', '2024-05-01'),
('RS105', 'IS107', '2024-05-03'),
('RS106', 'IS108', '2024-05-05'),
('RS107', 'IS109', '2024-05-07'),
('RS108', 'IS110', '2024-05-09'),
('RS109', 'IS111', '2024-05-11'),
('RS110', 'IS112', '2024-05-13'),
('RS111', 'IS113', '2024-05-15'),
('RS112', 'IS114', '2024-05-17'),
('RS113', 'IS115', '2024-05-19'),
('RS114', 'IS116', '2024-05-21'),
('RS115', 'IS117', '2024-05-23'),
('RS116', 'IS118', '2024-05-25'),
('RS117', 'IS119', '2024-05-27'),
('RS118', 'IS120', '2024-05-29');
SELECT * FROM return_status;

insert into books( isbn, book_title, category, rental_price, status, author, publisher)
values ( '978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

select * from members; 
-- updating an address

update members
set member_address ='125 Main St'
where member_id='C101';

-- delete record with ISBN 104

delete from issued_status 
where issued_id= 'IS121';

select * from issued_status;

-- books issued by emp 101

select * from issued_status
where issued_emp_id='E101';

-- employees who have issued more than 1 book

select issued_emp_id, count(issued_id) as total_count 
from issued_status
group by 1
having count(issued_id)>2;
 
-- CTAS: for each book and the total issue count

create table book_cnts as
select b.isbn,b.book_title, count(ist.issued_id) as no_issued 
from books b
join 
issued_status ist 
on b.isbn=ist.issued_book_isbn
group by b.isbn,2;


-- retrieve all books from a specific category

select * from books 
where category='Classic';

-- finding rental income by each category

select b.category,sum(b.rental_price) as total_rent_price, count(ist.issued_id) as no_issued 
from books b
join 
issued_status ist 
on b.isbn=ist.issued_book_isbn
group by 1;

-- selecting members who registered in the last 180 days

insert into members(member_id, member_name, member_address, reg_date)
values ('C140','Newmen 1', '100 Long St', '2025-04-01'),
		('C150', 'Newmen 2', '200 Long St', '2025-04-02');

select * from members
where reg_date > current_date - interval '180 days';

-- listing employee name with name of manager

select e.*, e2.emp_name as manager, b.branch_id
from employees as e
join branch as b
on b.branch_id = e.branch_id
join employees as e2
on b.manager_id = e2.emp_id;

-- table with books above $7

create table pricey_books as
select * from books 
where rental_price>7;

select * from pricey_books;

-- books not yet returned

select i.issued_book_name from issued_status i
left join return_status r on
i.issued_id = r.issued_id
where r.return_id is null;
