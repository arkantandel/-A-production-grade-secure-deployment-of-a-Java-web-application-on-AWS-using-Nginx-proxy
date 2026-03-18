-- ============================================================
--  rds_setup.sql  (works for local MySQL too)
--  Student Registration Application — Database Schema
--
--  Connect:  mysql -h <HOST> -u admin -p
--  Run:      source rds_setup.sql
-- ============================================================

CREATE DATABASE IF NOT EXISTS studentapp;
USE studentapp;

CREATE TABLE IF NOT EXISTS students (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    name          VARCHAR(100) NOT NULL,
    address       VARCHAR(200),
    age           INT,
    qualification VARCHAR(100),
    percentage    DECIMAL(5,2),
    year          INT,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Verify
SHOW TABLES;
DESC students;
