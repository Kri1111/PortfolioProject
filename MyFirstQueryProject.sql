--Select *
--From PortfolioProject..CovidDeaths
--order by 3,4

Select *
From PortfolioProject..CovidVaccine
Order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, Population
From PortfolioProject..CovidDeaths
order by 1,2

-- Looking Total cases vs total deaths
Select Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
order by 1,2

-- Looking Total cases vs total deaths in India
Select Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%India%'
and Continent is not null
order by DeathPercentage desc


-- Looking country with highest Infection rates compared to population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as PercentageofpopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%India%'
Group by Location,Population
order by PercentageofpopulationInfected desc

--country with highest cases

Select Location, Population, MAX(total_cases) as HighestInfectionCount
From PortfolioProject..CovidDeaths
--where location like '%India%'
Group by Location,Population
order by HighestInfectionCount desc


--country with hightest death count per population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as PercentageofpopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%India%'
Group by Location,Population
order by PercentageofpopulationInfected desc

--country with hightest death count per population
Select Location, MAX(cast(total_deaths as int)) TotalDeathCount 
From PortfolioProject..CovidDeaths
where continent is not NULL
Group by Location
order by  TotalDeathCount  desc

---Deaths by continents
Select continent, MAX(cast(total_deaths as int)) TotalDeathCount 
From PortfolioProject..CovidDeaths
where continent is  not null
Group by continent
order by  TotalDeathCount  desc

--Global numbers

Select  date, SUM(new_cases) as totalNewcase, Sum(cast(new_deaths as int)) as Totalnewdeath,  Sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where Continent is not null
Group by date
order by 1,2

Select dea.continent, dea.location, dea.date, Dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
    join PortfolioProject..CovidVaccine vac
	on dea.Location=vac.Location
	and dea.date=vac.date

where  dea.Continent is not null
order by ,2,3

-- total population vs vaccination
Select dea.continent, dea.location, dea.date, Dea.population, vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location,dea.Date) as Rolluppeoplevaccinated
From PortfolioProject..CovidDeaths dea
    join PortfolioProject..CovidVaccine vac
	on dea.Location=vac.Location
	and dea.date=vac.date

where  dea.Continent is not null
order by ,2,3

--use CTW 

with PopvsVac(Continents, Locations, Date, Populations, New_Vaccinations,Rolluppeoplevaccinated)
as
(
Select dea.continent, dea.location, dea.date, Dea.population, vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location,dea.Date) as Rolluppeoplevaccinated
From PortfolioProject..CovidDeaths dea
    join PortfolioProject..CovidVaccine vac
	on dea.Location=vac.Location
	and dea.date=vac.date

where  dea.Continent is not null
)
select *, (Rolluppeoplevaccinated/Populations)*100 
From PopvsVac







--temptable

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolluppeoplevaccinated numeric,
)
INSERT INTO  #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, Dea.population, vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location,dea.Date) as Rolluppeoplevaccinated
From PortfolioProject..CovidDeaths dea
    join PortfolioProject..CovidVaccine vac
	on dea.Location=vac.Location
	and dea.date=vac.date

where  dea.Continent is not null

select *, (Rolluppeoplevaccinated/Population)*100 
From  #PercentPopulationVaccinated

--creating view to store data for later visualisation

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, Dea.population, vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location,dea.Date) as Rolluppeoplevaccinated
From PortfolioProject..CovidDeaths dea
    join PortfolioProject..CovidVaccine vac
	on dea.Location=vac.Location
	and dea.date=vac.date

where  dea.Continent is not null


