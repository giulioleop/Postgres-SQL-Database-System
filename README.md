# Postgres-SQL-Database-System

Description of task:
“Milllie’s Musical Emporium (MME) Ltd has grown from a small company based in a small market town, to one of the country’s leading suppliers of musical instruments and associated media.
To cope with their growth and allow for more efficient stock recording, the store has decided to computerise their customer management and stock recording system. You have been tasked with developing a database application to meet their needs.
Using PostgreSQL, you are required to design and develop a prototype system that satisfies the requirements of the current system.
a)	Produce a SQL script file which can be run within PostgreSQL without error and which drops and creates your tables (correctly ensuring that any referential integrity issues can be resolved), and inserts sample data into each table.
b)	Using PostgreSQL develop:
I.	A PL/pgSQL stored procedure (and any associated code) which allows for registration of new customers.
II.	A PL/pgSQL stored procedure (and any associated code) which allows an existing customer to purchase a product. This transaction must allow the client to specify a specific product to purchase, a delivery date and time, ensuring that the delivery can only be booked if both that product and delivery slot are available.
