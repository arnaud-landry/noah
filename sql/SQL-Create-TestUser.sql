CREATE LOGIN testuser WITH PASSWORD = 'SA-PWD-CHANGEME-723387667'
,DEFAULT_DATABASE = testdb
GO

USE testdb
CREATE USER testuser FOR LOGIN testuser;
EXEC sp_addrolemember 'db_datareader', 'testuser'
EXEC sp_addrolemember 'db_datawriter', 'testuser'
GO
