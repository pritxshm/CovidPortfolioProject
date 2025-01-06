
/*
COVID 19 DATA EXPLORATION, DATA - https://ourworldindata.org/covid-deaths
*/

SELECT * 
FROM covid..CovidDeaths
where continent is not null
ORDER BY 3,4

SELECT *
FROM covid..CovidVaccinations
where continent is not null
ORDER BY 3,4


--Selecting the data to work with

SELECT location,date,population,total_cases,new_cases,total_deaths FROM 
covid..CovidDeaths
where continent is not null
ORDER BY 1,2

--Total Cases vs Total Population around the world

Select location, date, population, total_cases, new_cases, (total_cases)/population*100 as CasePercentage
From covid..CovidDeaths
where continent is not null
ORDER BY 1,2

--Total Case vs Total Population in the UAE

SELECT location, date, population, total_cases, new_cases, (total_cases)/population*100 CasePercentage
FROM covid..CovidDeaths
where location = 'United Arab Emirates'
ORDER BY 1,2

-- Total Cases vs Total Death
-- Shows the likelihood of dying if you contract COVID

SELECT location, date, population, total_cases, total_deaths, (total_deaths)/total_cases*100
FROM covid..CovidDeaths
WHERE continent is not null
ORDER BY 1,2


-- In the UAE.

SELECT location, date, population, total_cases, total_deaths, (total_deaths)/total_cases*100
FROM covid..CovidDeaths
WHERE continent is not null and location = 'United Arab Emirates'
ORDER BY 1,2

--Counties with the Highest Infection rate compared to the Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases)/population *100 as CasebyPopulation
FROM covid..CovidDeaths
WHERE continent is not null
Group by location,population
ORDER BY CasebyPopulation desc






-- Countries with Highest Death Count by population

SELECT location, MAX(Convert(int,total_deaths)) as HighestDeathCount, MAX(Convert(int,total_deaths))/population*100 as DeathbyPopulation
FROM covid..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY DeathbyPopulation desc


-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From covid..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From covid..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From covid..CovidDeaths dea
Join covid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From covid..CovidDeaths dea
Join covid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



--2) Temp Table

DROP Table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From covid..CovidDeaths dea
Join covid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


/*

Queries to Export to Excel for Tableau Dashboard as Tableau public does not connect to SQL server

*/

--1)

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From covid..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

--2)

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From covid..CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount

--3)

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From covid..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc

--4)

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From covid..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc































