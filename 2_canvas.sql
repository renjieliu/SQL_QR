-- using QR code version 2 as a starter, version 1 does not have any alignment pattern.
-- this is to have 3 position detection patterns (PDP) on the corners
-- PDP on the left upper is PDP-1, on the right upper is PDP-2, on the left lower is PDP-3
-- with a smaller squares on the right bottom for alignment, AP-4
-- the alignment pattern differs from version to version

-- '-' for empty
-- 'F' for the finder patern 
-- 'S' for separators
-- 'T' for timing patterns-1 
-- 't' for timing patterns-0
-- 'D' for the dark module

--  select nchar('9632')

drop table if exists #canvas 


declare @version_num int = 10

drop table if exists #versions 

; with cte as 
(select v= 1, n=21
union all
select v+1, n+4 from cte -- from version 1 to version 40, each one has 4 more blocks
where v < 40
) 
select * into #versions 
from cte 
option(maxrecursion  0)


declare @blocks int = (select n from #versions where v = @version_num) 
declare @finder int = 7

; with cte as 

(select id = 1, cell = REPLICATE(N'_', @blocks)
union all 
select id + 1, cell from cte 
where id < @blocks
)

select *
into #canvas 
from cte
option (maxrecursion 0)




-- PDP 1
--top line of PDP-1
update #canvas set cell = REPLICATE('F', @finder) + right(cell, @blocks - @finder) where id = 1 
-- bottom line of PDP-1
update #canvas set cell = REPLICATE('F', @finder) + right(cell, @blocks - @finder) where id = 7 
-- left line of PDP-1
update #canvas set cell = 'F' + right(cell, @blocks - 1) where id between 2 and 6 
-- right line of PDP-1
update #canvas set cell = left(cell, @finder - 1) + 'F' + right(cell, @blocks - @finder) where id between 2 and 6 
-- inner circle of PDP-1
update #canvas set cell = left(cell, 2) + REPLICATE('F', 3) + right(cell, @blocks - 2-3) where id BETWEEN 3 and 5


-- adding separators for PDP 1 

-- bottom line of PDP-1
update #canvas set cell = REPLICATE('S', @finder+1) + right(cell, @blocks - (@finder+1) ) where id = @finder+1 
-- right line of PDP-1
update #canvas set cell = left(cell, @finder) + 'S' + right(cell, @blocks - (@finder+1) ) where id between 1 and @finder
-- boundary of the inner circle of PDP-1 
update #canvas set cell = replace (left(cell, @finder), '_', 'S') + right(cell, len(cell)-@finder) where id between 2 and @finder-1 -- only update the left @finder characters, if it's _ , then it's a separator




-- PDP 2
--top line of PDP-2
update #canvas set cell = SUBSTRING(cell, 1, @blocks - @finder) + REPLICATE('F', @finder)  where id = 1 
-- bottom line of PDP-2
update #canvas set cell = SUBSTRING(cell, 1, @blocks - @finder) + REPLICATE('F', @finder) where id = 7 
-- left line of PDP-2
update #canvas set cell = SUBSTRING(cell, 1, @blocks - @finder) + 'F' + right(cell, @finder - 1) where id between 2 and 6 
-- right line of PDP-2
update #canvas set cell = left(cell, @blocks - 1 ) + 'F' where id between 2 and 6 
-- inner circle of PDP-2
update #canvas set cell = left(cell, @blocks - 2 - 3) + REPLICATE('F', 3) + right(cell, 2) where id BETWEEN 3 and 5

-- adding separators for PDP 2 

-- bottom line of PDP-2
update #canvas set cell = left(cell, @blocks - (@finder+1)) + REPLICATE('S', @finder+1) where id = @finder+1 
-- left line of PDP-2
update #canvas set cell = left(cell, @blocks - (@finder+1)) + 'S' + right(cell, @finder ) where id between 1 and @finder
-- boundary of the inner circle of PDP-2 
update #canvas set cell = left(cell, len(cell)- (@finder+1) ) + replace (right(cell, @finder+1), '_', 'S') where id between 2 and @finder-1 -- only update the left @finder characters, if it's _ , then it's a separator



-- PDP 3
--top line of PDP-3
update #canvas set cell = REPLICATE('F', @finder) + right(cell, @blocks - @finder) where id = @blocks-@finder+1 
-- bottom line of PDP-3
update #canvas set cell = REPLICATE('F', @finder) + right(cell, @blocks - @finder) where id = @blocks 
-- left line of PDP-3
update #canvas set cell = 'F' + right(cell, @blocks - 1) where id between @blocks-@finder+2 and @blocks-@finder+6 
-- right line of PDP-3
update #canvas set cell = left(cell, @finder - 1) + 'F' + right(cell, @blocks - @finder) where id between @blocks-@finder+2 and @blocks-@finder+6 
-- inner circle of PDP-3
update #canvas set cell = left(cell, 2) + REPLICATE('F', 3) + right(cell, @blocks - 2-3) where id BETWEEN @blocks-@finder+3 and @blocks-@finder+5


--adding separators for PDP 3

-- upper line of PDP-3
update #canvas set cell = REPLICATE('S', @finder+1) + right(cell, @blocks - (@finder+1) ) where id = @blocks-@finder 
-- right line of PDP-3
update #canvas set cell = left(cell, @finder) + 'S' + right(cell, @blocks - (@finder+1) ) where id between @blocks-@finder and @blocks
-- boundary of the inner circle of PDP-3 
update #canvas set cell = replace(left(cell, @finder+1), '_', 'S') + right(cell, @blocks - (@finder+1)) where id between @blocks-(@finder-1) and @blocks-1  -- only update the left @finder characters, if it's _ , then it's a separator


-- Adding timing patterns

-- vertial, mark T 
update #canvas set cell = left(cell, 6) + 'T' + right (cell, @blocks - 7) where id % 2 = 1 and id between 9 and @blocks - 8  
-- vertial, mark t 
update #canvas set cell = left(cell, 6) + 't' + right (cell, @blocks - 7) where id % 2 = 0 and id between 9 and @blocks - 8 

-- horizontal, mark Tt
update #canvas set cell = left(cell, 8) + left(REPLICATE('Tt', @blocks), @blocks - 16 ) + right (cell, 8)   where id = @finder -- just let it repeat, and take the numbers to fill the gap, which is 16 for all the versions



--plot the dark module 
update #canvas set cell = left(cell, 8) + 'D' + right(cell, @blocks - 9) where id = @blocks - 7



-- AP-4 -- get the table for position info 

drop table if exists #version_alignment_points

;with cte as 
(
select v = '2' , p1 = '6' ,p2 = '18' ,p3 = '0' ,p4 = '0' ,p5 = '0' ,p6 = '0' ,p7 = '0'  
 union all
select '3' ,'6' ,'22' ,'0' ,'0' ,'0' ,'0' ,'0'  
 union all
select '4' ,'6' ,'26' ,'0' ,'0' ,'0' ,'0' ,'0'  
 union all
select '5' ,'6' ,'30' ,'0' ,'0' ,'0' ,'0' ,'0'  
 union all
select '6' ,'6' ,'34' ,'0' ,'0' ,'0' ,'0' ,'0'  
 union all
select '7' ,'6' ,'22' ,'38' ,'0' ,'0' ,'0' ,'0'  
 union all
select '8' ,'6' ,'24' ,'42' ,'0' ,'0' ,'0' ,'0'  
 union all
select '9' ,'6' ,'26' ,'46' ,'0' ,'0' ,'0' ,'0'  
 union all
select '10' ,'6' ,'28' ,'50' ,'0' ,'0' ,'0' ,'0'  
 union all
select '11' ,'6' ,'30' ,'54' ,'0' ,'0' ,'0' ,'0'  
 union all
select '12' ,'6' ,'32' ,'58' ,'0' ,'0' ,'0' ,'0'  
 union all
select '13' ,'6' ,'34' ,'62' ,'0' ,'0' ,'0' ,'0'  
 union all
select '14' ,'6' ,'26' ,'46' ,'66' ,'0' ,'0' ,'0'  
 union all
select '15' ,'6' ,'26' ,'48' ,'70' ,'0' ,'0' ,'0'  
 union all
select '16' ,'6' ,'26' ,'50' ,'74' ,'0' ,'0' ,'0'  
 union all
select '17' ,'6' ,'30' ,'54' ,'78' ,'0' ,'0' ,'0'  
 union all
select '18' ,'6' ,'30' ,'56' ,'82' ,'0' ,'0' ,'0'  
 union all
select '19' ,'6' ,'30' ,'58' ,'86' ,'0' ,'0' ,'0'  
 union all
select '20' ,'6' ,'34' ,'62' ,'90' ,'0' ,'0' ,'0'  
 union all
select '21' ,'6' ,'28' ,'50' ,'72' ,'94' ,'0' ,'0'  
 union all
select '22' ,'6' ,'26' ,'50' ,'74' ,'98' ,'0' ,'0'  
 union all
select '23' ,'6' ,'30' ,'54' ,'78' ,'102' ,'0' ,'0'  
 union all
select '24' ,'6' ,'28' ,'54' ,'80' ,'106' ,'0' ,'0'  
 union all
select '25' ,'6' ,'32' ,'58' ,'84' ,'110' ,'0' ,'0'  
 union all
select '26' ,'6' ,'30' ,'58' ,'86' ,'114' ,'0' ,'0'  
 union all
select '27' ,'6' ,'34' ,'62' ,'90' ,'118' ,'0' ,'0'  
 union all
select '28' ,'6' ,'26' ,'50' ,'74' ,'98' ,'122' ,'0'  
 union all
select '29' ,'6' ,'30' ,'54' ,'78' ,'102' ,'126' ,'0'  
 union all
select '30' ,'6' ,'26' ,'52' ,'78' ,'104' ,'130' ,'0'  
 union all
select '31' ,'6' ,'30' ,'56' ,'82' ,'108' ,'134' ,'0'  
 union all
select '32' ,'6' ,'34' ,'60' ,'86' ,'112' ,'138' ,'0'  
 union all
select '33' ,'6' ,'30' ,'58' ,'86' ,'114' ,'142' ,'0'  
 union all
select '34' ,'6' ,'34' ,'62' ,'90' ,'118' ,'146' ,'0'  
 union all
select '35' ,'6' ,'30' ,'54' ,'78' ,'102' ,'126' ,'150'  
 union all
select '36' ,'6' ,'24' ,'50' ,'76' ,'102' ,'128' ,'154'  
 union all
select '37' ,'6' ,'28' ,'54' ,'80' ,'106' ,'132' ,'158'  
 union all
select '38' ,'6' ,'32' ,'58' ,'84' ,'110' ,'136' ,'162'  
 union all
select '39' ,'6' ,'26' ,'54' ,'82' ,'110' ,'138' ,'166'  
 union all
select '40' ,'6' ,'30' ,'58' ,'86' ,'114' ,'142' ,'170'  
 


) 
select ver = cast(v as int), pos = cast(p1 as int)
into #version_alignment_points
 from cte 
union all
select v, p = cast(p2 as int) from cte 
union all
select v, p = cast(p3 as int) from cte 
union all
select v, p = cast(p4 as int) from cte 
union all
select v, p = cast(p5 as int) from cte 
union all
select v, p = cast(p6 as int) from cte 
union all
select v, p = cast(p7 as int) from cte 


delete from #version_alignment_points where pos = 0 


drop table if exists #version_alignment_location

select
p1.ver
, point_1 = p1.pos
, point_2 = p2.pos 
into #version_alignment_location
from 
#version_alignment_points p1
inner join #version_alignment_points p2 on p1.ver = p2.ver
order by 1 


-- select * from #version_alignment_location
-- where ver = 10
-- order by 1, 2, 3 


-- next is to check for each point, if it's overlapping with the finder pattern




select * from #canvas



-- update #canvas set cell = replace(cell, 'F', nchar(9632))


-- declare @blocks int = 21 
-- declare @finder int = 7

-- --top line of PDP-1
-- update #canvas set cell = substring(cell, 0, 0)  +  REPLICATE('F', @finder)  + substring(cell, @finder + 1 , @blocks - @finder) 

-- -- bottom line of PDP-1
-- update #canvas set cell = substring(cell, 0, @finder * @blocks)  +  REPLICATE('F', 7)  + substring(cell, @blocks * @finder + @finder+ 1, @blocks -  @finder * @blocks) 

-- -- left line of PDP-1
-- update #canvas set cell = substring(cell, 0, 1*@blocks)  +  REPLICATE('F', 1)  + substring(cell, @blocks*2+2, @blocks - 1*@blocks) 
-- update #canvas set cell = substring(cell, 0, 2*@blocks)  +  REPLICATE('F', 1)  + substring(cell, @blocks*3+2, @blocks - 2*@blocks) 
-- update #canvas set cell = substring(cell, 0, 3*@blocks)  +  REPLICATE('F', 1)  + substring(cell, @blocks*4+2, @blocks - 3*@blocks) 
-- update #canvas set cell = substring(cell, 0, 4*@blocks)  +  REPLICATE('F', 1)  + substring(cell, @blocks*5+2, @blocks - 4*@blocks) 
-- update #canvas set cell = substring(cell, 0, 5*@blocks)  +  REPLICATE('F', 1)  + substring(cell, @blocks*6+2, @blocks - 5*@blocks) 



-- right line of PDP-1




 