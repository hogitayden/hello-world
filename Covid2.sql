USE Covid19
select *
from [dbo].[confirmed]

select *
from [dbo].[country]

select *
from [dbo].[Deaths]

select *
from [dbo].[recover]

select *
from [dbo].[sum_case]

select *
from [dbo].[total_case]

alter table [dbo].[total_case]
alter column people_vaccinated int

alter table [dbo].[total_case]
alter column people_partially_vaccinated int

select (cast(people_vaccinated as bigint) + cast(people_partially_vaccinated as bigint)) vaccinated
from [dbo].[total_case]

select cast((people_vaccinated + people_partially_vaccinated) as int)
from [dbo].[total_case]

SELECT 
country,
CASE WHEN iso IS NULL THEN -1 
	ELSE  iso end AS iso_not_null

FROM [Covid19].[dbo].[country]
WHERE country IS NOT NULL

-- join table
SELECT T.country, 
	S.confirmed, S.recovered, S.deaths,
	T.people_vaccinated, T.people_partially_vaccinated, T.administered, T.updated
FROM dbo.total_case T 
FULL JOIN dbo.sum_case S ON T.country = S.country 
WHERE T.country IS NOT NULL

SELECT *
FROM dbo.total_case T 
FULL JOIN dbo.sum_case S ON T.country = S.country 

WHERE T.country IS NOT NULL

EXEC [dbo].[spTotalCase]

SELECT *
FROM [dbo].[TotalCase]

SELECT isnull(new.country, 'others') country
	,sum(new.confirmed) confirmed
	,sum(new.recovered) recovered
FROM (SELECT S.[confirmed]
      ,S.[recovered]
      ,S.[deaths]
      ,S.[country]
	  ,[administered]
      ,[people_vaccinated]
      ,[people_partially_vaccinated]
      ,[iso]
      ,[updated]
		FROM dbo.total_case T 
		FULL JOIN dbo.sum_case S ON T.country = S.country) new
GROUP BY new.country 

-- clear lai bang total_case
	SELECT isnull(country, 'others')
			,sum(administered)
			,sum(people_vaccinated)
			,sum(people_partially_vaccinated)
	FROM [dbo].[total_case]
	GROUP BY country


ALTER TABLE [dbo].[confirmed] ADD id varchar(100) NULL

ALTER TABLE [dbo].[confirmed] 
ALTER COLUMN date varchar(256)

SELECT country + ' ' + date AS id 
FROM [dbo].[confirmed]

select TOP 1000 d.country, d.date, d.numbers as Deaths_number, r.numbers as recovers_number
from Deaths d left join recover r
on d.country = r.country	

select *
from [dbo].[recover]
where country = 'Afghanistan'

select top 10 country + ' ' + left(date, 10) as id
from Deaths

SELECT TOP 10 *
FROM Deaths

-------------------------------------------------- them cot Id, update Id, cong cac gia tri cung Id
ALTER TABLE Deaths
ADD Id nvarchar(50) NULL

UPDATE Deaths SET Id = country + ' ' + left(date, 10)


-- lap lai voi 2 table con lai
ALTER TABLE recover 
ADD Id nvarchar(50) NULL

UPDATE recover SET Id = country + ' ' + left(date, 10)

ALTER TABLE confirmed
ADD Id nvarchar(50) NULL

UPDATE confirmed SET Id = country + ' ' + left(date, 10)

SELECT TOP (100) c.country
				,c.Id
				,c.date
				,c.numbers as confirmed
				,d.numbers as deaths
				,r.numbers as recovers
INTO daily_case
FROM confirmed c 
LEFT JOIN Deaths d ON c.Id = d.Id
LEFT JOIN recover r ON c.Id = r.Id
ORDER BY country, date DESC 

SELECT *
FROM daily_case
ORDER BY country, date DESC 

DELETE FROM daily_case
WHERE confirmed = deaths
OR deaths = recovers
-----------------------------------------------------------------------------------------------------------
DECLARE @today datetime = GETDATE() 
SELECT CONCAT(DATEPART(year, @today), '-', DATEPART(mm, @today)) -- gan bien @today nhung khong chay duoc

SELECT CONCAT(DATEPART(year, GETDATE()), '-', DATEPART(mm, GETDATE()),'-', DATEPART(dd, GETDATE()))

-- xoa bot thoi gian gio phut giay
SELECT left(cast(date as nvarchar(20)),10)
FROM daily_case

