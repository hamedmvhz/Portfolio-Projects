--Let's check the 'Death' table 
SELECT *
FROM Covid..Death

-- And Also the 'Vaccination' table
SELECT *
FROM Covid..Vaccination

-- The probabilty of dying after getting COVID in each country 

SELECT Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM Covid..Death
WHERE continent is not null 
ORDER BY 1,2 DESC 

-- The probabilty of dying after getting COVID in each continent 

SELECT Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM  Covid..Death
WHERE continent is null 
ORDER BY 1,2 DESC 

-- Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) as count_with_highest_rate,  Max((total_cases/population))*100 AS percentage_ppl_covid
FROM Covid..Death
WHERE location is not null 
GROUP BY Location, Population
ORDER BY percentage_ppl_covid DESC

-- The percentage of population have gotten COVID in a descending order

SELECT Location, date, Population, total_cases,  (total_cases/population)*100 AS Percentage_ppl_covid
FROM Covid..Death
WHERE location is not null 
ORDER BY 1,2 DESC 

--Countries with Highest Infection Ratio

SELECT Location, Population, MAX(total_cases) as highest_infect_ratio,  Max((total_cases/population))*100 AS percentage_ppl_covid
FROM Covid..Death
WHERE location is not null 
GROUP BY Location, Population
ORDER BY  Percentage_ppl_covid DESC

-- Countries with highest death ratio

SELECT Location, MAX(cast(Total_deaths as int)) AS total_death_ppl
FROM Covid..Death
WHERE continent is not null 
GROUP BY Location
ORDER BY total_death_ppl DESC

-- Showing contintents with the highest death count per population

SELECT continent, MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM Covid..Death
WHERE continent is not null
GROUP BY continent 
ORDER BY TotalDeathCount desc

--We want to create and view vaccinated people in each country

CREATE VIEW Vaccinated_ppl_country
AS
WITH Vaccinated_people_country(continent,location,date,population,new_vaccinations,final_vaccinated_people) 
AS 
(
SELECT 
      dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	  SUM(cast(vac.new_vaccinations as int)) OVER(Partition BY dea.Location ORDER BY dea.location, dea.Date) AS final_vaccinated_people
FROM 
      Covid..Death dea
    JOIN Covid..Vaccination vac
      ON dea.location = vac.location
      AND dea.date = vac.date
WHERE dea.continent is not null 
) 

SELECT
  continent, location, date, population, new_vaccinations, final_vaccinated_people,
  (final_vaccinated_people/population)*100 AS percentage_vaccinated_people
FROM 
  Vaccinated_people_country 
--ORDER BY 2,3 DESC

--We want to create a new view for vaccinated people in each continent

CREATE VIEW Vaccinated_ppl_continent
AS
WITH Vaccinated_people_continent (continent,date,population,new_vaccinations,final_vaccinated_people)
AS
(
SELECT 
      dea.continent, dea.date, dea.population, vac.new_vaccinations,
    SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS final_vaccinated_people
FROM
      Covid..Death dea
    JOIN Covid..Vaccination vac
      ON dea.location = vac.location
      AND dea.date = vac.date
WHERE dea.continent is not null
) 
SELECT 
  continent, date, population, new_vaccinations, final_vaccinated_people,
  (final_vaccinated_people/population)*100 AS percentage_vaccinated_people
FROM 
  Vaccinated_people_continent 
--ORDER BY 2,3 Desc




