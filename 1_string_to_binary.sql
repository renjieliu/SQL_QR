declare @txt nvarchar(max) = 'ABCD'

drop table if exists #base 

select c = convert(varchar(max), cast(@txt as varbinary(max)), 2 )
into #base 

drop table if exists #hex_bin_lkp

; with cte as (
SELECT h = '0', b = '0000' 
UNION ALL

 SELECT '1', '0001' UNION ALL

 SELECT '2', '0010' UNION ALL

 SELECT '3', '0011' UNION ALL

 SELECT '4', '0100' UNION ALL 

 SELECT '5', '0101' UNION ALL

 SELECT '6', '0110' UNION ALL

 SELECT '7', '0111' UNION ALL 

 SELECT '8', '1000' UNION ALL

 SELECT '9', '1001' UNION ALL

 SELECT 'A', '1010' UNION ALL 

 SELECT 'B', '1011' UNION ALL

 SELECT 'C', '1100' UNION ALL

 SELECT 'D', '1101' UNION ALL 

 SELECT 'E', '1110' UNION ALL 

 SELECT 'F', '1111'
)
select
h = a.h + b.h + c.h + d.h 
, b = a.b + b.b + c.b + d.b 
into #hex_bin_lkp   
from cte a, cte b, cte c, cte d


drop table if exists #bin_form

; with cte as 
(
    select id = 1, curr = substring(c, 3, 2) + left(c, 2), rem = right(c, len(c) - 4) from #base
    union all 
    select id + 1 , substring(rem, 3, 2) + left(rem, 2), rem =  right(rem, len(rem) - 4)   from cte 
    where len(rem) > 0 
)
select id, curr, bin_form = cast(hb.b as varchar(max))
into #bin_form
from cte c inner join #hex_bin_lkp hb on c.curr = hb.h
option(maxrecursion 0)




-- Here is the binary form of the string
select res = string_agg(bin_form, '') within group(order by id) from #bin_form 




