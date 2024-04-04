SELECT *
FROM PortfolioProject_AlexTheAnalyst..CovidDeaths
WHERE continent is not null
ORDER BY 3,4;

--SELECT *
--FROM PortfolioProject_AlexTheAnalyst..CovidVaccinations
--ORDER BY 3,4

-- SELECT Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject_AlexTheAnalyst..CovidDeaths
WHERE continent is not null
ORDER BY location, date;

-- Looking at the total cases vs total deaths for each country
-- Shows the likelyhood of dieing if you contract COVID in a specific country

SELECT location, date, total_cases, total_deaths, ROUND((CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT) * 100), 2) as DeathPercentage
FROM PortfolioProject_AlexTheAnalyst..CovidDeaths
WHERE location = 'United States' AND continent is not null
ORDER BY location, date;

-- looking at the total cases vs the population
-- Show what percentage of population contracted COVID in a specific country

SELECT location, date, population, total_cases,  ROUND((CAST(total_cases AS FLOAT) / CAST(population AS FLOAT) * 100), 2) as CovidPercentageOfPopulation
FROM PortfolioProject_AlexTheAnalyst..CovidDeaths
WHERE location = 'United States' AND continent is not null
ORDER BY location, date;

-- What countries have the highest infections rates compared to populaiton?

SELECT location, population, Max(total_cases) as HighestInfectionCount,  ROUND(MAX((CAST(total_cases AS FLOAT) / CAST(population AS FLOAT) * 100)), 2) as CovidPercentageOfPopulation
FROM PortfolioProject_AlexTheAnalyst..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY CovidPercentageOfPopulation DESC;

-- Show the countries with the highest death counts per population

SELECT location,  MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject_AlexTheAnalyst..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC;


-- By continent if continent

SELECT continent,  SUM(total_deaths) as TotalDeathCount
FROM PortfolioProject_AlexTheAnalyst..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC;


-- Global Numbers

SELECT date, SUM(new_cases) as TotalNewCases, SUM(new_deaths) as TotalNewDeaths, ROUND((SUM(CAST(new_deaths AS FLOAT)) / SUM(CAST(new_cases AS FLOAT)) * 100), 2) 
	as DeathPercentageOfNewCases
FROM PortfolioProject_AlexTheAnalyst..CovidDeaths
WHERE continent is not null AND new_cases != 0
Group By date
ORDER BY date;

SELECT  SUM(new_cases) as TotalNewCases, SUM(new_deaths) as TotalNewDeaths, ROUND((SUM(CAST(new_deaths AS FLOAT)) / SUM(CAST(new_cases AS FLOAT)) * 100), 2) 
	as DeathPercentageOfNewCases
FROM PortfolioProject_AlexTheAnalyst..CovidDeaths
WHERE continent is not null AND new_cases != 0;
--Group By date
--ORDER BY date;







--- COVID VACINATIONS ---


SELECT * 
FROM PortfolioProject_AlexTheAnalyst..CovidDeaths dea
JOIN PortfolioProject_AlexTheAnalyst..CovidVaccinations vac
	On	dea.location = vac.location
	AND	dea.date = vac.date

-- Total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject_AlexTheAnalyst..CovidDeaths dea
JOIN PortfolioProject_AlexTheAnalyst..CovidVaccinations vac
	On	dea.location = vac.location
	AND	dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 1, 2, 3;

-- Rolling Count

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) 
	OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingTotalVaccinations
FROM PortfolioProject_AlexTheAnalyst..CovidDeaths dea
JOIN PortfolioProject_AlexTheAnalyst..CovidVaccinations vac
	On	dea.location = vac.location
	AND	dea.date = vac.date
WHERE dea.continent is not null AND vac.new_vaccinations is not null
ORDER BY 2, 3;

-- USE CTE

With PopvsVac(continent, location, date, population, new_vacinations, RollingTotalVaccinations)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) 
	OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingTotalVaccinations
FROM PortfolioProject_AlexTheAnalyst..CovidDeaths dea
JOIN PortfolioProject_AlexTheAnalyst..CovidVaccinations vac
	On	dea.location = vac.location
	AND	dea.date = vac.date
WHERE dea.continent is not null AND vac.new_vaccinations is not null
)

SELECT *, (CAST(RollingTotalVaccinations AS FLOAT) / CAST(population AS FLOAT)) * 100
FROM PopvsVac
ORDER  BY location, date

-- USE Tempt Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
	continent nvarchar(255),
	location nvarchar(255),
	date date,
	population bigInt,
	new_vaccinations bigInt,
	RollingTotalVaccinations bigInt
)


INSERT into #PercentPopulationVaccinated
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) 
		OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingTotalVaccinations
	FROM PortfolioProject_AlexTheAnalyst..CovidDeaths dea
	JOIN PortfolioProject_AlexTheAnalyst..CovidVaccinations vac
		On	dea.location = vac.location
		AND	dea.date = vac.date
	WHERE dea.continent is not null AND vac.new_vaccinations is not null

SELECT *, (CAST(RollingTotalVaccinations AS FLOAT) / CAST(population AS FLOAT)) * 100
FROM #PercentPopulationVaccinated
ORDER  BY location, date


-- Creating Views to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) 
		OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingTotalVaccinations
	FROM PortfolioProject_AlexTheAnalyst..CovidDeaths dea
	JOIN PortfolioProject_AlexTheAnalyst..CovidVaccinations vac
		On	dea.location = vac.location
		AND	dea.date = vac.date
	WHERE dea.continent is not null AND vac.new_vaccinations is not null