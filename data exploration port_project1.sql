SELECT *
from [PORTFOLIO Projects]..CovidDeaths
where continent is not null
order by 3,4


--SELECT *
--FROM CovidVaccination
--ORDER BY 3, 4;

--SELECT *
--FROM CovidDeaths
--ORDER BY 3, 4;

select location, date, total_cases, new_cases, total_deaths, population
from [PORTFOLIO Projects]..CovidDeaths
where continent is not null
order by 1,2

	
-- looking at the total cases vs total deaths
--shows likelihood of death if you contract covid in your country
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [PORTFOLIO Projects]..CovidDeaths
Where location like '%India%'
and continent is not null
order by 1,2


--looking at total cases vs population
-- shows what percentage of population got covid
select location, date, total_cases,population, (total_cases/population)*100 as PercentPopulationInfected
from [PORTFOLIO Projects]..CovidDeaths
where continent is not null
--where location like '%India%'
order by 1,2



--looking at countries with highest infection rate compared to population

select location, population, Max(total_cases) as HighestInfectionCount, MAX(total_cases/ population)*100 as PercentPopulationInfected
from [PORTFOLIO Projects]..CovidDeaths
--where location like '%India%'
where continent is not null
group by location, population
order by PercentPopulationInfected desc


--countries with highest death count per population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from [PORTFOLIO Projects]..CovidDeaths
--where location like '%India%'
where continent is not null
group by location 
order by TotalDeathCount desc



-- lets break things by continent
-- showing the continents with the highest death count per population
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from [PORTFOLIO Projects]..CovidDeaths
--where location like '%India%'
where continent is not null
group by continent 
order by TotalDeathCount desc


-- global numbers
Select   sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths , sum(cast(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage
From [PORTFOLIO Projects]..CovidDeaths
--Where location like '%India%'
where continent is not null
--group by date
order by 1,2


--loking at total polupation vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum( convert(int,vac.new_vaccinations)) 
over (Partition by dea.location order by dea.location, dea.date) as RollingPopulationVaccinated
from[PORTFOLIO Projects]..CovidDeaths dea
join [PORTFOLIO Projects]..CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
order by 2,3 



--use CTE
with PopvsVac (continent, location, date , population,newvaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum( convert(int,vac.new_vaccinations)) 
over (Partition by dea.location order by dea.location, dea.date) as RollingPopulationVaccinated
from[PORTFOLIO Projects]..CovidDeaths dea
join [PORTFOLIO Projects]..CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
--order by 2,3 
)

select*, (RollingPeopleVaccinated/population)*100
from PopvsVac



--Temp table
-- 1. Drop the table if it already exists so you start with a clean slate
DROP TABLE IF EXISTS #PercentPopulationVaccinated;
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum( convert(int,vac.new_vaccinations)) 
over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from[PORTFOLIO Projects]..CovidDeaths dea
join [PORTFOLIO Projects]..CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
--order by 2,3 

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

use [PORTFOLIO Projects]
go
--drop view if exists PercentPopulationVaccinated
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
  dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [PORTFOLIO Projects]..CovidDeaths dea
Join [PORTFOLIO Projects]..CovidVaccination vac
  On dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
--order by 2,3

SELECT * FROM PercentPopulationVaccinated;
