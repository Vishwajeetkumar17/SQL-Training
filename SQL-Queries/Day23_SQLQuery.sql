-- =============================================
-- Author:		Vishwajeet
-- Create date: 22-01-2026
-- Description:	Sample SP
-- =============================================

--use myDatabase;

--create procedure MyPractice
--as
--Begin

--SELECT * FROM [dbo].[Customers]

--End

--go
--exec MyPractice


--alter procedure MyPractice

--@City varchar(49)
--as
--Begin
--SELECT * FROM [dbo].[Customers] where City = @City

--End

--go
--execute MyPractice 'Coimbatore'

--create procedure [dbo].[Sp_GetCustomerByNameAndCity]
--	-- Add the parameters for the stored procedure here
--	@Name varchar(100),
--	@City varchar(50)
--as
--begin
--	select * from Customers where FullName = @Name and City = @City
--end
--go
--exec Sp_GetCustomerByNameAndCity 'Gopi Suresh','Coimbatore'

-------------------------------------------------------------------------------

--CRUD Operations using Design Query in Editor GUI

--INSERT INTO tbl_Department
--                  (ID, Name)
--VALUES (4, 'Dept4'),(5, 'Dept5')

--SELECT * from tbl_Department;
-------------------------------------------------------------------------------

-- Stored Procedures for CRUD Operations

--ALTER PROCEDURE [dbo].[Sp_CrudOperations]
--AS
--BEGIN
--    -- READ
--    SELECT *
--    FROM tbl_Department;

--    -- INSERT
--    INSERT INTO tbl_Department (ID, Name)
--    VALUES 
--        (6, 'Dept6'),
--        (7, 'Dept7');

--    -- UPDATE
--    UPDATE tbl_Department
--    SET 
--        ID = 55,
--        Name = 'Heavy Department'
--    WHERE ID = 5;

--    -- DELETE
--    DELETE FROM tbl_Department
--    WHERE ID = 1;
--END;
--GO

--EXEC Sp_CrudOperations;