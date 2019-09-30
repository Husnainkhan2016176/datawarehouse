create database final
use final

create table Customer
(
Surr_key int identity(1,1),
Id int primary key,
Name varchar(max),
address varchar(max)
)

ALTER TABLE Customer add modify_date datetime default getdate() not null
alter table Customer drop modify_date
update Customer
set modify_date=dateadd(day,-3,getdate())

insert into Customer values
(01,'gg Shah','Pakistan'),
(02,'Husnain','India'),
(03,'Kashan','United States'),
(04,'Bhatti','China')

select * from Customer

create table Product (
	Id int identity(1,1) primary key,
	prod_name varchar(50) not null,
	price decimal(20,2) not null
)
alter table Product add  modify_date  datetime default getdate()
update Product
set modify_date=GETDATE()
insert into Product
values
('TV',RAND()*(100000-9000)+9000),
('Play-Station',RAND()*(100000-9000)+9000),
('PC',RAND()*(100000-9000)+9000),
('Laptop', RAND()*(100000-9000)+9000)

select * from Product
drop table Product

create table Orders (
	Cust_id int foreign key references Customer(Id),
	Prod_id int foreign key references Product(Id),
	quantity int default 1,
	order_time date default getdate(),
	Modify_Date date
	primary key(Cust_id, Prod_id, order_time)
)
drop table Orders
select * from Orders

Insert into Orders (Cust_id,Prod_id) values
(1,1),
(2,2),
(3,3),
(4,4)

create table Orders2 (
	Cust_id int foreign key references Customer(Id),
	Prod_id int foreign key references Product(Id),
	quantity int default 1,
	order_time date default getdate(),
	Modify_Date date
	primary key(Cust_id, Prod_id, order_time)
)
drop table Orders2


create table orders_month (
cust_id int foreign key references customer(id),
order_month varchar(7) not null,
no_orders int not null,
modify_month varchar(7)
primary key(cust_id, order_month)
)

drop table orders_month


go
create procedure insertvalues @entries int
as begin
declare @count1 int=1, @count2 int=0, @maxprod int,@minprod int,@cust_id int=1,@prod_id int,@curdate date,
@sec int=0
select @minprod=min(Id) from Product
select @maxprod=max(Id) from Product
set @curdate=dateadd(day,-5,getdate())
while @count1<=(select Count(*) from Customer)
begin
set @cust_id=@count1
while @count2<@entries
begin
set @prod_id=RAND()*(@maxprod - @minprod + 1) + @minprod
insert into Orders(Cust_id,Prod_id,order_time)
values(@cust_id,@prod_id, dateadd(Month,-3,GETDATE()))
set @count2=@count2+1
set @sec=@sec+1
end
set @count2=0
set @count1=@count1+1
end
end

drop proc insertvalues
exec insertvalues 2

select * from Orders


go
create procedure sales2 
as begin
declare @maxDate date, @numRows int, @temp date
select @numRows=count(*) from orders2
if(@numRows > 0)
begin
delete from orders2
end
select @maxDate=max(order_time) from orders
select @temp=max(modify_date) from orders
if(@temp>@maxDate)
begin
set @maxDate = @temp
end
insert into orders2 
select * from orders
where convert(varchar(10), order_time, 102) 
>= convert(varchar(10), @maxDate, 102)
or convert(varchar(10), modify_date, 102) 
>= convert(varchar(10), @maxDate, 102)
end


exec sales2
drop proc sales2
select * from Orders2


go

create procedure monthly_orders
as begin
declare @maxDate datetime, @numRows int, @temp datetime
select @numRows=count(*) from orders_month
if(@numRows > 0)
begin
delete from orders_month
end
select @maxDate=max(order_time) from orders
select @temp=max(Modify_Date) from orders
if(@temp>@maxDate)
begin
set @maxDate = @temp
end
insert into orders_month 
select Cust_id, convert(varchar(7), order_time, 102), count(*), null
from orders 
where convert(varchar(7), order_time, 102) 
= convert(varchar(7), @maxDate, 102)
or convert(varchar(7), Modify_Date, 102) 
= convert(varchar(7), @maxDate, 102)
group by Cust_id, convert(varchar(7), order_time, 102)
update orders_month 
set Modify_Month = convert(varchar(7), @maxDate, 102)
where order_month !=  convert(varchar(7), @maxDate, 102) 
end

