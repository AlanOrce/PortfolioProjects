

--Limpeza de datos (Data Cleaning)


DELETE FROM PortfolioProject..GDP_per_cap_PPP
WHERE Year=2020;

UPDATE PortfolioProject..GDP_per_cap_PPP
SET Code = NULL
WHERE Code='';

DELETE FROM PortfolioProject..GDP_per_cap_PPP
WHERE Code is null;

Select *
FROM PortfolioProject..GDP_per_cap_PPP
order by 2,3


UPDATE PortfolioProject..Pop_using_Inet
SET Code = NULL
WHERE Code='';

DELETE FROM PortfolioProject..Pop_using_Inet
WHERE Code is null;

Select *
FROM PortfolioProject..Pop_using_Inet
order by 2,3


-- Rename columns

EXEC sp_rename 'dbo.ErrorLog.GDP per capita, PPP (constant 2017 international $)', 'GDP_per_cap', 'COLUMN';

EXEC sp_rename 'dbo.ErrorLog.Individuals using the Internet (% of population)', 'Internet_usage', 'COLUMN';





-- Paises ordenados con mayor uso de internet

Select Entity, MAX(Internet_usage) as Highest_Internet_usage
From PortfolioProject..Pop_using_Inet
Group by Entity
order by Highest_Internet_usage desc


Select Entity, AVG(Internet_usage) as Average_since_1990
From PortfolioProject..Pop_using_Inet
Group by Entity
order by Average_since_1990 desc



Select Entity, MAX(Internet_usage)/MIN(Internet_usage) as Internet_usage_growth
From PortfolioProject..Pop_using_Inet
where Internet_usage is not null and Internet_usage <> 0
Group by Entity	
order by Internet_usage_growth desc




--------------------------------------------------


DROP Table if exists InetvsGDP;

With InetvsGDP (Country, Year, InetUsage, GDPpercap)
as
(
Select inter.Entity, inter.Year, inter.Internet_usage, gdp.GDP_per_cap
From PortfolioProject..Pop_using_Inet inter
Join PortfolioProject..GDP_per_cap_PPP gdp
    On inter.Code = gdp.Code
    and inter.Year = gdp.Year

)
Select *, (InetUsage/GDPpercap)*100 as InetGDPRelationPercentage
From InetvsGDP
where GDPpercap is not null and GDPpercap <> 0
Order by 1,2




---10----[temp table]

DROP Table if exists #InetgrowthVsGDPgrowth
Create Table #InetgrowthVsGDPgrowth
(
Country nvarchar(255),
Year numeric,
InetUsage numeric,
GDPpercap float,
Internet_usage_growth float,
GDPpercap_growth float
)

Insert into #InetgrowthVsGDPgrowth
Select inter.Entity, CONVERT(numeric,inter.Year), inter.Internet_usage, gdp.GDP_per_cap
, MAX(inter.Internet_usage) OVER (Partition by inter.Entity)/MIN(inter.Internet_usage) OVER (Partition by inter.Entity) as Internet_usage_growth
, MAX(gdp.GDP_per_cap) OVER (Partition by inter.Entity)/MIN(gdp.GDP_per_cap) OVER (Partition by inter.Entity) as GDPpercap_growth
From PortfolioProject..Pop_using_Inet inter
Join PortfolioProject..GDP_per_cap_PPP gdp
    On inter.Code = gdp.Code
    and inter.Year = gdp.Year
where inter.Internet_usage is not null and inter.Internet_usage <> 0 and gdp.GDP_per_cap is not null and gdp.GDP_per_cap <> 0
GROUP BY inter.Entity, inter.Year, inter.Internet_usage, gdp.GDP_per_cap


Select *, (Internet_usage_growth/GDPpercap_growth) as InetGDPpercapRelation
From #InetgrowthVsGDPgrowth






---11----[view]

DROP view if exists InetgrowthVsGDPgrowth

Create view InetgrowthVsGDPgrowth as
Select inter.Entity, inter.Year, inter.Internet_usage, gdp.GDP_per_cap
, MAX(inter.Internet_usage) OVER (Partition by inter.Entity)/MIN(inter.Internet_usage) OVER (Partition by inter.Entity) as Internet_usage_growth
, MAX(gdp.GDP_per_cap) OVER (Partition by inter.Entity)/MIN(gdp.GDP_per_cap) OVER (Partition by inter.Entity) as GDPpercap_growth
From PortfolioProject..Pop_using_Inet inter
Join PortfolioProject..GDP_per_cap_PPP gdp
    On inter.Code = gdp.Code
    and inter.Year = gdp.Year
where inter.Internet_usage is not null and inter.Internet_usage <> 0 and gdp.GDP_per_cap is not null and gdp.GDP_per_cap <> 0
GROUP BY inter.Entity, inter.Year, inter.Internet_usage, gdp.GDP_per_cap


