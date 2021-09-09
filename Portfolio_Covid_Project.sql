Use Portofolio

SELECT * FROM Portofolio..CovidDeaths
ORDER BY 3, 4

SELECT *FROM [dbo].[CovidVaccinations]
ORDER BY 3, 4

--we are selectiong data to be used later on

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [dbo].[CovidDeaths]
where location= 'Congo'

--looking at the total cases vs total deaths
-- Shows the likelihood of dying from Covid if contracted in your country
SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as Death_Percentage
FROM [dbo].[CovidDeaths]
WHERE location= 'Congo'

--Looking at total_cases vs Population
SELECT location, date, total_cases, population,(total_cases/population)*100 as Percentage_of_Population_Infected
FROM [dbo].[CovidDeaths]
--WHERE location= 'Congo'

--Looking at countries with highest infection rates  vs population

SELECT location,population, max(total_cases) as Highest_Infectioncount,max((total_cases/population)*100) as Percentage_of_Population_Infected
FROM [dbo].[CovidDeaths]
GROUP BY location,population
ORDER BY Percentage_of_Population_Infected desc
--WHERE location= 'Congo'

--Showing countries with highest total deaths


SELECT location,max(cast(total_deaths as int)) as Highest_Total_Deaths
FROM [dbo].[CovidDeaths]
WHERE continent is not null
GROUP BY location
ORDER BY Highest_Total_Deaths Desc

--LET'S BREAK THINGS BBY CONTINENT
--Showing continents with highest death count
SELECT continent,max(cast(total_deaths as int)) as Highest_Total_Deaths
FROM [dbo].[CovidDeaths]
WHERE continent is not null
GROUP BY continent
ORDER BY Highest_Total_Deaths Desc


--  Global Numbers

SELECT date, SUM(new_cases) as Total_cases,SUM( cast(new_deaths as int)) as Total_deaths,(SUM(cast(new_deaths as int))/SUM(new_cases)*100) as Global_Death_Percentage
FROM [dbo].[CovidDeaths]
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

SELECT D.continent, D.location, D.date, D.population
,V.new_vaccinations, SUM(CAST(V.new_vaccinations as int)) OVER(PARTITION BY D.location ORDER BY D.location
,D.date) as Rolling_Vaccinated_People
FROM CovidDeaths D
join CovidVaccinations V
on D.location= V.location
and D.date= V.date
WHERE D.continent is not null

--USE CTE IN ORDER TO OBTAIN MAX AGGREGATED

WITH PopvsVac (continent, location, date, population,new_vaccinations, Rolling_Vaccinated_People)
AS
(
SELECT D.continent, D.location, D.date, D.population
,V.new_vaccinations, SUM(CAST(V.new_vaccinations as int)) OVER(PARTITION BY D.location ORDER BY D.location
,D.date) as Rolling_Vaccinated_People
FROM CovidDeaths D
join CovidVaccinations V
on D.location= V.location
and D.date= V.date
WHERE D.continent is not null
)

SELECT *, (Rolling_Vaccinated_People/population)*100
FROM PopvsVac

--Creating Views that will be used later on for visualisation

CREATE VIEW Percent_Population_Vacccinated
AS
SELECT D.continent, D.location, D.date, D.population
,V.new_vaccinations, SUM(CAST(V.new_vaccinations as int)) OVER(PARTITION BY D.location ORDER BY D.location
,D.date) as Rolling_Vaccinated_People
FROM CovidDeaths D
JOIN CovidVaccinations V
ON D.location= V.location
and D.date= V.date
WHERE D.continent is not null

SELECT * FROM Percent_Population_Vacccinated
WHERE continent='Africa'