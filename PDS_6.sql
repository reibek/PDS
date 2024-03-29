SELECT ST_ODBOR, ST_ZAMERANIE, POPIS_ODBORU, NVL(POPIS_ZAMERANIA, 'BEZ ZAMERANIA'),
    COUNT(CASE WHEN ROCNIK = 1 THEN 1 ELSE NULL END) AS POCET_PRVAKOV,
    COUNT(CASE WHEN ROCNIK = 2 THEN 1 ELSE NULL END) AS POCET_DRUHAKOV,
    COUNT(CASE WHEN ROCNIK = 3 THEN 1 ELSE NULL END) AS POCET_TRETIAKOV
FROM STUDENT RIGHT JOIN ST_ODBORY USING (ST_ODBOR, ST_ZAMERANIE)
GROUP BY ST_ODBOR, ST_ZAMERANIE, POPIS_ODBORU, NVL(POPIS_ZAMERANIA, 'BEZ ZAMERANIA');

--==============================================================================
-- 1. FUNKCIA PRE VYPOCET VAZENEHO STUDIJENHO PRIEMERU
--  a.) POMOCOU KURZORA

CREATE OR REPLACE FUNCTION PRIEMER 
    (   OC PRIKLAD_DB2.STUDENT.OS_CISLO%TYPE,
        ROK PRIKLAD_DB2.ZAP_PREDMETY.SKROK%TYPE )
RETURN DOUBLE
IS
    V_PRIEMER DOUBLE(2,2) := 0.0;
    CURSOR CUR_STUDENTI IS 
        SELECT 
            ECTS, 
            CASE VYSLEDOK 
                WHEN 'A' THEN 1 
                WHEN 'B' THEN 1.5
                WHEN 'C' THEN 2
                WHEN 'D' THEN 2.5
                WHEN 'E' THEN 3
                ELSE 4
            END AS KOEF
        FROM PRIKLAD_DB2.ZAP_PREDMETY JOIN PREDMET_BOD USING (CIS_PREDM, SKROK)
        WHERE OS_CISLO = OC
            AND ( CASE FORMA_KONT
                WHEN
            );
BEGIN

END;
/