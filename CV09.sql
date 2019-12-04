-- Celkova suma ktoru kazda osoba dostala na prispevkoch a celkova suma, ktoru
-- odviedla

SELECT 
    XMLROOT(
        XMLELEMENT("osoba",
            XMLATTRIBUTES( ROD_CISLO AS "rod_cislo"),
            XMLELEMENT("meno", MENO),
            XMLELEMENT("priezvisko", PRIEZVISKO)
        ), 
    VERSION '1.0')
FROM
    (SELECT OS.ROD_CISLO, OS.MENO, OS.PRIEZVISKO, 
        SUM(PR.SUMA) AS PRISPEVKY, 
        SUM(PL.SUMA) AS ODVODY,
        SUM(PL.SUMA) - SUM(PR.SUMA) AS STATUS,
        ROW_NUMBER() OVER(ORDER BY SUM(PL.SUMA) - SUM(PR.SUMA)) AS POCET
    FROM P_OSOBA OS 
        LEFT JOIN P_POBERATEL POB ON (OS.ROD_CISLO = POB.ROD_CISLO)
        LEFT JOIN P_PRISPEVKY PR ON (POB.ID_POBERATELA = PR.ID_POBERATELA)
        LEFT JOIN P_POISTENIE POI ON (OS.ROD_CISLO = POI.ROD_CISLO)
        LEFT JOIN P_ODVOD_PLATBA PL ON (PL.ID_POISTENCA = POI.ID_POISTENCA) 
    GROUP BY OS.ROD_CISLO, OS.MENO, OS.PRIEZVISKO)
WHERE POCET <= (SELECT COUNT(*) FROM P_OSOBA) * 0.3;

DESC KVET3.Osoba_Rek;

CREATE TABLE OSOBA_RECURSIVE AS SELECT * FROM KVET3.Osoba_Rek;

DESC OSOBA_RECURSIVE;

ALTER TABLE OSOBA_RECURSIVE ADD PRIMARY KEY(ID);
ALTER TABLE OSOBA_RECURSIVE ADD FOREIGN KEY(MATKA) REFERENCES OSOBA_RECURSIVE(ID);

SELECT * FROM USER_CONSTRAINTS WHERE TABLE_NAME = 'OSOBA_RECURSIVE';

ALTER TABLE OSOBA_RECURSIVE DROP CONSTRAINT 
ALTER TABLE OSOBA_RECURSIVE ADD FOREIGN KEY(MATKA) REFERENCES OSOBA_RECURSIVE(ID) DEFERRABLE;
ALTER TABLE OSOBA_RECURSIVE SET CONSTRAINTS = DEFERRED;

INSERT INTO OSOBA_RECURSIVE VALUES(5, 'MenoDieta', 'PriezvDieta', 50, 25);
INSERT INTO OSOBA_RECURSIVE VALUES(50, 'MenoMatka', 'PriezvMatka', null, 60);

COMMIT;

SELECT DI.MENO, DI.PRIEZVISKO, MAT.MENO, MAT.PRIEZVISKO
FROM OSOBA_RECURSIVE DI LEFT JOIN OSOBA_RECURSIVE MAT ON (DI.MATKA = MAT.ID);

SELECT DI.MENO, DI.PRIEZVISKO, MAT.MENO, MAT.PRIEZVISKO
FROM OSOBA_RECURSIVE DI LEFT JOIN OSOBA_RECURSIVE MAT ON (DI.MATKA = MAT.ID AND DIET.VEK < 18);

--==============================================================================
-- 1.   Nastavte:
set long 2000;

-- 2.   V OS vytvorte adresar pre ulozenie XML suborov a nastavte prava pre 
--      vsetkych na zapis a c?tanie.

--      '/home/fri.uniza.sk/rabek2'
--      'D:\FRI\ING\I. SEMESTER\Pokroèilé databázové systémy'

-- 3.   Pr?kazom CREATE DIRECTORY vytvorte ”Oraclovsky” adresar pre pr?stup z 
--      PL/SQL a namapujte ho na adresar z bodu 2.

CREATE OR REPLACE DIRECTORY XML_DIR
    AS 'D:\FRI\ING\I. SEMESTER\Pokroèilé databázové systémy\XML_DIR';
    
-- 4.   Vytvorte procedury na pracu so subormi.

-- *****************************************************************************
-- NACITA CLOB ZO SUBORU NA SERVERI                                             
-- *****************************************************************************
CREATE OR REPLACE FUNCTION get_local_ascii_data (   p_dir   IN VARCHAR2,
                                                    p_file  IN VARCHAR2     )
RETURN CLOB IS
    l_bfile         BFILE;
    l_data          CLOB;
    
    src_csid        NUMBER  := NLS_CHARSET_ID('UTF8');
    dest_offset     INTEGER := 1;
    src_offset      INTEGER := 1;
    lang_context    INTEGER := dbms_lob.default_lang_ctx;
    warning         INTEGER;