drop proc monthly_orders
exec monthly_orders

create trigger modify_time on orders
after update
as begin
update orders set modify_date = GETDATE()
where order_time in (select order_time from inserted)
and Cust_id in (select Cust_id from inserted)
and Prod_id in (Select Prod_id from inserted)
end


exec monthly_orders

update orders set quantity = 3 where Cust_id = 2


select * from Orders
select * from Orders2
select * from orders_month
select * from Product

/************************************Dimensions**************************************/

create table Customer_Dim
(
Surr_key int identity(1,1) primary key,
Id int,
Name varchar(max),
address varchar(max),
Starting_From datetime,
Uptil datetime
)
alter table Customer_Dim
drop table Customer_Dim


create table Product_Dim (
	Surr_Key int identity(1,1) primary key,
	Id int,
	prod_name varchar(50) not null,
	price decimal(20,2) not null,
	Starting_From datetime,
	Uptil datetime

)

drop table Product_Dim


drop table Product_Dim

/***********************************DATE DIMENSION************************************/
CREATE TABLE [dbo].[Dim_Date] (
   [DateKey] [int] NOT NULL,
   [Date] [date] NOT NULL,
   [Day] [tinyint] NOT NULL,
   [DaySuffix] [char](2) NOT NULL,
   [Weekday] [tinyint] NOT NULL,
   [WeekDayName] [varchar](10) NOT NULL,
   [WeekDayName_Short] [char](3) NOT NULL,
   [WeekDayName_FirstLetter] [char](1) NOT NULL,
   [DOWInMonth] [tinyint] NOT NULL,
   [DayOfYear] [smallint] NOT NULL,
   [WeekOfMonth] [tinyint] NOT NULL,
   [WeekOfYear] [tinyint] NOT NULL,
   [Month] [tinyint] NOT NULL,
   [MonthName] [varchar](10) NOT NULL,
   [MonthName_Short] [char](3) NOT NULL,
   [MonthName_FirstLetter] [char](1) NOT NULL,
   [Quarter] [tinyint] NOT NULL,
   [QuarterName] [varchar](6) NOT NULL,
   [Year] [int] NOT NULL,
   [MMYYYY] [char](6) NOT NULL,
   [MonthYear] [char](7) NOT NULL,
   IsWeekend BIT NOT NULL,
   IsHoliday BIT NOT NULL,
   HolidayName VARCHAR(20) NULL,
   SpecialDays VARCHAR(20) NULL,
   [FinancialYear] [int] NULL,
   [FinancialQuater] [int] NULL,
   [FinancialMonth] [int] NULL,
   [FirstDateofYear] DATE NULL,
   [LastDateofYear] DATE NULL,
   [FirstDateofQuater] DATE NULL,
   [LastDateofQuater] DATE NULL,
   [FirstDateofMonth] DATE NULL,
   [LastDateofMonth] DATE NULL,
   [FirstDateofWeek] DATE NULL,
   [LastDateofWeek] DATE NULL,
   CurrentYear SMALLINT NULL,
   CurrentQuater SMALLINT NULL,
   CurrentMonth SMALLINT NULL,
   CurrentWeek SMALLINT NULL,
   CurrentDay SMALLINT NULL,
   PRIMARY KEY CLUSTERED ([DateKey] ASC)
   )

   SET NOCOUNT ON

TRUNCATE TABLE DIM_Date

DECLARE @CurrentDate DATE = '2016-01-01'
DECLARE @EndDate DATE = '2020-12-31'

