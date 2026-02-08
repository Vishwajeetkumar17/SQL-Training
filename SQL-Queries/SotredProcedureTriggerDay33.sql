-- =============================================
-- Author: Vishwajeet
-- Create date: 05-02-2926
-- Description:	sample
-- =============================================
DROP TRIGGER IF EXISTS sales.Inserting_Trigger_Customer;
GO


CREATE or ALTER TRIGGER sales.Inserting_Trigger_Customer
ON sales.customers
AFTER INSERT
AS
BEGIN
    set nocount on;
    declare @name varchar(max)
    set @name=(select last_name from inserted)
    insert into dbo.LogTable(Id,Logtext)
    values(
    NEWID(),@name + ' is inserted'+ convert(varchar(30),getdate(),120)
    )
END;
GO


----------------------------------------------------------------------------------------------------------------------

INSERT INTO sales.customers
(first_name, last_name, phone, email, street, city, state, zip_code)
VALUES
('Vemula', 'Thiluck Vardhan', '8885619995', 'thiluck@gmail.com',
 'MG Road', 'Hyderabad', 'Telangana', '5000');

select * from LogTable;


