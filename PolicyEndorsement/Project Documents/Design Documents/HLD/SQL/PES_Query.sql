use Sep19CHN

CREATE schema Group2 

----------------------------
--Admin Table
----------------------------
CREATE TABLE Group2.Admin
(
adminID int primary key,
loginID varchar(10),
userType varchar(15)
)

--------------------------
--Customer Table
--------------------------
CREATE TABLE Group2.Customer
(
customerID int primary key,
loginID varchar(10),
customerName varchar(30),
customerAddress varchar(50),
customerTelephone varchar(12),
customerGender char,
customerDOB DateTime,
customerSmoking varchar(20),
customerHobbies varchar(20),
nomineeName varchar(30),
nomineeRelation varchar(20),
userType varchar(15)
)

-----------------------------
--Login Table
-----------------------------
CREATE TABLE Group2.LoginCredentials
(
loginID varchar(10) primary key,
userpassword varchar(20),
userType varchar(15)
)

----------------------------------
--Insurance Product Table
----------------------------------
CREATE TABLE Group2.InsuranceProduct
(
productID int primary key,
productName varchar(30),
productLine varchar(200)
)

------------------------------------
--Policy Table
------------------------------------
CREATE TABLE Group2.Policy
(
policyNumber int primary key,
policyName varchar(30),
policyDetails varchar(200),
productID int FOREIGN KEY (productID) REFERENCES Group2.InsuranceProduct(productID)
)

----------------------------------
--Customer Policy Details Table
----------------------------------
CREATE TABLE Group2.CustomerPolicyDetails
(
policyNumber int FOREIGN KEY (policyNumber) REFERENCES Group2.Policy(policyNumber),
customerID int FOREIGN KEY (customerID) REFERENCES Group2.Customer(customerID),
premiumFrequency varchar(20)
)

--------------------------------------
--Endorsement Table
--------------------------------------
CREATE TABLE Group2.Endorsements
(
transactionID int identity(1000,1) primary key,
customerID int FOREIGN KEY (customerID) REFERENCES Group2.Customer(customerID),
policyNumber int FOREIGN KEY (policyNumber) REFERENCES Group2.Policy(policyNumber),
policyName varchar(30),
productName varchar(30),
productLine varchar(200),
customerName varchar(30),
customerAddress varchar(50),
customerTelephone varchar(12),
customerGender char,
customerDOB DateTime,
customerSmoking varchar(20),
nomineeName varchar(30),
nomineeRelation varchar(20),
premiumFrequency varchar(20),
statusEndo varchar(20)
)

------------------------------------------------------------------------
--Endorsement Temporary Table
------------------------------------------------------------------------
CREATE TABLE Group2.EndorsementsTemp
(
transactionID int identity(1000,10) primary key,
customerID int FOREIGN KEY (customerID) REFERENCES Group2.Customer(customerID),
policyNumber int FOREIGN KEY (policyNumber) REFERENCES Group2.Policy(policyNumber),
policyName varchar(30),
productLine varchar(30),
customerName varchar(30),
customerAddress varchar(50),
customerTelephone varchar(12),
customerGender char,
customerDOB DateTime,
customerSmoking varchar(20),
nomineeName varchar(30),
nomineeRelation varchar(20),
premiumFrequency varchar(20),
statusEndo varchar(20)
)

--------------------------------------
--Customer Uploaded Document Path Table
--------------------------------------
CREATE TABLE Group2.CustDocuments
(
transactionID int FOREIGN KEY (transactionID) REFERENCES Group2.EndorsementsTemp(transactionID),
docsPath varchar(100)
)

--------------------------------------
--Customer Uploaded Document Table
--------------------------------------
CREATE TABLE Group2.CustomerDocs
(
customerID varchar(20),
policyNumber int,
img image
)

------------------------------------------
--Populating the Admin, Customer, LoginCredentials, InsuranceProduct, Policy, CustomerPolicyDetails, Endorsement
------------------------------------------

INSERT INTO Group2.Admin VALUES(8003,'ADM8003','ADMIN')

INSERT INTO Group2.Customer VALUES(5003,'CUST5003','Maria S','Kolkata','9856274123','F','02/05/1992','Non-Smoker','Painting','Sarah S','Sister','CUSTOMER')

INSERT INTO Group2.LoginCredentials VALUES('CUST5002','5002','CUSTOMER')

INSERT INTO Group2.InsuranceProduct VALUES(2, 'Non-Life Insurance')

INSERT INTO Group2.Policy VALUES(25,'Crop Insurance',
'Crop insurance is purchased by agricultural producers to protect against either 
the loss of their crops due to natural disasters, such as hail, drought, and floods.',2)

INSERT INTO Group2.CustomerPolicyDetails VALUES (24,5001,'YEARLY')

INSERT INTO Group2.Endorsements VALUES(5002,24,'Travel Insurance','Non-Life Insurance',
'Robert J','Bangalore','9811234561','M','10/10/1991','Smoker','John J','Father' ,'YEARLY')

INSERT INTO Group2.EndorsementsTemp VALUES(5002,22,	
'Home Insurance','Non-Life Insurance',
'Saumya R','Delhi','9988112347','F','1990-05-08','Smoker','Ram','Father','MONTHLY','C:','PENDING')

select * from  Group2.Endorsements

----------------------------------------------------------------
--Procedure for inserting in Endorsement Temporary
----------------------------------------------------------------
CREATE PROC [Group2].[usp_InsertEndoTemp]
@ccustomerID int,
@cpolicyNumber int,
@cpolicyName varchar(30),
@cproductLine varchar(200),
@cName varchar(30),
@cAddress varchar(50),
@cPh varchar(12),
@cGender char,
@cDOB DateTime,
@cSmoking varchar(20),
@cnomineeName varchar(30),
@cnomineeRelation varchar(20),
@cpremiumFrequency varchar(20),
@cstatusEndo varchar(20)
AS
BEGIN
--SET IDENTITY_INSERT Group2.EndorsementsTemp  ON
INSERT INTO Group2.EndorsementsTemp
 (customerID, policyNumber, policyName,productLine, customerName,
 customerAddress,customerTelephone,customerGender,customerDOB,
 customerSmoking,nomineeName,nomineeRelation,premiumFrequency,docPath,statusEndo)
VALUES(@ccustomerID,@cpolicyNumber,@cpolicyName,@cproductLine,
 @cName,@cAddress,@cPh,@cGender,@cDOB,@cSmoking,@cnomineeName,
 @cnomineeRelation,@cpremiumFrequency,@cstatusEndo)
END

-----------------------------------------------------------------------------
--Search Policy Procedure
---------------------------------------------------------------------------------
CREATE PROC Group2.usp_SearchPolicy
@PN int ,
@CID int
AS 
BEGIN
SELECT CPD.policyNumber,CPD.customerID,PC.policyName, PC.policyDetails
from Group2.CustomerPolicyDetails CPD INNER JOIN Group2.Policy PC
ON CPD.policyNumber=PC.policyNumber where   
(CPD.policyNumber=@PN and CPD.customerID=@CID)
END



-----------------------------------------------------------------
--Audit Temporary Endorsement Table  
-----------------------------------------------------------------
CREATE TABLE Group2.AuditEndorsementsTemp
(
auditID int identity(100,1),
transactionID int,
customerID int,
policyNumber int,
policyName varchar(30),
dateUpdated DateTime
)

-----------------------------------------------------------------
--Audit Endorsement Table  
-----------------------------------------------------------------
create table Group2.AuditEndoresements
(
auditID int identity(100,1),
transactionID int,
customerID int,
policyNumber int,
policyName varchar(30),
dateUpdated DateTime
)

-----------------------------------------------------------------
--Triggering Update on Endorsing 
-----------------------------------------------------------------
create trigger Group2.trigger_updateOnEndo
ON Group2.EndorsementsTemp
FOR update
AS
DECLARE @transactionID int;
DECLARE @customerID int;
DECLARE @policyNumber int;
DECLARE @policyName varchar(30);

SELECT @transactionID = i.transactionID from inserted i;	
SELECT @customerID = i.customerID from inserted i;	
SELECT @policyNumber = i.policyNumber from inserted i;	
SELECT @policyName = i.policyName from inserted i;	

BEGIN

INSERT INTO Group2.AuditEndoresements
VALUES(@transactionID,@customerID,@policyNumber,@policyName,getDate())

END

-------------------------------------------------------
--Endorsement procedure
-------------------------------------------------------
CREATE PROC Group2.usp_Endorsements
@cid int,
@pno int
AS
BEGIN
SELECT transactionID,policyName,productLine,
customerName,customerAddress,customerTelephone,
nomineeName,nomineeRelation
FROM Group2.Endorsements
WHERE (customerID=@cid AND policyNumber = @pno)
END

-------------------------------------------------------
--Display Endorsement Procedure
-------------------------------------------------------
CREATE PROC Group2.usp_ViewEndorsements
@cid int,
@pno int
AS
BEGIN
SELECT customerID,policyNumber,policyName,productLine,
customerName,customerAddress,customerTelephone,customerGender,
customerDOB,customerSmoking,nomineeName,nomineeRelation,premiumFrequency,customerDocs
FROM Group2.Endorsements
WHERE (customerID=@cid AND policyNumber = @pno)
END




--------------------------------------------------------
--Triggering Update on Customer Details
--------------------------------------------------------

create trigger Group2.trigger_customerUpdate
ON Group2.Endorsements
for insert
as
declare @customerID varchar(30);
declare @customerName varchar(30);
declare @customerAddress varchar(50);
declare @customerTelephone varchar(12);
declare @customerGender char;
declare @customerDOB DateTime;
declare @customerSmoking varchar(20);
declare @nomineeName varchar(30);
declare @nomineeRelation varchar(20);

select @customerName = i.customerName from inserted i;	
select @customerAddress = i.customerAddress from inserted i;	
select @customerTelephone = i.customerTelephone from inserted i;	
select @customerGender = i.customerGender from inserted i;	
select @customerDOB = i.customerDOB from inserted i;	
select @customerSmoking = i.customerSmoking from inserted i;	
select @nomineeName = i.nomineeName from inserted i;	
select @nomineeRelation = i.nomineeRelation from inserted i;	

begin
update Group2.Customer set
customerName=@customerName,
customerAddress=@customerAddress,
customerTelephone=@customerTelephone,
customerGender=@customerGender,
customerDOB=@customerDOB,
customerSmoking=@customerSmoking,
nomineeName=@nomineeName,
nomineeRelation=@nomineeRelation
where (customerID=@customerID AND @customerName = customerName);

end

--------------------------------------------------------
--Display Customer Endorsement Procedure
--------------------------------------------------------
create proc Group2.usp_AllCustEndo
as
begin
select * from Group2.Endorsements
end

exec Group2.usp_AllCustEndo

--------------------------------------------------------
--Get Uploaded image procedure
--------------------------------------------------------
alter proc Group2.usp_RetrieveImage
@cid int,
@pn int
as
begin
select * from Group2.CustomerDocs
 where customerID=@cid AND policyNumber=@pn
end


--------------------------------------------------------
--update procedure for user data
--------------------------------------------------------
ALTER PROC Group2.abhi_updateUserDetails
@tID INT,
@cID INT,
@pNumber INT,
@pName INT,
@prodLine INT,
@cName VARCHAR(30),
@cAddress VARCHAR(30),
@cTelephone VARCHAR(50),
@cGender VARCHAR(12),
@cDOB DATETIME,
@cSmoking VARCHAR(20),
@nName VARCHAR(30),
@nRelation VARCHAR(20),
@pFrequency VARCHAR(20),
@eStatus VARCHAR(20)
AS
BEGIN
UPDATE Group2.Endorsements SET customerID=@cID,policyNumber=@pNumber,policyName=@pName,productLine=@prodLine,customerName=@cName,customerAddress=@cAddress,customerTelephone=@cTelephone,customerGender=@cGender,customerDOB=@cDOB,customerSmoking=@cSmoking,nomineeName=@nName,nomineeRelation=@nRelation,premiumFrequency=@pFrequency,endoStatus=@eStatus 
END

--------------------------------------------------------
--display procedure for user details
--------------------------------------------------------
CREATE PROC Group2.abhi_displayUserDetails
AS
BEGIN
SELECT * FROM Group2.EndorsementsTemp
END

--------------------------------------------------------
--delete procedure foruser details
--------------------------------------------------------
CREATE PROC Group2.abhi_deleteUserDetails
@cID int
AS
BEGIN
DELETE FROM Group2.EndorsementsTemp
WHERE customerID = @cID
END