WHILE @CurrentDate < @EndDate
BEGIN
   INSERT INTO [dbo].[Dim_Date] (
      [DateKey],
      [Date],
      [Day],
      [DaySuffix],
      [Weekday],
      [WeekDayName],
      [WeekDayName_Short],
      [WeekDayName_FirstLetter],
      [DOWInMonth],
      [DayOfYear],
      [WeekOfMonth],
      [WeekOfYear],
      [Month],
      [MonthName],
      [MonthName_Short],
      [MonthName_FirstLetter],
      [Quarter],
      [QuarterName],
      [Year],
      [MMYYYY],
      [MonthYear],
      [IsWeekend],
      [IsHoliday],
      [FirstDateofYear],
      [LastDateofYear],
      [FirstDateofQuater],
      [LastDateofQuater],
      [FirstDateofMonth],
      [LastDateofMonth],
      [FirstDateofWeek],
      [LastDateofWeek]
      )
   SELECT DateKey = YEAR(@CurrentDate) * 10000 + MONTH(@CurrentDate) * 100 + DAY(@CurrentDate),
      DATE = @CurrentDate,
      Day = DAY(@CurrentDate),
      [DaySuffix] = CASE 
         WHEN DAY(@CurrentDate) = 1
            OR DAY(@CurrentDate) = 21
            OR DAY(@CurrentDate) = 31
            THEN 'st'
         WHEN DAY(@CurrentDate) = 2
            OR DAY(@CurrentDate) = 22
            THEN 'nd'
         WHEN DAY(@CurrentDate) = 3
            OR DAY(@CurrentDate) = 23
            THEN 'rd'
         ELSE 'th'
         END,
      WEEKDAY = DATEPART(dw, @CurrentDate),
      WeekDayName = DATENAME(dw, @CurrentDate),
      WeekDayName_Short = UPPER(LEFT(DATENAME(dw, @CurrentDate), 3)),
      WeekDayName_FirstLetter = LEFT(DATENAME(dw, @CurrentDate), 1),
      [DOWInMonth] = DAY(@CurrentDate),
      [DayOfYear] = DATENAME(dy, @CurrentDate),
      [WeekOfMonth] = DATEPART(WEEK, @CurrentDate) - DATEPART(WEEK, DATEADD(MM, DATEDIFF(MM, 0, @CurrentDate), 0)) + 1,
      [WeekOfYear] = DATEPART(wk, @CurrentDate),
      [Month] = MONTH(@CurrentDate),
      [MonthName] = DATENAME(mm, @CurrentDate),
      [MonthName_Short] = UPPER(LEFT(DATENAME(mm, @CurrentDate), 3)),
      [MonthName_FirstLetter] = LEFT(DATENAME(mm, @CurrentDate), 1),
      [Quarter] = DATEPART(q, @CurrentDate),
      [QuarterName] = CASE 
         WHEN DATENAME(qq, @CurrentDate) = 1
            THEN 'First'
         WHEN DATENAME(qq, @CurrentDate) = 2
            THEN 'second'
         WHEN DATENAME(qq, @CurrentDate) = 3
            THEN 'third'
         WHEN DATENAME(qq, @CurrentDate) = 4
            THEN 'fourth'
         END,
      [Year] = YEAR(@CurrentDate),
      [MMYYYY] = RIGHT('0' + CAST(MONTH(@CurrentDate) AS VARCHAR(2)), 2) + CAST(YEAR(@CurrentDate) AS VARCHAR(4)),
      [MonthYear] = CAST(YEAR(@CurrentDate) AS VARCHAR(4)) + UPPER(LEFT(DATENAME(mm, @CurrentDate), 3)),
      [IsWeekend] = CASE 
         WHEN DATENAME(dw, @CurrentDate) = 'Sunday'
            OR DATENAME(dw, @CurrentDate) = 'Saturday'
            THEN 1
         ELSE 0
         END,
      [IsHoliday] = 0,
      [FirstDateofYear] = CAST(CAST(YEAR(@CurrentDate) AS VARCHAR(4)) + '-01-01' AS DATE),
      [LastDateofYear] = CAST(CAST(YEAR(@CurrentDate) AS VARCHAR(4)) + '-12-31' AS DATE),
      [FirstDateofQuater] = DATEADD(qq, DATEDIFF(qq, 0, GETDATE()), 0),
      [LastDateofQuater] = DATEADD(dd, - 1, DATEADD(qq, DATEDIFF(qq, 0, GETDATE()) + 1, 0)),
      [FirstDateofMonth] = CAST(CAST(YEAR(@CurrentDate) AS VARCHAR(4)) + '-' + CAST(MONTH(@CurrentDate) AS VARCHAR(2)) + '-01' AS DATE),
      [LastDateofMonth] = EOMONTH(@CurrentDate),
      [FirstDateofWeek] = DATEADD(dd, - (DATEPART(dw, @CurrentDate) - 1), @CurrentDate),
      [LastDateofWeek] = DATEADD(dd, 7 - (DATEPART(dw, @CurrentDate)), @CurrentDate)

   SET @CurrentDate = DATEADD(DD, 1, @CurrentDate)
END

--Update Holiday information
UPDATE Dim_Date
SET [IsHoliday] = 1,
   [HolidayName] = 'Christmas'
WHERE [Month] = 12
   AND [DAY] = 25

UPDATE Dim_Date
SET SpecialDays = 'Valentines Day'
WHERE [Month] = 2
   AND [DAY] = 14

--Update current date information
UPDATE Dim_Date
SET CurrentYear = DATEDIFF(yy, GETDATE(), DATE),
   CurrentQuater = DATEDIFF(q, GETDATE(), DATE),
   CurrentMonth = DATEDIFF(m, GETDATE(), DATE),
   CurrentWeek = DATEDIFF(ww, GETDATE(), DATE),
   CurrentDay = DATEDIFF(dd, GETDATE(), DATE)

create table Fact_Order (
	Order_Id int identity(1,1) primary key,
	Cust_id int foreign key references Customer_Dim(Surr_Key),
	Prod_id int foreign key references Product_Dim(Surr_Key),
	quantity int default 1,
	Date_Id int foreign key references Dim_Date(DateKey)
	
)

drop table Fact_Order

drop table Fact_Order
select * from Customer_Dim
use final
go
create proc custDimUpdate
as begin
declare @lastupdate datetime
if ((select count(*) from Customer_Dim)=0)
begin
insert into Customer_Dim(Id,Name,address,Starting_From)
select * from Customer
end
else
begin

select @lastupdate=max(Starting_From) from Customer_Dim

declare @id int
Declare curs cursor for
select Id from Customer
where modify_date>@lastupdate and
Id in (select Id from Customer_Dim)

open curs
fetch next from curs into @id
while @@FETCH_STATUS=0
begin
update Customer_Dim
set Uptil=(select modify_date from Customer where Id=@id)
where Id=@id and Uptil is Null

insert into Customer_Dim(Id,Name,address,Starting_From)
select * from Customer
where Id=@id

fetch next from curs into @id
end

CLOSE curs;
DEALLOCATE curs;

insert into Customer_Dim(Id,Name,address,Starting_From)
select * from Customer
where modify_date > @lastupdate and
id not in (select Id from Customer_Dim)


end
end

exec custDimUpdate
select * from Customer
Select * from Customer_Dim
delete from Customer_Dim

exec custDimUpdate
drop proc custDimUpdate

SET IDENTITY_INSERT Customer_Dim ON

select count(*) from Customer
select * from Customer_Dim


insert into Customer (Id,Name,address) values
(5,'Ahmad','Hongkong')
insert into Customer (Id,Name,address) values
(6,'Ali','NewYork')

update Customer
set modify_date=getdate()
where Id=5

go
Create Proc prodDimUpdate
as
begin
declare @lastupdate datetime
if ((select count(*) from Product_Dim)=0)
begin
insert into Product_Dim(Id,prod_name,price,Starting_From)
select * from Product
end
else
begin

select @lastupdate=max(Starting_From) from Product_Dim

declare @id int
Declare curs cursor for
select Id from Product
where modify_date>@lastupdate and
Id in (select Id from Product_Dim)

open curs
fetch next from curs into @id
while @@FETCH_STATUS=0
begin
update Product_Dim
set Uptil=(select modify_date from Product where Id=@id)
where Id=@id and Uptil is Null

insert into Product_Dim(Id,prod_name,price,Starting_From)
select * from Product
where Id=@id