UPDATE daily_case -- chay thanh cong nhung khong ra ket qua nhu tren
SET date = left(cast(date as nvarchar(20)),10)

-- tao cot thoi gian moi - bo gio phut giay di, xoa cot thoi gian cu
ALTER TABLE daily_case
ADD update_day nvarchar(20) NULL

UPDATE daily_case
SET update_day = left(cast(date as nvarchar(20)),10)

ALTER TABLE daily_case
DROP COLUMN date 

-- cho nay sai, ko delete from truc tiep nhu subquery nay duoc --
DELETE FROM (SELECT TOP (100) c.country
				,c.Id
				,c.date
				,c.numbers as confirmed
				,d.numbers as deaths
				,r.numbers as recovers
FROM confirmed c 
LEFT JOIN Deaths d ON c.Id = d.Id
LEFT JOIN recover r ON c.Id = r.Id
ORDER BY country, date DESC) daily_case
WHERE confirmed = deaths

-- sai theo cai duoi
DELETE FROM Deaths
WHERE numbers = ANY (SELECT numbers
				FROM confirmed)

-- cai nay cung sai, ket qua ra gia tri dung cua bang Deaths chu ko ra gia tri trung lap vs recover can xoa ---
SELECT *
FROM Deaths d
WHERE d.numbers = (select r.numbers 
				from recover r
				where r.numbers = d.numbers)

-- so sanh country xuat hien trong bang confirm ma ko co trong country
select distinct cf.country -- khong chay vi chua bo gia tri null
from confirmed cf
where cf.country not in (select distinct c.country 
			from country c
			where c.country is not null) 

-- tinh so luong obs country trong cac bang
select distinct(country)
from sum_case --180 nuoc, 1 null

select distinct(country)
from total_case -- 153 nuoc, 1 null

select distinct(country)
from deaths -- 196 nuoc

select distinct(country)
from recover -- 196 nuoc

select distinct(country)
from confirmed -- 196 nuoc

EXEC [dbo].[spDailyCase]

EXEC [dbo].[spVaccine]

EXEC [dbo].[spGeography]

--- dat lai id cho 3 bang confirm theo dang country_yyyymmdd
ALTER TABLE confirmed
ALTER COLUMN id2 nvarchar(50) NULL -- ko can gan NULL cot tu nhan gia tri NULL

SELECT TOP 10 country 
			+ '_'
			+ cast (YEAR(date) as varchar)
			+ cast (MONTH(date) as varchar)
			+ cast (DAY(date) as varchar)
FROM confirmed

UPDATE confirmed SET id2 = country 
			+ '_'
			+ cast (YEAR(date) as varchar)
			+ cast (MONTH(date) as varchar)
			+ cast (DAY(date) as varchar)

-- doi ten cot trong bang
SELECT * FROM confirmed
EXEC sp_rename 'confirmed.id2', 'id', 'column'

ALTER TABLE confirmed

UPDATE recover SET id = country 
			+ '_'
			+ cast (YEAR(date) as varchar)
			+ cast (MONTH(date) as varchar)
			+ cast (DAY(date) as varchar)

FORMAT(GETDATE(), 'mm')

select convert(varchar(10),getdate(),112)
SELECT TOP 10 country 
			+ '_'
			+ CONVERT(varchar(20), date, 112) id
FROM confirmed

-- update lai cot id cho them so 0 cho dep, dung ham convert style 112
UPDATE confirmed SET id = country 
			+ '_'
			+ CONVERT(varchar(20), date, 112)
UPDATE Deaths SET id = country 
			+ '_'
			+ CONVERT(varchar(20), date, 112)
UPDATE recover SET id = country 
			+ '_'
			+ CONVERT(varchar(20), date, 112)
-----
DROP TABLE daily_case
		SELECT TOP (100) c.country
					,c.id
					,c.date
					,c.numbers as confirmed
					,d.numbers as deaths
					,r.numbers as recovers
		INTO daily_case
		FROM confirmed c 
		LEFT JOIN Deaths d ON c.id = d.id
		LEFT JOIN recover r ON c.id = r.id
		ORDER BY country, date DESC 

		DELETE FROM daily_case
		WHERE confirmed = deaths
		OR deaths = recovers
----
select country
from confirmed
where country IS NULL

EXEC [dbo].[spDailyCase]