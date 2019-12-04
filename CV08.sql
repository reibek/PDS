-- 1. vytvorte tabulku osoba_xml typu XMLTYPE:

CREATE TABLE OSOBA_XML OF XMLTYPE;

-- 2. vlozte aspon dva riadky (2 XML subory) s nasledovnou strukturou:
--  <osoba rc="810505/2323">
--      <meno>Jozko</meno>
--      <priezvisko>Mrkvicka</priezvisko>
--  </osoba>

INSERT INTO OSOBA_XML VALUES 
(XMLTYPE('
    <osoba rc="810505/2323">
        <meno>Jozko</meno>
        <priezvisko>Mrkvicka</priezvisko>
    </osoba>
'));

INSERT INTO OSOBA_XML VALUES 
(XMLTYPE('
    <osoba rc="921128/4757">
        <meno>Martin</meno>
        <priezvisko>Vrba</priezvisko>
    </osoba>
'));

-- 3. vyp?ste obsah tabulky osoba_xml

SELECT * FROM OSOBA_XML O;

SELECT VALUE(O) FROM OSOBA_XML O;

SELECT OBJECT_VALUE FROM OSOBA_XML;

-- 4. vyp?ste menny zoznam osob

SELECT EXTRACTVALUE(VALUE(O), '/osoba/@rc') AS ROD_CISLO,
    EXTRACTVALUE(VALUE(O), '/osoba/meno') AS MENO,
    EXTRACTVALUE(VALUE(O), '/osoba/priezvisko') AS PRIEZVISKO
FROM OSOBA_XML O;

-- 5. zmente priezvisko nejakej osoby

UPDATE OSOBA_XML O
SET VALUE(O) = UPDATEXML(VALUE(O),
    '/osoba/priezvisko/text()', 'Hrasok')
WHERE EXTRACTVALUE(VALUE(O), '//@rc') = '810505/2323';

-- 6. zmente rodne c?slo nejakej osoby

UPDATE OSOBA_XML O
SET VALUE(O) = UPDATEXML(VALUE(O),
    '/osoba/@rc', '921128/1111')
WHERE EXTRACTVALUE(VALUE(O), '//@rc') = '921128/4757';

-- 7. vlozte osobu z osoba_xml do tabulky os_udaje

INSERT INTO OS_UDAJE
    SELECT 
        EXTRACTVALUE(VALUE(O), '/osoba/@rc'),
        EXTRACTVALUE(VALUE(O), '/osoba/meno'),
        EXTRACTVALUE(VALUE(O), '/osoba/priezvisko'), 
        NULL, 
        NULL, 
        NULL
    FROM OSOBA_XML O
    WHERE EXTRACTVALUE(VALUE(O), '//@rc') = '921128/1111';
    
SELECT * FROM OS_UDAJE;

--==============================================================================
-- Vytvorte "Zoznamy studentov na predmety” pre predmety A914 a A913 v sk. roku 
-- 2005 zo schemy priklad_db2
--==============================================================================

SET LONG 2000;
SET PAGES 1000;
SPOOL 'D:\FRI\ING\I. SEMESTER\Pokroèilé databázové systémy\Zoznamy studentov na predmety.xml';

SELECT XMLROOT(
    XMLELEMENT("predmet",
        XMLATTRIBUTES(CIS_PREDM AS "cislo",
            NAZOV AS "nazov"    
        ),
        XMLAGG(XMLELEMENT("student",
            XMLFOREST(
                OS_CISLO AS "oc",
                MENO || ' ' || PRIEZVISKO AS "meno",
                ST_SKUPINA AS "skupina"
            )
        ))
    )
, version '1.0') AS XML
FROM
    PRIKLAD_DB2.ZAP_PREDMETY
    JOIN PRIKLAD_DB2.PREDMET USING (CIS_PREDM)
    JOIN PRIKLAD_DB2.STUDENT USING (OS_CISLO)
    JOIN PRIKLAD_DB2.OS_UDAJE USING (ROD_CISLO)
WHERE
    CIS_PREDM IN ('A914','A913')
    AND SKROK = 2005
GROUP BY CIS_PREDM, NAZOV;

SPOOL OFF;

--==============================================================================
-- Vytvorte "Kontrolu studia studenta" s nasledovnou strukturou:
--==============================================================================

SET LONG 2000;
SET PAGES 1000;
SPOOL 'D:\FRI\ING\I. SEMESTER\Pokroèilé databázové systémy\Kontrola studenta.xml';

SELECT XMLROOT(
    XMLELEMENT("report", 
        XMLELEMENT("hlavicka",
            XMLFOREST(  'Kontrola studenta'     AS "title",
                        OS_CISLO                AS "os_cislo",
                        MENO                    AS "meno",
                        PRIEZVISKO              AS "priezvisko",
                        ST_SKUPINA              AS "st_skupina" 
            )
        ),
        XMLELEMENT("telo",
            XMLAGG(XML_POM.PREDMETY)
        ),
        XMLELEMENT("zaver",
            XMLATTRIBUTES(  'V Martine'                     AS "miesto",
                            TO_CHAR(SYSDATE, 'DD.MM.YYYY')  AS "datum",
                            USER                            AS "kto"
            )
        )
    )
, version '1.0') AS XML
FROM
    ( 
        SELECT  
            XMLELEMENT("skrok",
                XMLATTRIBUTES(SKROK AS "rok"),
                XMLAGG(XMLELEMENT("predmet",
                    XMLFOREST(  CIS_PREDM   AS "cis_predm",
                                NAZOV       AS "nazov",
                                VYSLEDOK    AS "znamka",
                                ECTS        AS "kredit"
                    )
                ))
            ) AS PREDMETY,
            SKROK
        FROM 
            PRIKLAD_DB2.ZAP_PREDMETY
            JOIN PRIKLAD_DB2.PREDMET USING (CIS_PREDM)
        WHERE OS_CISLO = 2950
        GROUP BY SKROK
    )XML_POM,
    PRIKLAD_DB2.STUDENT
    JOIN PRIKLAD_DB2.OS_UDAJE USING (ROD_CISLO)
WHERE OS_CISLO = 2950
GROUP BY OS_CISLO, MENO, PRIEZVISKO, ST_SKUPINA;

SPOOL OFF;



