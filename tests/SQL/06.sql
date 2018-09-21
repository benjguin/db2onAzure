SELECT count(*)
FROM t100ka a 
inner join t100kb b on a.str2 = b.str2 and a.id <> b.id;
