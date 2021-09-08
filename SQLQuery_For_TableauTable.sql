SELECT SUM(new_cases) as Total_cases,SUM( cast(new_deaths as int)) as Total_deaths,
(SUM(cast(new_deaths as int))/SUM(new_cases)*100) as Global_Death_Percentage
FROM [dbo].[CovidDeaths]
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

--Second Table

SELECT location, SUM(CAST(new_deaths as int)) as Total_deaths
FROM [dbo].[CovidDeaths]
WHERE continent is null
AND location not in ('World','European Union', 'International')
GROUP BY location
ORDER BY Total_deaths desc

--third table
SELECT location,population,max(total_cases) as Highest_Infectioncount,max((total_cases/population)*100) as Percentage_of_Population_Infected
FROM [dbo].[CovidDeaths]
GROUP BY location,population
ORDER BY Percentage_of_Population_Infected desc

SELECT location,population, date,max(total_cases) as Highest_Infectioncount,max((total_cases/population)*100) as Percentage_of_Population_Infected
FROM [dbo].[CovidDeaths]
GROUP BY location,population,date
ORDER BY Percentage_of_Population_Infected desc