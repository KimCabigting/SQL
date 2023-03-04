---Covid 19 Data Exploration 

---Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types



Select*
From PortfolioProject..CovidDeaths
Where continent is not null

---- Select Data that we are going to start with

Select
  location
 ,date
 ,total_cases
 ,new_cases
 ,total_deaths
 ,population
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2


-- COMPARING TOTAL CASES VS TOTAL DEATHS

-- Shows probability of dying if you contract covid in the Philippines

Select
  location
 ,date
 ,total_cases
 ,total_deaths
 ,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%Philippines%'
and continent is not null
Order by 1,2

--COMPARING TOTAL CASES VS TOTAL POPULATION

--Shows the percentage of population infected with Covid in the Philippines

Select
  location
 ,date
 ,population
 ,total_cases
 ,(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%Philippines%'
and continent is not null
Order by 1,2

--IDENTIFYING COUNTRIES WITH THE HIGHEST INFECTION RATE VS POPULATION

Select 
Location
,Population
,MAX(total_cases) as HighestInfectionCount
,Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location, Population
order by PercentPopulationInfected desc

----IDENTIFYING COUNTRIES WITH THE HIGHEST DEATH RATE  VS POPULATION

Select 
Location
,MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount DESC

-- ANALYZING DATA BY CONTINENT

--Showing contintents with the highest death count per population

Select continent
,MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select 
 SUM(new_cases) as total_cases
,SUM(cast(new_deaths as int)) as total_deaths
,SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
order by 1,2

--COMPARING TOTAL POPULATION VS VACCINATIONS

--Shows Percentage of Population that has recieved at least one Covid Vaccine

Select 
dea.continent
,dea.location
,dea.date
,dea.population
,vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

--Using CTE to perform Calculation on Partition By in previous query

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select 
dea.continent
,dea.location, dea.date
,dea.population
,vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

)
Select
*
,(RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255)
,Location nvarchar(255)
,Date datetime
,Population numeric
,New_vaccinations numeric
,RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select 
dea.continent
,dea.location
,dea.date
,dea.population
,vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date


Select *
,(RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- CREAYING VIEW TO STORE DATA FOR VISUALIZATION

---View for percentage of Population that has recieved at least one Covid Vaccine

Create View PercentPopulationVaccinated as

Select 
dea.continent
,dea.location
,dea.date
,dea.population
,vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

---View for identidying countries with the highest infection rate  vs. population 

Create view InfectionratePopulation as

Select 
Location
,Population
,MAX(total_cases) as HighestInfectionCount
,Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location, Population
--order by PercentPopulationInfected desc

---View for identidying countries with the highest death rate  vs. population

Create view DeathratePopulation as

Select 
Location
,MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by Location
--order by TotalDeathCount DESC

--view for showing contintents with the highest death count per population

Create view continentdeathratepop as

Select continent
,MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by continent
--order by TotalDeathCount desc

