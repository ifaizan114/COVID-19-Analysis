------------------ Generally Checking The Integrity of Data ------------------
SELECT *
FROM PORTFOLIO..CovidDeaths
where continent is not null
Order by 3,4


SELECT *
FROM PORTFOLIO..Covidvaccinations
Order by 3,4


-- Select Data that we are going to be using ----------------------
Select Location, date, total_cases, new_cases, total_deaths, population
FROM PORTFOLIO..CovidDeaths
order by 1,2


-- Looking at Total Cases vs Total Deaths--------------------------
Select Location, date, total_cases, total_deaths, 
       (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
FROM PORTFOLIO..CovidDeaths
Where location like '%states%'
order by 1,2


-- Looking at Total Cases vs Population----------------------------
Select Location, date, population, total_cases,  
       (cast(total_cases as float)/cast(population as float))*100 as DeathPercentage
FROM PORTFOLIO..CovidDeaths
order by 1,2


-- Looking at Countries with Highest infection Rate----------------
Select Location, population, MAX(total_cases) as HighestInfectionCount,  
       MAX((cast(total_cases as float)/cast(population as float)))*100 as PercentPopulationInfected
FROM PORTFOLIO..CovidDeaths
GROUP BY Location, population
order by PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population-------
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PORTFOLIO..CovidDeaths
where continent is not null
GROUP BY Location
order by TotalDeathCount desc


-- LET's BREAK THINGS DOWN BY CONTINENT----------------------------
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PORTFOLIO..CovidDeaths
where (continent is null) AND  location NOT LIKE '%income%'
GROUP BY location
order by TotalDeathCount desc


-- GLOBAL NUMBERS----------------------------------------------------
Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths,
       (SUM(cast(total_deaths as float))/SUM(cast(total_cases as float)))*100 as DeathPercentage
FROM PORTFOLIO..CovidDeaths
Where continent is not null
--Group By date
order by 1,2


-- Looking at Total Population vs Vaccinations------------------------
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
FROM PORTFOLIO..CovidDeaths dea
JOIN PORTFOLIO..Covidvaccinations vac
	On dea.location = vac.location
WHERE dea.continent is not null
ORDER BY 2,3


-- USE CTE ------------------------------------------------------------
With PopvsVac(Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
FROM PORTFOLIO..CovidDeaths dea
JOIN PORTFOLIO..Covidvaccinations vac
	On dea.location = vac.location
WHERE dea.continent is not null
--ORDER BY 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac








---------------- Retreiving The Tables we need for visualization ---------------------


-- Tableau Table 1 -----------------------
Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths,
       (SUM(cast(total_deaths as float))/SUM(cast(total_cases as float)))*100 as DeathPercentage
FROM PORTFOLIO..CovidDeaths
Where continent is not null
--Group By date
order by 1,2


--Tableau Table 2 ------------------------
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PORTFOLIO..CovidDeaths
where (continent is null) 
AND  location NOT LIKE ('%income%')
AND location NOT IN ('World', 'European Union')
GROUP BY location
order by TotalDeathCount desc


--Tableau Table 3 ------------------------
Select Location, population, MAX(total_cases) as HighestInfectionCount,  
       MAX((cast(total_cases as float)/cast(population as float)))*100 as PercentPopulationInfected
FROM PORTFOLIO..CovidDeaths
GROUP BY Location, population
order by PercentPopulationInfected desc


--Tableau Table 4 ------------------------
Select Location, population, date, MAX(total_cases) as HighestInfectionCount,  
       MAX((cast(total_cases as float)/cast(population as float)))*100 as PercentPopulationInfected
FROM PORTFOLIO..CovidDeaths
GROUP BY Location, population, date
order by PercentPopulationInfected desc