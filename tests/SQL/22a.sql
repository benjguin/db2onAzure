INSERT INTO t2x_1e6_a 
    SELECT id, str1, SUBSTRING(str1,1,1) concat '-' concat str1 as str2 from t2x_1e5
    UNION ALL SELECT 100000 + id, str1, SUBSTRING(str1,2,1)  concat '-' concat str1 as str2 from t2x_1e5
    UNION ALL SELECT 200000 + id, str1, SUBSTRING(str1,3,1)  concat '-' concat str1 as str2 from t2x_1e5
    UNION ALL SELECT 300000 + id, str1, SUBSTRING(str1,4,1)  concat '-' concat str1 as str2 from t2x_1e5
    UNION ALL SELECT 400000 + id, str1, SUBSTRING(str1,5,1)  concat '-' concat str1 as str2 from t2x_1e5
    UNION ALL SELECT 500000 + id, str1, SUBSTRING(str1,6,1)  concat '-' concat str1 as str2 from t2x_1e5
    UNION ALL SELECT 600000 + id, str1, SUBSTRING(str1,7,1)  concat '-' concat str1 as str2 from t2x_1e5
    UNION ALL SELECT 700000 + id, str1, SUBSTRING(str1,8,1)  concat '-' concat str1 as str2 from t2x_1e5
    UNION ALL SELECT 800000 + id, str1, SUBSTRING(str1,10,1) concat '-' concat str1 as str2 from t2x_1e5
    UNION ALL SELECT 900000 + id, str1, SUBSTRING(str1,11,1) concat '-' concat str1 as str2 from t2x_1e5;

/*
for SQL DB

INSERT INTO t2x_1e6_a 
    SELECT id, str1, SUBSTRING(str1,1,1) + '-' + str1 as str2 from t2x_1e5
    UNION ALL SELECT 100000 + id, str1, SUBSTRING(str1,2,1)  + '-' + str1 as str2 from t2x_1e5
    UNION ALL SELECT 200000 + id, str1, SUBSTRING(str1,3,1)  + '-' + str1 as str2 from t2x_1e5
    UNION ALL SELECT 300000 + id, str1, SUBSTRING(str1,4,1)  + '-' + str1 as str2 from t2x_1e5
    UNION ALL SELECT 400000 + id, str1, SUBSTRING(str1,5,1)  + '-' + str1 as str2 from t2x_1e5
    UNION ALL SELECT 500000 + id, str1, SUBSTRING(str1,6,1)  + '-' + str1 as str2 from t2x_1e5
    UNION ALL SELECT 600000 + id, str1, SUBSTRING(str1,7,1)  + '-' + str1 as str2 from t2x_1e5
    UNION ALL SELECT 700000 + id, str1, SUBSTRING(str1,8,1)  + '-' + str1 as str2 from t2x_1e5
    UNION ALL SELECT 800000 + id, str1, SUBSTRING(str1,10,1) + '-' + str1 as str2 from t2x_1e5
    UNION ALL SELECT 900000 + id, str1, SUBSTRING(str1,11,1) + '-' + str1 as str2 from t2x_1e5;


*/