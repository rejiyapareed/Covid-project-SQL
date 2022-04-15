SELECT *
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY location,date;

 ....select data that we are going to use
 SELECT location,date,total_cases,new_cases,total_deaths,population
 FROM covid_deaths
 ORDER BY location,date;

 ---looking at total cases vs total deaths
 ---shows likelihood of dying with covid in your country
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS deathpercentage
 FROM covid_deaths
 WHERE location LIKE '%states%'
 ORDER BY location,date;

 ---looking at total cases vs population
 --shows what percentage of population got covid
  SELECT location,date,total_cases,population,(total_deaths/population)*100 AS deathpercentage
 FROM covid_deaths
ORDER BY location,date;

---looking at countries with highest infection rate compared to population
SELECT location,population,MAX(total_cases) AS Highestinfectioncount ,MAX((total_cases)/population)*100 AS percentpopulationinfected
 FROM covid_deaths
 GROUP BY location,population
 ORDER BY percentpopulationinfected  DESC;

 ---showing countries with highest death rate per population
 SELECT location,MAX( CAST (total_deaths AS int)) AS Totaldeathcount 
 FROM covid_deaths
 WHERE continent IS NOT NULL
 GROUP BY location
 ORDER BY Totaldeathcount   DESC;


 ---LETS BREAK THINGS DOWN BY CONTINENT
 SELECT continent,MAX( CAST (total_deaths AS int)) AS Totaldeathcount 
 FROM covid_deaths
 WHERE continent IS NOT NULL
 GROUP BY continent
 ORDER BY Totaldeathcount   DESC;

 ---showing continents with highest death count per population
 SELECT continent,MAX( CAST (total_deaths AS int)) AS Totaldeathcount 
 FROM covid_deaths
 WHERE continent IS NOT NULL
 GROUP BY continent
 ORDER BY Totaldeathcount   DESC;

 ---global numbers
 SELECT SUM(new_cases) AS total_cases,SUM(CAST(new_deaths AS int)) AS total_deaths,SUM(CAST(new_deaths AS int))/SUM(new_cases) * 100 AS Deathpercentage
 FROM covid_deaths
 WHERE continent IS NOT NULL;

 SELECT *
 FROM [dbo].[covid_vaccinations];

 ---JOINING 2 TABLES
 SELECT *
 FROM covid_deaths AS dea
 JOIN [dbo].[covid_vaccinations] AS vac
 ON dea.location=vac.location
 AND dea.date=vac.date;

 ---looking at total population vs vaccination
 SELECT dea.continent,dea.location, dea.date,dea.population,vac.new_vaccinations,SUM(CAST(vac.new_vaccinations AS int))  OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS rollingpeopleaccinated
 FROM covid_deaths AS dea
 JOIN [dbo].[covid_vaccinations] AS vac
 ON dea.location=vac.location
 AND dea.date=vac.date
 WHERE dea.continent IS NOT NULL
 ORDER BY continent,location,date;


 ---using CTE
  WITH popvsvac(continent,location,date,population,new_vaccinations,rollingpeoplevaccinated)
  AS
  (
  SELECT dea.continent,dea.location, dea.date,dea.population,vac.new_vaccinations,SUM(CAST(vac.new_vaccinations AS int))  OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS rollingpeopleaccinated
 FROM covid_deaths AS dea
 JOIN [dbo].[covid_vaccinations] AS vac
 ON dea.location=vac.location
 AND dea.date=vac.date
 WHERE dea.continent IS NOT null
 )
 SELECT * ,
 rollingpeoplevaccinated/population) *100
 FROM popvsvac;


 ---create TEMP table
 CREATE TABLE #percentpopulationvaccinated
 (
 continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 rollingpeoplevaccinated numeric
 )
 INSERT INTO #percentpopulationvaccinated
  SELECT dea.continent,dea.location, dea.date,dea.population,vac.new_vaccinations,SUM(CAST(vac.new_vaccinations AS int))  OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS rollingpeopleaccinated
 FROM covid_deaths AS dea
 JOIN [dbo].[covid_vaccinations] AS vac
 ON dea.location=vac.location
 AND dea.date=vac.date
 WHERE dea.continent IS NOT null

 SELECT * ,
 (rollingpeoplevaccinated/population) *100
 FROM #percentpopulationvaccinated;


 ---Create view to store data for later visulaizations
 CREATE VIEW percentpopulationvaccinated AS
  SELECT dea.continent,dea.location, dea.date,dea.population,vac.new_vaccinations,SUM(CAST(vac.new_vaccinations AS int))  OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS rollingpeopleaccinated
 FROM covid_deaths AS dea
 JOIN [dbo].[covid_vaccinations] AS vac
 ON dea.location=vac.location
 AND dea.date=vac.date
 WHERE dea.continent IS NOT null




  
