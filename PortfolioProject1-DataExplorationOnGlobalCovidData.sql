select * from PortfolioProject1..CovidDeaths 
where continent is not null
order by 3,4


select * from PortfolioProject1..CovidVaccinations order by 3,4


-- Select data we're going to be using --
select location, date, total_cases, new_cases, total_deaths, population from PortfolioProject1..CovidDeaths order by 1,2

 
-- 1) looking at total cases v/s total deaths: 
-- shows likelihood of dying (%) if a person gets infected by the virus as per countries and timestamp
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as 'DeathPercentage%'
from PortfolioProject1..CovidDeaths 
where location like '%India%'
order by 1,2


-- 2) looking at total cases v/s total population: 
-- shows what % of population was infected
select location, date, total_cases, population, (total_cases/population)*100 as 'PopulationPercentageInfected'
from PortfolioProject1..CovidDeaths 
where location like '%India%'
order by 1,2


-- 3) Highest infection rates of all countries as per their population sorted from highest to lowest:
select location, max(total_cases) as 'highest infection count', population, max((total_cases/population))*100 as 'PopulationPercentageInfected'
from PortfolioProject1..CovidDeaths 
group by location, population
order by PopulationPercentageInfected desc



-- 4) Countries with highest death count per population:
select location, max(cast(total_deaths as int)) as 'TotalDeathCount'
from PortfolioProject1..CovidDeaths 
where continent is not null
group by location
order by TotalDeathCount desc



-- 5) Breaking things down as per continent: showing continents with highest death count
select location, max(cast(total_deaths as int)) as 'TotalDeathCount'
from PortfolioProject1..CovidDeaths 
where continent is null
group by location
order by TotalDeathCount desc



-- 6) Global numbers: total cases, death and death % globally on a daily basis 
select date, sum(new_cases) as 'total cases', sum(cast(new_deaths as int)) as 'total deaths', sum(cast(new_deaths as int))/sum(new_cases)*100 as 'DeathPercentage%'
from PortfolioProject1..CovidDeaths 
where continent is not null
group by date
order by 1,2



-- 7) Global numbers: total cases, death and death % globally taking into consideration all dates
select sum(new_cases) as 'total cases', sum(cast(new_deaths as int)) as 'total deaths', sum(cast(new_deaths as int))/sum(new_cases)*100 as 'DeathPercentage%'
from PortfolioProject1..CovidDeaths 
where continent is not null
order by 1,2



-- 8) Joining the death and vaccination tables for further exploration:
select * 
from PortfolioProject1..CovidDeaths death
join PortfolioProject1..CovidVaccinations vac
on death.location = vac.location and death.date = vac.date



-- 9 ) Total population vs vaccinations:
select death.continent, death.location, death.date, death.population, vac.new_vaccinations
from PortfolioProject1..CovidDeaths death
join PortfolioProject1..CovidVaccinations vac
on death.location = vac.location and death.date = vac.date
where death.continent is not null
order by 2,3




-- 10) Rolling count of total vaccinaitons in each country on a daily basis:
select death.continent, death.location, death.date, death.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) over (partition by death.location order by death.location, death.date)
from PortfolioProject1..CovidDeaths death
join PortfolioProject1..CovidVaccinations vac
on death.location = vac.location and death.date = vac.date
where death.continent is not null
order by 2,3




-- 11) total population vs total vaccination using rolling count:

-- Using Commom Table Exressions:
with popvsvac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(

select death.continent, death.location, death.date, death.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) over (partition by death.location order by death.location, death.date) as 'RollingPeopleVaccinated'
from PortfolioProject1..CovidDeaths death
join PortfolioProject1..CovidVaccinations vac
on death.location = vac.location and death.date = vac.date
where death.continent is not null
)

select *, (RollingPeopleVaccinated/Population)*100 as '% people vaccinated' from popvsvac
order by 2,3


-- Using a temp table:
Drop table if exists #PercentPopVac
create table #PercentPopVac
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopVac
select death.continent, death.location, death.date, death.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) over (partition by death.location order by death.location, death.date) as 'RollingPeopleVaccinated'
from PortfolioProject1..CovidDeaths death
join PortfolioProject1..CovidVaccinations vac
on death.location = vac.location and death.date = vac.date
where death.continent is not null


select *, (RollingPeopleVaccinated/Population)*100 as '% people vaccinated' from #PercentPopVac
order by 2,3



-- 12) Creating views for visualizations in tableau/excel/power BI:
Create view PercentPopulationVaccinated as
select death.continent, death.location, death.date, death.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) over (partition by death.location order by death.location, death.date) as 'RollingPeopleVaccinated'
from PortfolioProject1..CovidDeaths death
join PortfolioProject1..CovidVaccinations vac
on death.location = vac.location and death.date = vac.date
where death.continent is not null


select * from PercentPopulationVaccinated