fetch next from curs into @id
end

CLOSE curs;
DEALLOCATE curs;

insert into Product_Dim(Id,prod_name,price,Starting_From)
select * from Product
where modify_date > @lastupdate and
id not in (select Id from Product_Dim)


end
end

exec prodDimUpdate
drop proc prodDimUpdate
select * from Product_Dim
delete from Product_Dim

insert into Product(prod_name,price) values
('Telephone',950)

update Product
set price=1900
Where Id=6


create trigger modify_customer on Customer
after update
as begin
update Customer set modify_date = GETDATE()
where Id in (select Id from inserted)
end

create trigger modify_product on Product
after update
as begin
update Product set modify_date = GETDATE()
where Id in (select Id from inserted)
end

select * from Dim_Date


select * from Orders

go
create proc dimfact
as
begin
declare @cust_id int, @prod_id int, @date_id int, @order_time datetime, @modify_time datetime,@maxdate datetime, @lastupdate date
declare @cust_surrkey int, @prod_surrkey int, @date_key int
if((select count(*) from Fact_Order)=0)
begin
declare curs cursor
for select Cust_id, Prod_id,order_time,Modify_Date from Orders
 open curs

 fetch next from curs into
 @cust_id,@prod_id,@order_time,@modify_time
 while @@FETCH_STATUS=0
 begin
 select @cust_surrkey=Surr_Key from Customer_Dim where Id=@cust_id and Uptil is NULL
 select @prod_surrkey=Surr_Key from Product_Dim where  Id=@prod_id and Uptil is NULL
 set @maxdate=(select max(order_time) from Orders)
 if @maxdate<(select max(Modify_Date) from Orders) 
 begin
 set @maxdate=(select max(Modify_Date) from Orders)
 end
  fetch next from curs into
 @cust_id,@prod_id,@order_time,@modify_time

 set @maxdate=convert(date,@maxdate)
 set @date_key=(select DateKey from Dim_Date where [Date]=@maxdate)
 insert into Fact_Order (Cust_id,Prod_id,Date_Id)
 values(@cust_surrkey,@prod_surrkey,@date_key)

 end
 close curs
 deallocate curs
end

else
begin
set @lastupdate=(select max(d.[Date])
from Fact_Order as o
inner join Dim_Date as d
on o.Date_Id=d.DateKey)

 
declare curs cursor
for select Cust_id, Prod_id,order_time,Modify_Date from Orders
where convert(date,order_time)>=@lastupdate OR convert(date,modify_date)>=@lastupdate
 open curs

 fetch next from curs into
 @cust_id,@prod_id,@order_time,@modify_time
 while @@FETCH_STATUS=0
 begin
 select @cust_surrkey=Surr_Key from Customer_Dim where Id=@cust_id and Uptil is NULL
 select @prod_surrkey=Surr_Key from Product_Dim where  Id=@prod_id and Uptil is NULL
 set @maxdate=(select max(order_time) from Orders)
 if @maxdate<(select max(Modify_Date) from Orders) 
 begin
 set @maxdate=(select max(Modify_Date) from Orders)
 end
  fetch next from curs into
 @cust_id,@prod_id,@order_time,@modify_time

 set @maxdate=convert(date,@maxdate)
 set @date_key=(select DateKey from Dim_Date where [Date]=@maxdate)
 if(select count(*) from Fact_Order where Cust_id=@cust_surrkey and Prod_id=@prod_surrkey and Date_Id=@date_key)=0
 begin
 insert into Fact_Order (Cust_id,Prod_id,Date_Id)
 values(@cust_surrkey,@prod_surrkey,@date_key)
 end
end
close curs
deallocate curs
end
end





drop proc dimfact
exec dimfact
select * from Fact_Order
select * from Orders
insert into Orders(Cust_id,Prod_id,quantity,order_time,Modify_Date)
values(4,2,2,dateadd(day,+2,getdate()),NULL)

delete from Fact_Order
select * from Customer_Dim
select * from Product_Dim

update Customer set address='Sirilanka' where Id=4

update Product set prod_name='LAN Cable'  where Id=9


