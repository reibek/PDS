desc zamestnanci;

create table tab_objects of t_osoba;

insert into tab_objects
select osoba from zamestnanci;

select * from tab_objects p order by value(p);

select * from zamestnanci order by osoba;

desc t_osoba;

select meno, priezvisko, to_date(substr(rod_cislo, 5,2)||mod(substr(rod_cislo,3,2),50)||substr(rod_cislo,1,2),'DDMMYY')
from SOC_POISTOVNA.p_osoba;

create or replace function najdiZradu(rc SOC_POISTOVNA.p_osoba.rod_cislo%TYPE) return number
is 
    vek number(3);
begin
    select months_between(to_date(substr(rc, 5,2)||mod(cast(substr(rc,3,2)as integer), 50)||substr(rc,1,2),'DDMMYY'), sysdate) / 12
    into vek
    from dual;
    
    return vek;
    
exception when others then return -1;
end;
/

select meno, priezvisko, najdiZradu(rod_cislo)
from SOC_POISTOVNA.p_osoba;

select * from 
    (select meno, priezvisko, rank() over (order by najdiZradu(rod_cislo) desc) as ra
    from p_osoba)
where ra between 1 and 3;

select * from 
    (select meno, priezvisko, rank() over (order by najdiZradu(rod_cislo) desc) as ra
    from p_osoba)
where ra <= (select count(*) from p_osoba)/100 * 3;


