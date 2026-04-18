-- ============================================================
--  sql-init.sql — bootstrap для Flink SQL Client
--
--  Повторяет DDL из com.example.paimon.PaimonHdfsJob:
--    Paimon catalog → test_db → test_table.
--
--  Выполняется автоматически при старте ./bin/sql-client.sh.
-- ============================================================

-- SQL Gateway стартует только с jar'ами из $FLINK_HOME/lib.
-- Paimon-коннектор кладётся сабмит-плейбуком в per-job lib-папку,
-- поэтому подключаем его явно в текущую сессию.
ADD JAR 'file:///opt/flink-ivkochkozharov/flink-2.2.0/jobs/paimon-hdfs-job-1.0-SNAPSHOT/lib/paimon-flink-2.1-1.3.1.jar';

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
