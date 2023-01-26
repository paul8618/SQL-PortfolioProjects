/*
Covid 19 data exploration

Skills used: Joins, CTE's, Temp Tables, Windows functionis, Aggregate functions , creating views, coverting data types

*/

SELECT * FROM [Portfolio Project]..CovidVaccinations
order by 3,4

SELECT location, continent FROM [Portfolio Project]..CovidDeaths
Where location = 'World' or location = 'High income' or location = 'Upper middle income' or location = 'Lower middle income' or location = 'Low income'
order by 1, 2

-- select data that will be used  

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM [Portfolio Project]..CovidDeaths
order by 1,2


-- look at total cases vs total deaths in percentage basis 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM [Portfolio Project]..CovidDeaths
WHERE location = 'Canada'
order by 1,2


-- total cases vs population in Canada 
SELECT location, date, population, total_cases, (total_cases/population)*100 AS Population_Percentage
FROM [Portfolio Project]..CovidDeaths
WHERE location = 'Taiwan'
order by 1,2


-- countries with highest infection rate compared to population 
SELECT location, population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population))*100 AS Percent_population_infected
FROM [Portfolio Project]..CovidDeaths
--WHERE location = 'Taiwan'
group by location, population
order by Percent_population_infected DESC


--Countries with highest death count per population 
SELECT location, Max(CAST(total_deaths as int)) as Total_Death_count
FROM [Portfolio Project]..CovidDeaths
WHERE continent is not null
group by location
order by Total_Death_count DESC


-- Calcs by continent in location 
SELECT location, Max(cast(total_deaths as int)) as Total_death_count
From [Portfolio Project]..CovidDeaths
WHERE continent is null and location <> 'High income' and location <> 'Upper middle income' and location <> 'Lower middle income' and location <> 'Low income' and location <> 'World' and location <> 'International'
Group by location
Order by Total_death_count DESC


-- highest death count by continent 
SELECT continent, Max(CAST(total_deaths as int)) as Total_Death_count
FROM [Portfolio Project]..CovidDeaths
WHERE continent is not null
group by continent
order by Total_Death_count DESC


-- Global numbers 
SELECT date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS Death_Percentage
FROM [Portfolio Project]..CovidDeaths
--WHERE location = 'Canada'
Where continent is not null
Group by date
order by 1,2


-- Total New vaccinations per day 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null 
Order By 2, 3




-- Total population vs vaccinations
-- Show percentage of population that has received at least one dose of covid vaccine 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) over (Partition by dea.location ORDER by dea.location, dea.date) as Rolling_people_vaccinated
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null 
Order By 2, 3

-- total cases vs age 
SELECT dea.location, SUM(dea.total_cases) as TotalCases, vac.aged_65_older, vac.aged_70_older, (dea.total_cases - vac.aged_65_older - vac.aged_70_older) as PeopleBefore65
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
GROUP by dea.location, dea.total_cases, vac.aged_65_older, vac.aged_70_older

;



-- Using CTE to perform Calculation on Partition By in previous query

-- 
WITH PopvsVac (continent, location, date, population, new_vaccinations, Rolling_people_vaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) over (Partition by dea.location ORDER by dea.location, dea.date) as Rolling_people_vaccinated
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null 
--Order By 2, 3
)

SELECT *, (Rolling_people_vaccinated/population)*100
FROM PopvsVac


-- Use TEMP Tables to perform Calculation on Partition By in previous query
DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255), location nvarchar(255), date datetime, population numeric, new_vaccinations numeric, Rolling_people_vaccinatied numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) over (Partition by dea.location ORDER by dea.location, dea.date) as Rolling_people_vaccinated
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null 
--Order By 2, 3

SELECT *, (Rolling_people_vaccinatied/population)*100
FROM #PercentPopulationVaccinated


-- create view to store data for visualization 
CREATE View PercntPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) over (Partition by dea.location ORDER by dea.location, dea.date) as Rolling_people_vaccinated
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null 



