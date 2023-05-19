select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

--Select data that we are going to be using

select Location, Date, Total_Cases, New_Cases, Total_Deaths, Population
from PortfolioProject..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract covid in your country

select Location, Date, Total_Cases, Total_Deaths, (Total_Deaths/Total_Cases)*100 as Death_Percentage
from PortfolioProject..CovidDeaths
where location like '%canada%'
and continent is not null
order by 1,2


--Looking at Total Cases vs Population
--Shows what percentage of population got covid


select Location, Date, Total_Cases, Population, (Total_Cases/Population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where location like '%canada%'
order by 1,2


--Looking at countries with highest infection rate compared to population

select Location, Population, max(total_cases) as HighestInfectionCount, max((Total_Cases/Population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%canada%'
group by Location, Population
order by PercentPopulationInfected desc


--Showing Countries with highest Death Count per Population

select location, max(cast(Total_Deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%canada%'
where continent is not null
group by location, Population
order by TotalDeathCount desc

--Let's break it down by continent

--Showing the continents with the highest death count per population

select continent, max(cast(Total_Deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%canada%'
where continent is not null
group by continent
order by TotalDeathCount desc


--Global numbers

select Date, sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%canada%'
where continent is not null
group by date
order by 1,2


--Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location Order by dea.Location, 
	dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Use CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location Order by dea.Location, 
	dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


--TEMP TABLE

drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location Order by dea.Location, 
	dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100 as PercentPopulationVaccinated
from #PercentPopulationVaccinated


--Creating view to store data for later visualization


create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location Order by dea.Location, 
	dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select *
from PercentPopulationVaccinated


create view PopulationvsVaccinations as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location Order by dea.Location, 
	dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select *
from PopulationvsVaccinations