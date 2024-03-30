select * from [dbo].[DIM_CUSTOMER]
select * from [dbo].[DIM_DATE]
select * from [dbo].[DIM_LOCATION]
select * from [dbo].[DIM_MANUFACTURER]
select * from [dbo].[DIM_MODEL]
select * from [dbo].[FACT_TRANSACTIONS]

1.
select distinct state
from DIM_LOCATION as l
join FACT_TRANSACTIONS as t
on l.IDLocation=t.IDLocation
where cast(year(date)as int)>2005

2. 
select  State, sum(quantity) as _total_qty
from DIM_LOCATION as l
join FACT_TRANSACTIONS as t
on l.IDLocation=t.IDLocation
join DIM_MODEL as mo
on t.IDModel=mo.IDModel
join DIM_MANUFACTURER as ma
on mo.IDManufacturer=ma.IDManufacturer
where country ='US' AND Manufacturer_Name='Samsung'
group by state 
order by count(quantity) desc

3.
select model_name,ZipCode,State,count(*)
from DIM_LOCATION as l
join FACT_TRANSACTIONS as t
on l.IDLocation=t.IDLocation
join DIM_MODEL as mo
on t.IDModel=mo.IDModel
group by model_name,ZipCode,State
order by count(*) desc

4.

select top 1 Model_Name,Manufacturer_Name,Unit_price
from DIM_MODEL as mo
join DIM_MANUFACTURER as ma
on mo.IDManufacturer=ma.IDManufacturer
order by Unit_price



select * from [dbo].[DIM_MODEL]

5.

WITH TopManufacturers AS (
    SELECT TOP 5 m.Manufacturer_Name,dm.IDManufacturer,SUM(ft.Quantity) AS TotalQuantity
    FROM dim_model dm
    JOIN fact_transactions ft ON dm.IDModel = ft.IDModel
	join DIM_MANUFACTURER as m on dm.IDManufacturer=m.IDManufacturer
    GROUP BY m.Manufacturer_Name,dm.IDManufacturer
    ORDER BY TotalQuantity DESC
)
SELECT Manufacturer_Name,dm.IDModel,dm.Model_Name,TotalQuantity,AVG(dm.Unit_price) AS AveragePrice
FROM dim_model dm
JOIN TopManufacturers tm ON dm.IDManufacturer = tm.IDManufacturer
GROUP BY Manufacturer_Name,dm.IDModel, dm.Model_Name,TotalQuantity
ORDER BY TotalQuantity desc,AveragePrice desc;


6.
select customer_name,c.IDCustomer,avg(totalprice) as _avg
from DIM_CUSTOMER as c
join FACT_TRANSACTIONS as t
on c.IDCustomer=t.IDCustomer
where cast(year(date)as int)=2009
group by Customer_Name,c.IDCustomer
having avg(totalprice)>500

7.
select model_name
from
(select top 5 model_name
from DIM_MODEL as mo
join FACT_TRANSACTIONS as t
on mo.IDModel=t.IDModel
where cast(year(date)as int)=2008
group by Model_Name
order by sum(Quantity) desc) as s1

intersect 

select model_name 
from
(select top 5 model_name
from DIM_MODEL as mo
join FACT_TRANSACTIONS as t
on mo.IDModel=t.IDModel
where cast(year(date)as int)=2009
group by Model_Name
order by sum(Quantity) desc) as s2

intersect

select model_name
from
(select top 5 model_name
from DIM_MODEL as mo
join FACT_TRANSACTIONS as t
on mo.IDModel=t.IDModel
where cast(year(date)as int)=2010
group by Model_Name
order by sum(Quantity) desc) as s3

8.
(SELECT TOP 2 Manufacturer_Name, _total,_year
FROM
(
  SELECT ma.Manufacturer_Name, SUM(totalprice) AS _total,CAST(YEAR(date) AS INT) as _year,
         DENSE_RANK() OVER (ORDER BY SUM(totalprice) DESC) AS _rank
  FROM DIM_MANUFACTURER AS ma
  JOIN DIM_MODEL AS mo ON ma.IDManufacturer = mo.IDManufacturer
  JOIN FACT_TRANSACTIONS AS t ON mo.IDModel = t.IDModel
  WHERE CAST(YEAR(date) AS INT)= 2009 
  GROUP BY ma.Manufacturer_Name,CAST(YEAR(date) AS INT)
) AS subquery
where _rank=2)

union

(SELECT TOP 2 Manufacturer_Name, _total,_year
FROM
(
  SELECT ma.Manufacturer_Name, SUM(totalprice) AS _total,CAST(YEAR(date) AS INT) as _year,
         DENSE_RANK() OVER (ORDER BY SUM(totalprice) DESC) AS _rank
  FROM DIM_MANUFACTURER AS ma
  JOIN DIM_MODEL AS mo ON ma.IDManufacturer = mo.IDManufacturer
  JOIN FACT_TRANSACTIONS AS t ON mo.IDModel = t.IDModel
  WHERE CAST(YEAR(date) AS INT)= 2010
  GROUP BY ma.Manufacturer_Name,CAST(YEAR(date) AS INT)
) AS subquery
where _rank=2)


9.
select distinct Manufacturer_Name,cast(year(date)as int)
from DIM_MANUFACTURER as ma
join DIM_MODEL as mo
on ma.IDManufacturer=mo.IDManufacturer
join FACT_TRANSACTIONS as t
on mo.IDModel=t.IDModel
where cast(year(date)as int)=2010 and cast(year(date)as int) <> 2009


10.
         select *
		 from
          ( select  YEAR(ft.Date) AS Transaction_Year,
            dc.Customer_Name,
            AVG(ft.TotalPrice) AS Average_Spend,
            AVG(ft.Quantity) AS Average_Quantity,
            ROW_NUMBER() OVER (PARTITION BY YEAR(ft.Date) ORDER BY AVG(ft.TotalPrice) DESC) AS _rank
        FROM
            FACT_TRANSACTIONS ft
            JOIN dim_customer dc ON ft.IDCustomer = dc.IDCustomer
        GROUP BY
            YEAR(ft.Date),
            dc.Customer_Name ) as s
         where _rank<=10


