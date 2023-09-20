-- PATH: 'Database Name'.dbo.'Table Name'
-- select * from indian_census_data.dbo.data1

-- alter table data2 drop column F8,F9,F10,F11,F12,F13,F14,F15,F16,F17,F18

select * from data1
-- select * from indian_census_data.dbo.data1

select * from data2

-- Q1. Nmuber of rows into our Database?

select count(*) from data1
select count(*) from data2

-- Q2. Dataset for Jharkhand and Bihar

select * from data1 where state in ('Jharkhand', 'Bihar')

-- Q3. Total population of India

select sum(population) as total_population from data2

-- Q4. Average growth by each state in India

select state, avg(growth)*100 avg_growth from indian_census_data.dbo.data1 group by state

-- Q5. Average Sex ratio by each state of the India

select state, round(avg(sex_ratio),0) avg_sex_ratio from indian_census_data.dbo.data1 group by state order by avg_sex_ratio desc

-- Q6. Average Literacy rate of all State

select state, round(avg(literacy),0) avg_literacy from indian_census_data.dbo.data1 
group by state 
having round(avg(literacy),0) > 90
order by avg_literacy desc 

-- Q7. Which are the Top 3 States, showing highest growth ratio

select top 3 state, avg(growth)*100 avg_growth from indian_census_data.dbo.data1 group by state order by avg_growth desc

-- Q8. List a Bottom 3 States, which has lowest sex_ratio

select top 3 state, avg(sex_ratio) avg_sex_ratio from indian_census_data.dbo.data1 group by state order by avg_sex_ratio asc

-- Q9. Top and Bottom 3 states in Literacy Rate

drop table if exists #topstates

create table #topstates
( state nvarchar(255),topstates float
)
insert into #topstates
select state, round(avg(literacy),0) avg_literacy from indian_census_data.dbo.data1 group by state order by avg_literacy desc

select top 3 * from #topstates order by #topstates.topstates desc
--
drop table if exists #bottomstates

create table #bottomstates
( state nvarchar(255), bottomstate float
)
insert into #bottomstates
select state, round(avg(literacy),0) avg_literacy from indian_census_data.dbo.data1 group by state order by avg_literacy desc

select top 3 * from #bottomstates order by #bottomstates.bottomstate asc 
--

select * from(
select top 3 * from #topstates order by #topstates.topstates desc) a
union
select * from(
select top 3 * from #bottomstates order by #bottomstates.bottomstate asc) b

-- Error: 'There is already an object named '#topstates' in the database.' [As it is created for the first time and again we,
--		we run the complete quary then it'll throw an error because table is already created there,
--      so we have to use 'drop table concept' before creation and running the complete query]


-- Q10. States starting with letter 'A'

select distinct state from indian_census_data.dbo.data1 where lower(state) like 'a%' or lower(state) like 'b%'

-- Q11. States starting with letter 'A' and ending with letter 'D'

select distinct state from indian_census_data.dbo.data1 where lower(state) like 'a%' and lower(state) like '%m'

-- Q12. Total number of Males & Females in each state

-- Total Males and Females in Population

select d.state, sum(d.males) total_males, sum(d.females) total_females from
(select c.district, c.state, round(c.population/(c.sex_ratio+1),0) males, round((c.population*c.sex_ratio)/(c.sex_ratio+1),0) females from 
(select a.district, a.state, a.sex_ratio/1000 sex_ratio, b.population from indian_census_data.dbo.data1 a inner join indian_census_data.dbo.data2 b 
on a.district=b.district) c) d
group by d.state

-- Finding Formula for Females & Males:

-- female/males=sex_ratio ......1

-- females+males=population .......2

-- females=population-males ......3 substitute Eqa.3 into Eqa.1 

-- (population-males)=sex_ratio*males

-- population=males(sex_ratio)+1

-- males = population / (sex_ratio+1) ......Males ... substitute males into Eqa.2

-- females = population-population/(sex_ratio+1)

-- =population(1-1/((sex_ratio+1)))
-- =(population*(sex_ratio))/(sex_ratio+1) ----Final, shorten into this one.


-- Q13. Which State has the Total Highest Literacy Rate

-- Total Literacy Rate

select d.state, sum(Literate_people) total_literate_population, sum(Illiterate_people) total_illiterate_population from
(select c.district, c.state, round((c.literacy_ratio*population),0) Literate_people, round((1-c.literacy_ratio)*c.population,0) Illiterate_people from
(select a.district, a.state, a.literacy/100 literacy_ratio, b.population from indian_census_data.dbo.data1 a inner join indian_census_data.dbo.data2 b 
on a.district=b.district) c) d
group by d.state

-- Finding Formula for Females & Males:

-- total literate people/population = literate_ratio ......1

-- total literate people=literate_ratio*population

-- total illiterate people=(1-literacy ratio)*population
----------------


-- Q14. Population in Previous Census

select sum(previous_census_population) total_prev_census_pop, sum(current_census_population) total_current_census_pop from
(select d.state, sum(d.previous_census_population) previous_census_population, sum(d.current_census_population) current_census_population from
(select c.district, c.state, round(c.population/(1+growth),0) previous_census_population, c.population current_census_population from
(select a.district, a.state, a.growth growth, b.population from indian_census_data.dbo.data1 a inner join indian_census_data.dbo.data2 b 
on a.district=b.district) c) d
group by d.state) e


-- Population:
-- Count pervious population by calculating growth rate and then suntracting that rate of population from current population

-- prev_census+growth*prev_census=population
-- previous_census=population/(1+growth)

------------------------


-- Q15. Population Vs Area

select (g.total_area/g.total_prev_census_pop) as previous_census_population_vs_area, (g.total_area/total_current_census_pop) as current_census_population_vs_area from
(select q.*, r.total_area from(

select '1' as keyy, f.* from
(select sum(e.previous_census_population) total_prev_census_pop, sum(e.current_census_population) total_current_census_pop from
(select d.state, sum(d.previous_census_population) previous_census_population, sum(d.current_census_population) current_census_population from
(select c.district, c.state, round(c.population/(1+growth),0) previous_census_population, c.population current_census_population from
(select a.district, a.state, a.growth growth, b.population from indian_census_data.dbo.data1 a inner join indian_census_data.dbo.data2 b 
on a.district=b.district) c) d
group by d.state) e) f) q inner join (

select '1' as keyy, a.* from
(select sum(area_km2) total_area from indian_census_data.dbo.data2) a) r on q.keyy=r.keyy) g


-- Q16. Output Top 3 District from each State with Highest Literacy rate


select a.* from
(select district, state, literacy, rank() over(partition by state order by literacy desc) rnk 
from indian_census_data.dbo.data1) a

where a.rnk in (1, 2, 3) order by state

