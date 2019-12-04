--==============================================================================
-- 1. Vytvorte funkciu Get_pocet_opakovani, ktorej vstupn˝m parametrom bude 
-- osobnÈ ËÌslo ötudenta, v˝sledkom bude poËet predmetov, ktorÈ opakoval 
-- (pouûite prÌkaz Select...into). 

CREATE OR REPLACE FUNCTION GET_POCET_OPAKOVANI (
    PA_OS_CISLO IN RABEK2.STUDENT.OS_CISLO%TYPE
    )
RETURN NUMBER IS POC_OPAKOVANI NUMBER(2,0):=0;
BEGIN
    SELECT COUNT(*) INTO POC_OPAKOVANI
    FROM (SELECT OS_CISLO, COUNT(CIS_PREDM)
        FROM ZAP_PREDMETY
        WHERE OS_CISLO = PA_OS_CISLO
        GROUP BY OS_CISLO, CIS_PREDM
        HAVING COUNT(*) > 1);
        
    RETURN POC_OPAKOVANI;
    
END GET_POCET_OPAKOVANI;
/

-- a. Otestujte pomocou vykonania funkcie prÌkazom EXECUTE a pomocou prÌkazu 
-- Select

EXECUTE GET_POCET_OPAKOVANI(500424);

SELECT GET_POCET_OPAKOVANI(500424) FROM DUAL;

--==============================================================================
-- 2. Vytvorte anonymn˝ blok, ktorÈho parametrom bude ËÌslo predmetu (vyûiadajte
-- v r·mci tela od pouûÌvateæa). Na konzolu vypÌöte n·zov predmetu. Pouûite 
-- prÌkaz Select... into.

SET SERVEROUTPUT ON;

DECLARE
    C_PREDMETU RABEK2.PREDMET.CIS_PREDM%TYPE := 'BI06';
    N_PREDMETU RABEK2.PREDMET.NAZOV%TYPE;
BEGIN
    SELECT NAZOV INTO N_PREDMETU
    FROM PREDMET
    WHERE CIS_PREDM = C_PREDMETU;
    
    DBMS_OUTPUT.PUT_LINE('NAZOV PREDMETU: ' || N_PREDMETU);
END;
/

-- a. Otestujte pre predmet BI06, BI08.
-- b. Vyrieöte problÈm:
--      i. DefinovanÌm v˝nimky

SET SERVEROUTPUT ON;

DECLARE
    C_PREDMETU RABEK2.PREDMET.CIS_PREDM%TYPE := 'BI08';
    N_PREDMETU RABEK2.PREDMET.NAZOV%TYPE;
BEGIN
    SELECT NAZOV INTO N_PREDMETU
    FROM PREDMET
    WHERE CIS_PREDM = C_PREDMETU;
    
    DBMS_OUTPUT.PUT_LINE('NAZOV PREDMETU: ' || N_PREDMETU);
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('PREDMET "' || C_PREDMETU || '" NEBOL NAJDENY');
END;
/

--==============================================================================
-- 8. Pomocou kombin·cie kurzorov dosiahnite nasledovn˝ v˝pis. AspoÚ jeden z 
-- kurzorov MUSÕ byù typu OPEN, LOOP, ...PouûÌvajte kurzory s parametrom. DÙrazne
-- odpor˙Ëame form·tovanie proced˙ry apostupnÈ debuggovanie. Reöpektujte spr·vny
-- v˝sledok sk˙öky podæa jednotliv˝ch typov (predmet konËiaci sk˙ökou i 
-- z·poËtom, predmet konËiaci len sk˙ökou, ...). Pre zobrazenie si zv‰Ëöite 
-- spracov·van˙ dÂûku riadku. Form·tovan˝ v˝stup uloûte do s˙boru sn·zvom 
-- login.txt. 

































