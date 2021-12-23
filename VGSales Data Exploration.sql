select *
from vgsales v ;

-- 1)
-- Top 10 seller video game Worldwide

select Name, Platform, Global_sales
from vgsales v 
order by 3 DESC 
limit 10;

-- The most sold genre worldwide

	select count(distinct genre) from vgsales v ;

	-- We know there are 12 distinct genres, which are:

	select distinct genre from vgsales v ;



-- 2)
-- Most sold genre by yearly release date globaly

create view SalesPerGenreYear(genre, year, Na_sales, EU_sales, JP_sales, Other_sales, Global_sales) as
	select genre, year, max(Na_sales), max(Eu_sales), max(JP_Sales), max(Other_Sales),  max(global_sales)
	from vgsales v 
	group by genre, year
	order by `Year` ;

select genre, year, global_sales
from salespergenreyear 
where (year, global_sales) in (select year, max(global_sales) from GSperGenreYear
								group by year);

-- This process was highly simplified by creating a view.
-- We can now see for each year, what was the most sold genre, and for that genre it's total global sales.

-- It made much more sense to create a view incuding all the max sales per genre per release year, so now
-- we can actually see use the same query, slightly modified, to view it for each region
							
	select genre, year, NA_sales
	from salespergenreyear 
	where (year, NA_sales) in (select year, max(NA_sales) from GSperGenreYear
									group by year);
	
	select genre, year, EU_sales
	from salespergenreyear 
	where (year, EU_sales) in (select year, max(EU_sales) from GSperGenreYear
									group by year);
								
									
	-- and so on...
								
-- 3)
-- We now want to know the percentage of sales from each region per year
-- We are going to store it on a view
create view PercentageSales(year, PerNA, PerEU, PerJP, PerOther) as
	select year, sum(NA_Sales)/sum(Global_Sales)*100 PerNA, sum(EU_Sales)/sum(Global_Sales)*100 PerEU, sum(JP_Sales)/sum(Global_Sales)*100 PerJP, 
	sum(Other_Sales)/sum(Global_Sales)*100 PerOther
	from vgsales v 
	group by year;

select * from percentagesales
order by 1;

-- This shows us how the sales of games released in all th destinct years is distributed.
-- Also, we can clearly see how up to 1982, how most of the sales where concentrated in NA.


-- 4) 
-- Now we will look for the platform that has sold the most (in total and per year of release).

	-- First, how many different platform we have since 1980?
	
	select count(distinct platform)
	from vgsales v ;

	-- 31 platforms
	-- Which are...?

	select DISTINCT platform
	from vgsales v ;

-- Now going to the initial question
drop view salesperplatform;
create view SalesPerPlatform(platform, year, Global_sales) as
	select Platform, year, sum(global_sales)
	from vgsales v 
	group by platform, year;

select * from salesperplatform ;

select platform, year, sum(global_sales)
from vgsales v 
group by platform, year
having (year, sum(global_sales)) in  (select year, max(Global_Sales)
									  from salesperplatform 
									  group by year)
order by 2;

-- What this shows us, is for example, that for the games released on 2015, PS4 was
-- the platform which has had the biggest amount of sales.

-- 5) 
-- Amount of games released for each platform

select platform, count(year)
from vgsales v 
group by platform
order by 2 DESC ;

	-- Per year...? 
	select platform, year, count(year)
	from vgsales v 
	group by Platform , year
	order by 1, 2;
	
	-- If we would want to filter any specific platform to see their years sales (year meaning year of release)
	select platform, year, count(year)
	from vgsales v 
	group by Platform , year
	having platform = 'PS4'
	order by 1, 2;
	
	select platform, year, count(year)
	from vgsales v 
	group by Platform , year
	having platform = 'Wii'
	order by 1, 2;
	
	-- and so on...

-- 6)
-- And if we want to know the year for which each platform released the biggest amount of games
create view GamesPerYear(platform, year, TotReleased) as
	select platform, year, count(name)
	from vgsales v 
	group by platform, year
	order by 2, 1;

select platform, year, count(name)
from vgsales v 
group by platform, year
having (platform, count(name)) in (select platform, max(totreleased) 
									from gamesperyear
									group by platform)
order by 2, 1;
	

							
select year, max(totreleased)
from gamesperyear 
group by year;
