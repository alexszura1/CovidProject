Select *
From PortfolioProject..CovidDeaths$
Where continent is not null
order by 3,4

Select *
From PortfolioProject..CovidVaccinations$
order by 3,4


Select	Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
order by 1,2


--Total cases vs. Deaths

Select	Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where continent is not null
Where location like '%states%'
order by 1,2


--Total Cases vs. Population

Select	Location, date, total_cases, Population, (total_cases/population)*100 as InfectedPercentage
From PortfolioProject..CovidDeaths$
Where continent is not null
Where location like '%states%'
order by 1,2

--Countries w/ highest infection rate vs. population
Select	Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as InfectedPercentage
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by Location, Population
order by InfectedPercentage desc

--  Countries w/ highest death count/population

Select	Location, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by Location
order by TotalDeathCount desc
 
--Breakdown by continent (highest death count)
Select	location, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is null
Group by location
order by TotalDeathCount desc


--Global numbers
Select  Sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where continent is not null
--Group by date
order by 1,2



--Total population vs. vaccinations
Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

--use CTE

With PopvsVac (continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as VacPercentage
From PopvsVac

--Temp table

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as VacPercentage
From #PercentPopulationVaccinated





--creating view to store data future visuals

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated

