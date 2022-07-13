DROP TABLE IF EXISTS customer CASCADE;
DROP TABLE IF EXISTS bank_details CASCADE;
DROP TABLE IF EXISTS product CASCADE;
DROP TABLE IF EXISTS purchase CASCADE;
DROP TABLE IF EXISTS store CASCADE;
DROP TABLE IF EXISTS stock CASCADE;
DROP TABLE IF EXISTS booked_slot CASCADE;


CREATE TABLE IF NOT EXISTS customer (
	customer_id SERIAL PRIMARY KEY,
	name VARCHAR (50) NOT NULL,
	surname VARCHAR (50) NOT NULL,
	email VARCHAR (100) UNIQUE NOT NULL,
	address VARCHAR (50),
	phone VARCHAR (50),
	date_of_birth DATE CHECK (date_of_birth BETWEEN '1900-01-01' AND CURRENT_DATE)
);

CREATE TABLE IF NOT EXISTS bank_details (
	bank_details_id SERIAL PRIMARY KEY,
	customer_id INTEGER REFERENCES customer(customer_id) NOT NULL,
	bank_name VARCHAR (50) NOT NULL,
	sort_code INTEGER NOT NULL,
	account_number INTEGER NOT NULL	
);

CREATE TABLE  IF NOT EXISTS product (
	product_id SERIAL PRIMARY KEY,
	product_name VARCHAR (100) NOT NULL,
	product_type VARCHAR (50) NOT NULL,
	description VARCHAR (300),
	product_cost DECIMAL NOT NULL CHECK(product_cost > 0)
);

CREATE TABLE  IF NOT EXISTS store (
	store_id SERIAL PRIMARY KEY,
	store_address VARCHAR (200),
	store_city VARCHAR (200),
	store_phone VARCHAR (50)
);

CREATE TABLE IF NOT EXISTS booked_slot (
	delivery_id SERIAL PRIMARY KEY,
	delivery_date DATE NOT NULL CHECK (delivery_date > CURRENT_DATE),
	delivery_time VARCHAR (2) CHECK(delivery_time = 'AM' OR delivery_time = 'PM') NOT NULL
);

CREATE TABLE  IF NOT EXISTS purchase (
	purchase_id SERIAL PRIMARY KEY,
	customer_id INTEGER REFERENCES customer(customer_id) NOT NULL,
	product_id INTEGER REFERENCES product(product_id) NOT NULL,
	purchase_date TIMESTAMP NOT NULL NOT NULL,
	delivery_id INTEGER REFERENCES booked_slot(delivery_id)
);

CREATE TABLE  IF NOT EXISTS stock (
	product_id INTEGER REFERENCES product(product_id) NOT NULL,
	store_id INTEGER REFERENCES store(store_id) NOT NULL,
	quantity SMALLINT NOT NULL CHECK (quantity >= 0),
	PRIMARY KEY(product_id, store_id)
);

INSERT INTO customer (name, surname,email, date_of_birth)
VALUES ('Walter', 'White', 'walter@mail.com', '1990-12-12');

INSERT INTO customer (name, surname,email, address, phone, date_of_birth)
VALUES ('Tyler', 'Durden', 'tyler@mail.com', 'Knuckle road', '020202020', '1997-06-02');

INSERT INTO bank_details (customer_id, bank_name, sort_code, account_number)
VALUES
(1, 'Barclays', 999999, 12345678),
(2, 'HSBC', 888888, 87654321);

INSERT INTO product (product_name, product_type, description, product_cost) VALUES
('Guitar', 'Instrument', 'John Frusciante''s electric guitar', 600.00),
('Smells like teen spirit', 'CD', 'Smells like teen spirit - Nirvana', 20.00),
('Drum kit', 'Instrument', 'Full-size starter drum kit', 200.00),
('Have a drink on me', 'Book', 'Bon Scott: The Inside Story of Ac/DC''s Troubled Frontman', 15.00);

INSERT INTO store (store_address, store_city, store_phone) VALUES
('7 Watermeadow Lane', 'London', '020776655'),
('20 ALbert Drive', 'Manchester', '016123456'),
('1 Capern road', 'Birmingham', '0121223344');

INSERT INTO stock (product_id, store_id, quantity) VALUES
(1, 1, 6),
(1, 2, 12),
(1, 3, 8),
(2, 1, 9),
(2, 2, 14),
(2, 3, 19),
(3, 1, 1),
(3, 3, 5),
(4, 1, 0),
(4, 2, 0),
(4, 3, 0);

INSERT INTO purchase (customer_id, product_id, purchase_date)
VALUES 
(1, 1, CURRENT_TIMESTAMP);

INSERT INTO purchase (customer_id, product_id, purchase_date) 
VALUES
(1, 3, CURRENT_TIMESTAMP),
(2, 2, CURRENT_TIMESTAMP);

INSERT INTO booked_slot (delivery_date, delivery_time) VALUES
('2021-10-01', 'AM'),
('2021-11-11', 'PM');



-- Procedure to create a new customer
CREATE OR REPLACE PROCEDURE new_customer (
	new_name customer.name%TYPE, 
	new_surname customer.surname%TYPE,
	new_email customer.email%TYPE,
	new_address customer.address%TYPE,
	new_phone customer.phone%TYPE,
	new_date_of_birth customer.date_of_birth%TYPE
)
LANGUAGE 'plpgsql'
AS $$
BEGIN 
	INSERT INTO customer 
	(
	name, 
	surname,
	email,
	address,
	phone,
	date_of_birth
	)
	VALUES
	(new_name, new_surname, new_email, new_address, new_phone, new_date_of_birth);
	RAISE NOTICE 'The new customer % % has been registered', new_name, new_surname;
END; $$;


-- Function to search for a customer
CREATE OR REPLACE FUNCTION find_customer(search_customer customer.customer_id%TYPE)
	RETURNS customer.customer_id%TYPE 
LANGUAGE plpgsql
AS $$
  BEGIN
  SELECT customer_id INTO STRICT search_customer FROM customer
  WHERE customer_id = search_customer;
  RETURN search_customer;
  EXCEPTION
  	WHEN NO_DATA_FOUND THEN
		RAISE NOTICE 'The customer could not be found';
END;$$;

-- Function to search for a product
CREATE OR REPLACE FUNCTION find_product(search_product_id product.product_id%TYPE)
   RETURNS product.product_id%TYPE
   LANGUAGE plpgsql
  AS
$$
BEGIN
 SELECT product_id
 INTO STRICT search_product_id
 FROM product
 WHERE search_product_id = product.product_id;
  RETURN search_product_id;
EXCEPTION
 	WHEN NO_DATA_FOUND THEN
 		RAISE NOTICE 'The product could not be found';
END;
$$;

--function to check if product in stock and how many are available in all stores
CREATE OR REPLACE FUNCTION check_if_in_stock (my_product_id product.product_id%TYPE)
returns BOOLEAN
language plpgsql
  as $$
DECLARE
count_stock INTEGER;
BEGIN
 SELECT SUM (quantity) FROM stock
 WHERE product_id = find_product(my_product_id)
 GROUP BY stock.product_id
 INTO count_stock;
 	CASE 
 	WHEN count_stock < 1 THEN
 	RAISE NOTICE 'Product not in stock';
	RETURN False;
	ELSE
	RAISE NOTICE 'The product is in stock. % pieces available', count_stock;
	RETURN True;
 	END CASE;
END;
$$;

-- Function to check slot availability
CREATE OR REPLACE FUNCTION slot_availability (my_date booked_slot.delivery_date%TYPE, my_time booked_slot.delivery_time%TYPE)
RETURNS BOOLEAN
LANGUAGE plpgsql
	AS $$
	DECLARE 
	counting INTEGER; 
	BEGIN
		IF my_date < CURRENT_DATE THEN
			RAISE EXCEPTION 'The delivery slot can not be in the past';
		END IF;
		IF my_time != 'AM' AND my_time != 'PM' THEN
			RAISE EXCEPTION 'Insert correct delivery time (AM or PM)';
		END IF;
		SELECT COUNT(delivery_date) INTO counting FROM booked_slot
			WHERE my_date = booked_slot.delivery_date AND my_time = booked_slot.delivery_time;
		IF counting = 0 THEN
			RAISE NOTICE 'Date available';
			RETURN 1;
		ELSE
			RAISE NOTICE 'Sorry, date not available';
			RETURN 0;
		END IF;	
END; $$;



-- Function to make a purchase
CREATE OR REPLACE PROCEDURE make_a_purchase (
	my_customer customer.customer_id%TYPE, 
	my_product product.product_id%TYPE,
	my_date booked_slot.delivery_date%TYPE,
	my_time booked_slot.delivery_time%TYPE
	)
LANGUAGE plpgsql    
AS $$
DECLARE
product_in_stock BOOLEAN;
my_slot BOOLEAN;
my_delivery_id booked_slot.delivery_id%TYPE;

BEGIN
	--checking customer and product availability
	my_customer = find_customer(my_customer);
	product_in_stock = check_if_in_stock (my_product);
	
	IF product_in_stock = False THEN
		RAISE NOTICE 'Sorry, we hope it will be in stock again soon';
		RETURN;
		
	ELSEIF product_in_stock = True THEN
		--checking if delivery slot is available:
		my_slot = slot_availability (my_date, my_time);
			IF my_slot = True THEN
				-- Updating booked_slot table with a new slot:
				INSERT INTO booked_slot (delivery_date, delivery_time)
					VALUES (
					my_date, 
					my_time 	
					);
					
				my_delivery_id = delivery_id FROM booked_slot 
					WHERE booked_slot.delivery_date = my_date AND booked_slot.delivery_time = my_time;

				-- Updating purchase table with a new purchase and delivery slot
				INSERT INTO purchase (customer_id, product_id, purchase_date, delivery_id)
					VALUES (
					find_customer (my_customer),
					find_product (my_product),
					CURRENT_TIMESTAMP,
					my_delivery_id
					);
					RAISE NOTICE 'The customer % % has bought the product %. The delivery slot will be on %, %', 
					customer.name FROM customer WHERE customer_id = my_customer,
					customer.surname FROM customer WHERE customer_id = my_customer,
					product.product_name FROM product WHERE product_id = my_product,
					my_date, my_time;
			ELSE
			RAISE NOTICE 'Please choose another delivery slot';
		END IF;
	END IF;
COMMIT;
END; $$;