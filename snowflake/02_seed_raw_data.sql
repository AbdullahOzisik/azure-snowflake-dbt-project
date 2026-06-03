-- Vult de RAW-database met wat voorbeelddata, zodat de dbt-modellen
-- (die naar source('raw', ...) verwijzen) meteen iets hebben om te draaien.
-- Voer uit ná 01_setup.sql, als ACCOUNTADMIN.

use role accountadmin;
use database raw;
use schema public;

-- Klanten
create or replace table customers (
  id          integer,
  first_name  string,
  last_name   string,
  email       string,
  created_at  timestamp
);

insert into customers (id, first_name, last_name, email, created_at) values
  (1, 'Emma',  'de Vries',   'emma@example.com',  '2024-01-15 09:00:00'),
  (2, 'Lucas', 'Jansen',     'lucas@example.com', '2024-02-03 14:30:00'),
  (3, 'Sophie','Bakker',     'sophie@example.com','2024-02-20 11:15:00'),
  (4, 'Daan',  'Visser',     'daan@example.com',  '2024-03-08 16:45:00'),
  (5, 'Julia', 'Smit',       'julia@example.com', '2024-03-25 10:00:00');

-- Orders
create or replace table orders (
  id            integer,
  customer_id   integer,
  order_status  string,
  order_total   number(10,2),
  ordered_at    timestamp
);

insert into orders (id, customer_id, order_status, order_total, ordered_at) values
  (101, 1, 'completed', 49.99,  '2024-01-20 12:00:00'),
  (102, 1, 'completed', 19.50,  '2024-02-10 13:30:00'),
  (103, 2, 'completed', 120.00, '2024-02-15 09:45:00'),
  (104, 3, 'shipped',   75.25,  '2024-03-01 17:20:00'),
  (105, 4, 'completed', 30.00,  '2024-03-12 08:10:00'),
  (106, 5, 'cancelled', 200.00, '2024-04-02 15:00:00'),
  (107, 2, 'completed', 60.75,  '2024-04-18 11:30:00');
