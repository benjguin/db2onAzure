SELECT a.id, b.id, a.str1, b.str1, SUBSTRING(a.str1,32,1), SUBSTRING(b.str1,32,1)
FROM (SELECT id, str1, str2 FROM t2x_1e6_a LIMIT 10000) a 
CROSS JOIN (SELECT id, str1, str2 FROM t2x_1e6_b LIMIT 10000) b 
ORDER BY 5 desc, 6 asc
LIMIT 100;

/* SQL DB 

SELECT TOP 100 
    a.id, b.id, a.str1, b.str1, SUBSTRING(a.str1,32,1), SUBSTRING(b.str1,32,1)
FROM (SELECT TOP 10000 id, str1, str2 FROM t2x_1e6_a) a 
CROSS JOIN (SELECT TOP 10000 id, str1, str2 FROM t2x_1e6_b) b 
ORDER BY 5 desc, 6 asc;

*/