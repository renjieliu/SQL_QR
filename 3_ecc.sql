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



go 

----------------------------
-- Below is the script to use CTE to mimic array[n] operation 
-- It's like generating a table dynamically, and it can be referenced in the recursive part.

-- To split the string, and generate the ordinal number, to mimic the array index
-- Note - as my current SQL server version (15.0: SQL Server 2019) does not support enable_ordinal 
-- The ROW_NUMBER wrapper can be removed with SQL server 2022, as enable_ordinal function is enabled starting from this version.

create function u_split_string( 
@input varchar(max)
, @delimiter char(1)
)
returns table as return 
with cte as (
select 
id = 1 
, curr = left(@input, CHARINDEX(@delimiter, @input)-1)  
, rem = right(@input, len(@input)-CHARINDEX(@delimiter, @input)) 
where CHARINDEX (@delimiter, @input) != 0	
union all 
select id + 1, curr = left(rem, CHARINDEX(@delimiter, rem)-1), right(rem, len(rem)-CHARINDEX(@delimiter, rem)) from cte
where CHARINDEX(@delimiter, rem) != 0 
)
select 
id = ROW_NUMBER() over (order by id )
, val 
, rem 
from (

	select id, val = curr, rem from cte 
	where curr != ''
	union all 
	select id+1, rem, '' from cte
	where id = (select max(id) from cte)
	and rem != ''
	union all 
	select id = -1
	, @input
	, ''
	where CHARINDEX (@delimiter, @input) = 0 	
) dummy_name  

go 


---Testing code

-- below code is something like 
/* 

arr = [1]
for i in range(10):
    print(arr[i])
    arr.append(i)

*/ 


; with cte as
(
	select n = 1
		, curr = (select val from dbo.u_split_string('1', ',') where id = 1 )
        , og = cast('1' as varchar(max))
	union all 
	select 
	n+1
	, curr = (select val from dbo.u_split_string(og + ',' + cast(n+1 as varchar(max)), ',') where id = n + 1  )
	, og + ', ' + cast(n+1 as varchar(max))
    from cte 
	where n < 10 

)
select * from cte 

 


----------------------------
