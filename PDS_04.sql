--==============================================================================

create or replace type t_adresa as object(
    ulica varchar2(15),
    psc char(5),
    mesto varchar2(25),
    member procedure vypis
);

create or replace type body t_adresa as
    member procedure vypis is
    begin
        DBMS_OUTPUT.PUT_LINE(self.ulica || ', ' || self.psc || ' ' || self.mesto);
    end vypis;
end;

--==============================================================================

create or replace type t_osoba as object(
    meno varchar2(10),
    priezvisko varchar2(15),
    adresa t_adresa,
    member procedure vypis_adresu
);

create or replace type body t_osoba as
    member procedure vypis_adresu is
    begin
        DBMS_OUTPUT.PUT_LINE(meno || ' ' || priezvisko);
        adresa.vypis;
    end vypis_adresu;
    map member function tried return varchar2 is 
    begin
        return meno || priezvisko;
    end tried;
end;

--==============================================================================

create table tab_1 of t_osoba;

alter type t_osoba add map member function tried
    return varchar2 cascade;
    
--==============================================================================

create table zamestnanci (
    osoba t_osoba,
    os_cislo integer
);

insert into zamestnanci
    values(t_osoba('Andrej', 'Rabek', t_adresa('Gorkeho 38', '03601', 'Martin')), 11223344);
    
insert into zamestnanci
    values(t_osoba('Jozef', 'Malik', t_adresa('Visnova 56', '04663', 'Bratislava')), 11223345);

insert into zamestnanci
    values(t_osoba('Koloman', 'Matny', t_adresa('Jamna 35', '38859', 'Nitra')), 11223343);
    
--==============================================================================

select z.osoba.priezvisko pr, z.osoba.meno
from zamestnanci z
order by pr;

select z.osoba.priezvisko pr, z.osoba.meno
from zamestnanci z
order by osoba;

--==============================================================================

alter type t_osoba add order member function tried2
    return varchar2 cascade;