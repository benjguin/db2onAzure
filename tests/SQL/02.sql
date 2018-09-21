insert into t10k with dummy(id) as(select 1 from sysibm.sysdummy1 union all select id + 1 from dummy where id < 10000) select id, newguid() as str1 from dummy;
