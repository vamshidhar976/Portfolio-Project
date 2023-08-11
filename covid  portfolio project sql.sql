select *
from CovidDeaths
order by 3,4
--select *
--from covidvaccinations
--order by 3,4
--select data that we are going to use
select Location,date,total_cases,new_cases,total_deaths,population
from CovidDeaths
order by 1,2
--comparing total_cases vs total_deaths
select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as percentageof_deaths
from CovidDeaths
where location like '%states'
order by 1,2

-- we will total_cases vs population
select Location,date,total_cases,population,(total_cases/population)*100 as mutationpercentage,total_deaths,(total_deaths/population)*100 as deathper
from CovidDeaths
where Location like 'india'
order by 1,2
--countries with highest infection rate compared to poulation

select Location,population,max(total_cases) as maxcases,max((total_cases/population)*100) as maxper
from CovidDeaths
group by Location,population
order by maxcases desc
--showing highest death count per population
select Location,population,max(cast(total_deaths as int)) as max_deaths,max((total_deaths/population)*100) as total_death_per
from CovidDeaths
where continent is not null
group by population,Location
order by max_deaths desc

-- Lets break things by continent

select continent,max(population),max(cast(total_deaths as int)) as max_deaths,max((total_deaths/population)*100) as total_death_per
from CovidDeaths
where continent is not null
group by continent
order by max_deaths desc
-- showing continents with highest death count

select sum(new_cases) as new_cases,sum(cast(new_deaths as int)) as new_deaths,(sum(cast(new_deaths as int))/sum(new_cases))*100 as deathper
from CovidDeaths
where continent is not null

select *
from covidvaccinations
 -- eliminate unwanted columns
select location,max(new_tests),max(positive_rate),max(new_vaccinations)
from covidvaccinations
where continent is not null
group by location
order by location
--joining  coviddeaths and covid vaccinations tables
select *
from CovidDeaths dea
inner join covidvaccinations vac
on dea.date=vac.date and dea.location=vac.location

-- looking total population vs  total vaccinations

select dea.location,dea.population ,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location),dea.date
from protfolioproject..CovidDeaths dea
 join protfolioproject..covidvaccinations vac
on dea.location=vac.location
where dea.continent is not null
group by dea.location,dea.population,vac.new_vaccinations,dea.date
order by 1,2,3


with pop_vs_vac (continent,location,date,population,new_vaccinations,sumofnew_vaccinations)
as 
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as sumofnew_vaccinations
from protfolioproject..CovidDeaths dea 
join protfolioproject..covidvaccinations vac
on dea.location=vac.location  and dea.date=vac.date
where dea.continent is not null 
)
select *,(sumofnew_vaccinations/population)*100 as percentage_ofvaccination
from pop_vs_vac

--Temp table percentagofpeoplevaccinated
drop table if exists percentagofpeoplevaccinated
create table percentagofpeoplevaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
sumofnew_vaccinations numeric)

insert into percentagofpeoplevaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as sumofnew_vaccinations
from protfolioproject..CovidDeaths dea 
join protfolioproject..covidvaccinations vac
on dea.location=vac.location  and dea.date=vac.date
where dea.continent is not null

select *,(sumofnew_vaccinations/population)*100 as percentage_ofvaccination
from percentagofpeoplevaccinated

--creating view to store data for later visualization

create view percentagof_people_vaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as sumofnew_vaccinations
from protfolioproject..CovidDeaths dea 
join protfolioproject..covidvaccinations vac
on dea.location=vac.location  and dea.date=vac.date
where dea.continent is not null 
--order by 2,3
 
 select *
 from percentagof_people_vaccinated








