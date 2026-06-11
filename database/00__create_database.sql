/*
    Gathel - 00__create_database.sql
    Database engine: SQL Server
    Database name: Gathel

    Manual script executed before Flyway.

    Purpose:
    - Creates the Gathel database if it does not exist.
    - Selects the Gathel database to verify that the connection is correct.

    Important notes:
    - This file is NOT a Flyway migration.
    - This script must be executed manually before running `flyway migrate`.
    - Flyway will manage the schema, catalogs, seed data and validation scripts after the database already exists.
*/

IF DB_ID(N'Gathel') IS NULL
BEGIN
    CREATE DATABASE Gathel;
END;
GO

USE Gathel;
GO

SELECT DB_NAME() AS CurrentDatabase;
GO
