Select *
From PortoflioProject ..CovidDeaths
where continent is not null
Order by 3,4

--Select *
--From PortoflioProject ..CovidVaccinations
--Order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortoflioProject ..CovidDeaths
where continent is not null
Order by 1,2


--looking at total cases vs total deaths: % of people who died
-- shows the likelyhood of dying if you contract covid in your country
Select location, date, total_cases,total_deaths ,(total_deaths/total_cases)*100 as DeathPercentage
From PortoflioProject ..CovidDeaths
where location like '%Egypt%'
and continent is not null
Order by 1,2

--looking at total cases vs the populations
--what % of population got covid
Select location, date, total_cases,population ,(total_cases/population)*100 as PopulationInfectedPercentage
From PortoflioProject ..CovidDeaths
where location like '%Egypt%'
and continent is not null
Order by 1,2

--what country had the highest infection rate compared to population
Select Location, Population , Max(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PopulationInfectedPercentage
From PortoflioProject ..CovidDeaths
--where location like '%Egypt%'
Group by Location, Population
Order by PopulationInfectedPercentage desc

--showing countries with highest death count per population 

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortoflioProject ..CovidDeaths
--where location like '%Egypt%'
Where continent is not null
Group by Location, Population
Order by TotalDeathCount desc

-- by continent 
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortoflioProject ..CovidDeaths
--where location like '%Egypt%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc

-- global numbers
Select  SUM(new_cases) as total_cases ,SUM(cast(new_deaths as int)) as total_deaths ,SUM(cast(new_deaths as int))/SUM(new_cases) *100 as DeathPercentage
From PortoflioProject ..CovidDeaths
--where location like '%Egypt%'
where continent is not null
--Group by date
Order by 1,2


-- total population vs vaccination
--how many people got vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert (int, vac.new_vaccinations )) OVER ( Partition by dea.location,  dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated /population) *100
From PortoflioProject ..CovidDeaths dea
join PortoflioProject ..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date= vac.date
Where dea.continent is not null
Order by 2,3 


-- use cte
with PopVsVac (Continent, Location, date, population,new_vaccinations, RollingPeopleVaccinated )
 as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert (int, vac.new_vaccinations )) OVER ( Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated /population) *100
From PortoflioProject ..CovidDeaths dea
join PortoflioProject ..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date= vac.date
Where dea.continent is not null
--Order by 2,3
)
Select * , (RollingPeopleVaccinated /population) *100
From PopVsVac


-- temp table


Drop Table if exists  #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
 Insert into #PercentPopulationVaccinated
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert (int, vac.new_vaccinations )) OVER ( Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated /population) *100
From PortoflioProject ..CovidDeaths dea
join PortoflioProject ..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date= vac.date
Where dea.continent is not null
--Order by 2,3

Select * , (RollingPeopleVaccinated /population) *100
From #PercentPopulationVaccinated



--creating view to store data later for visualisation

Create View PercentPopulationVaccinated as 
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert (int, vac.new_vaccinations )) OVER ( Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated /population) *100
From PortoflioProject ..CovidDeaths dea
join PortoflioProject ..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date= vac.date
Where dea.continent is not null
--Order by 2,3


select *
From PercentPopulationVaccinated