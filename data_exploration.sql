/* 
Covid 19 Data Exploration in BigQuery
Skills used- Joins, aggregate functions, GROUP BY, PARTITION BY, Temp tables.
Created tables using the query results to use them for visualizations later.
*/

--Exploring CovidDeaths table

SELECT
    *
FROM
    Covid_data.CovidDeaths
WHERE 
  continent IS NOT NULL


--Exploring CovidVaccinations table

SELECT
    *
FROM
    Covid_data.CovidVaccinations
WHERE 
  continent is NOT NULL


--Selecting the data I will be using for performing aggregate functions

SELECT
    location,
    date,
    population,
    total_cases,
    new_cases,
    total_deaths
FROM
    Covid_data.CovidDeaths
WHERE 
  continent IS NOT NULL
ORDER BY 
  location,date DESC


--Looking at total cases vs total deaths and calculating Total Death Percentage


SELECT
    location,
    date,
    total_cases,
    total_deaths,
    (total_deaths/total_cases)*100 AS DeathPercentage
FROM
    Covid_data.CovidDeaths
WHERE
  continent IS NOT NULL
ORDER BY 
  location,date DESC


-- looking at everyday total cases,total deaths for Canada for the year 2023 until March 16th and Calculating Total Death Percentage sorted by date


SELECT
    date,
    total_cases,
    total_deaths,
    ROUND((total_deaths/total_cases)*100,2) AS death_percentage
FROM
    Covid_data.CovidDeaths
WHERE
  location = 'Canada'
    AND
    date BETWEEN '2023-01-01' AND '2023-03-16'
    AND
    continent IS NOT NULL
ORDER BY 
  date DESC


--Looking at Total cases Vs Population
--To show what percentage of population got infected with covid


SELECT
    location,
    date,
    population,
    total_cases,
    (total_cases/population)*100 AS percent_population_infected
FROM
    Covid_data.CovidDeaths
WHERE 
  continent IS NOT NULL
ORDER BY 
  location,date DESC


--To show what percentage of Canadians got infected with covid


SELECT
    date,
    population,
    total_cases,
    ROUND((total_cases/population)*100,2) AS percent_population_infected
FROM
    Covid_data.CovidDeaths
WHERE
  location = 'Canada'
    AND
    continent IS NOT NULL
ORDER BY
  date DESC


--Finding the locations/countries with highest infection rate compared to the population


SELECT
    location,
    population,
    Max(total_cases) AS highest_infection_count,
    Max((total_cases/population))*100 AS percent_population_infected
FROM
    Covid_data.CovidDeaths
WHERE 
  Continent IS NOT NULL
GROUP BY 
  location, population
ORDER BY 
  percent_population_infected DESC


--Finding the top 5 countries with highest death counts per population


SELECT
    location,
    Max(total_deaths) AS highest_death_count
FROM
    Covid_data.CovidDeaths
WHERE 
  continent IS NOT NULL
GROUP BY 
  location
ORDER BY 
  highest_death_count DESC
LIMIT 5


--Global numbers
--To find daily total cases, deaths and death percentage numbers across the world sorted by date


SELECT
    date,
    SUM(total_cases) AS total_infected,
    SUM(total_deaths)AS total_CovidDeaths,
    SUM(total_deaths)/SUM(total_cases)*100 AS total_DeathPercentage
FROM
    Covid_data.CovidDeaths
WHERE 
  continent IS NOT NULL
GROUP BY
  date
ORDER BY
  date DESC


--Joining 2 tables( CovidDeaths and CovidVaccinations)


SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.people_fully_vaccinated,
    vac.new_vaccinations
FROM
    Covid_data.CovidDeaths AS dea
    JOIN
    Covid_data.CovidVaccinations AS vac
    ON dea.location = vac.location
        AND dea.date = vac.date
WHERE 
  dea.continent IS NOT NULL
ORDER BY 
  dea.location, dea.date DESC


-- Total population Vs Vaccinations
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
GROUP BY
  dea.location,
  dea.date,
  dea.population
ORDER BY 
  dea.location, dea.date DESC


--Finding percentage of population that have received at least 1 covid vaccine
--First to find rolling people vaccinated using Partition BY 
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations)OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS rolling_people_vaccinated
FROM
    Covid_data.CovidDeaths AS dea
    JOIN
    Covid_data.CovidVaccinations AS vac
    ON dea.location = vac.location
        AND dea.date = vac.date
WHERE 
  dea.continent IS NOT NULL
ORDER BY 
  dea.location, dea.date DESC


--Use of Temp table to perform calculations to find percentage of population vaccinated with at least 1 dose


WITH
    PercentagePopulationVaccinated
    AS
    (
        SELECT
            dea.continent,
            dea.location,
            dea.date,
            dea.population,
            vac.new_vaccinations,
            SUM(vac.new_vaccinations)OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS rolling_people_vaccinated
        FROM
            Covid_data.CovidDeaths AS dea
            JOIN
            Covid_data.CovidVaccinations AS vac
            ON dea.location = vac.location
                AND dea.date = vac.date
        WHERE 
  dea.continent IS NOT NULL
        ORDER BY 
  dea.location, dea.date DESC
    )


SELECT
    *,
    (rolling_people_vaccinated/population)*100 AS percentage_people_vaccinated
FROM
    PercentagePopulationVaccinated


--Saving the results of the above query in a new table(PercentagePopulationVaccinated) within the same dataset(Covid_data) to use it for visualization later.
