
-- Basic inspection of the dataset
select * from athletes;
select distinct team from athletes;
select distinct sex from athletes;
select distinct id from athletes;
select min(height) as min_height, max(height) as max_height, avg(height) as avg_height from athletes;
select min(weight) as min_weight, max(weight) as max_weight, avg(weight) as avg_weight from athletes;
select min(year) as firstevent, max( year) as lastevent from athlete_events
select count (distinct city) as city, count(distinct sport) as sports, count(distinct event) as [events],count(medal) as medals
from athlete_events

--Q1) which team has won the maximum gold medals over the years?

select top 1 a.team, count(ae.medal) as goldmedals from athletes a
inner join athlete_events ae
on a.id=ae.athlete_id
where ae.medal='Gold'
group by a.team
order by goldmedals desc

/*Q2 for each team print total silver medals and year in which they won maximum silver medal..output 3 columns
team,total_silver_medals, year_of_max_silver*/

with cte as (
select a.team,ae.year , count(distinct event) as silver_medals
,rank() over(partition by team order by count(distinct event) desc) as rn
from athlete_events ae
inner join athletes a on ae.athlete_id=a.id
where medal='Silver'
group by a.team,ae.year)
select team,sum(silver_medals) as total_silver_medals, max(case when rn=1 then year end) as  year_of_max_silver
from cte
group by team;

/* Q3) Which player has won maximum gold medals  amongst the players 
which have won only gold medal (never won silver or bronze) over the years*/

with cte as 
(select [name],medal from athlete_events ae
inner join athletes a on ae.athlete_id=a.id)
select top 1 name, count(1) as total_gold_medals
from cte
where name not in ( select distinct name from cte where medal in ('Silver', 'Bronze'))
and medal='Gold'
group by [name]
order by total_gold_medals desc

/*Q4) In each year which player has won maximum gold medal . Write a query to print year,player name 
and no of golds won in that year . In case of a tie print comma separated player names*/

with cte as 
(select name,year, count(event) as goldmedals
from athletes a
inner join athlete_events ae
on a.id=ae.athlete_id
where medal='Gold'
group by name,year)
select year,goldmedals,STRING_AGG (name, ',') as players
from
(select cte.*, rank() over (partition by year order by goldmedals desc) as rnk from cte)a
where rnk=1
group by year,goldmedals;

/* Q5) In which event and year India has won its first gold medal,first silver medal and first bronze medal
print 3 columns medal,year,sport*/

with cte as
(select a.team,ae.medal,ae.year,ae.event,count(medal) as wonmedals from athletes a
inner join athlete_events ae
on a.id=ae.athlete_id
where ae.medal!= 'NA'and a.team='India'
group by a.team,ae.medal,ae.year,ae.event)
select team,medal,event,year from(
select cte.*,rank() over (partition by medal order by year asc) as rnk from cte)a
where rnk=1

--Alternate approach
select distinct * from (
select medal,year,event,rank() over(partition by medal order by year) rn
from athlete_events ae
inner join athletes a on ae.athlete_id=a.id
where team='India' and medal != 'NA'
) A
where rn=1;

--Q6) find players who won gold medal in summer and winter olympics both.

select a.name,ae.athlete_id from athlete_events ae 
inner join athletes a on ae.athlete_id=a.id
where medal='Gold'
group by a.name,ae.athlete_id
having count(distinct season)=2;

/*Q7) find players who won gold, silver and bronze medal in a single olympics.
print player name along with year.*/

select ae.year,a.name
from athletes a
inner join athlete_events ae
on a.id=ae.athlete_id
where medal != 'NA'
group by ae.year ,a.name
having count(distinct medal)=3

/*Q8) find players who have won gold medals in consecutive 3 summer olympics in the same event . 
Consider only olympics 2000 onwards. Assume summer olympics happens every 4 year starting 2000.
print player name and event name.*/

select * from athlete_events;
select * from athletes;

with cte as (
select name,year,event
from athletes a
inner join athlete_events ae
on a.id=ae.athlete_id
where year>=2000 and medal='Gold' and season='Summer'
group by name,year,event)
select * from (
select *, lag(year,1) over (partition by name,event order by year) as prev_year,
lead(year,1) over (partition by name,event order by year) as next_year from cte) a
where year=prev_year+4 and year=next_year-4;





























