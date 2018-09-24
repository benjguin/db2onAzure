/*
  create the schema and the function
*/

DROP TABLE t10k;
DROP TABLE t100ka;
DROP TABLE t100kb;

CREATE TABLE t10k
( 
    id INT NOT NULL,
    str1 varchar(50) NOT NULL
);

CREATE TABLE t100ka
( 
    id INT NOT NULL,
    str1 varchar(50) NOT NULL, 
    str2 varchar(50) NOT NULL
);

CREATE TABLE t100kb
( 
    id INT NOT NULL,
    str1 varchar(50) NOT NULL, 
    str2 varchar(50) NOT NULL
);

CREATE FUNCTION newguid() RETURNS CHAR(32) NOT DETERMINISTIC RETURN hex(generate_unique()) || hex(CHR(CAST(RAND()*255 AS SMALLINT))) || hex(CHR(CAST(RAND()*255 AS SMALLINT))) || hex(CHR(CAST(RAND()*255 AS SMALLINT)));
