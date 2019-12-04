-- 1.   Importujte si tabu¾ku osoba_tab (pouite export export_osoba_tab.exp). 
--      Zistite si pouívate¾a, ktorı export vykonal. 

-- [PUTTY]:
--  imp rabek2@orcl_obelix fromuser=student touser=rabek2 file=export_osoba_tab.exp

-- 2.   Ko¾ko riadkov bolo naimportovanıch? Akú štruktúru má tabu¾ka? 

SELECT COUNT(*) FROM OSOBA_TAB;

DESC OSOBA_TAB;

-- 3.   Vytvorte primárny k¾úè. Index nech sa zadefinuje implicitne. 

ALTER TABLE OSOBA_TAB ADD CONSTRAINT OSOBA_PK PRIMARY KEY (ROD_CISLO);

-- 4.   Vytvorte index nad atribútmi meno a priezvisko (v danom poradí). 

CREATE INDEX IND_OSOBA_M_P ON OSOBA_TAB(MENO, PRIEZVISKO);

-- 5.   Pokúste sa vytvori index nad atribútmi priezvisko a meno (v danom 
--      poradí). Je to moné? Ak áno, preèo, ak nie, preèo? 

CREATE INDEX IND_OSOBA_P_M ON OSOBA_TAB(PRIEZVISKO, MENO);

-- 6.   Vypíšte si zoznam vytvorenıch indexov (user_indexes). 

SELECT * FROM user_indexes WHERE TABLE_NAME = 'OSOBA_TAB';

-- 7.   Ktorı z nich je primárnym k¾úèom? (user_constraints).

SELECT * FROM user_constraints WHERE TABLE_NAME = 'OSOBA_TAB';

-- 8.   Vypíšte atribúty, z ktorıch sa skladajú jednotlivé indexy? V akom poradí
--      sú indexované atribúty? (user_ind_columns)

SELECT * FROM user_ind_columns WHERE TABLE_NAME = 'OSOBA_TAB';

-- 9.   Vytvorte si tabu¾ku muzi_tab, ktorá bude ma rovnakú štruktúru ako 
--      tabu¾ka osoba_tab, ale bude obsahova len údaje o muoch. 
--      Akú kardinalitu má vytvorená tabu¾ka? Aké indexy sú v nej definované? 

CREATE TABLE MUZI_TAB AS 
    SELECT * FROM OSOBA_TAB WHERE SUBSTR(ROD_CISLO,3,1) IN ('0','1');
    
DESC MUZI_TAB;

SELECT * FROM user_indexes WHERE TABLE_NAME = 'MUZI_TAB';

-- 10.  Vypíšte meno a priezvisko osoby s rodnım èíslom 660227/4987. Aká 
--      prístupová metóda bola pouitá? Ktorı index (ak nejakı pouitı bol...)?

SELECT MENO, PRIEZVISKO FROM MUZI_TAB WHERE ROD_CISLO = '660227/4987';

SELECT * FROM TABLE(DBMS_XPLAN.display_cursor);

-- 11.  Vypíšte údaje (rod_cislo, meno) o osobe, ktorej priezvisko je Jurisin. 
--      Ko¾ko záznamov ste získali? Aká prístupová metóda bola pouitá? Preèo? 
--      (porovnávajte na rovnos). 

SELECT ROD_CISLO, MENO FROM OSOBA_TAB WHERE PRIEZVISKO = 'Jurisin';

-- 12.  Vypíšte rodné èísla priezviská všetkıch osôb, ktorıch meno je Michal. 
--      Ko¾ko záznamov ste získali? Aká prístupová metóda bola pouitá? Ktorı 
--      index bol pouitı? Preèo? 

SELECT ROD_CISLO, PRIEZVISKO FROM OSOBA_TAB WHERE MENO = 'Michal';

-- 13.  Vypíšte rodné èisla a priezviská všetkıch osôb, ktorıch meno je Michal.
--      Pouite hint s indexom s atribútmi meno, priezvisko. Ko¾ko záznamov ste 
--      získali? Aká prístupová metóda bola pouitá? Ktorı index bol pouitı? 
--      Preèo?

SELECT /*+ INDEX(OSOBA_TAB IND_OSOBA_M_P) */
    ROD_CISLO, PRIEZVISKO FROM OSOBA_TAB WHERE MENO = 'Michal';

-- 14.  Vypíšte rodné èísla a priezviská všetkıch osôb, ktorıch meno je Michal. 
--      Pouite hint s indexom s atribútmi priezvisko, meno. Ko¾ko záznamov ste 
--      získali? Aká prístupová metóda bola pouitá? Ktorı index bol pouitı? 
--      Preèo?

SELECT /*+ INDEX(OSOBA_TAB IND_OSOBA_P_M) */
    ROD_CISLO, PRIEZVISKO FROM OSOBA_TAB WHERE MENO = 'Michal';
    
-- 15.  Vypíšte rodné èísla a priezviská všetkıch osôb, ktorıch meno je Roderik.
--      Ko¾ko záznamov ste získali? Aká prístupová metóda bola pouitá? Ktorı 
--      index bol pouitı? Preèo? 

SELECT ROD_CISLO, PRIEZVISKO FROM OSOBA_TAB WHERE MENO = 'Roderik';

-- 16.  Vypíšte rodné èísla a priezviská všetkıch osôb, ktorıch meno je Roderik. 
--      Pouite hint s indexom s atribútmi priezvisko, meno. Ko¾ko záznamov ste 
--      získali? Aká prístupová metóda bola pouitá? Ktorı index bol pouitı? 
--      Preèo? 

SELECT /*+ INDEX(OSOBA_TAB IND_OSOBA_P_M) */
    ROD_CISLO, PRIEZVISKO FROM OSOBA_TAB WHERE MENO = 'Roderik';
    

