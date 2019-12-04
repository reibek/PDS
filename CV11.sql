drop database link db_link_cloud;

create database link db_link_cloud
connect to student01
    identified by student01
    using '(DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = oradat2.uniza.sk)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = orcl)
    )
  )';
  
select * from  letisko.l_osoba@db_link_cloud
where priezvisko not in (select priezvisko from os_udaje);