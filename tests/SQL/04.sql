INSERT INTO t100kb
    SELECT id, str1, SUBSTRING(str1,12,1) concat '-' concat  str1 as str2 from t10k
    UNION ALL SELECT 10000 + id, str1, SUBSTRING(str1,13,1) concat '-' concat str1 as str2 from t10k
    UNION ALL SELECT 20000 + id, str1, SUBSTRING(str1,15,1) concat '-' concat str1 as str2 from t10k
    UNION ALL SELECT 30000 + id, str1, SUBSTRING(str1,16,1) concat '-' concat str1 as str2 from t10k
    UNION ALL SELECT 40000 + id, str1, SUBSTRING(str1,17,1) concat '-' concat str1 as str2 from t10k
    UNION ALL SELECT 50000 + id, str1, SUBSTRING(str1,18,1) concat '-' concat str1 as str2 from t10k
    UNION ALL SELECT 60000 + id, str1, SUBSTRING(str1,20,1) concat '-' concat str1 as str2 from t10k
    UNION ALL SELECT 70000 + id, str1, SUBSTRING(str1,21,1) concat '-' concat str1 as str2 from t10k
    UNION ALL SELECT 80000 + id, str1, SUBSTRING(str1,22,1) concat '-' concat str1 as str2 from t10k
    UNION ALL SELECT 90000 + id, str1, SUBSTRING(str1,23,1) concat '-' concat str1 as str2 from t10k;