BEGIN
    DBMS_LOB.createtemporary (  lob_loc => l_data,
                                cache => TRUE,
                                dur => DBMS_LOB.call);
                                
    l_bfile := BFILENAME(p_dir, p_file);
    DBMS_LOB.fileopen(l_bfile, DBMS_LOB.file_readonly);
    DBMS_LOB.loadclobfromfile(l_data, l_bfile, DBMS_LOB.getlength(l_bfile),
    dest_offset,src_offset, src_csid, lang_context, warning);
    DBMS_LOB.fileclose(l_bfile);
    
    RETURN l_data;
END;
/

-- *****************************************************************************
-- ULOZI CLOB DO SUBORU NA SERVERI                                              
-- *****************************************************************************
CREATE OR REPLACE PROCEDURE put_local_ascii_data (
    p_data  IN CLOB, 
    p_dir   IN VARCHAR2, 
    p_file  IN VARCHAR2     )
IS

    l_out_file      UTL_FILE.file_type;
    l_buffer        VARCHAR2 (32767);
    l_amount        BINARY_INTEGER  := 32767;
    l_pos           INTEGER         := 1;
    l_clob_len      INTEGER;
BEGIN
    l_clob_len:= DBMS_LOB.getlength (p_data);
    l_out_file:=UTL_FILE.fopen (p_dir,p_file,'w',32767);
    
    WHILE l_pos < l_clob_len
    LOOP
        DBMS_LOB.READ (p_data,l_amount,l_pos,l_buffer);
        
        IF l_buffer IS NOT NULL
        THEN
            UTL_FILE.put (l_out_file, l_buffer);
            UTL_FILE.fflush (l_out_file);
        END IF;
        
        l_pos := l_pos+ l_amount;
    END LOOP;
    
    UTL_FILE.fclose (l_out_file);
EXCEPTION
    WHEN OTHERS
    THEN
        IF UTL_FILE.is_open (l_out_file)
        THEN
            UTL_FILE.fclose (l_out_file);
        END IF;
        DBMS_OUTPUT.put_line ( SQLCODE|| ' - '|| SQLERRM);
        RAISE;
END;
/

-- *****************************************************************************
-- ULOZI BLOB DO SUBORU NA SERVERI                                              
-- *****************************************************************************
CREATE OR REPLACE PROCEDURE put_local_binary_data (
    p_data  IN BLOB,
    p_dir   IN VARCHAR2,
    p_file  IN VARCHAR2     ) 
IS

    l_out_file      UTL_FILE.file_type;
    l_buffer        RAW (32767);
    l_amount        BINARY_INTEGER  := 32767;
    l_pos           INTEGER         := 1;
    l_blob_len      INTEGER;
    
BEGIN
    l_blob_len := DBMS_LOB.getlength(p_data);
    l_out_file := UTL_FILE.fopen(p_dir, p_file, 'w', 32767);
    WHILE l_pos < l_blob_len
    LOOP
        DBMS_LOB.READ(p_data, l_amount, l_pos, l_buffer);
        IF l_buffer IS NOT NULL THEN
            UTL_FILE.put_raw(l_out_file, l_buffer, TRUE);
        END IF;
        l_pos := l_pos+l_amount;
    END LOOP;
    
EXCEPTION
    WHEN OTHERS THEN
        IF UTL_FILE.is_open(l_out_file) THEN
            UTL_FILE.fclose(l_out_file);
        END IF;
    RAISE;
END put_local_binary_data;
/

-- *****************************************************************************
-- VYROB BLOB ZO SUBORU NA SERVERI                                              
-- *****************************************************************************
CREATE OR REPLACE FUNCTION get_local_binary_data(
    p_dir   IN VARCHAR2,
    p_file  IN VARCHAR2     ) 
RETURN BLOB IS

    l_amount        PLS_INTEGER;
    l_buffer        RAW (32767);
    l_data          BLOB;
    l_out_file      UTL_FILE.file_type;
    l_length        NUMBER;
    v_dest_offset   NUMBER(38)                  := 1 ;
    v_src_offset    NUMBER(38)                  := 1 ;
    v_buf_size      CONSTANT BINARY_INTEGER     := 32767;
    v_write_amount  BINARY_INTEGER;
    v_total_amount  BINARY_INTEGER              :=0 ;
    
BEGIN
    DBMS_LOB.createtemporary (lob_loc => l_data, CACHE => true,
        dur => DBMS_LOB.CALL);
    l_out_file := UTL_FILE.fopen(LOCATION=> p_dir, filename => p_file,
        open_mode => 'r', max_linesize => v_buf_size);
BEGIN
    v_dest_offset := 1;
    WHILE (TRUE) LOOP
        UTL_FILE.get_raw(file => l_out_file, buffer => l_buffer,
            len => v_buf_size);
        IF l_buffer IS NOT NULL THEN
            v_write_amount := LENGTH (l_buffer)/2; -- sanity check
            v_total_amount := v_total_amount + v_write_amount;
        ELSE
            -- RAISE get_raw_read_null_bytes;
            RAISE_APPLICATION_ERROR(-20000,'XXXX');
        END IF;
        DBMS_LOB.WRITE(lob_loc=> l_data, amount => v_write_amount,
            offset => v_dest_offset, buffer => l_buffer);
        v_dest_offset := v_dest_offset + v_write_amount;
    END LOOP;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
    NULL;
END;

    UTL_FILE.fclose(file => l_out_file);
    RETURN l_data;

END get_local_binary_data;
/


