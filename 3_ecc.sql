drop table if exists #gf 

; with cte as 
(
    select id = 0, val = 1 
    union all 
    select id + 1
        , case when val*2 >=256 then (val * 2) ^ 285  -- 11d 
                else val*2 
            end  
    from cte  
    where  id < 255
)
select id, val into #gf from cte
order by 1 desc
option (maxrecursion 0 )


drop table if exists #gf_inv

select id = val, val = id into #gf_inv from #gf 

update #gf_inv set id = 0 where val = 0; 


drop table if exists #generator 

select n = 1 into #generator














