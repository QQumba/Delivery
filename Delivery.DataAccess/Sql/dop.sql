create view check_expensive_good 
    as
select g.name
from sales s
join goods g on s.good_id = g.good_id
group by s.sales_id
having max(g.price);