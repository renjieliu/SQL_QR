-- this is to have 3 position detection patterns (PDP) on the corners
-- PDP on the left upper is PDP-1, on the right upper is PDP-2, on the left lower is PDP-3
-- with a smaller squares on the right bottom for alignment




--  select nchar('9632')

drop table if exists #canvas 

; with cte as 

(select id = 1, cell = REPLICATE(N'0', 21)
union all 
select id + 1, cell from cte 
where id < 21
)

select *
into #canvas 
from cte
option (maxrecursion 0)



declare @totalpixel int = 21 
declare @pdp int = 7

-- PDP 1
--top line of PDP-1
update #canvas set cell = REPLICATE('1', @pdp) + right(cell, @totalpixel - @pdp) where id = 1 
-- bottom line of PDP-1
update #canvas set cell = REPLICATE('1', @pdp) + right(cell, @totalpixel - @pdp) where id = 7 
-- left line of PDP-1
update #canvas set cell = '1' + right(cell, @totalpixel - 1) where id between 2 and 6 
-- right line of PDP-1
update #canvas set cell = left(cell, @pdp - 1) + '1' + right(cell, @totalpixel - @pdp) where id between 2 and 6 
-- inner circle of PDP-1
update #canvas set cell = left(cell, 2) + REPLICATE('1', 3) + right(cell, @totalpixel - 2-3) where id BETWEEN 3 and 5



-- PDP 2
--top line of PDP-2
update #canvas set cell = SUBSTRING(cell, 1, @totalpixel - @pdp) + REPLICATE('1', @pdp)  where id = 1 
-- bottom line of PDP-2
update #canvas set cell = SUBSTRING(cell, 1, @totalpixel - @pdp) + REPLICATE('1', @pdp) where id = 7 
-- left line of PDP-2
update #canvas set cell = SUBSTRING(cell, 1, @totalpixel - @pdp) + '1' + right(cell, @pdp - 1) where id between 2 and 6 
-- right line of PDP-2
update #canvas set cell = left(cell, @totalpixel - 1 ) + '1' where id between 2 and 6 
-- inner circle of PDP-2
update #canvas set cell = left(cell, @totalpixel - 2 - 3) + REPLICATE('1', 3) + right(cell, 2) where id BETWEEN 3 and 5



-- PDP 3
--top line of PDP-3
update #canvas set cell = REPLICATE('1', @pdp) + right(cell, @totalpixel - @pdp) where id = @totalpixel-@pdp+1 
-- bottom line of PDP-3
update #canvas set cell = REPLICATE('1', @pdp) + right(cell, @totalpixel - @pdp) where id = @totalpixel 
-- left line of PDP-3
update #canvas set cell = '1' + right(cell, @totalpixel - 1) where id between @totalpixel-@pdp+2 and @totalpixel-@pdp+6 
-- right line of PDP-3
update #canvas set cell = left(cell, @pdp - 1) + '1' + right(cell, @totalpixel - @pdp) where id between @totalpixel-@pdp+2 and @totalpixel-@pdp+6 
-- inner circle of PDP-3
update #canvas set cell = left(cell, 2) + REPLICATE('1', 3) + right(cell, @totalpixel - 2-3) where id BETWEEN @totalpixel-@pdp+3 and @totalpixel-@pdp+5


-- PDP-4 -- need to check the positions 





-- update #canvas set cell = replace(cell, '1', nchar(9632))


-- declare @totalpixel int = 21 
-- declare @pdp int = 7

-- --top line of PDP-1
-- update #canvas set cell = substring(cell, 0, 0)  +  REPLICATE('1', @pdp)  + substring(cell, @pdp + 1 , @totalpixel - @pdp) 

-- -- bottom line of PDP-1
-- update #canvas set cell = substring(cell, 0, @pdp * @totalpixel)  +  REPLICATE('1', 7)  + substring(cell, @totalpixel * @pdp + @pdp+ 1, @totalpixel -  @pdp * @totalpixel) 

-- -- left line of PDP-1
-- update #canvas set cell = substring(cell, 0, 1*@totalpixel)  +  REPLICATE('1', 1)  + substring(cell, @totalpixel*2+2, @totalpixel - 1*@totalpixel) 
-- update #canvas set cell = substring(cell, 0, 2*@totalpixel)  +  REPLICATE('1', 1)  + substring(cell, @totalpixel*3+2, @totalpixel - 2*@totalpixel) 
-- update #canvas set cell = substring(cell, 0, 3*@totalpixel)  +  REPLICATE('1', 1)  + substring(cell, @totalpixel*4+2, @totalpixel - 3*@totalpixel) 
-- update #canvas set cell = substring(cell, 0, 4*@totalpixel)  +  REPLICATE('1', 1)  + substring(cell, @totalpixel*5+2, @totalpixel - 4*@totalpixel) 
-- update #canvas set cell = substring(cell, 0, 5*@totalpixel)  +  REPLICATE('1', 1)  + substring(cell, @totalpixel*6+2, @totalpixel - 5*@totalpixel) 



-- right line of PDP-1

select * from #canvas 

-- TODO - 


 