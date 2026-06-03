-- Snowflake setup voor het dbt-project.
-- Voer dit uit in Snowsight (Worksheets) als ACCOUNTADMIN.
-- Maakt warehouse, databases, een role en een dbt-user aan.

use role accountadmin;

-- Warehouse voor dbt-transformaties (klein + auto-suspend = lage kosten).
create warehouse if not exists transforming
  warehouse_size = 'xsmall'
  auto_suspend = 60
  auto_resume = true
  initially_suspended = true;

-- Databases: RAW (bronlanding) en ANALYTICS (dbt-output).
create database if not exists raw;
create database if not exists analytics;

-- Role voor dbt.
create role if not exists transformer;

-- Rechten op het warehouse.
grant usage   on warehouse transforming to role transformer;
grant operate on warehouse transforming to role transformer;

-- Leesrechten op de RAW-database (bronnen).
grant usage  on database raw                  to role transformer;
grant usage  on all schemas in database raw   to role transformer;
grant select on all tables in schema raw.public    to role transformer;
grant select on future tables in schema raw.public to role transformer;

-- Volledige rechten op ANALYTICS (waar dbt zijn modellen wegschrijft).
grant usage         on database analytics to role transformer;
grant create schema on database analytics to role transformer;

-- dbt-user. LET OP: vervang het wachtwoord door iets sterks en uniek!
create user if not exists dbt_user
  password = 'CHANGE_ME_StrongPassword123!'
  default_role = transformer
  default_warehouse = transforming
  must_change_password = false;

grant role transformer to user dbt_user;

-- Geef ook jouw eigen rol toegang, zodat je kunt meekijken/testen.
grant role transformer to role sysadmin;
