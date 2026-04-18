-- ============================================================
--  sql-init.sql — bootstrap для Flink SQL Client
--
--  Повторяет DDL из com.example.paimon.PaimonHdfsJob:
--    Paimon catalog → test_db → test_table.
--
--  Выполняется автоматически при старте ./bin/sql-client.sh.
-- ============================================================

CREATE CATALOG IF NOT EXISTS paimon_catalog WITH (
  'type'      = 'paimon',
  'warehouse' = 'hdfs:///user/kochkozharov/paimon/warehouse'
);

USE CATALOG paimon_catalog;

CREATE DATABASE IF NOT EXISTS test_db;
USE test_db;

CREATE TABLE IF NOT EXISTS test_table (
  id      BIGINT,
  name    STRING,
  amount  DOUBLE,
  ts      TIMESTAMP(3),
  PRIMARY KEY (id) NOT ENFORCED
) WITH (
  'bucket' = '2'
);
