drop table if exists #gf 

; with cte as 
(
    select id = 0, val = 1 
    union all 
    select id + 1
        , case when val*2 >=256 then (val * 2) ^ 285  -- 0x11D
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


select * from #generator

drop table if exists #ecc_length 



select ecc_length = 10 into #ecc_length











----------------------------------------------
--Todo - how to compute ECC_length? 
drop table if exists #data_poly

select id =cast( '1' as int) , n = cast('72' as int)
into #data_poly 
 union all
select '2' , '69' union all
select '3' , '76' union all
select '4' , '76' union all
select '5' , '79' union all
select '6' , '32' union all
select '7' , '87' union all
select '8' , '79' union all
select '9' , '82' union all
select '10' , '76' union all
select '11' , '68' union all
select '12' , '0' union all
select '13' , '0' union all
select '14' , '0' union all
select '15' , '0' union all
select '16' , '0' union all
select '17' , '0' union all
select '18' , '0' union all
select '19' , '0' union all
select '20' , '0' union all
select '21' , '0' 




select * from #data_poly 
