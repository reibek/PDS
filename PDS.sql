-- OSOBY, KT. NEBOLI STUDENTAMI
SELECT * FROM OS_UDAJE WHERE ROD_CISLO NOT IN 
    (SELECT ROD_CISLO FROM STUDENT);
    
-- POCET DNI OD 10.01.2015 DO DNES
SELECT TRUNC((SYSDATE-TO_DATE('10.01.2015', 'DD.MM.YYYY'))) FROM DUAL;

-- OSOBY, KT. NEBOLI STUDENTAMI POMOCOU EXISTS
SELECT * FROM OS_UDAJE WHERE NOT EXISTS 
    (SELECT * FROM STUDENT WHERE OS_UDAJE.ROD_CISLO=STUDENT.ROD_CISLO);
    
-- KU KAZDEMU ROCNIKU POCET STUDENTOV
SELECT ROCNIK, COUNT(ROD_CISLO) AS POCET_STUDENTOV FROM STUDENT
    GROUP BY ROCNIK
    ORDER BY ROCNIK;
    
-- VYPISTE MENNY ZOZNAM OSOB, KT. BOLI ASPON 2KRAT STUDENTAMI
SELECT MENO, PRIEZVISKO FROM OS_UDAJE
    WHERE ROD_CISLO IN (
        SELECT OS.ROD_CISLO
            FROM OS_UDAJE OS JOIN STUDENT ST ON (OS.ROD_CISLO = ST.ROD_CISLO)
            GROUP BY OS.ROD_CISLO
            HAVING COUNT(OS.ROD_CISLO) > 1
        );
        
SELECT OS.ROD_CISLO, OS.MENO, OS.PRIEZVISKO
    FROM OS_UDAJE OS JOIN STUDENT ST ON (OS.ROD_CISLO = ST.ROD_CISLO)
    GROUP BY OS.ROD_CISLO, OS.MENO, OS.PRIEZVISKO
    HAVING COUNT(OS.ROD_CISLO) > 1;
    
-- VYPISTE OSOBY, KT. NEMAJU EVIDOVANE POISTENIE K MINULEMU ROKU


-- KU KAZD. OKRESU VYPISTE ZOZNAM ZIEN, AK NEMA ZIADNU ZENU, TAK ASPON NAZOV OKRESU
SELECT N_OKRESU, OS.MENO, OS.PRIEZVISKO
FROM P_OKRES JOIN P_MESTO USING (ID_OKRESU) LEFT JOIN P_OSOBA OS USING (PSC)
WHERE SUBSTR(OS.ROD_CISLO, 3, 1) = 5 OR SUBSTR(OS.ROD_CISLO, 3, 1) = 6
ORDER BY N_OKRESU;
    
-- KOLKO ZAMESTNANCOV MA TESCO
SELECT COUNT(*) FROM P_ZAMESTNAVATEL ZA JOIN P_ZAMESTNANEC ZM ON (ZA.ICO = ZM.ID_ZAMESTNAVATELA)
    WHERE ZA.NAZOV = 'Tesco';
    
-- KU KAZDEMU VEKU POCET OSOB OSLOBODENYCH OD PLATENIA POISTENIA
SELECT DISTINCT ABS(TRUNC(months_between(TO_DATE(SUBSTR(ROD_CISLO,1,2), 'YY'), SYSDATE) /12)) AS VEK, COUNT(*) AS POCET
FROM P_OSOBA OS JOIN P_POISTENIE PO USING (ROD_CISLO)
WHERE UPPER(PO.OSLOBODENY) = 'A'
GROUP BY ABS(TRUNC(months_between(TO_DATE(SUBSTR(ROD_CISLO,1,2), 'YY'), SYSDATE) /12))
ORDER BY ABS(TRUNC(months_between(TO_DATE(SUBSTR(ROD_CISLO,1,2), 'YY'), SYSDATE) /12));
    
SELECT DISTINCT ROD_CISLO, OS.MENO, OS.PRIEZVISKO,
TO_DATE(SUBSTR(ROD_CISLO,1,2)||MOD(CAST(SUBSTR(ROD_CISLO,3,2) AS INTEGER), 50)||SUBSTR(ROD_CISLO,5,2), 'YYMMDD') AS DATUM
FROM P_OSOBA OS JOIN P_POISTENIE PO USING (ROD_CISLO)
    WHERE UPPER(PO.OSLOBODENY) = 'A';
    
