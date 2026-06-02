/*
    Gathel - 00__create_database.sql
    Script manual previo a Flyway.

    Este script crea la base de datos Gathel si todavía no existe.
    No se ejecuta como migración Flyway.
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