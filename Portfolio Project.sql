select *
from PortfolioProject..covidDeaths
order by 3,4

--select *
--from PortfolioProject..covidVaccinations
--order by 3,4

--select location, date, total_cases, new_cases, total_deaths, population
--from PortfolioProject..covidDeaths
--order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths,
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from PortfolioProject..covidDeaths
where location like '%brazil%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid

select location, date, population, total_cases, 
(total_cases/population)*100 as DeathPercentage
from PortfolioProject..covidDeaths
where location like '%brazil%'
order by 1,2

-- Look at Countries with Highest Infection Rate compared to Population

select location, population, max(total_cases) as HighestInfectionCount, 
max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..covidDeaths
group by location, population
order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population

select location, MAX(cast(total_deaths as float)) as TotalDeathCount
from PortfolioProject..covidDeaths
where continent != ''
group by location
order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENTS

-- Showing continents with the highest death count per population


select continent, sum(cast(total_deaths as float)) as TotalDeathCount
from PortfolioProject..covidDeaths
where continent != ''
group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS

select date, sum(cast(new_cases as float)) as TotalCases, sum(cast(new_deaths as float)) as TotalDeaths,
sum(convert(float,new_deaths)) / nullif(sum(convert(float,New_cases)),0) *100 as DeathPercentage
--, total_deaths,(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from PortfolioProject..covidDeaths
where continent != ''
group by date
order by 1,2

-- Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
 sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
 as RollingPeopleVaccinated
from PortfolioProject..covidDeaths dea
join PortfolioProject..covidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent != ''
order by 2,3

-- USE CTE

with PopvsVac (Continent, location, date, population,new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
 sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
 as RollingPeopleVaccinated
from PortfolioProject..covidDeaths dea
join PortfolioProject..covidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent != ''
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

--	TEMP TABLE
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations nvarchar(255),
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated

select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
 sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
 as RollingPeopleVaccinated
from PortfolioProject..covidDeaths dea
join PortfolioProject..covidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent != ''
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


-- Creating View to store data for late visualizations

CREATE VIEW PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
 sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
 as RollingPeopleVaccinated
from PortfolioProject..covidDeaths dea
join PortfolioProject..covidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent != ''



select *
from PercentPopulationVaccinated


