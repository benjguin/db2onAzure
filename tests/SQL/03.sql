INSERT INTO t100ka 
    SELECT id, str1, SUBSTRING(str1,1,1) concat '-' concat str1 as str2 from t10k
    UNION ALL SELECT 10000 + id, str1, SUBSTRING(str1,2,1) concat '-' concat str1 as str2 from t10k
    UNION ALL SELECT 20000 + id, str1, SUBSTRING(str1,3,1) concat '-' concat str1 as str2 from t10k
    UNION ALL SELECT 30000 + id, str1, SUBSTRING(str1,4,1) concat '-' concat str1 as str2 from t10k
    UNION ALL SELECT 40000 + id, str1, SUBSTRING(str1,5,1) concat '-' concat str1 as str2 from t10k
    UNION ALL SELECT 50000 + id, str1, SUBSTRING(str1,6,1) concat '-' concat str1 as str2 from t10k
    UNION ALL SELECT 60000 + id, str1, SUBSTRING(str1,7,1) concat '-' concat str1 as str2 from t10k
    UNION ALL SELECT 70000 + id, str1, SUBSTRING(str1,8,1) concat '-' concat str1 as str2 from t10k
    UNION ALL SELECT 80000 + id, str1, SUBSTRING(str1,10,1) concat '-' concat str1 as str2 from t10k
    UNION ALL SELECT 90000 + id, str1, SUBSTRING(str1,11,1) concat '-' concat str1 as str2 from t10k;
