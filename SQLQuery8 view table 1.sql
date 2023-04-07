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

select *
from PercentagePopulationVaccinated