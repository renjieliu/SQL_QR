-- using QR code version 2 as a starter, version 1 does not have any alignment pattern.
-- this is to have 3 position detection patterns (PDP) on the corners
-- PDP on the left upper is PDP-1, on the right upper is PDP-2, on the left lower is PDP-3
-- with a smaller squares on the right bottom for alignment, AP-4
-- the alignment pattern differs from version to version

-- '-' for empty
-- 'p' for the PDP 
-- 's' for separators
-- ''


--  select nchar('9632')

drop table if exists #canvas 

; with cte as 

(select id = 1, cell = REPLICATE(N'_', 21)
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
update #canvas set cell = REPLICATE('p', @pdp) + right(cell, @totalpixel - @pdp) where id = 1 
-- bottom line of PDP-1
update #canvas set cell = REPLICATE('p', @pdp) + right(cell, @totalpixel - @pdp) where id = 7 
-- left line of PDP-1
update #canvas set cell = 'p' + right(cell, @totalpixel - 1) where id between 2 and 6 
-- right line of PDP-1
update #canvas set cell = left(cell, @pdp - 1) + 'p' + right(cell, @totalpixel - @pdp) where id between 2 and 6 
-- inner circle of PDP-1
update #canvas set cell = left(cell, 2) + REPLICATE('p', 3) + right(cell, @totalpixel - 2-3) where id BETWEEN 3 and 5


-- adding separators for PDP 1 

-- bottom line of PDP-1
update #canvas set cell = REPLICATE('s', @pdp+1) + right(cell, @totalpixel - (@pdp+1) ) where id = @pdp+1 
-- right line of PDP-1
update #canvas set cell = left(cell, @pdp) + 's' + right(cell, @totalpixel - (@pdp+1) ) where id between 1 and @pdp
-- boundary of the inner circle of PDP-1 
update #canvas set cell = replace (left(cell, @pdp), '_', 's') + right(cell, len(cell)-@pdp) where id between 2 and @pdp-1 -- only update the left @pdp characters, if it's _ , then it's a separator




-- PDP 2
--top line of PDP-2
update #canvas set cell = SUBSTRING(cell, 1, @totalpixel - @pdp) + REPLICATE('p', @pdp)  where id = 1 
-- bottom line of PDP-2
update #canvas set cell = SUBSTRING(cell, 1, @totalpixel - @pdp) + REPLICATE('p', @pdp) where id = 7 
-- left line of PDP-2
update #canvas set cell = SUBSTRING(cell, 1, @totalpixel - @pdp) + 'p' + right(cell, @pdp - 1) where id between 2 and 6 
-- right line of PDP-2
update #canvas set cell = left(cell, @totalpixel - 1 ) + 'p' where id between 2 and 6 
-- inner circle of PDP-2
update #canvas set cell = left(cell, @totalpixel - 2 - 3) + REPLICATE('p', 3) + right(cell, 2) where id BETWEEN 3 and 5

-- adding separators for PDP 2 

-- bottom line of PDP-2
update #canvas set cell = left(cell, @totalpixel - (@pdp+1)) + REPLICATE('s', @pdp+1) where id = @pdp+1 
-- left line of PDP-2
update #canvas set cell = left(cell, @totalpixel - (@pdp+1)) + 's' + right(cell, @pdp ) where id between 1 and @pdp
-- boundary of the inner circle of PDP-2 
update #canvas set cell = left(cell, len(cell)- (@pdp+1) ) + replace (right(cell, @pdp+1), '_', 's') where id between 2 and @pdp-1 -- only update the left @pdp characters, if it's _ , then it's a separator



-- PDP 3
--top line of PDP-3
update #canvas set cell = REPLICATE('p', @pdp) + right(cell, @totalpixel - @pdp) where id = @totalpixel-@pdp+1 
-- bottom line of PDP-3
update #canvas set cell = REPLICATE('p', @pdp) + right(cell, @totalpixel - @pdp) where id = @totalpixel 
-- left line of PDP-3
update #canvas set cell = 'p' + right(cell, @totalpixel - 1) where id between @totalpixel-@pdp+2 and @totalpixel-@pdp+6 
-- right line of PDP-3
update #canvas set cell = left(cell, @pdp - 1) + 'p' + right(cell, @totalpixel - @pdp) where id between @totalpixel-@pdp+2 and @totalpixel-@pdp+6 
-- inner circle of PDP-3
update #canvas set cell = left(cell, 2) + REPLICATE('p', 3) + right(cell, @totalpixel - 2-3) where id BETWEEN @totalpixel-@pdp+3 and @totalpixel-@pdp+5


--adding separators for PDP 3

-- upper line of PDP-3
update #canvas set cell = REPLICATE('s', @pdp+1) + right(cell, @totalpixel - (@pdp+1) ) where id = @totalpixel-@pdp 
-- right line of PDP-3
update #canvas set cell = left(cell, @pdp) + 's' + right(cell, @totalpixel - (@pdp+1) ) where id between @totalpixel-@pdp and @totalpixel
-- boundary of the inner circle of PDP-3 
update #canvas set cell = replace(left(cell, @pdp+1), '_', 's') + right(cell, @totalpixel - (@pdp+1)) where id between @totalpixel-(@pdp-1) and @totalpixel-1  -- only update the left @pdp characters, if it's _ , then it's a separator



select * from #canvas

-- AP-4 -- need to check the positions 





-- update #canvas set cell = replace(cell, 'p', nchar(9632))


-- declare @totalpixel int = 21 
-- declare @pdp int = 7

-- --top line of PDP-1
-- update #canvas set cell = substring(cell, 0, 0)  +  REPLICATE('p', @pdp)  + substring(cell, @pdp + 1 , @totalpixel - @pdp) 

-- -- bottom line of PDP-1
-- update #canvas set cell = substring(cell, 0, @pdp * @totalpixel)  +  REPLICATE('p', 7)  + substring(cell, @totalpixel * @pdp + @pdp+ 1, @totalpixel -  @pdp * @totalpixel) 

-- -- left line of PDP-1
-- update #canvas set cell = substring(cell, 0, 1*@totalpixel)  +  REPLICATE('p', 1)  + substring(cell, @totalpixel*2+2, @totalpixel - 1*@totalpixel) 
-- update #canvas set cell = substring(cell, 0, 2*@totalpixel)  +  REPLICATE('p', 1)  + substring(cell, @totalpixel*3+2, @totalpixel - 2*@totalpixel) 
-- update #canvas set cell = substring(cell, 0, 3*@totalpixel)  +  REPLICATE('p', 1)  + substring(cell, @totalpixel*4+2, @totalpixel - 3*@totalpixel) 
-- update #canvas set cell = substring(cell, 0, 4*@totalpixel)  +  REPLICATE('p', 1)  + substring(cell, @totalpixel*5+2, @totalpixel - 4*@totalpixel) 
-- update #canvas set cell = substring(cell, 0, 5*@totalpixel)  +  REPLICATE('p', 1)  + substring(cell, @totalpixel*6+2, @totalpixel - 5*@totalpixel) 



-- right line of PDP-1




 