Select*
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4 

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 6,4

-- Looking at total Cases Vs Total Deaths
-- Shows likeliehood of dying if you contract covid in a certain country. 
--This can change depending upon the country we want to search for by chnaging the name in the LIKE operator '%______%'
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
From PortfolioProject..CovidDeaths 
Where location like '%states%' 
Order by 1,2 



-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid For United States

Select Location, date, population, total_cases,(total_cases/population)*100 as DeathPercentage 
From PortfolioProject..CovidDeaths 
Where location like '%states%' 
Order by 1,2 



-- Looking at countries with Highest Infection Rate Compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected 
From PortfolioProject..CovidDeaths 
--Where location like '%states%' 
Group by Location, Population
Order by PercentPopulationInfected desc



-- Showing Countries with the highest death count per population
-- We must use the cast function to ensure the data type is correct

Select Location, MAX(cast(total_deaths as bigint)) as TotalDeathCount
From PortfolioProject..CovidDeaths 
--Where location like '%states%' 
Where continent is not null
Group by location
Order by TotalDeathCount desc



-- Can be broken down by Continent
-- Canda is not in North American Number
Select continent, MAX(cast(total_deaths as bigint)) as TotalDeathCount
From PortfolioProject..CovidDeaths 
--Where location like '%states%' 
Where continent is not null
Group by continent
Order by TotalDeathCount desc



--Showing continents with highest deathcount

Select continent, MAX(cast(total_deaths as bigint)) as TotalDeathCount
From PortfolioProject..CovidDeaths 
--Where location like '%states%' 
Where continent is not null
Group by continent
Order by TotalDeathCount desc



-- Looking at global numbers

Select date, SUM(new_cases)as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths, SUM(cast 
(new_deaths as bigint))/SUM(New_Cases)*100 as DeathPercentage 
From PortfolioProject..CovidDeaths 
--Where location like '%states%' 
where continent is not null
Group By date
Order by 1,2 



-- Looking at Total Population vs Vaccintaion

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


--Use CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 Sum(Convert(bigint,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location,dea.Date) 
as RollingPeopleVaccinated
From PortfolioProject.. CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date 
Where dea.continent is not null
--order by 2,3
)
Select * , (RollingPeopleVaccinated/Population)*100 as percentvaccinated 
From PopvsVac




-- Temp Table

Drop Table if exists #PercentPopulationVaccinated 
Create Table #PercentPopulationVaccinated
(
Continet nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 Sum(Convert(bigint,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location,dea.Date)
 as RollingPeopleVaccinated
 --(RollingPeopleVaccinated/population)*100
From PortfolioProject.. CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date 
Where dea.continent is not null
--order by 2,3

Select * , (RollingPeopleVaccinated/Population)*100 as percentvaccinated 
From #PercentPopulationVaccinated




-- Creating View to Store data for later in Visualizations


Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select*
From PercentPopulationVaccinated
