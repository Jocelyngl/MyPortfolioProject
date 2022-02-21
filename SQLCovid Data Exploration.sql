/*
COVID 19 DATA EXPLORATION
Skills used: CTE's, Temp Tables, Windows, Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select *
From PortfolioProject..['Covid Deaths$']
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations$
--order by 3,4


-- Select data that we are going to be starting with 

Select Location, date, total_cases, new_cases, total_deaths, population
Where continent is not null
From PortfolioProject..['Covid Deaths$']
order by 1,2


-- Looking at Total cases vs Total Deaths
-- Shows Likeihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..['Covid Deaths$']
Where location like '%states%'
and continent is not null
order by 1,2


-- Looking at Total Cases v Popultion
-- Shows what percentage of population got covid-19

Select Location, date, population,total_cases,(total_cases/population)*100 as PercentagePopulationInfected
From PortfolioProject..['Covid Deaths$']
Where location like '%states%'
order by 1,2


-- Looking at countries wit highest infection rate cmared to population

Select Location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as
PercentPopultionInfected
From PortfolioProject..['Covid Deaths$']
-- Where location like '%states%'
Group by location, population
Order by PercentPopultionInfected desc


-- Showing Countires with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount 
From PortfolioProject..['Covid Deaths$']
-- Where location like '%states%'
Where continent is not null
Group by location
Order by TotalDeathCount desc

-- Let's BREAK THINGS DOWN BY CONTINENT 

-- Showing Continents with the highest death count per population 

Select continent, MAX(cast(Total_Deaths as int)) as TotalDeathsCount
From PortfolioProject..['Covid Deaths$']
-- Where location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathsCount desc


-- Global Numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM (new_cases)*100 as DeathPercentage
From PortfolioProject..['Covid Deaths$']
-- Where Location is like'%states%'
Where continent	is not null
Group by date
order by 1,2


-- Looking at Total Population v Vaccinations
-- Showing percentage of population that has recieved at east one covid vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location,
dea.date) as RollingPeopleVaccinated
From PortfolioProject..['Covid Deaths$']  dea
Join PortfolioProject..CovidVaccinations$  vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE  dea.continent is not null
Order by 2,3


-- USE CTE to perform calculation on Partition by in previous query 

WITH PopvsVac (Continent, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location,
dea.date) as RollingPeopleVaccinated
--,(RollingVaccinated/population)*100
From PortfolioProject..['Covid Deaths$']  dea
Join PortfolioProject..CovidVaccinations$  vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE  dea.continent is not null
--Order by 2,3 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

Select *
From PortfolioProject..CovidVaccinations$


--- Using Temp Table to Perform Calculations on Partition by in previous query 
DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime, 
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location , dea.date, dea.population, vac.new_vaccinations
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.date) as RollingPeopleVaccinated
--,(RollingVaccinated/population)*100
From PortfolioProject..['Covid Deaths$']  dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--Order by 2,3 

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location , dea.date, dea.population, vac.new_vaccinations
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.date) as RollingPeopleVaccinated
--,(RollingVaccinated/population)*100
From PortfolioProject..['Covid Deaths$']  dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 

























