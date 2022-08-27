SELECT * FROM portfolioproject.dbo.CovidDeaths;

Select * 
From portfolioproject..CovidDeaths
Where continent is not null
order by 3,4 



--------------------------------------------------
--turn the columns to floats and ints for operations
-----------------------------------------------------
ALTER TABLE dbo.CovidDeaths ALTER COLUMN total_deaths float;  
GO  

ALTER TABLE dbo.CovidDeaths ALTER COLUMN total_cases float;  
GO  

ALTER TABLE dbo.CovidDeaths ALTER COLUMN Population INT;  
GO 

ALTER TABLE dbo.CovidDeaths ALTER COLUMN new_cases INT;  
GO 
------------------------------------------
--to allow devision by 0
SET ARITHABORT OFF 
SET ANSI_WARNINGS OFF


-------------------------------------------------------------
-- Total Cases vs Total Deaths in Algeria (lilkihood of dying)
-------------------------------------------------------------------
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From portfolioproject..CovidDeaths
Where location like '%Algeria%'
and continent is not null 
order by 1,2
----------------------------------------
-- Total cases VS population 

--------------------------
Select Location, date, total_cases, Population, (total_cases/Population)*100 as DeathPercentage
From portfolioproject..CovidDeaths
Where location like '%Algeria%'
and continent is not null 
order by 1,2

----------------------------------------------
-- Countries with Highest Infection Rate compared to Population
------------------------------------------------------
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/Population))*100 as PercentPopulationInfected
From portfolioproject..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc -- order the results by the percentages decending

-- showing Countries with Highest Death Count per Population
Select Location,  MAX(total_deaths) as TotalDeathCount
From portfolioproject..CovidDeaths
Group by Location
order by TotalDeathCount desc
---------------------------------------------
--Break things down by continent with showing the heighst death count per population

--------------------------------------------------
Select continent,  MAX(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc


--Global numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
--Group By date
order by 1,2
-------------------------------------------------------------
--Covid vaccination dataset
-------------------------------------------------------------
-- view the covidvacination database
Select * From portfolioproject..CovidVaccinations


--looking at total population VS vaccinated population
---------------------------------
-- join the tables 
-------------------------------------
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
From portfolioproject..CovidDeaths dea
join portfolioproject..CovidVaccinations vac
On dea.location = vac.location
Where dea.continent is not null
and dea.date = vac.date
order by 1,2,3

-----------------------------------------------------
--  perform Calculation on Partition By in previous query (summing the vacinations for one location then starting over) 
-------------------------------------------------------------------------------------------------
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,
dea.Date) as RollingPeopleVaccinated
,
From portfolioproject..CovidDeaths dea
join portfolioproject..CovidVaccinations vac
On dea.location = vac.location
Where dea.continent is not null
and dea.date = vac.date
order by 2,3


-- Using % to perform the Calculation on Partition By in previous query to calculate the rolling vaccination percentages 
--to allow devision by 0
-------------------------------------------
SET ARITHABORT OFF 
SET ANSI_WARNINGS OFF

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.Population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From portfolioproject..CovidDeaths dea
Join portfolioproject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


---------------------------------------------------------------------
--TEMP TABLE
------------------------------------------------------

Create Table #Percentpplvaccinated
(
Continent varchar(50),
Location varchar(50),
Date datetime,
Population float,
New_vaccinations float,
RollingPeopleVaccinated float
)

Insert into #Percentpplvaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date


Select *, (RollingPeopleVaccinated/Population)*100
From #Percentpplvaccinated

--------------------------------------------------------

 -- Creating View to store data for later visualizations

CREATE VIEW pplvac as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated

From portfolioproject..CovidDeaths dea
Join portfolioproject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date


Select * From pplvac






