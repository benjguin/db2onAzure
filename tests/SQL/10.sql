DROP TABLE TESTUNIQUE;

CREATE TABLE TESTUNIQUE 
( 
    ID1 INT NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1, INCREMENT BY 1, NO CACHE),
    ID2 CHAR(13) FOR BIT DATA
);
