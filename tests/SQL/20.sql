/*
  create the schema and the function
*/

DROP TABLE t2x_1e5;
DROP TABLE t2x_1e6_a;
DROP TABLE t2x_1e6_b;

CREATE TABLE t2x_1e5
( 
    id INT NOT NULL,
    str1 varchar(50) NOT NULL
);

CREATE TABLE t2x_1e6_a
( 
    id INT NOT NULL,
    str1 varchar(50) NOT NULL, 
    str2 varchar(50) NOT NULL
);

CREATE TABLE t2x_1e6_b
( 
    id INT NOT NULL,
    str1 varchar(50) NOT NULL, 
    str2 varchar(50) NOT NULL
);

/*
CREATE FUNCTION newguid() RETURNS CHAR(32) NOT DETERMINISTIC RETURN hex(generate_unique()) || hex(CHR(CAST(RAND()*255 AS SMALLINT))) || hex(CHR(CAST(RAND()*255 AS SMALLINT))) || hex(CHR(CAST(RAND()*255 AS SMALLINT)));
*/