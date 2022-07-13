-- Creating new customer
SELECT * FROM customer;
CALL new_customer ('Marcell', 'Jacobs','marcell@mail.com', '9 Woodside', '0777777', '1990-01-01');
SELECT * FROM customer;

--Testing product availability function
--Product not in stock:
SELECT check_if_in_stock (find_product(4));
-- Product in stock:
SELECT check_if_in_stock (find_product(2));

--Testing slot_availability function
-- with a past date:
SELECT slot_availability ('2001-10-01', 'PM');
-- with a non-valid time: 
SELECT slot_availability ('2021-10-01', 'Noon');
-- Date not available:
SELECT slot_availability ('2021-10-01', 'AM');
-- Date available:
SELECT slot_availability ('2021-11-24', 'PM');	
	
--testing procedure for a new purchase:
-- Customer non existent:
CALL make_a_purchase (9, 4, '2022-01-01', 'AM');
--Product non existent:
CALL make_a_purchase (2, 8, '2022-01-01', 'AM');
--Product not in stock:
CALL make_a_purchase (2, 4, '2021-10-01','AM');
--Slot not available:
CALL make_a_purchase (2, 3, '2021-10-01','AM');

--Checking purchase table before running a successfull purchase:
SELECT * FROM purchase;
--Slot available, purchase successfull:
CALL make_a_purchase (2, 3, '2021-11-24','AM');
--Checking purchase table if updated:
SELECT * FROM purchase;