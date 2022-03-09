Select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3, 4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3, 4


-- Select Data that we are going to be using
--Select location, date, total_cases, new_cases, total_deaths, population
--From PortfolioProject..CovidDeaths
--Order by 1, 2

-- Looking at Total Cases vs Total Deaths
--delete
--From PortfolioProject..CovidDeaths
--where total_cases=0

-- shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
From PortfolioProject..CovidDeaths
where location like '%states%'
order by 1, 2;

-- looking at total cases vs population
-- shows what percentage of population got covid
Select location, date, total_cases, population, (total_cases/ population)*100 as PercetPopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%states%'
order by 1, 2;


-- looking at countries with highest infection rate compared to population
Select location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/ population))*100 as PercetPopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%states%'
group by location, population
order by PercetPopulationInfected desc;


-- showing countries with highest death count per population
Select location, MAX(cast(total_deaths as int)) as TotalDeathcount
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by location
order by totaldeathcount desc;


-- break things down by continent
Select continent, MAX(cast(total_deaths as int)) as TotalDeathcount
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by totaldeathcount desc;


-- showing continents with  the highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathcount
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by totaldeathcount desc;


-- global numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Deathspercentage--, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
-- group by date
order by 1, 2;


-- looking at total population vs vaccinations


WITH PopvsVac (continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
  dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
Select *, (RollingPeopleVaccinated/population) * 100
From PopvsVac


-- temp table
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
  dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

Select *, (RollingPeopleVaccinated/population) * 100
From #PercentPopulationVaccinated


-- Creating view to store data for later visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
  dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3


Select *
From PercentPopulationVaccinated