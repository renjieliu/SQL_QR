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
	select id+1, val = rem, rem ='' from cte -- put the last part back
	where id = (select max(id) from cte) and rem != ''
	union all 
	select id = -1, @input, '' -- in case the string does not contain the delimiter at all
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

 

-----------------TODO: Need to have a CTE to update the string, to mimic the update in the array -----------------








----------------------------

/*

def generate_error_correction(data, ecc_length):
    """
    生成错误纠正码
    :param data: 输入数据（文本，以字节表示）
    :param ecc_length: 错误校正码长度
    :return: 错误校正码
    """
    # 二进制的 Galois Field 表 (QR码在GF(256)中运算)
    gf256 = [1]

    for _ in range(255):
        next_val = gf256[-1] * 2
        if next_val >= 256:
            next_val ^= 0x11d  # 与生成多项式 x^8 + x^4 + x^3 + x^2 + 1 异或
        gf256.append(next_val)

    gf256_inv = [0] * 256
    for i, val in enumerate(gf256):
        gf256_inv[val] = i



-- above is done 

-- need to work on below part



    # 创建 Reed-Solomon 生成多项式
    
    generator = [1] -- in sql, this is string '1'
    
	for r in range(ecc_length): --  iteration <= @ecc_length  
        p1 = generator -- curr root, string '1' 
        p2 =[1, gf256[r]]  -- a = 1, b = (select xx from gf where x = r)
		result = [0] * (len(p1) + len(p2) - 1) --  have a string, replicate('0', (len(p1) + len(p2) - 1) )
        
        for i in range(len(p1)): # this needs to be a table, with 2 columns, col1 - 1 to len(p1), col2 - 1 to len(p2)
            for j in range(len(p2)):
                result[i + j] ^= p1[i] * p2[j] # the result will be updatin the string in corresponding location
        
        generator = result --update the root to current result, which is the string after updating 
    



    for i, g in enumerate(generator):
        print(i, g)
    
    # 将数据转化为多项式
    data_poly = [ord(c) for c in data] + [0] * ecc_length # done
    print(data_poly)

    # 利用生成多项式计算余数（即错误校正码）
    for i in range(len(data)):
        coef = data_poly[i]
        if coef != 0:
            for j in range(len(generator)):
                A = gf256_inv[coef]
                B = generator[j]
                x = ( A + B ) % 255 
                data_poly[i + j] ^= gf256[ x  ]

    return data_poly[-ecc_length:]




# def galois_mult(a, b):
#     """伽罗瓦域中的乘法"""
#     return (a + b) % 255


 
data = "HELLO WORLD"  # 输入文本
ecc_length = 10  # 错误纠正码长度

ecc = generate_error_correction(data, ecc_length)
print("错误纠正码：", ecc)



*/ 