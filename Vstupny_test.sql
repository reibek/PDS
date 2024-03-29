-- Pomocou pr�kazu/ pr�kazov DELETE vyma�te osoby, ktor� zaplatili za posledn� 2
-- mesiace na odvodoch najmen�iu sumu, pri�om dbajte na referen�n� integritu
CREATE TABLE POM AS
    SELECT ROD_CISLO 
    FROM P_OSOBA 
        JOIN P_POISTENIE USING (ROD_CISLO)
        JOIN P_ODVOD_PLATBA USING (ID_POISTENCA)
    WHERE DAT_PLATBY BETWEEN ADD_MONTHS(SYSDATE, -2) AND SYSDATE
        AND SUMA = (SELECT MIN(SUMA) FROM P_ODVOD_PLATBA);
        
DELETE FROM P_ODVOD_PLATBA
WHERE ID_POISTENCA = (
    SELECT ID_POISTENCA 
    FROM P_POISTENIE 
    WHERE ROD_CISLO IN (SELECT * FROM POM)
    );
    
DELETE FROM P_POISTENIE
WHERE ROD_CISLO IN (SELECT * FROM POM);

DELETE FROM P_ZAMESTNANEC
WHERE ROD_CISLO IN (SELECT * FROM POM);

DELETE FROM P_PRISPEVKY
WHERE ID_POBERATELA = (
    SELECT ID_POBERATELA 
    FROM P_POBERATEL 
    WHERE ROD_CISLO IN (SELECT * FROM POM)
    );
    
DELETE FROM P_POBERATEL
WHERE ROD_CISLO IN (SELECT * FROM POM);

DELETE FROM P_ZTP
WHERE ROD_CISLO IN (SELECT * FROM POM);

DELETE FROM P_ZAMESTNAVATEL
WHERE ICO IN (SELECT * FROM POM);

DELETE FROM P_PLATITEL
WHERE ID_PLATITELA IN (SELECT * FROM POM);

DELETE FROM P_OSOBA
WHERE ROD_CISLO IN (SELECT * FROM POM);
    
DROP TABLE POM;

-- Pomocou pr�kazu/ pr�kazov DELETE vyma�te inform�cie o v�etk�ch �en�ch ktor� 
-- maj� narodeniny zajtra, pri�om dbajte na referen�n� integritu.
CREATE TABLE POM_ZENY AS
    SELECT MENO, PRIEZVISKO, ROD_CISLO, TO_DATE(SUBSTR(ROD_CISLO,1,2) || DECODE(SUBSTR(ROD_CISLO,3,1),'5','0','6','1') || SUBSTR(ROD_CISLO,4,1) || SUBSTR(ROD_CISLO,5,2), 'YYMMDD') AS DATUM_NARODENIA
    FROM P_OSOBA 
    WHERE (SUBSTR(ROD_CISLO,3,1) = 5
        OR SUBSTR(ROD_CISLO,3,1) = 6);
        
CREATE TABLE POM_ZAJTRA AS 
    SELECT MENO, PRIEZVISKO, DATUM_NARODENIA
    FROM POM_ZENY
    WHERE TO_CHAR(DATUM_NARODENIA, 'DDMM') = TO_CHAR(SYSDATE+1, 'DDMM');
    
    -- DELETE AKO V PREDCHADZAJUCICH 
    
DROP TABLE POM_ZAJTRA;
DROP TABLE POM_ZENY;

-- Pomocou pr�kazu/ pr�kazov DELETE vyma�te pr�spevky osob�m, ktor� bud� tento 
-- rok oslavova� okr�hle narodeniny, pri�om dbajte na referen�n� integritu.
CREATE TABLE POM_OKRUHLE AS
    SELECT ROD_CISLO
    FROM P_OSOBA
    WHERE MOD(MONTHS_BETWEEN(TO_DATE('0101' || SUBSTR(ROD_CISLO,1,2), 'DDMMYY'), TRUNC(SYSDATE, 'YYYY')) / 12, 10) = 0;
    
DELETE FROM P_PRISPEVKY PR
WHERE PR.ID_POBERATELA IN (
    SELECT PO.ID_POBERATELA 
    FROM P_POBERATEL PO
    WHERE PO.ROD_CISLO IN (
        SELECT * FROM POM_OKRUHLE));
        
SELECT COUNT(*) FROM P_PRISPEVKY;

SELECT * FROM POM_OKRUHLE;

DROP TABLE POM_OKRUHLE;

-- Vyp�te mest�, ktor� maj� viac ako 1 PS�
SELECT COUNT(PSC), N_MESTA 
FROM P_MESTO
GROUP BY N_MESTA
HAVING COUNT(PSC) > 1
ORDER BY COUNT(PSC) DESC;

-- Ku ka�d�mu n�zvu mesta vyp�te po�et aktu�lne nezamestnan�ch os�b, ktor� maj�
-- aspo� 2 r�zne postihnutia

CREATE TABLE POM_DVE_POST AS 
    SELECT COUNT(ID_POSTIHNUTIA) AS POCET, ROD_CISLO
    FROM P_ZTP
    GROUP BY ROD_CISLO
    HAVING COUNT(ID_POSTIHNUTIA) > 1;
    
SELECT OS.MENO, OS.PRIEZVISKO
FROM P_OSOBA OS
WHERE OS.ROD_CISLO NOT IN (SELECT ROD_CISLO FROM P_ZAMESTNANEC)
    AND OS.ROD_CISLO IN (SELECT ROD_CISLO FROM POM_DVE_POST);
    
DROP TABLE POM_DVE_POST;
