CREATE LOGIN noah WITH PASSWORD = 'SA-PWD-CHANGEME-723387667'
,DEFAULT_DATABASE = NOAH
GO

USE NOAH
CREATE USER noah FOR LOGIN noah;
EXEC sp_addrolemember 'db_datareader', 'noah'
EXEC sp_addrolemember 'db_datawriter', 'noah'
GO
