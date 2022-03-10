
SELECT *
FROM [PortfolioProject(ATA)]..CovidDeaths
ORDER BY 3, 4


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract COVID-19 in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS DeathPercentage
FROM [PortfolioProject(ATA)]..CovidDeaths
WHERE Location = 'Netherlands'
AND continent IS NOT NULL
ORDER BY 1, 2


 -- Looking at Total Cases vs Population
 -- Shows what percentage of population got COVID-19
SELECT Location, date, total_cases, population, (total_cases / population) * 100 AS PercentPopulationInfected
FROM [PortfolioProject(ATA)]..CovidDeaths
WHERE Location = 'Netherlands'
AND continent IS NOT NULL
ORDER BY 1, 2


-- Looking at countries with Highest Infection Rate compared to Population 
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)) * 100 AS PercentPopulationInfected
FROM [PortfolioProject(ATA)]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location, population
ORDER BY PercentPopulationInfected DESC


-- Showing Countries with Highest Death Count per Population
SELECT Location, MAX(CAST(Total_Deaths AS INT)) AS TotalDeathCount
FROM [PortfolioProject(ATA)]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC


-- Let's break things down by continent
SELECT location, MAX(CAST(Total_Deaths AS INT)) AS TotalDeathCount
FROM [PortfolioProject(ATA)]..CovidDeaths
WHERE continent IS NULL
AND NOT location='High income'
AND NOT location='Upper middle income'
AND NOT location='Lower middle income'
AND NOT location='Low income'
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Showing continents with highest deathcount per population
SELECT continent, MAX(CAST(Total_Deaths AS INT)) AS TotalDeathCount
FROM [PortfolioProject(ATA)]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Continent
ORDER BY TotalDeathCount DESC


-- Global numbers
SELECT 
	date, 
	SUM(new_cases) AS Total_Cases, 
	SUM(CAST(new_deaths AS int)) AS Total_Deaths, 
	SUM(CAST(new_deaths AS int))/SUM(new_cases) * 100 AS DeathPercentage
FROM [PortfolioProject(ATA)]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2


-- Looking at Total Population vs Vaccination
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(CONVERT(Bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated,
	(RollingPeopleVaccinated/Population) AS PercentageVaccinated
FROM CovidVaccinations vac
JOIN CovidDeaths dea
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
GROUP BY dea.continent,   
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations
ORDER BY 2,3


-- CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(CONVERT(Bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [PortfolioProject(ATA)]..CovidVaccinations vac
JOIN [PortfolioProject(ATA)]..CovidDeaths dea
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric,
)
Insert into #PercentPopulationVaccinated
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(CONVERT(Bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [PortfolioProject(ATA)]..CovidVaccinations vac
JOIN [PortfolioProject(ATA)]..CovidDeaths dea
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating view to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated AS 
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(CONVERT(Bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [PortfolioProject(ATA)]..CovidVaccinations vac
JOIN [PortfolioProject(ATA)]..CovidDeaths dea
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


-- Shows likelihood of dying if you contract COVID-19 in your country
CREATE VIEW ChanceOfDyingNetherlands AS
SELECT 
	Location, 
	date, 
	total_cases, 
	total_deaths, 
	(total_deaths / total_cases) * 100 AS DeathPercentage
FROM [PortfolioProject(ATA)]..CovidDeaths
WHERE Location = 'Netherlands'
AND continent IS NOT NULL


-- Shows what percentage of population got COVID-19
CREATE VIEW InfectionRateNetherlands AS
SELECT 
	Location, 
	date, 
	total_cases, 
	population, 
	(total_cases / population) * 100 AS PercentPopulationInfected
FROM [PortfolioProject(ATA)]..CovidDeaths
WHERE Location = 'Netherlands'
AND continent IS NOT NULL