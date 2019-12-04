-- 1. pre tabulky zo schemy priklad db2
-- Spravte ulozenu funkciu priemer, priemer2 s parametrami skolsky rok(rok) a 
-- osobne cslo (oc), ktora vrati studijny priemer zadaneho studenta od pociatku 
-- studia po zadany skolsky rok (vratane).
-- (a) priemer - pomocou kurzoru

CREATE OR REPLACE FUNCTION PRIEMER
(   OC      PRIKLAD_DB2.STUDENT.OS_CISLO%TYPE,
    ROK     PRIKLAD_DB2.ZAP_PREDMETY.SKROK%TYPE     ) 
RETURN NUMBER AS
CURSOR CUR_STUDENT(OSC PRIKLAD_DB2.STUDENT.OS_CISLO%TYPE, SROK PRIKLAD_DB2.ZAP_PREDMETY.SKROK%TYPE) IS
            SELECT 
                SUM(CASE
                    WHEN VYSLEDOK = 'A' THEN 1 
                    WHEN VYSLEDOK = 'B' THEN 1.5
                    WHEN VYSLEDOK = 'C' THEN 2
                    WHEN VYSLEDOK = 'D' THEN 2.5
                    WHEN VYSLEDOK = 'E' THEN 3
                    WHEN VYSLEDOK = 'F' THEN 4
                    WHEN VYSLEDOK IS NULL THEN 4
                    ELSE CAST(VYSLEDOK AS INTEGER)
                END * ECTS) / SUM(ECTS) AS PRIEMER     
            FROM PRIKLAD_DB2.ZAP_PREDMETY
            WHERE OS_CISLO = OSC
                AND CIS_PREDM IN (
                    SELECT CIS_PREDM 
                    FROM PRIKLAD_DB2.ZAP_PREDMETY
                        JOIN PRIKLAD_DB2.PREDMET_BOD USING (CIS_PREDM, SKROK)
                    WHERE (FORMA_KONT = 's' AND ZAPOCET IS NOT NULL AND DATUM_SK IS NOT NULL AND VYSLEDOK IS NOT NULL)
                        OR (FORMA_KONT = 'e' AND DATUM_SK IS NOT NULL AND VYSLEDOK IS NOT NULL)
                        OR (FORMA_KONT = 'z' AND ZAPOCET IS NOT NULL AND VYSLEDOK IS NOT NULL)
                );
BEGIN
    FOR REC IN CUR(OC, 2019) LOOP
        
    END LOOP;
END PRIEMER;
/

SELECT OS_CISLO FROM PRIKLAD_DB2.ZAP_PREDMETY;

SELECT KVET3.PRIEMER(2437) FROM DUAL;
/

-- 2. Select v selecte
-- Vypiste studenta s maximalnym poctom kreditov. (Ak je ich viac, vypiste 
-- vsetkych)

SELECT OS_CISLO, MAX(SUM(ECTS))
FROM ZAP_PREDMETY

-- 4.





