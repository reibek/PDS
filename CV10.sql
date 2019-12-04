-- 1.   Importujte si tabu�ku osoba_tab (pou�ite export export_osoba_tab.exp). 
--      Zistite si pou��vate�a, ktor� export vykonal. 

-- [PUTTY]:
--  imp rabek2@orcl_obelix fromuser=student touser=rabek2 file=export_osoba_tab.exp

-- 2.   Ko�ko riadkov bolo naimportovan�ch? Ak� �trukt�ru m� tabu�ka? 

SELECT COUNT(*) FROM OSOBA_TAB;

DESC OSOBA_TAB;

-- 3.   Vytvorte prim�rny k���. Index nech sa zadefinuje implicitne. 

ALTER TABLE OSOBA_TAB ADD CONSTRAINT OSOBA_PK PRIMARY KEY (ROD_CISLO);

-- 4.   Vytvorte index nad atrib�tmi meno a priezvisko (v danom porad�). 

CREATE INDEX IND_OSOBA_M_P ON OSOBA_TAB(MENO, PRIEZVISKO);

-- 5.   Pok�ste sa vytvori� index nad atrib�tmi priezvisko a meno (v danom 
--      porad�). Je to mo�n�? Ak �no, pre�o, ak nie, pre�o? 

CREATE INDEX IND_OSOBA_P_M ON OSOBA_TAB(PRIEZVISKO, MENO);

-- 6.   Vyp�te si zoznam vytvoren�ch indexov (user_indexes). 

SELECT * FROM user_indexes WHERE TABLE_NAME = 'OSOBA_TAB';

-- 7.   Ktor� z nich je prim�rnym k���om? (user_constraints).

SELECT * FROM user_constraints WHERE TABLE_NAME = 'OSOBA_TAB';

-- 8.   Vyp�te atrib�ty, z ktor�ch sa skladaj� jednotliv� indexy? V akom porad�
--      s� indexovan� atrib�ty? (user_ind_columns)

SELECT * FROM user_ind_columns WHERE TABLE_NAME = 'OSOBA_TAB';

-- 9.   Vytvorte si tabu�ku muzi_tab, ktor� bude ma� rovnak� �trukt�ru ako 
--      tabu�ka osoba_tab, ale bude obsahova� len �daje o mu�och. 
--      Ak� kardinalitu m� vytvoren� tabu�ka? Ak� indexy s� v nej definovan�? 

CREATE TABLE MUZI_TAB AS 
    SELECT * FROM OSOBA_TAB WHERE SUBSTR(ROD_CISLO,3,1) IN ('0','1');
    
DESC MUZI_TAB;

SELECT * FROM user_indexes WHERE TABLE_NAME = 'MUZI_TAB';

-- 10.  Vyp�te meno a priezvisko osoby s rodn�m ��slom 660227/4987. Ak� 
--      pr�stupov� met�da bola pou�it�? Ktor� index (ak nejak� pou�it� bol...)?

SELECT MENO, PRIEZVISKO FROM MUZI_TAB WHERE ROD_CISLO = '660227/4987';

SELECT * FROM TABLE(DBMS_XPLAN.display_cursor);

-- 11.  Vyp�te �daje (rod_cislo, meno) o osobe, ktorej priezvisko je Jurisin. 
--      Ko�ko z�znamov ste z�skali? Ak� pr�stupov� met�da bola pou�it�? Pre�o? 
--      (porovn�vajte na rovnos�). 

SELECT ROD_CISLO, MENO FROM OSOBA_TAB WHERE PRIEZVISKO = 'Jurisin';

-- 12.  Vyp�te rodn� ��sla priezvisk� v�etk�ch os�b, ktor�ch meno je Michal. 
--      Ko�ko z�znamov ste z�skali? Ak� pr�stupov� met�da bola pou�it�? Ktor� 
--      index bol pou�it�? Pre�o? 

SELECT ROD_CISLO, PRIEZVISKO FROM OSOBA_TAB WHERE MENO = 'Michal';

-- 13.  Vyp�te rodn� �isla a priezvisk� v�etk�ch os�b, ktor�ch meno je Michal.
--      Pou�ite hint s indexom s atrib�tmi meno, priezvisko. Ko�ko z�znamov ste 
--      z�skali? Ak� pr�stupov� met�da bola pou�it�? Ktor� index bol pou�it�? 
--      Pre�o?

SELECT /*+ INDEX(OSOBA_TAB IND_OSOBA_M_P) */
    ROD_CISLO, PRIEZVISKO FROM OSOBA_TAB WHERE MENO = 'Michal';

-- 14.  Vyp�te rodn� ��sla a priezvisk� v�etk�ch os�b, ktor�ch meno je Michal. 
--      Pou�ite hint s indexom s atrib�tmi priezvisko, meno. Ko�ko z�znamov ste 
--      z�skali? Ak� pr�stupov� met�da bola pou�it�? Ktor� index bol pou�it�? 
--      Pre�o?

SELECT /*+ INDEX(OSOBA_TAB IND_OSOBA_P_M) */
    ROD_CISLO, PRIEZVISKO FROM OSOBA_TAB WHERE MENO = 'Michal';
    
-- 15.  Vyp�te rodn� ��sla a priezvisk� v�etk�ch os�b, ktor�ch meno je Roderik.
--      Ko�ko z�znamov ste z�skali? Ak� pr�stupov� met�da bola pou�it�? Ktor� 
--      index bol pou�it�? Pre�o? 

SELECT ROD_CISLO, PRIEZVISKO FROM OSOBA_TAB WHERE MENO = 'Roderik';

-- 16.  Vyp�te rodn� ��sla a priezvisk� v�etk�ch os�b, ktor�ch meno je Roderik. 
--      Pou�ite hint s indexom s atrib�tmi priezvisko, meno. Ko�ko z�znamov ste 
--      z�skali? Ak� pr�stupov� met�da bola pou�it�? Ktor� index bol pou�it�? 
--      Pre�o? 

SELECT /*+ INDEX(OSOBA_TAB IND_OSOBA_P_M) */
    ROD_CISLO, PRIEZVISKO FROM OSOBA_TAB WHERE MENO = 'Roderik';
    

