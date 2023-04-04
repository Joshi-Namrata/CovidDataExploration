-- Tableau project queries

--Table 1-
-- Finding total infected, total covid deaths and total death percentage globally

SELECT
    SUM(total_cases) AS total_infected,
    SUM(total_deaths)AS total_CovidDeaths,
    SUM(total_deaths)/SUM(total_cases)*100 AS DeathPercentage
FROM
    Covid_data.CovidDeaths
WHERE 
  continent IS NOT NULL


-- Table 2-
-- Total Death counts per location( continent)
-- We take some locations out as they are not included in the above queries and want to stay consistent

SELECT
    location,
    SUM(total_deaths) as total_death_count
FROM
    Covid_data.CovidDeaths
WHERE 
  continent IS NULL
    AND
    location NOT IN ('World','High income','Upper middle income','Lower middle income','Low income', 'European Union')
GROUP BY
  location
ORDER BY 
   total_death_count DESC


-- Table 3-
--Locations with highest infection rate compared to the population


SELECT
    location,
    population,
    Max(total_cases) AS highest_infection_count,
    Max((total_cases/population))*100 AS percent_population_infected
FROM
    Covid_data.CovidDeaths
--WHERE 
--Continent IS NOT NULL
GROUP BY 
  location, population
ORDER BY 
  percent_population_infected DESC


-- Table 4-
----North America countries highest infection rate compared to the population over time


SELECT
    location,
    date,
    population,
    Max(total_cases) AS highest_infection_count,
    Max((total_cases/population))*100 AS percent_population_infected
FROM
    Covid_data.CovidDeaths
WHERE
  Continent = "North America"
GROUP BY 
  location, population,date
ORDER BY 
  percent_population_infected DESC


-- Table 5
--To find the max percentage of population who are fully vaccinated


SELECT
    dea.location,
    dea.date,
    dea.population,
    Max(vac.people_fully_vaccinated) AS maximum_people_fully_vaccinated,
    Max(vac.people_fully_vaccinated/population)*100 As percent_people_fully_vaccinated
FROM
    Covid_data.CovidDeaths AS dea
    JOIN
    Covid_data.CovidVaccinations AS vac
    ON dea.location = vac.location
        AND dea.date = vac.date
WHERE 
  dea.continent='North America'
GROUP BY
  dea.location,
  dea.date,
  dea.population
ORDER BY 
  dea.location, dea.date DESC