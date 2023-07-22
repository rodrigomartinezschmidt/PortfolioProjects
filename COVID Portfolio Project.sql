SELECT *
FROM PortfolioProyect..CovidDeaths$
where continent is not null 
order by 3,4

--SELECT *
--FROM PortfolioProyect..CovidVaccinations$
--order by 3,4


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProyect..CovidDeaths$
where continent is not null 
order by 1,2


-- Looking at Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProyect..CovidDeaths$
Where location like '%Argentina%'
and continent is not null 
order by 1,2


-- Looking at Total Cases vs Population

SELECT location, date, total_cases, population, (total_cases/population)*100 as TotalCasesPercentage
FROM PortfolioProyect..CovidDeaths$
Where location like '%Argentina%'
and continent is not null 
order by 1,2


-- Looking at Countries with Highest Inflection rate compared to population

SELECT location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProyect..CovidDeaths$
where continent is not null 
Group by location, population
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProyect..CovidDeaths$
where continent is not null 
Group by location
order by  TotalDeathCount desc


-- Showing Continents with the Highest Death Count 
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProyect..CovidDeaths$
where continent is null
Group by location
order by  TotalDeathCount desc


-- GLOBAL NUMBERS

select SUM(new_cases) as TotalNewCases, SUM(cast(new_deaths as int)) as TotalNewDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProyect..CovidDeaths$
--where location like '%Argentina&'
where continent is not null
order by 1,2

-- Loking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProyect..CovidDeaths$ dea
join PortfolioProyect..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 2, 3

-- USE CTE to look at percentage of the population that has been vaccinated

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProyect..CovidDeaths$ dea
join PortfolioProyect..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/population)*100
from PopvsVac

-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProyect..CovidDeaths$ dea
join PortfolioProyect..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProyect..CovidDeaths$ dea
join PortfolioProyect..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null

SELECT *
FROM PercentPopulationVaccinated

