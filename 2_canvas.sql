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



declare @blocks int = (select cast(n as int) from #versions where v = @version_num) 
declare @finder int = 7  -- this is the blocks needed for the finder


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
-- and curr.canvas_rn = 15 and curr.canvas_cn = 28


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


select loc, count(*) from #canvas_ready_to_plot
group by loc 
order by 2 desc 






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






-- To import the error correction table from https://www.thonky.com/qr-code-tutorial/error-correction-table

drop table if exists #ecc_spec 

select ver = '1' ,ecc_level = 'L' ,nr_Codewords = '19' ,ecc_per_block = '7' ,grp1_blocks = '1' ,grp1_each_blocks_data_codewords = '19' ,grp2_blocks = '' ,grp2_each_blocks_data_codewords = '' ,comments = '(19*1) = 19'  
into #ecc_spec 
 union all
select '1' ,'M' ,'16' ,'10' ,'1' ,'16' ,'' ,'' ,'(16*1) = 16' union all select '1' ,'Q' ,'13' ,'13' ,'1' ,'13' ,'' ,'' ,'(13*1) = 13' union all select '1' ,'H' ,'9' ,'17' ,'1' ,'9' ,'' ,'' ,'(9*1) = 9' union all select '2' ,'L' ,'34' ,'10' ,'1' ,'34' ,'' ,'' ,'(34*1) = 34' union all select '2' ,'M' ,'28' ,'16' ,'1' ,'28' ,'' ,'' ,'(28*1) = 28' union all select '2' ,'Q' ,'22' ,'22' ,'1' ,'22' ,'' ,'' ,'(22*1) = 22' union all select '2' ,'H' ,'16' ,'28' ,'1' ,'16' ,'' ,'' ,'(16*1) = 16' union all select '3' ,'L' ,'55' ,'15' ,'1' ,'55' ,'' ,'' ,'(55*1) = 55' union all select '3' ,'M' ,'44' ,'26' ,'1' ,'44' ,'' ,'' ,'(44*1) = 44' union all select '3' ,'Q' ,'34' ,'18' ,'2' ,'17' ,'' ,'' ,'(17*2) = 34' union all select '3' ,'H' ,'26' ,'22' ,'2' ,'13' ,'' ,'' ,'(13*2) = 26' union all select '4' ,'L' ,'80' ,'20' ,'1' ,'80' ,'' ,'' ,'(80*1) = 80' union all select '4' ,'M' ,'64' ,'18' ,'2' ,'32' ,'' ,'' ,'(32*2) = 64' union all select '4' ,'Q' ,'48' ,'26' ,'2' ,'24' ,'' ,'' ,'(24*2) = 48' union all select '4' ,'H' ,'36' ,'16' ,'4' ,'9' ,'' ,'' ,'(9*4) = 36' union all select '5' ,'L' ,'108' ,'26' ,'1' ,'108' ,'' ,'' ,'(108*1) = 108' union all select '5' ,'M' ,'86' ,'24' ,'2' ,'43' ,'' ,'' ,'(43*2) = 86' union all select '5' ,'Q' ,'62' ,'18' ,'2' ,'15' ,'2' ,'16' ,'(15*2) + (16*2) = 62' union all select '5' ,'H' ,'46' ,'22' ,'2' ,'11' ,'2' ,'12' ,'(11*2) + (12*2) = 46' union all select '6' ,'L' ,'136' ,'18' ,'2' ,'68' ,'' ,'' ,'(68*2) = 136' union all select '6' ,'M' ,'108' ,'16' ,'4' ,'27' ,'' ,'' ,'(27*4) = 108' union all select '6' ,'Q' ,'76' ,'24' ,'4' ,'19' ,'' ,'' ,'(19*4) = 76' union all select '6' ,'H' ,'60' ,'28' ,'4' ,'15' ,'' ,'' ,'(15*4) = 60' union all select '7' ,'L' ,'156' ,'20' ,'2' ,'78' ,'' ,'' ,'(78*2) = 156' union all select '7' ,'M' ,'124' ,'18' ,'4' ,'31' ,'' ,'' ,'(31*4) = 124' union all select '7' ,'Q' ,'88' ,'18' ,'2' ,'14' ,'4' ,'15' ,'(14*2) + (15*4) = 88' union all select '7' ,'H' ,'66' ,'26' ,'4' ,'13' ,'1' ,'14' ,'(13*4) + (14*1) = 66' union all select '8' ,'L' ,'194' ,'24' ,'2' ,'97' ,'' ,'' ,'(97*2) = 194' union all select '8' ,'M' ,'154' ,'22' ,'2' ,'38' ,'2' ,'39' ,'(38*2) + (39*2) = 154' union all select '8' ,'Q' ,'110' ,'22' ,'4' ,'18' ,'2' ,'19' ,'(18*4) + (19*2) = 110' union all select '8' ,'H' ,'86' ,'26' ,'4' ,'14' ,'2' ,'15' ,'(14*4) + (15*2) = 86' union all select '9' ,'L' ,'232' ,'30' ,'2' ,'116' ,'' ,'' ,'(116*2) = 232' union all select '9' ,'M' ,'182' ,'22' ,'3' ,'36' ,'2' ,'37' ,'(36*3) + (37*2) = 182' union all select '9' ,'Q' ,'132' ,'20' ,'4' ,'16' ,'4' ,'17' ,'(16*4) + (17*4) = 132' union all select '9' ,'H' ,'100' ,'24' ,'4' ,'12' ,'4' ,'13' ,'(12*4) + (13*4) = 100' union all select '10' ,'L' ,'274' ,'18' ,'2' ,'68' ,'2' ,'69' ,'(68*2) + (69*2) = 274' union all select '10' ,'M' ,'216' ,'26' ,'4' ,'43' ,'1' ,'44' ,'(43*4) + (44*1) = 216' union all select '10' ,'Q' ,'154' ,'24' ,'6' ,'19' ,'2' ,'20' ,'(19*6) + (20*2) = 154' union all select '10' ,'H' ,'122' ,'28' ,'6' ,'15' ,'2' ,'16' ,'(15*6) + (16*2) = 122'  
 union all
select '11' ,'L' ,'324' ,'20' ,'4' ,'81' ,'' ,'' ,'(81*4) = 324' union all select '11' ,'M' ,'254' ,'30' ,'1' ,'50' ,'4' ,'51' ,'(50*1) + (51*4) = 254' union all select '11' ,'Q' ,'180' ,'28' ,'4' ,'22' ,'4' ,'23' ,'(22*4) + (23*4) = 180' union all select '11' ,'H' ,'140' ,'24' ,'3' ,'12' ,'8' ,'13' ,'(12*3) + (13*8) = 140' union all select '12' ,'L' ,'370' ,'24' ,'2' ,'92' ,'2' ,'93' ,'(92*2) + (93*2) = 370' union all select '12' ,'M' ,'290' ,'22' ,'6' ,'36' ,'2' ,'37' ,'(36*6) + (37*2) = 290' union all select '12' ,'Q' ,'206' ,'26' ,'4' ,'20' ,'6' ,'21' ,'(20*4) + (21*6) = 206' union all select '12' ,'H' ,'158' ,'28' ,'7' ,'14' ,'4' ,'15' ,'(14*7) + (15*4) = 158' union all select '13' ,'L' ,'428' ,'26' ,'4' ,'107' ,'' ,'' ,'(107*4) = 428' union all select '13' ,'M' ,'334' ,'22' ,'8' ,'37' ,'1' ,'38' ,'(37*8) + (38*1) = 334' union all select '13' ,'Q' ,'244' ,'24' ,'8' ,'20' ,'4' ,'21' ,'(20*8) + (21*4) = 244' union all select '13' ,'H' ,'180' ,'22' ,'12' ,'11' ,'4' ,'12' ,'(11*12) + (12*4) = 180' union all select '14' ,'L' ,'461' ,'30' ,'3' ,'115' ,'1' ,'116' ,'(115*3) + (116*1) = 461' union all select '14' ,'M' ,'365' ,'24' ,'4' ,'40' ,'5' ,'41' ,'(40*4) + (41*5) = 365' union all select '14' ,'Q' ,'261' ,'20' ,'11' ,'16' ,'5' ,'17' ,'(16*11) + (17*5) = 261' union all select '14' ,'H' ,'197' ,'24' ,'11' ,'12' ,'5' ,'13' ,'(12*11) + (13*5) = 197' union all select '15' ,'L' ,'523' ,'22' ,'5' ,'87' ,'1' ,'88' ,'(87*5) + (88*1) = 523' union all select '15' ,'M' ,'415' ,'24' ,'5' ,'41' ,'5' ,'42' ,'(41*5) + (42*5) = 415' union all select '15' ,'Q' ,'295' ,'30' ,'5' ,'24' ,'7' ,'25' ,'(24*5) + (25*7) = 295' union all select '15' ,'H' ,'223' ,'24' ,'11' ,'12' ,'7' ,'13' ,'(12*11) + (13*7) = 223' union all select '16' ,'L' ,'589' ,'24' ,'5' ,'98' ,'1' ,'99' ,'(98*5) + (99*1) = 589' union all select '16' ,'M' ,'453' ,'28' ,'7' ,'45' ,'3' ,'46' ,'(45*7) + (46*3) = 453' union all select '16' ,'Q' ,'325' ,'24' ,'15' ,'19' ,'2' ,'20' ,'(19*15) + (20*2) = 325' union all select '16' ,'H' ,'253' ,'30' ,'3' ,'15' ,'13' ,'16' ,'(15*3) + (16*13) = 253' union all select '17' ,'L' ,'647' ,'28' ,'1' ,'107' ,'5' ,'108' ,'(107*1) + (108*5) = 647' union all select '17' ,'M' ,'507' ,'28' ,'10' ,'46' ,'1' ,'47' ,'(46*10) + (47*1) = 507' union all select '17' ,'Q' ,'367' ,'28' ,'1' ,'22' ,'15' ,'23' ,'(22*1) + (23*15) = 367' union all select '17' ,'H' ,'283' ,'28' ,'2' ,'14' ,'17' ,'15' ,'(14*2) + (15*17) = 283' union all select '18' ,'L' ,'721' ,'30' ,'5' ,'120' ,'1' ,'121' ,'(120*5) + (121*1) = 721' union all select '18' ,'M' ,'563' ,'26' ,'9' ,'43' ,'4' ,'44' ,'(43*9) + (44*4) = 563' union all select '18' ,'Q' ,'397' ,'28' ,'17' ,'22' ,'1' ,'23' ,'(22*17) + (23*1) = 397' union all select '18' ,'H' ,'313' ,'28' ,'2' ,'14' ,'19' ,'15' ,'(14*2) + (15*19) = 313' union all select '19' ,'L' ,'795' ,'28' ,'3' ,'113' ,'4' ,'114' ,'(113*3) + (114*4) = 795' union all select '19' ,'M' ,'627' ,'26' ,'3' ,'44' ,'11' ,'45' ,'(44*3) + (45*11) = 627' union all select '19' ,'Q' ,'445' ,'26' ,'17' ,'21' ,'4' ,'22' ,'(21*17) + (22*4) = 445' union all select '19' ,'H' ,'341' ,'26' ,'9' ,'13' ,'16' ,'14' ,'(13*9) + (14*16) = 341' union all select '20' ,'L' ,'861' ,'28' ,'3' ,'107' ,'5' ,'108' ,'(107*3) + (108*5) = 861' union all select '20' ,'M' ,'669' ,'26' ,'3' ,'41' ,'13' ,'42' ,'(41*3) + (42*13) = 669' union all select '20' ,'Q' ,'485' ,'30' ,'15' ,'24' ,'5' ,'25' ,'(24*15) + (25*5) = 485' union all select '20' ,'H' ,'385' ,'28' ,'15' ,'15' ,'10' ,'16' ,'(15*15) + (16*10) = 385'  
 union all
select '21' ,'L' ,'932' ,'28' ,'4' ,'116' ,'4' ,'117' ,'(116*4) + (117*4) = 932' union all select '21' ,'M' ,'714' ,'26' ,'17' ,'42' ,'' ,'' ,'(42*17) = 714' union all select '21' ,'Q' ,'512' ,'28' ,'17' ,'22' ,'6' ,'23' ,'(22*17) + (23*6) = 512' union all select '21' ,'H' ,'406' ,'30' ,'19' ,'16' ,'6' ,'17' ,'(16*19) + (17*6) = 406' union all select '22' ,'L' ,'1006' ,'28' ,'2' ,'111' ,'7' ,'112' ,'(111*2) + (112*7) = 1006' union all select '22' ,'M' ,'782' ,'28' ,'17' ,'46' ,'' ,'' ,'(46*17) = 782' union all select '22' ,'Q' ,'568' ,'30' ,'7' ,'24' ,'16' ,'25' ,'(24*7) + (25*16) = 568' union all select '22' ,'H' ,'442' ,'24' ,'34' ,'13' ,'' ,'' ,'(13*34) = 442' union all select '23' ,'L' ,'1094' ,'30' ,'4' ,'121' ,'5' ,'122' ,'(121*4) + (122*5) = 1094' union all select '23' ,'M' ,'860' ,'28' ,'4' ,'47' ,'14' ,'48' ,'(47*4) + (48*14) = 860' union all select '23' ,'Q' ,'614' ,'30' ,'11' ,'24' ,'14' ,'25' ,'(24*11) + (25*14) = 614' union all select '23' ,'H' ,'464' ,'30' ,'16' ,'15' ,'14' ,'16' ,'(15*16) + (16*14) = 464' union all select '24' ,'L' ,'1174' ,'30' ,'6' ,'117' ,'4' ,'118' ,'(117*6) + (118*4) = 1174' union all select '24' ,'M' ,'914' ,'28' ,'6' ,'45' ,'14' ,'46' ,'(45*6) + (46*14) = 914' union all select '24' ,'Q' ,'664' ,'30' ,'11' ,'24' ,'16' ,'25' ,'(24*11) + (25*16) = 664' union all select '24' ,'H' ,'514' ,'30' ,'30' ,'16' ,'2' ,'17' ,'(16*30) + (17*2) = 514' union all select '25' ,'L' ,'1276' ,'26' ,'8' ,'106' ,'4' ,'107' ,'(106*8) + (107*4) = 1276' union all select '25' ,'M' ,'1000' ,'28' ,'8' ,'47' ,'13' ,'48' ,'(47*8) + (48*13) = 1000' union all select '25' ,'Q' ,'718' ,'30' ,'7' ,'24' ,'22' ,'25' ,'(24*7) + (25*22) = 718' union all select '25' ,'H' ,'538' ,'30' ,'22' ,'15' ,'13' ,'16' ,'(15*22) + (16*13) = 538' union all select '26' ,'L' ,'1370' ,'28' ,'10' ,'114' ,'2' ,'115' ,'(114*10) + (115*2) = 1370' union all select '26' ,'M' ,'1062' ,'28' ,'19' ,'46' ,'4' ,'47' ,'(46*19) + (47*4) = 1062' union all select '26' ,'Q' ,'754' ,'28' ,'28' ,'22' ,'6' ,'23' ,'(22*28) + (23*6) = 754' union all select '26' ,'H' ,'596' ,'30' ,'33' ,'16' ,'4' ,'17' ,'(16*33) + (17*4) = 596' union all select '27' ,'L' ,'1468' ,'30' ,'8' ,'122' ,'4' ,'123' ,'(122*8) + (123*4) = 1468' union all select '27' ,'M' ,'1128' ,'28' ,'22' ,'45' ,'3' ,'46' ,'(45*22) + (46*3) = 1128' union all select '27' ,'Q' ,'808' ,'30' ,'8' ,'23' ,'26' ,'24' ,'(23*8) + (24*26) = 808' union all select '27' ,'H' ,'628' ,'30' ,'12' ,'15' ,'28' ,'16' ,'(15*12) + (16*28) = 628' union all select '28' ,'L' ,'1531' ,'30' ,'3' ,'117' ,'10' ,'118' ,'(117*3) + (118*10) = 1531' union all select '28' ,'M' ,'1193' ,'28' ,'3' ,'45' ,'23' ,'46' ,'(45*3) + (46*23) = 1193' union all select '28' ,'Q' ,'871' ,'30' ,'4' ,'24' ,'31' ,'25' ,'(24*4) + (25*31) = 871' union all select '28' ,'H' ,'661' ,'30' ,'11' ,'15' ,'31' ,'16' ,'(15*11) + (16*31) = 661' union all select '29' ,'L' ,'1631' ,'30' ,'7' ,'116' ,'7' ,'117' ,'(116*7) + (117*7) = 1631' union all select '29' ,'M' ,'1267' ,'28' ,'21' ,'45' ,'7' ,'46' ,'(45*21) + (46*7) = 1267' union all select '29' ,'Q' ,'911' ,'30' ,'1' ,'23' ,'37' ,'24' ,'(23*1) + (24*37) = 911' union all select '29' ,'H' ,'701' ,'30' ,'19' ,'15' ,'26' ,'16' ,'(15*19) + (16*26) = 701' union all select '30' ,'L' ,'1735' ,'30' ,'5' ,'115' ,'10' ,'116' ,'(115*5) + (116*10) = 1735' union all select '30' ,'M' ,'1373' ,'28' ,'19' ,'47' ,'10' ,'48' ,'(47*19) + (48*10) = 1373' union all select '30' ,'Q' ,'985' ,'30' ,'15' ,'24' ,'25' ,'25' ,'(24*15) + (25*25) = 985' union all select '30' ,'H' ,'745' ,'30' ,'23' ,'15' ,'25' ,'16' ,'(15*23) + (16*25) = 745'  
 union all
select '31' ,'L' ,'1843' ,'30' ,'13' ,'115' ,'3' ,'116' ,'(115*13) + (116*3) = 1843' union all select '31' ,'M' ,'1455' ,'28' ,'2' ,'46' ,'29' ,'47' ,'(46*2) + (47*29) = 1455' union all select '31' ,'Q' ,'1033' ,'30' ,'42' ,'24' ,'1' ,'25' ,'(24*42) + (25*1) = 1033' union all select '31' ,'H' ,'793' ,'30' ,'23' ,'15' ,'28' ,'16' ,'(15*23) + (16*28) = 793' union all select '32' ,'L' ,'1955' ,'30' ,'17' ,'115' ,'' ,'' ,'(115*17) = 1955' union all select '32' ,'M' ,'1541' ,'28' ,'10' ,'46' ,'23' ,'47' ,'(46*10) + (47*23) = 1541' union all select '32' ,'Q' ,'1115' ,'30' ,'10' ,'24' ,'35' ,'25' ,'(24*10) + (25*35) = 1115' union all select '32' ,'H' ,'845' ,'30' ,'19' ,'15' ,'35' ,'16' ,'(15*19) + (16*35) = 845' union all select '33' ,'L' ,'2071' ,'30' ,'17' ,'115' ,'1' ,'116' ,'(115*17) + (116*1) = 2071' union all select '33' ,'M' ,'1631' ,'28' ,'14' ,'46' ,'21' ,'47' ,'(46*14) + (47*21) = 1631' union all select '33' ,'Q' ,'1171' ,'30' ,'29' ,'24' ,'19' ,'25' ,'(24*29) + (25*19) = 1171' union all select '33' ,'H' ,'901' ,'30' ,'11' ,'15' ,'46' ,'16' ,'(15*11) + (16*46) = 901' union all select '34' ,'L' ,'2191' ,'30' ,'13' ,'115' ,'6' ,'116' ,'(115*13) + (116*6) = 2191' union all select '34' ,'M' ,'1725' ,'28' ,'14' ,'46' ,'23' ,'47' ,'(46*14) + (47*23) = 1725' union all select '34' ,'Q' ,'1231' ,'30' ,'44' ,'24' ,'7' ,'25' ,'(24*44) + (25*7) = 1231' union all select '34' ,'H' ,'961' ,'30' ,'59' ,'16' ,'1' ,'17' ,'(16*59) + (17*1) = 961' union all select '35' ,'L' ,'2306' ,'30' ,'12' ,'121' ,'7' ,'122' ,'(121*12) + (122*7) = 2306' union all select '35' ,'M' ,'1812' ,'28' ,'12' ,'47' ,'26' ,'48' ,'(47*12) + (48*26) = 1812' union all select '35' ,'Q' ,'1286' ,'30' ,'39' ,'24' ,'14' ,'25' ,'(24*39) + (25*14) = 1286' union all select '35' ,'H' ,'986' ,'30' ,'22' ,'15' ,'41' ,'16' ,'(15*22) + (16*41) = 986' union all select '36' ,'L' ,'2434' ,'30' ,'6' ,'121' ,'14' ,'122' ,'(121*6) + (122*14) = 2434' union all select '36' ,'M' ,'1914' ,'28' ,'6' ,'47' ,'34' ,'48' ,'(47*6) + (48*34) = 1914' union all select '36' ,'Q' ,'1354' ,'30' ,'46' ,'24' ,'10' ,'25' ,'(24*46) + (25*10) = 1354' union all select '36' ,'H' ,'1054' ,'30' ,'2' ,'15' ,'64' ,'16' ,'(15*2) + (16*64) = 1054' union all select '37' ,'L' ,'2566' ,'30' ,'17' ,'122' ,'4' ,'123' ,'(122*17) + (123*4) = 2566' union all select '37' ,'M' ,'1992' ,'28' ,'29' ,'46' ,'14' ,'47' ,'(46*29) + (47*14) = 1992' union all select '37' ,'Q' ,'1426' ,'30' ,'49' ,'24' ,'10' ,'25' ,'(24*49) + (25*10) = 1426' union all select '37' ,'H' ,'1096' ,'30' ,'24' ,'15' ,'46' ,'16' ,'(15*24) + (16*46) = 1096' union all select '38' ,'L' ,'2702' ,'30' ,'4' ,'122' ,'18' ,'123' ,'(122*4) + (123*18) = 2702' union all select '38' ,'M' ,'2102' ,'28' ,'13' ,'46' ,'32' ,'47' ,'(46*13) + (47*32) = 2102' union all select '38' ,'Q' ,'1502' ,'30' ,'48' ,'24' ,'14' ,'25' ,'(24*48) + (25*14) = 1502' union all select '38' ,'H' ,'1142' ,'30' ,'42' ,'15' ,'32' ,'16' ,'(15*42) + (16*32) = 1142' union all select '39' ,'L' ,'2812' ,'30' ,'20' ,'117' ,'4' ,'118' ,'(117*20) + (118*4) = 2812' union all select '39' ,'M' ,'2216' ,'28' ,'40' ,'47' ,'7' ,'48' ,'(47*40) + (48*7) = 2216' union all select '39' ,'Q' ,'1582' ,'30' ,'43' ,'24' ,'22' ,'25' ,'(24*43) + (25*22) = 1582' union all select '39' ,'H' ,'1222' ,'30' ,'10' ,'15' ,'67' ,'16' ,'(15*10) + (16*67) = 1222' union all select '40' ,'L' ,'2956' ,'30' ,'19' ,'118' ,'6' ,'119' ,'(118*19) + (119*6) = 2956' union all select '40' ,'M' ,'2334' ,'28' ,'18' ,'47' ,'31' ,'48' ,'(47*18) + (48*31) = 2334' union all select '40' ,'Q' ,'1666' ,'30' ,'34' ,'24' ,'34' ,'25' ,'(24*34) + (25*34) = 1666' union all select '40' ,'H' ,'1276' ,'30' ,'20' ,'15' ,'61' ,'16' ,'(15*20) + (16*61) = 1276'  
 




-- To import the version / type number of bits as below table

/*
Versions 1 through 9
Numeric mode: 10 bits
Alphanumeric mode: 9 bits
Byte mode: 8 bits
Japanese mode: 8 bits
Versions 10 through 26
Numeric mode: 12 bits
Alphanumeric mode: 11 bits
Byte mode: 16
Japanese mode: 10 bits
Versions 27 through 40
Numeric mode: 14 bits
Alphanumeric mode: 13 bits
Byte mode: 16 bits
Japanese mode: 12 bits
*/ 

 

drop table if exists #version_mode_bits

select 
version_start = cast('1' as int) 
, version_end = cast('9' as int)
 ,mode = cast('1'  as int)
 ,bits = cast('10'   as int)
into #version_mode_bits
 union all
select '1' ,'9' ,'2' ,'9'  
 union all
select '1' ,'9' ,'3' ,'8'  
 union all
select '1' ,'9' ,'4' ,'8'  
 union all
select '10' ,'26' ,'1' ,'12'  
 union all
select '10' ,'26' ,'2' ,'11'  
 union all
select '10' ,'26' ,'3' ,'16'  
 union all
select '10' ,'26' ,'4' ,'10'  
 union all
select '27' ,'40' ,'1' ,'14'  
 union all
select '27' ,'40' ,'2' ,'13'  
 union all
select '27' ,'40' ,'3' ,'16'  
 union all
select '27' ,'40' ,'4' ,'12'  
 


--- TODO - need to put all the variables to a table

--select * from #version_mode_bits


-- TODO - To find the total length for the version + error correction level 

select * from #canvas_ready_to_plot


-- TODO - adding terminator



-- TODO - adding pad bytes 0 if the total length up to this point is not a multiple of 8



-- TODO - adding padding -- EC 11 (236, 17) -- 11101100, 00010001




-- TODO - to concatenate the terminator, paddings to the #plot_txt_bin.plot_text 



-- TODO - generate ECC 

-- In general, the values are always equal to 2 times the previous power, and if that value is 256 or greater, it is XORed with 285.





-- TODO - merge ECC into #plot_txt_bin.plot_text










--- Below is to generate the plot_path

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


-- select * from #canvas 


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



