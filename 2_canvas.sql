-- this is the initial version - goal is to make the code work, and it can be scanned

-- ================= Future =================
-- * Check the text to determine if it's type 1, 2, 3 or 4
-- * Check the text length to determine the version number -- https://www.thonky.com/qr-code-tutorial/character-capacities 
-- * Apply different mask 
-- * Calculate the penalty score
-- ==========================================





-- using QR code version 2 as a starter, version 1 does not have any alignment pattecanvas_rn.
-- this is to have 3 position detection pattecanvas_rns (PDP) on the cocanvas_rners
-- PDP on the left upper is PDP-1, on the right upper is PDP-2, on the left lower is PDP-3
-- with a smaller squares on the right bottom for alignment, AP-4
-- the alignment pattecanvas_rn differs from version to version


-- convention - all the lower case letter will be marked as 0, and upper case will be marked as 1 in the end 

-- '-' for empty
-- 'F' for the finder patecanvas_rn  
-- 's' for separators  
-- 'T' for timing pattecanvas_rns-1
-- 't' for timing pattecanvas_rns-0
-- 'D' for the dark module
-- 'A' for alignment 
-- 'a' for inside of alignment
-- 'r' for reserved areas


--  select nchar('9632')
rollback 

drop table if exists #canvas 


declare @version_num int = 5

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


