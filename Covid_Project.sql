--select max(total_vaccinations)as total_vaccination from  Covid_Project..['covid data$']
--where total_vaccinations is  not null

--select the data
select * from Covid_Project..covidDeaths
where continent is null



select location, date,total_cases, new_cases,total_deaths, population
from Covid_Project..covidDeaths
where continent is not null
order by 1,2

--death_percentage(i.e total_deaths vs total_cases)
select location, date,cast(total_cases as int) as total_cases,
cast(total_deaths as int)as total_deaths,(cast(total_deaths as numeric)/cast(total_cases as numeric))*100 as total_death_percentage
from Covid_Project..covidDeaths
where continent is not null and location='India'
order by 1,2

--wt percentage of people get affected by covid
select location, date,population ,
CONVERT(float,total_cases),
round((cast(total_cases as float)/population)*100,5) as change_of_getting_covid
from Covid_Project..covidDeaths
where continent is not null and location='India'
order by 1,2


-- Highest infection percentage
select location,population,max(total_cases)as higest_cases,
max((cast(total_cases as float)/population)*100) as percentage_of_change
from Covid_Project..covidDeaths
group by location,population
--having location='India'
order by percentage_of_change desc

--Highest deathcount
select location, max(cast(total_cases as int)) as totaldeathcount
from Covid_Project..covidDeaths
where continent is not null
group by location
--having location like '%states'
order by totaldeathcount desc

--Continent numbers
select continent,sum(cast(total_cases as numeric)) from Covid_Project..covidDeaths
where continent is not null
group by continent

--Total Vaccination Vs Total Population

select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations )) over (partition by dea.location order by dea.location, dea.date  ) as rolling_count
from Covid_Project..covid_vaccinations vac join Covid_Project..CovidDeaths dea on vac.date=dea.date and vac.location=dea.location
where dea.continent is not null 
order by 2,3


--with CTE(functions)

with Vac_vs_Pop (continent,location,date,population,new_vaccination ,rolling_count)
as(
	select dea.continent,dea.location,dea.date,dea.population, convert(numeric,vac.new_vaccinations ),
	sum(convert(numeric,vac.new_vaccinations )) over (partition by dea.location order by dea.location, dea.date  ) as rolling_count
	from Covid_Project..covid_vaccinations vac join Covid_Project..CovidDeaths dea on vac.date=dea.date and vac.location=dea.location
	where dea.continent is not null 
)
--it show us how much percentage the people get vaccinated
select location,population,(rolling_count/population)*100 as totvac from Vac_vs_Pop

group by location, population,new_vaccination,rolling_count
order by 1,2,3



--By using TempTables 
DROP TABLE IF EXISTS #vac_vs_pop
CREATE TABLE #vac_vs_pop(
continent nvarchar(255),
location nvarchar(255),
date datetime, 
population numeric,
new_vaccinations numeric,
rolling_count numeric
)
insert  into #vac_vs_pop 
select dea.continent,dea.location,dea.date,dea.population, convert(numeric,vac.new_vaccinations ),
	sum(convert(numeric,vac.new_vaccinations )) over (partition by dea.location order by dea.location, dea.date  ) as rolling_count
	from Covid_Project..covid_vaccinations vac join Covid_Project..CovidDeaths dea on vac.date=dea.date and vac.location=dea.location
	where dea.continent is not null 


select location, population,(rolling_count/population)*100 as totvac from #vac_vs_pop
group by location, population,new_vaccinations,rolling_count
order by 1,2,3


--BY USING VIEWS
CREATE VIEW pop AS 
		select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
		sum(convert(numeric,vac.new_vaccinations )) over (partition by dea.location order by dea.location, dea.date ) as rolling_count
		from Covid_Project..covid_vaccinations vac 
		join Covid_Project..CovidDeaths dea
		on vac.date=dea.date and vac.location=dea.location
		where dea.continent is not null 

select location, population,(rolling_count/population)*100 as totvac from pop
group by location, population,new_vaccinations,rolling_count
order by 1,2,3
