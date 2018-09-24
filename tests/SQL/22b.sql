INSERT INTO t2x_1e6_b
    SELECT id, str1, SUBSTRING(str1,12,1) concat '-' concat  str1 as str2 from t2x_1e5
    UNION ALL SELECT 100000 + id, str1, SUBSTRING(str1,13,1) concat '-' concat str1 as str2 from t2x_1e5
    UNION ALL SELECT 200000 + id, str1, SUBSTRING(str1,15,1) concat '-' concat str1 as str2 from t2x_1e5
    UNION ALL SELECT 300000 + id, str1, SUBSTRING(str1,16,1) concat '-' concat str1 as str2 from t2x_1e5
    UNION ALL SELECT 400000 + id, str1, SUBSTRING(str1,17,1) concat '-' concat str1 as str2 from t2x_1e5
    UNION ALL SELECT 500000 + id, str1, SUBSTRING(str1,18,1) concat '-' concat str1 as str2 from t2x_1e5
    UNION ALL SELECT 600000 + id, str1, SUBSTRING(str1,20,1) concat '-' concat str1 as str2 from t2x_1e5
    UNION ALL SELECT 700000 + id, str1, SUBSTRING(str1,21,1) concat '-' concat str1 as str2 from t2x_1e5
    UNION ALL SELECT 800000 + id, str1, SUBSTRING(str1,22,1) concat '-' concat str1 as str2 from t2x_1e5
    UNION ALL SELECT 900000 + id, str1, SUBSTRING(str1,23,1) concat '-' concat str1 as str2 from t2x_1e5;

/* SQL DB

INSERT INTO t2x_1e6_b
    SELECT id, str1, SUBSTRING(str1,12,1) + '-' +  str1 as str2 from t2x_1e5
    UNION ALL SELECT 100000 + id, str1, SUBSTRING(str1,13,1) + '-' + str1 as str2 from t2x_1e5
    UNION ALL SELECT 200000 + id, str1, SUBSTRING(str1,15,1) + '-' + str1 as str2 from t2x_1e5
    UNION ALL SELECT 300000 + id, str1, SUBSTRING(str1,16,1) + '-' + str1 as str2 from t2x_1e5
    UNION ALL SELECT 400000 + id, str1, SUBSTRING(str1,17,1) + '-' + str1 as str2 from t2x_1e5
    UNION ALL SELECT 500000 + id, str1, SUBSTRING(str1,18,1) + '-' + str1 as str2 from t2x_1e5
    UNION ALL SELECT 600000 + id, str1, SUBSTRING(str1,20,1) + '-' + str1 as str2 from t2x_1e5
    UNION ALL SELECT 700000 + id, str1, SUBSTRING(str1,21,1) + '-' + str1 as str2 from t2x_1e5
    UNION ALL SELECT 800000 + id, str1, SUBSTRING(str1,22,1) + '-' + str1 as str2 from t2x_1e5
    UNION ALL SELECT 900000 + id, str1, SUBSTRING(str1,23,1) + '-' + str1 as str2 from t2x_1e5;


*/