use covid_project

-- 1.Select DATA that will be used

select  location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2

--2. Checking Total Cases vs Total Deaths 
-- Shows likelihood of dying if you contract in your country 
select  location, date, total_cases, total_deaths, 
((total_deaths/total_cases)*100) as DeathPercentage
from CovidDeaths
where location like 'poland'
order by 1,2
--minuta 23:14 tutorial

--3. Looking at Total Cases vs Population in Poland 
-- Shows what percentage of population got Covid
select  location, date, total_cases, population, 
((total_cases/population)*100) as PercentagePopulationInfected
from CovidDeaths 
where location like 'poland'
order by 1,2

--4. Looking at Countries with highest infection rate compared to population 
SELECT 
    location, 
    population, 
    MAX(total_cases) as HighestInfectionCount, 
    ROUND((MAX(total_cases) * 100.0 / population), 2) as PercentagePopulationInfected
FROM 
    CovidDeaths 
WHERE continent is not null
GROUP BY 
    location, 
    population
ORDER BY 
    PercentagePopulationInfected DESC;

--5 Showing Countries with the Highest Death Count er Population 
SELECT location, Max(cast(total_deaths as int)) as TotalDeathsCount
FROM 
    CovidDeaths 
WHERE continent is not null
GROUP BY 
    location
ORDER BY 
    TotalDeathsCount DESC;

--6 Showing Continent with the Highest Death Count er Population 
SELECT continent, Max(cast(total_deaths as int)) as TotalDeathsCount
FROM 
    CovidDeaths 
WHERE continent is  not null
GROUP BY 
    continent
ORDER BY 
    TotalDeathsCount DESC;


--GLOBAL NUMBERS

-- Deaths Percentage 

SELECT date, SUM(new_cases) as totalCases,SUM(cast(new_deaths as int)) as totalDeaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is  not null
group by date
order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT cd.continent, cd.location,cd.date, cd.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) over 
(Partition by cd.location Order by cd.location, cd.date) as  RollingPeopleVaccinated
FROM CovidDeaths cd
Join CovidVaccinations$ vac
on cd.location = vac.location
and cd.date = vac.date
WHERE cd.continent is  not null
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

with PopvsVac (Continent, Location, Date, Population,New_vaccinations, RollingPeopleVaccinated) as
(SELECT cd.continent, cd.location,cd.date, cd.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) over 
(Partition by cd.location Order by cd.location, cd.date) as  RollingPeopleVaccinated
FROM CovidDeaths cd
Join CovidVaccinations$ vac
on cd.location = vac.location
and cd.date = vac.date
WHERE cd.continent is  not null
)
select *, (RollingPeopleVaccinated/Population)*100 as PercentageVaccinated 
from PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query
DROP Table if exists #PercentagePopulationVaccineted
Create Table #PercentagePopulationVaccineted
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentagePopulationVaccineted
SELECT cd.continent, cd.location,cd.date, cd.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) over 
(Partition by cd.location Order by cd.location, cd.date) as  RollingPeopleVaccinated
FROM CovidDeaths cd
Join CovidVaccinations$ vac
on cd.location = vac.location
and cd.date = vac.date
--WHERE cd.continent is  not null
select *,(RollingPeopleVaccinated/Population)*100
from #PercentagePopulationVaccineted


--create view to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT cd.continent, cd.location,cd.date, cd.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) over 
(Partition by cd.location Order by cd.location, cd.date) as  RollingPeopleVaccinated
FROM CovidDeaths cd
Join CovidVaccinations$ vac
on cd.location = vac.location
and cd.date = vac.date
WHERE cd.continent is  not null

select * from PercentPopulationVaccinated