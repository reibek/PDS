--==============================================================================
-- 1. Vytvorte funkciu Get_pocet_opakovani, ktorej vstupn�m parametrom bude 
-- osobn� ��slo �tudenta, v�sledkom bude po�et predmetov, ktor� opakoval 
-- (pou�ite pr�kaz Select...into). 

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

-- a. Otestujte pomocou vykonania funkcie pr�kazom EXECUTE a pomocou pr�kazu 
-- Select

EXECUTE GET_POCET_OPAKOVANI(500424);

SELECT GET_POCET_OPAKOVANI(500424) FROM DUAL;

--==============================================================================
-- 2. Vytvorte anonymn� blok, ktor�ho parametrom bude ��slo predmetu (vy�iadajte
-- v r�mci tela od pou��vate�a). Na konzolu vyp�te n�zov predmetu. Pou�ite 
-- pr�kaz Select... into.

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
-- b. Vyrie�te probl�m:
--      i. Definovan�m v�nimky

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
-- 8. Pomocou kombin�cie kurzorov dosiahnite nasledovn� v�pis. Aspo� jeden z 
-- kurzorov MUS� by� typu OPEN, LOOP, ...Pou��vajte kurzory s parametrom. D�razne
-- odpor��ame form�tovanie proced�ry apostupn� debuggovanie. Re�pektujte spr�vny
-- v�sledok sk��ky pod�a jednotliv�ch typov (predmet kon�iaci sk��kou i 
-- z�po�tom, predmet kon�iaci len sk��kou, ...). Pre zobrazenie si zv��ite 
-- spracov�van� d�ku riadku. Form�tovan� v�stup ulo�te do s�boru sn�zvom 
-- login.txt. 

































