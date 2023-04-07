select location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as death_rate
from PortfolioProject..deaths$
order by 1,2

---total_case vs population

select location, date, population, total_cases, (total_cases/population)*100 as deathpercentage
from PortfolioProject..deaths$
where location = 'Nigeria'
order by 1,2

---Countries with highest infection rate
select location,population, MAX(total_cases) highestinfections, max((total_cases/population)*100) as infectionrate
from PortfolioProject..deaths$
--where location='United States'
where continent is not null
group by location, population
order by 4 desc

---Countries with the highest Death Count per population
select location, max(cast(total_cases as int)) as deathcount
from PortfolioProject..deaths$
where continent is not null
group by location
order by 2 desc

---Countries with the highest Death Count per population by continent
select continent, max(cast(total_cases as int)) as deathcount
from PortfolioProject..deaths$
where continent is not null
group by continent
order by 2 desc

---Let's check with the nulls 
select location, max(cast(total_cases as int)) as deathcount
from PortfolioProject..deaths$
where continent is null
group by location
order by 2 desc

--Global numbers
select date, sum(new_cases), sum(new_deaths)
from PortfolioProject..deaths$
where continent is not null
group by date
--or
select date, max(cast(total_cases as int)), max(total_deaths)
from PortfolioProject..deaths$
where continent is not null
group by date

--Global deathrate
select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(new_deaths)/sum(new_cases))*100 as globaldeathrate
from portfolioProject..deaths$
where continent is not null

select max(cast(total_cases as float)) as cases, max(cast(total_deaths as float)) as deaths,(max(cast(total_deaths as float)) /max(cast(total_cases as float)))*100 as deathrate
from PortfolioProject..deaths$
where continent is not null

--Now let's explore the vaccinations table
select *
from PortfolioProject..Sheet1$

--Joining our two tables
select *
from PortfolioProject..deaths$ dea
join PortfolioProject..Sheet1$ vac
on dea.location=vac.location
and dea.date=vac.date

--Total population vs vaccination (number of people that are vaccinated per time)
--Use CTE
with popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated) as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(float,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from PortfolioProject..deaths$ dea
join PortfolioProject..Sheet1$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rollingpeoplevaccinated/population)*100 as vacrate
from popvsvac


--CREATING A TEMP TABLE
DROP Table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)
insert into #PercentagePopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(float,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from PortfolioProject..deaths$ dea
join PortfolioProject..Sheet1$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
select *, (rollingpeoplevaccinated/population)*100 as vacrate
from #PercentagePopulationVaccinated

--Creating views to store data for later visualizations
 Create View PercentagePopulationVaccinated as 
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(float,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from PortfolioProject..deaths$ dea
join PortfolioProject..Sheet1$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3