declare @blocks int = (select cast(n as int) from #versions where v = @version_num) 
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
update #canvas set cell = REPLICATE('s', @finder+1) + right(cell, @blocks - (@finder+1) ) where id = @finder+1 
-- right line of PDP-1
update #canvas set cell = left(cell, @finder) + 's' + right(cell, @blocks - (@finder+1) ) where id between 1 and @finder
-- boundary of the inner circle of PDP-1 
update #canvas set cell = replace (left(cell, @finder), '_', 's') + right(cell, len(cell)-@finder) where id between 2 and @finder-1 -- only update the left @finder characters, if it's _ , then it's a separator




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
update #canvas set cell = left(cell, @blocks - (@finder+1)) + REPLICATE('s', @finder+1) where id = @finder+1 
-- left line of PDP-2
update #canvas set cell = left(cell, @blocks - (@finder+1)) + 's' + right(cell, @finder ) where id between 1 and @finder
-- boundary of the inner circle of PDP-2 
update #canvas set cell = left(cell, len(cell)- (@finder+1) ) + replace (right(cell, @finder+1), '_', 's') where id between 2 and @finder-1 -- only update the left @finder characters, if it's _ , then it's a separator



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
update #canvas set cell = REPLICATE('s', @finder+1) + right(cell, @blocks - (@finder+1) ) where id = @blocks-@finder 
-- right line of PDP-3
update #canvas set cell = left(cell, @finder) + 's' + right(cell, @blocks - (@finder+1) ) where id between @blocks-@finder and @blocks
-- boundary of the inner circle of PDP-3 
update #canvas set cell = replace(left(cell, @finder+1), '_', 's') + right(cell, @blocks - (@finder+1)) where id between @blocks-(@finder-1) and @blocks-1  -- only update the left @finder characters, if it's _ , then it's a separator


-- Adding timing pattecanvas_rns

-- vertial, mark T 
update #canvas set cell = left(cell, 6) + 'T' + right (cell, @blocks - 7) where id % 2 = 1 and id between 9 and @blocks - 8  
-- vertial, mark t 
update #canvas set cell = left(cell, 6) + 't' + right (cell, @blocks - 7) where id % 2 = 0 and id between 9 and @blocks - 8 

-- horizontal, mark Tt
update #canvas set cell = left(cell, 8) + left(REPLICATE('Tt', @blocks), @blocks - 16 ) + right (cell, 8)   where id = @finder -- just let it repeat, and take the numbers to fill the gap, which is 16 for all the versions



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

select 
ver = cast(v as int), pos = cast(p1 as int) + 1  -- the location in the table is 0-based. but my row id is 1-based.
into #version_alignment_points
 from cte 
union all
select v, p = cast(p2 as int)+ 1 from cte where cast(p2 as int) <> 0
union all
select v, p = cast(p3 as int)+ 1  from cte where cast(p3 as int) <> 0
union all
select v, p = cast(p4 as int)+ 1  from cte where cast(p4 as int) <> 0
union all
select v, p = cast(p5 as int)+ 1  from cte where cast(p5 as int) <> 0
union all
select v, p = cast(p6 as int)+ 1  from cte where cast(p6 as int) <> 0
union all
select v, p = cast(p7 as int)+ 1  from cte where cast(p7 as int) <> 0


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



-- get all the blocks where it's being taken by the finder or separator pattecanvas_rn

-- put the matrix into one flat string, and find the location of all the F and s - Finder and separator

-- declare @flat nvarchar(max) = (select flat = STRING_AGG(cell,'') within group(order by id ) from #canvas )
drop table if exists #finder_separator_covered
drop table if exists #flat

; with cte as 
(
select loc = 0
, curr = cast('' as varchar(max))
, rem = cast( STRING_AGG(cell,'') within group(order by id ) as varchar(max))
from #canvas 
union all 
select loc+ 1, left(rem, 1), right(rem, len(rem)-1 )from cte
where rem != ''
)
select * into #flat
from cte
OPTION (maxrecursion 0)

delete from #flat where loc = 0  -- take out the starting row.


-- ; with cte as 
-- (
-- select curr = @flat, loc = PATINDEX('%[Fs]%', @flat) , rem = right(@flat, len(@flat) - PATINDEX('%[Fs]%', @flat) )
-- union all 
-- select rem, loc + PATINDEX('%[Fs]%', rem), right(rem, len(rem) - PATINDEX('%[Fs]%', rem) ) 
-- from cte
-- where PATINDEX('%[Fs]%', rem) != 0
-- ) 
-- select *
-- into #finder_separator_covered
-- from cte 
-- OPTION(maxrecursion 0)



-- next is to compute 5*5 points of the alignment pattecanvas_rn
-- the point is in the middle of the 5*5 pixel. 
-- if the point is at 6, 7 location, ver is 10
-- the upper left cocanvas_rner is 6 * (10-3) (full rows) + 7 (current col) - 2 (offset)

drop table if exists #base_uppers

select 
val.*
, v.n
, left_upper_point = v.n *(point_1-3) + point_2 - 2 
, right_upper_point = v.n *(point_1-3) + point_2 + 2
into #base_uppers
from #version_alignment_location val inner join #versions v
on val.ver = v.v
where ver = 10 -- @version_num


-- select * from #base_uppers


drop table if exists #alignment_covered

; with cte as 
(
select canvas_rn = 1,  ver, n, point_1, point_2, covered_point_start = left_upper_point, covered_point_end = right_upper_point from #base_uppers
union all 
select canvas_rn + 1, ver, n, point_1, point_2, covered_point_start+n, covered_point_end +n from cte
where canvas_rn < 5
) 
select * into #alignment_covered 
from cte 
OPTION (maxrecursion 0)


-- select * from #finder_separator_covered 
drop table if EXISTS #alignments  -- alignments covered area

; with cte as
(
select 
ac.ver
, ac.n
, ac.point_1
, ac.point_2
, ac.covered_point_start
, ac.covered_point_end
, overlapped = count(f.loc) over (partition by ac.ver, ac.n, ac.point_1, ac.point_2 )
from #alignment_covered ac 
left outer join #flat f
on f.loc between ac.covered_point_start and ac.covered_point_end 
and f.curr in ('F', 's')
)
select 
*
, center_loc = n*(point_1-1) + point_2 -- get the center location of the alignment pattecanvas_rn
, canvas_rn = ROW_NUMBER() over(partition by point_1 , point_2 order by covered_point_start) -- row number for each alignment block
into #alignments 
from cte 
where overlapped = 0 


update tgt 
set tgt.curr = 'a'
from #flat tgt inner join #alignments src 
on tgt.loc between src.covered_point_start and src.covered_point_end 

-- for upper and lower 
update tgt 
set tgt.curr = 'A'
from #flat tgt inner join #alignments src 
on tgt.loc between src.covered_point_start and src.covered_point_end
and src.canvas_rn in (1, 5)

-- for left and right
update tgt 
set tgt.curr = 'A'
from #flat tgt inner join #alignments src 
on tgt.loc in (src.covered_point_start,  src.covered_point_end) 
and src.canvas_rn not in (1, 5)


-- for center
update tgt 
set tgt.curr = 'A'
from #flat tgt inner join #alignments src 
on tgt.loc = src.center_loc


-- select * from #flat

alter table #flat drop column rem 



-- location starts from 1, to avoid 57 / 57 --> 1, which should be on the same first row

-- drop table if exists #canvas_staging

-- select 
-- canvas_rn = (loc-1)/@blocks -- this is the group id
-- , cell = STRING_AGG(curr, '') within group(order by (loc-1)/@blocks, loc)
-- into #canvas_staging
-- from #flat 
-- group by (loc-1)/@blocks




-- next is to plot the reserved version information area

-- location starts from 1, to avoid 25 / 25 --> 1, which should be on the same first row
drop table if exists #canvas_staging 

select 
loc
, canvas_rn = (loc-1) / @blocks -- the row number for the cell on the canvas
, canvas_cn = (loc-1) % @blocks -- the col number for the cell on the canvas
, cell = curr
, total_blocks = @blocks
, col_direction = cast(NULL as varchar)
into #canvas_staging
from #flat

update #canvas_staging set canvas_rn = canvas_rn +1, canvas_cn = canvas_cn + 1 -- row and col starts from 1 

---- for all the versions <= 7 

-- PDP-1 lower line
update #canvas_staging 
set cell = 'r'
where 
canvas_rn = 9 
and canvas_cn <= 9 
and cell = '_'
-- and @version_num < 7


-- PDP-1 upper right line
update #canvas_staging 
set cell = 'r'
where 
canvas_rn <= 9 
and canvas_cn = 9 
and cell = '_'
-- and @version_num < 7

-- PDP-2 lower line
update #canvas_staging 
set cell = 'r'
where 
canvas_rn = 9 
and canvas_cn >= @blocks - 7
and cell = '_'
-- and @version_num < 7

-- PDP-3 right line
update #canvas_staging 
set cell = 'r'
where 
canvas_rn >= @blocks - 7 
and canvas_cn = 9
and cell = '_'
-- and @version_num < 7


---- for version >= 7, reserved region



-- PDP-2 left region
update #canvas_staging 
set cell = 'r'
where 
canvas_rn <= 6 
and canvas_cn BETWEEN @blocks - 10 and 57 - 8 
and cell = '_'
and @version_num >=7 

-- PDP-3 upper region
update #canvas_staging 
set cell = 'r'
where 
canvas_rn between @blocks - 10 and 57 - 8 
and canvas_cn <= 6 
and cell = '_'
and @version_num >= 7


--plot the dark module 
update #canvas_staging set cell = 'D' where canvas_cn = 9 and canvas_rn = total_blocks - 7


-- Next, to zigzag apply the data to the canvas 


-- col_direction: 0 up, 1 down 
-- column total will always be odd number, put column into col groups
-- for the even groups, it's up, for the odd groups, it's down
-- eg. col = 57, 57/2 = 28, even, it's up 
-- col = 56, 56/2 = 28, even, it's up
-- col = 55, 55/2 = 27, odd, it's down


/* 

Steps for the Zigzag -  

0. From right to left, flag each column direction

1. For the columns going up

1.1 Even numbered column - this is the turning zig
 
 - Regular case, from all the available cells (row - 1, col + 1) or (row-1, col) 
 
 - If not found, turn left, from the available cells (row, col - 1) -- this will take care of the Timing pattecanvas_rn as well.

1.2 Odd numbered column
 
 - Regular case - from all the available cells (row, col - 1) or (row-1, col)

2. For the columns going down

2.1 Even numbered column - this is the turning zig
 
 - Regular case, from the available cells, (row + 1, col + 1) or (row + 1,  col)
 
 - If not found, from all the available cells, turn  left (row, col - 1)

 - For the down column at (blocks, 10) location, need to jump to the left upper, the cell above the dark module.
2.2 Odd numbered column
 
 - Regular case, from all the available cells, (row, col - 1) or (row+1, col)

*/




update #canvas_staging set col_direction = case when (canvas_cn / 2) % 2 = 0 then 'u' else 'd' end


drop table if exists #avail

select 
loc

, canvas_rn
, canvas_cn

, col_direction
, cell

into #avail 
from #canvas_staging
where cell = '_'


create index idx on #avail(canvas_rn, canvas_cn)


drop table if exists #zigzag_nxt


select 
curr.*
, zigzag_group = 'ue' --up and even column
, nxt_rn = COALESCE(nxt1.canvas_rn, nxt2.canvas_rn, nxt3.canvas_rn) 
, nxt_cn = COALESCE(nxt1.canvas_cn, nxt2.canvas_cn, nxt3.canvas_cn) 
into #zigzag_nxt
from #avail curr 
left outer join #avail nxt1  -- normal zigzag, to find the nearest previous row 
on (nxt1.canvas_rn < curr.canvas_rn and nxt1.canvas_cn = curr.canvas_cn + 1)
and not exists (select * from #avail nxt11 
                 where nxt11.canvas_rn < curr.canvas_rn 
                    and nxt11.canvas_cn = curr.canvas_cn
                    and nxt11.canvas_rn > nxt1.canvas_rn
                ) 

left outer join #avail nxt2 -- same col, nearest previous rows
on (nxt2.canvas_rn < curr.canvas_rn and nxt2.canvas_cn = curr.canvas_cn)
and not exists (select * from #avail nxt22 
                 where nxt22.canvas_rn < curr.canvas_rn 
                    and nxt22.canvas_cn = curr.canvas_cn
                    and nxt22.canvas_rn > nxt2.canvas_rn
                )  

left outer join #avail nxt3  -- same row, nearest left cols
on (nxt3.canvas_rn = curr.canvas_rn and nxt3.canvas_cn < curr.canvas_cn)
and not exists (select * from #avail nxt33
                 where nxt33.canvas_rn = curr.canvas_rn 
                    and nxt33.canvas_cn < curr.canvas_cn
                    and nxt33.canvas_cn > nxt3.canvas_cn
                ) 

where 
curr.col_direction = 'u'
and curr.canvas_cn %2 = 0 -- up and even col
-- and curr.canvas_rn = 10 and curr.canvas_cn = 8


insert into #zigzag_nxt
select 
curr.*
, zigzag_group = 'uo' --up and odd column
, nxt_rn = COALESCE(nxt1.canvas_rn, nxt2.canvas_rn) 
, nxt_cn = COALESCE(nxt1.canvas_cn, nxt2.canvas_cn) 
from #avail curr 
left outer join #avail nxt1  -- same row, nearest left cols
on (nxt1.canvas_rn = curr.canvas_rn and nxt1.canvas_cn < curr.canvas_cn)
and not exists (select * from #avail nxt11
                 where nxt11.canvas_rn = curr.canvas_rn 
                    and nxt11.canvas_cn < curr.canvas_cn
                    and nxt11.canvas_cn > nxt1.canvas_cn
                ) 

left outer join #avail nxt2 -- same col, nearest previous rows
on (nxt2.canvas_rn < curr.canvas_rn and nxt2.canvas_cn = curr.canvas_cn)
and not exists (select * from #avail nxt22 
                 where nxt22.canvas_rn < curr.canvas_rn 
                    and nxt22.canvas_cn = curr.canvas_cn
                    and nxt22.canvas_rn > nxt2.canvas_rn
                )  

where 
curr.col_direction = 'u'
and curr.canvas_cn %2 = 1 -- up and even col
-- and curr.canvas_rn = 10 and curr.canvas_cn = 8



insert into #zigzag_nxt
select  
curr.*
, zigzag_group = 'de' --down and even column
, nxt_rn = COALESCE(nxt1.canvas_rn, nxt2.canvas_rn, nxt3.canvas_rn, nxt4.canvas_rn) 
, nxt_cn = COALESCE(nxt1.canvas_cn, nxt2.canvas_cn, nxt3.canvas_cn, nxt4.canvas_cn) 
from #avail curr 
left outer join #avail nxt1  -- normal zigzag, to find the nearest following row 
on (nxt1.canvas_rn > curr.canvas_rn and nxt1.canvas_cn = curr.canvas_cn + 1)
and not exists (select * from #avail nxt11 
                 where nxt11.canvas_rn > curr.canvas_rn 
                    and nxt11.canvas_cn = curr.canvas_cn
                    and nxt11.canvas_rn < nxt1.canvas_rn
                ) 

left outer join #avail nxt2 -- same col, nearest following rows
on (nxt2.canvas_rn > curr.canvas_rn and nxt2.canvas_cn = curr.canvas_cn)
and not exists (select * from #avail nxt22 
                 where nxt22.canvas_rn > curr.canvas_rn 
                    and nxt22.canvas_cn = curr.canvas_cn
                    and nxt22.canvas_rn < nxt2.canvas_rn
                )  

left outer join #avail nxt3  -- same row, nearest left cols
on (nxt3.canvas_rn = curr.canvas_rn and nxt3.canvas_cn < curr.canvas_cn)
and not exists (select * from #avail nxt33
                 where nxt33.canvas_rn = curr.canvas_rn 
                    and nxt33.canvas_cn < curr.canvas_cn
                    and nxt33.canvas_cn > nxt3.canvas_cn
                ) 

left outer join #avail nxt4  -- nearest left upper cell
on (nxt4.canvas_rn < curr.canvas_rn and nxt4.canvas_cn < curr.canvas_cn)
and not exists (select * from #avail nxt44
                 where nxt44.canvas_rn < curr.canvas_rn 
                    and nxt44.canvas_cn < curr.canvas_cn
                    and (nxt44.canvas_rn > nxt4.canvas_rn
                        or 
                        nxt44.canvas_cn > nxt4.canvas_cn
                        )
                )

where 
curr.col_direction = 'd'
and curr.canvas_cn %2 = 0 -- up and even col
--and curr.canvas_rn = 26 and curr.canvas_cn = 30



insert into #zigzag_nxt
select 
curr.*
, zigzag_group = 'do' --down and odd column
, nxt_rn = COALESCE(nxt1.canvas_rn, nxt2.canvas_rn) 
, nxt_cn = COALESCE(nxt1.canvas_cn, nxt2.canvas_cn) 
from #avail curr 
left outer join #avail nxt1  -- same row, nearest left cols
on (nxt1.canvas_rn = curr.canvas_rn and nxt1.canvas_cn < curr.canvas_cn)
and not exists (select * from #avail nxt11
                 where nxt11.canvas_rn = curr.canvas_rn 
                    and nxt11.canvas_cn < curr.canvas_cn
                    and nxt11.canvas_cn > nxt1.canvas_cn
                ) 

left outer join #avail nxt2 -- same col, nearest following rows
on (nxt2.canvas_rn > curr.canvas_rn and nxt2.canvas_cn = curr.canvas_cn)
and not exists (select * from #avail nxt22 
                 where nxt22.canvas_rn > curr.canvas_rn 
                    and nxt22.canvas_cn = curr.canvas_cn
                    and nxt22.canvas_rn < nxt2.canvas_rn
                )  

where 
curr.col_direction = 'd'
and curr.canvas_cn %2 = 1 -- up and even col
-- and curr.canvas_rn = 10 and curr.canvas_cn = 8


drop table if exists #canvas_zigzag_nxt



select 
s.*
, zz.zigzag_group
, zz.nxt_rn
, zz.nxt_cn
, nxt_loc = nxt_loc.loc -- the exact loc on the canvas
into #canvas_zigzag_nxt
from #canvas_staging s 
left outer join #zigzag_nxt zz 
on s.loc = zz.loc
left outer join #canvas_staging nxt_loc
on zz.nxt_rn = nxt_loc.canvas_rn and zz.nxt_cn = nxt_loc.canvas_cn


---- Next is to get sequence number for the zigzag path

drop table if exists #plot_order

; with cte AS
(
    select plot_order = 1, currLoc = loc, nxt_loc from #canvas_zigzag_nxt 
    where cell = '_' and loc = total_blocks*total_blocks -- starting point
    union all
    select plot_order + 1, c.nxt_loc, nxt.nxt_loc
    from cte c inner join #canvas_zigzag_nxt nxt 
    on c.nxt_loc = nxt.loc
) 
select * into #plot_order from cte
OPTION(maxrecursion 0)


drop table if exists #canvas_ready_to_plot 


select 
c.*
, p.plot_order 
into #canvas_ready_to_plot 
from #canvas_zigzag_nxt c
left outer join #plot_order p
on c.loc = p.currLoc



select * from #canvas_zigzag_nxt 
where cell = '_' and nxt_loc is null 

select * from #canvas_zigzag_nxt 
where canvas_rn = 57 and canvas_cn = 10




---- Next is to get the text into binary, and place on to the canvas

declare @txt nvarchar(max) = 'Today is 2024-11-20. It is a Wednesday. This is the text to show on the QR Code'
declare @type_of_characters int = 3 --  1: number, 2: alphanum, 3: bytes, 4: Kanji
declare @len int = len(@txt)

drop table if exists #base 

select 
c = convert(varchar(max), cast(@txt as varbinary(max)), 2 )
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


drop table if exists #txt_bin_form -- turn to little endian

; with cte as 
(
    select id = 1, curr = substring(c, 3, 2) + left(c, 2), rem = right(c, len(c) - 4) from #base
    union all 
    select id + 1 , substring(rem, 3, 2) + left(rem, 2), rem =  right(rem, len(rem) - 4)   from cte 
    where len(rem) > 0 
)
select id, curr, bin_form = cast(hb.b as varchar(max))
into #txt_bin_form
from cte c inner join #hex_bin_lkp hb on c.curr = hb.h
option(maxrecursion 0)


-- select * from #txt_bin_form 
-- order by 1 

-- select
-- txt = string_agg(bin_form, '') within group(order by id) 
-- from #txt_bin_form 



drop table if exists #plot_txt_bin


select plot_txt = 
(
    select right(b, 4) -- convert the type to 4 bits 
    from #hex_bin_lkp h
    where h = right(convert(varchar(max), cast(@type_of_characters as varbinary(max)), 2 ), 4)
)
+
(
    select right(b, 8) -- convert the len to 8 bits 
    from #hex_bin_lkp h
    where h = right(convert(varchar(max), cast(@len as varbinary(max)), 2 ), 4)
)
+
(
    select -- concat the txt in ascii_bin_form 
    txt = string_agg(bin_form, '') within group(order by id) 
    from #txt_bin_form 
)
into #plot_txt_bin




; with cte as 
(

    select 
    id = 1
    , curr = cast( left(plot_txt, 1) as varchar(max) )
    , rem = cast( right(plot_txt, len(plot_txt) - 1)  as varchar(max)) 
    from #plot_txt_bin
    union all 
    select 
    id + 1
    , left(rem, 1)
    , rem = right(rem, len(rem) - 1)
    from cte
    where rem != ''
)
select id, curr from cte 
order by 1 
OPTION(maxrecursion 0)





--------- Next is to generate the ECC --------- 



--select * from #canvas_zigzag_nxt





-- select * from #avail
-- where canvas_rn = 10 and canvas_cn = 8



/* 
select 
canvas_rn 
, cell = STRING_AGG(cell, '') within group(order by canvas_rn, loc)
from #canvas_zigzag_nxt
group by canvas_rn 

*/





/* 
select
loc
, nxt = case when col_direction = 0 and canvas_cn % 2 = 1 then -- for the odd columns and it's going up
                        case when exists(select * from #avail a2 where a2.loc = a1.loc - 1 ) then a1.loc - 1 -- use the left one
                             else 'TBD'
                        end 
             when col_direction = 0 and canvas_cn % 2 = 0 then -- for the even columns and it's going up
                  case when 1=1 then 'TBD'
                       else 'TBD'                
                  end 
                     
             when col_direction = 1 and canvas_cn % 2 = 1 then -- for the odd columns and it's going down
                  case when 1=1 then 'TBD'
                       else 'TBD'                
                  end 

             when col_direction = 1 and canvas_cn % 2 = 0 then -- for the even columns and it's going down
                  case when 1=1 then 'TBD'
                       else 'TBD'                
                  end 
        end 

from #avail a1 order by 1 desc 
 */







-- 1. type of the data, 4 bits





-- 2. number of the characters in the message, 8 bits 




-- 3. The real characters in binary form.











-- select * from #flat

-- select * from #alignments


-- select * from #canvas



-- next is to check for each point, if it's overlapping with the finder pattecanvas_rn




-- select * from #canvas



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




 