-- ZOZNAM KTO JE OSLOBODENY OD PLATENIA POISTENIA A NEPOBERA ZIADEN PRISPEVOK
SELECT DISTINCT ROD_CISLO, OS.MENO, OS.PRIEZVISKO
FROM P_OSOBA OS JOIN P_POISTENIE PO USING (ROD_CISLO)
WHERE UPPER(PO.OSLOBODENY) = 'A' AND ROD_CISLO NOT IN (SELECT DISTINCT ROD_CISLO
    FROM P_POBERATEL);
    
-- KU KAZDEJ OSOBE KOLKO ZAPLATILA MINULY ROK
CREATE TABLE POM AS SELECT 
    MENO, 
    PRIEZVISKO, 
    CASE TO_CHAR(DAT_PLATBY, 'YYYY') 
        WHEN '2016' THEN SUMA
        ELSE 0 
    END AS ZAPLATENE
FROM P_OSOBA 
    LEFT JOIN P_POISTENIE USING (ROD_CISLO)
    LEFT JOIN P_ODVOD_PLATBA USING (ID_POISTENCA)
;

SELECT MENO, PRIEZVISKO, SUM(NVL(ZAPLATENE, 0)) AS SUMA_SPOLU
FROM POM 
GROUP BY MENO, PRIEZVISKO
ORDER BY SUMA_SPOLU DESC;

DROP TABLE POM;

-- KU KAZDEMU CLOVEKU JEHO MENOVCA
SELECT DISTINCT
    OS1.MENO,
    OS1.PRIEZVISKO,
    OS1.ROD_CISLO,
    OS2.MENO,
    OS1.PRIEZVISKO,
    OS2.ROD_CISLO
FROM P_OSOBA OS1, P_OSOBA OS2
WHERE 0=0
    AND OS1.ROD_CISLO != OS2.ROD_CISLO
    AND OS1.PRIEZVISKO = OS2.PRIEZVISKO;
    
-- OSOBY POBERAJUCE VIAC AKO JEDEN TYP PRISPEVKU
SELECT 
    ROD_CISLO,
    OS.MENO,
    OS.PRIEZVISKO,
    COUNT(DISTINCT PO.ID_TYPU)
FROM 
    P_OSOBA OS
    JOIN P_POBERATEL PO USING (ROD_CISLO)
WHERE 
    PO.DAT_DO >= SYSDATE 
    OR PO.DAT_DO IS NULL 
GROUP BY
    ROD_CISLO,
    OS.MENO,
    OS.PRIEZVISKO
HAVING 
    COUNT(DISTINCT PO.ID_TYPU) > 1
;

-- OSOBY NEMAJUCE ZAPLATENE ODVODY ZA POSL 6 MESIACOV
SELECT 
    ROD_CISLO,
    OS.MENO,
    OS.PRIEZVISKO
FROM 
    P_OSOBA OS
    LEFT JOIN P_POISTENIE PO USING (ROD_CISLO)
    LEFT JOIN P_ODVOD_PLATBA PL USING (ID_POISTENCA)
WHERE 
    ID_POISTENCA NOT IN (
        SELECT ID_POISTENCA 
        FROM P_ODVOD_PLATBA PL2
        WHERE PL2.DAT_PLATBY > ADD_MONTHS(SYSDATE, -6)
    )
GROUP BY
    ROD_CISLO,
    OS.MENO,
    OS.PRIEZVISKO
;

-- K MESIACOM MINULEHO ROKU CELK. SUMA VYPLATENYCH PRISPEVKOV
SELECT 
    EXTRACT(MONTH FROM PR.KEDY),
    SUM(SUMA)
FROM
    P_PRISPEVKY PR
GROUP BY
    EXTRACT(MONTH FROM PR.KEDY)
ORDER BY 
    EXTRACT(MONTH FROM PR.KEDY)
;

-- OSOBY SUCASNE VIACKRAT POISTENCAMI
SELECT
    MENO,
    PRIEZVISKO,
    DAT_OD,
    DAT_DO
FROM
    P_OSOBA
    JOIN P_POISTENIE USING (ROD_CISLO)
ORDER BY 
    PRIEZVISKO
;

-- OSOBY NEPLNIACE SI SVOJE POVINNOSTI ASPON V 20% PRIPADOV
SELECT 
    ROD_CISLO,
    OS.MENO,
    OS.PRIEZVISKO,
    CASE
        WHEN DAT_PLATBY > ADD_MONTHS(OBDOBIE, 2) THEN 1
        ELSE 0
    END AS NESPLNENE
FROM 
    P_OSOBA OS
    LEFT JOIN P_POISTENIE PO USING (ROD_CISLO)
    LEFT JOIN P_ODVOD_PLATBA PL USING (ID_POISTENCA)
ORDER BY NESPLNENE DESC
;










