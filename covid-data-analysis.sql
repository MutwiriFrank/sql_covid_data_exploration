select * from covid_deaths 
order by 3,4


-- select data to be used

select location, date, total_cases, new_cases, total_deaths, population
from covid_deaths
order by 1,2

-- total cases vs total deaths

-- posibility of dying from covid in 2022

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from covid_deaths cd 
where (total_deaths/total_cases) > 0 and  date > '2021-12-31'
order by 1,2  desc 

-- total cases vs population

select location, date, total_cases, population, (total_cases/population) * 100 as total_infection_rate
from covid_deaths
--where location like  '%Kenya%'
order by 1,2 Desc


-- country with highest infection rate, total cases vs population

select  location,  population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population) * 100) as total_infection_rate
from covid_deaths
group by location, population 
order by total_infection_rate desc


-- How many people died 
select location,  MAX(total_deaths) as max_total_deaths
from covid_deaths 
where total_deaths > 0 and continent is not null 
group by location 
order by max_total_deaths desc

--Deaths per continent
select  location, MAX(total_deaths) as continent_total_deaths
from covid_deaths
where continent is null and  location like '%Africa' or location like '%Europe' or location like '%Asia%' 
or location like '%Asia%' or location like '%Oceania%' or location like '%North America%' or location like '%South America%'
group by  location
order by continent_total_deaths desc

--Global numbers
select  MAX(total_cases) as world_total_cases, MAX(total_deaths) as world_total_deaths, 
MAX(total_deaths)/MAX(total_cases) as world_death_rate
from covid_deaths 


-- Total population and vaccination

-- CTE

with pop_to_vac (continent, location, date, population, new_vaccinations, cumulative_vaccination)
as (
select cd.continent, cd."location", cd."date", cd.population, cv.new_vaccinations,
SUM(cv.new_vaccinations) over ( partition by cd.location order by cd."location" , cd."date"  ) 
as cumulative_vaccination
from covid_deaths cd 
join covid_vaccination cv 
on cd.location = cv.location 
and cd.date = cv.date
where cd.continent is not null
)

select *, (cumulative_vaccination/population )*100  as percentage_vaccinated
from pop_to_vac


-- Temp Table for storing kenya covid data 

drop table if exists percentange_vacinated ;
CREATE TEMP TABLE percentange_vacinated
(
continent varchar(50),
location varchar(50),
date varchar(50),
population BIGINT,
new_vaccinations BIGINT,
cumulative_vaccination BIGINT

);

INSERT INTO percentange_vacinated
select cd.continent, cd."location", cd."date", cd.population, cv.new_vaccinations,
SUM(cv.new_vaccinations) over ( partition by cd.location order by cd."location" , cd."date"  ) 
as cumulative_vaccination
from covid_deaths cd 
join covid_vaccination cv 
on cd.location = cv.location 
and cd.date = cv.date
where cd.location = 'Kenya';

select * 
from percentange_vacinated


-- view for fetching kenya covid data
drop view  kenya_covid_data ;
create view kenya_covid_data as

select cd.continent, cd."location", cd."date", cd.population,  cd.total_cases,  cv.new_vaccinations, 'cv.new_tests', cd.new_deaths, 
SUM(cv.new_vaccinations) over ( partition by cd.location order by cd."location" , cd."date"  ) 
as cumulative_vaccination
from covid_deaths cd 
join covid_vaccination cv 
on cd.location = cv.location 
and cd.date = cv.date
where cd.location = 'Kenya';

select * from kenya_covid_data;

















