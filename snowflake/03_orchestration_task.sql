-- Demo van Snowflake-orkestratie met een TASK (imperatief, naast de
-- declaratieve Dynamic Tables in dbt). Voer uit als ACCOUNTADMIN, bv.:
--   python snowflake/run_sql.py snowflake/03_orchestration_task.sql
--
-- Wat het doet: elke paar minuten het aantal rijen in dim_customers wegschrijven
-- naar een audit-tabel, zodat je scheduling + task-history kunt laten zien.

use role accountadmin;
use database analytics;

-- Aparte 'ops'-schema voor operationele/audit-objecten.
create schema if not exists ops;

-- Audit-tabel: één rij per meting.
create table if not exists analytics.ops.row_counts (
  measured_at timestamp_ltz default current_timestamp(),
  table_name  string,
  row_count   number
);

-- De task zelf. Draait op warehouse TRANSFORMING, elke ochtend om 06:00.
--   CRON-velden: minuut uur dag-vd-maand maand dag-vd-week  + tijdzone.
--   '0 6 * * *' = elke dag om 06:00. Voor een interval i.p.v. CRON: '5 MINUTE'.
create or replace task analytics.ops.log_customer_count
  warehouse = transforming
  schedule  = 'USING CRON 0 6 * * * Europe/Amsterdam'
  as
    insert into analytics.ops.row_counts (table_name, row_count)
    select 'dim_customers', count(*)
    from analytics.dbt_dev_marts.dim_customers;

-- Tasks starten standaard SUSPENDED; activeren met RESUME.
alter task analytics.ops.log_customer_count resume;

-- ---------------------------------------------------------------------------
-- Handig om los te draaien (in Snowsight of via run_sql.py):
--
--   -- meteen één keer uitvoeren (niet wachten op de schedule):
--   execute task analytics.ops.log_customer_count;
--
--   -- resultaat bekijken:
--   select * from analytics.ops.row_counts order by measured_at desc;
--
--   -- run-historie van de task:
--   select name, state, scheduled_time, completed_time, error_message
--   from table(information_schema.task_history(
--     task_name => 'LOG_CUSTOMER_COUNT'))
--   order by scheduled_time desc;
--
--   -- BELANGRIJK: na de demo pauzeren (anders blijft 'ie elke 5 min draaien):
--   alter task analytics.ops.log_customer_count suspend;
-- ---------------------------------------------------------------------------
