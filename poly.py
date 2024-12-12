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

    print ('gf256', gf256)

    # 创建 Reed-Solomon 生成多项式
    
    generator = [1]
    for r in range(ecc_length):
        p1 = generator # p1 = 
        p2 =[1, gf256[r]]  # a = 1, b = (select xx from gf where x = r)
        result = [0] * (len(p1) + len(p2) - 1)
    
        
        print(f"length of p1: {len(p1)}") 
        print(f"length of p2: {len(p2)}") 
        print(f"length of result: {len(result)}") 
        
        
        for i in range(len(p1)):
            for j in range(len(p2)):
                result[i + j] ^= p1[i] * p2[j]
        print('p1:', p1)
        print('p2:', p2)

        generator = result
    
    print('Step 1 Result - ')
    print('Generator: ', generator)
    

##########################################################################################

    print('Step 2 Result - ')
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

print('Final Result - ')
print("错误纠正码：", ecc)



arr = [0] * 10
for i in range(10):
    arr[i] = i
print(arr)