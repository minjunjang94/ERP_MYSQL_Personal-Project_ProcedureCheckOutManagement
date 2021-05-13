drop PROCEDURE _SBProcedureCheckOut_Check;

DELIMITER $$
CREATE PROCEDURE _SBProcedureCheckOut_Check
	(
		 InData_OperateFlag			CHAR(2)			-- 작업표시
		,InData_CompanySeq			INT				-- 법인내부코드
		,InData_ProcedureName		VARCHAR(100)	-- 프로시져 내부코드
        ,InData_IsCheckOut			CHAR(1)			-- 체크아웃 여부
        ,InData_Remark				VARCHAR(700)	-- 작업내용
        ,Login_UserSeq				INT  			-- 현재 로그인 중인 유저
        ,OUT RETURN_OUT 			INT				-- IsCheck 결과 내보내기
    )
Error_Out:BEGIN -- Error_Out : 오류가 발생했을 경우 프로시져 종료

	-- 오류 관리 변수---------------------------------------
	DECLARE CompanySeq 			INT;
	DECLARE IsCheck 			INT;
    DECLARE Result  			VARCHAR(500);
	-- -------------------------------------------------
    
    -- 변수선언 --    
    DECLARE Var_ProcedureSeq 	INT;    
    
	-- 변수설정 --
	SET Var_ProcedureSeq = (SELECT A.ProcedureSeq FROM _TCBaseProcedure AS A WHERE A.CompanySeq = InData_CompanySeq AND ProcedureName = InData_ProcedureName);
	
    
	-- 오류 관리 테이블---------------------------------------
	CREATE TEMPORARY TABLE IsCheck_TEMP
    (CompanySeq INT, IsCheck INT, Result VARCHAR(500));
	INSERT INTO IsCheck_TEMP VALUES(InData_CompanySeq, 1111, '');    
	-- -------------------------------------------------	 

    -- OperateFlag의 값이 'U' 외의 값이 들어갈 경우 에러발생------------------------------------------------------------------------------
    IF ((SELECT IFNULL(A.ProcedureSeq, 1111)  AS ProcedureSeq 
				FROM _TCBaseProcedure 		  AS A 
                RIGHT OUTER JOIN (SELECT '')  AS ERR_CHECK_1  ON InData_OperateFlag <> 'U'
		 limit 1
         ) = (SELECT 1111)) 
	THEN
	   -- TRUE
	   SET CompanySeq = InData_CompanySeq;
        
    ELSE
	   UPDATE IsCheck_TEMP AS A
	   SET  A.IsCheck = 9999
		   ,A.Result  = '[ (U) : 업데이트 ] 외의 명령을 입력할 수 없습니다.'
	   WHERE (InData_OperateFlag <> 'U');       
       -- 체크종료 구문--------------------------------------------------------------------------
	   SET IsCheck		= (SELECT A.IsCheck FROM IsCheck_TEMP AS A);
	   SET Result		= (SELECT A.Result  FROM IsCheck_TEMP AS A);    
	   IF ((SELECT IsCheck) = (SELECT 1111)) THEN SET RETURN_OUT = IsCheck; -- IsCheck : '1111'일 경우 정상, '9999'일 경우 에러발생
	   ELSE SELECT Result AS Result; SET RETURN_OUT = IsCheck; END IF;-- 에러가 발생할 경우 메시지 출력
	   DROP TEMPORARY TABLE IsCheck_TEMP; -- 임시테이블 삭제
       LEAVE Error_Out; -- 프로시져 종료
       -- ------------------------------------------------------------------------------------
    END IF;  



 	-- InData_CompanySeq, InData_ProcedureName, InData_Remark 를 필수로 입력하지 않을 경우 에러발생 ------------------------------------------------
     IF ((SELECT IFNULL(A.ERR, 1111)  		  AS ProcedureSeq 
				FROM (SELECT 9999 AS ERR) 	  AS A 
				RIGHT OUTER JOIN (SELECT '')  AS ERR_CHECK_1  ON (
																	   (InData_CompanySeq		   = 0 ) 
																	OR (InData_ProcedureName       = '')
																    OR (InData_Remark 	   		   = '')
																 )   
															  AND ( InData_OperateFlag LIKE 'U' )
		 limit 1
         ) = (SELECT 1111)) 
	THEN
	   -- TRUE
	   SET CompanySeq = InData_CompanySeq;
        
    ELSE    
	   UPDATE IsCheck_TEMP AS A
	   SET  A.IsCheck = 9999
		   ,A.Result  = '법인내부코드, 프로시저명, 작업내용 은 필수값 입니다.'
	   WHERE (InData_OperateFlag LIKE 'U');
       -- 체크종료 구문--------------------------------------------------------------------------
	   SET IsCheck		= (SELECT A.IsCheck FROM IsCheck_TEMP AS A);
	   SET Result		= (SELECT A.Result  FROM IsCheck_TEMP AS A);      
	   IF ((SELECT IsCheck) = (SELECT 1111)) THEN SET RETURN_OUT = IsCheck; -- IsCheck : '1111'일 경우 정상, '9999'일 경우 에러발생
	   ELSE SELECT Result AS Result; SET RETURN_OUT = IsCheck; END IF; -- 에러가 발생할 경우 메시지 출력
	   DROP TEMPORARY TABLE IsCheck_TEMP; -- 임시테이블 삭제
       LEAVE Error_Out; -- 프로시져 종료
       -- ------------------------------------------------------------------------------------
    END IF;   



 	-- InData_IsCheckOut이 '0' or '1' 값이 아니면 에러발생 ------------------------------------------------
     IF ((SELECT IFNULL(A.ProcedureSeq, 1111)  AS ProcedureSeq 
				FROM _TCBaseProcedure 		   AS A 
				RIGHT OUTER JOIN (SELECT '')   AS ERR_CHECK_1  ON ( InData_IsCheckOut < 0 OR InData_IsCheckOut > 1 )
															  AND ( InData_OperateFlag LIKE 'U' )
		 limit 1
         ) = (SELECT 1111)) 
	THEN
	   -- TRUE
	   SET CompanySeq = InData_CompanySeq;
        
    ELSE    
	   UPDATE IsCheck_TEMP AS A
	   SET  A.IsCheck = 9999
		   ,A.Result  = '[체크아웃 여부]의 값은 1 또는 0 값만 입력가능합니다.'
	   WHERE (InData_OperateFlag LIKE 'U');
       -- 체크종료 구문--------------------------------------------------------------------------
	   SET IsCheck		= (SELECT A.IsCheck FROM IsCheck_TEMP AS A);
	   SET Result		= (SELECT A.Result  FROM IsCheck_TEMP AS A);      
	   IF ((SELECT IsCheck) = (SELECT 1111)) THEN SET RETURN_OUT = IsCheck; -- IsCheck : '1111'일 경우 정상, '9999'일 경우 에러발생
	   ELSE SELECT Result AS Result; SET RETURN_OUT = IsCheck; END IF; -- 에러가 발생할 경우 메시지 출력
	   DROP TEMPORARY TABLE IsCheck_TEMP; -- 임시테이블 삭제
       LEAVE Error_Out; -- 프로시져 종료
       -- ------------------------------------------------------------------------------------
    END IF;   
    
    

    -- InData_CompanySeq의 값이 _TSBaseCompany.CompanySeq의 데이터에 존재하는 값이 없을 경우 에러발생 ------------------------------------------------------------------------------
    IF ((SELECT IFNULL(A.CompanySeq, 1111)  	AS CompanySeq 
				FROM _TSBaseCompany 		  	AS A 
				RIGHT OUTER JOIN (SELECT '')  AS ERR_CHECK_1  ON  (InData_CompanySeq  <>    	A.CompanySeq ) 
															  AND (InData_OperateFlag LIKE      'U'			 )
		 limit 1
         ) = (SELECT 1111)) 
	THEN
	   -- TRUE
	   SET CompanySeq = InData_CompanySeq;
        
    ELSE
	   UPDATE IsCheck_TEMP AS A
	   SET  A.IsCheck = 9999
		   ,A.Result  = '등록된 법인 정보가 아닙니다. 법인등록을 해주세요.'
	   WHERE (InData_OperateFlag LIKE 'U');
       -- 체크종료 구문--------------------------------------------------------------------------
	   SET IsCheck		= (SELECT A.IsCheck FROM IsCheck_TEMP AS A);
	   SET Result		= (SELECT A.Result  FROM IsCheck_TEMP AS A);    
	   IF ((SELECT IsCheck) = (SELECT 1111)) THEN SET RETURN_OUT = IsCheck; -- IsCheck : '1111'일 경우 정상, '9999'일 경우 에러발생
	   ELSE SELECT Result AS Result; SET RETURN_OUT = IsCheck; END IF;-- 에러가 발생할 경우 메시지 출력
	   DROP TEMPORARY TABLE IsCheck_TEMP; -- 임시테이블 삭제
       LEAVE Error_Out; -- 프로시져 종료
       -- ------------------------------------------------------------------------------------
    END IF;  



	-- 체크아웃 되어있는 프로시져에 수정할 경우 에러발생(시도하는 유저와 다른 경우)----------------------------------------------------------------------------
    IF ((SELECT IFNULL(A.ProcedureSeq, 1111)  AS ProcedureSeq 
				FROM _TCBaseProcedure 		  AS A 
				RIGHT OUTER JOIN (SELECT '')  AS ERR_CHECK_1  ON A.CompanySeq       =    InData_CompanySeq
															 AND A.ProcedureName    =    InData_ProcedureName
                                                             AND A.CheckOutUserSeq  <>   Login_UserSeq
                                                             AND A.IsCheckOut	    =    1	-- 이미 체크아웃이 되어있는지 체크
															 AND (InData_OperateFlag LIKE 'U')
		limit 1
         ) = (SELECT 1111)) 
	THEN
	   -- TRUE
	   SET CompanySeq = InData_CompanySeq;
       
    ELSE
	   -- FALES
	   UPDATE IsCheck_TEMP AS A
	   SET  A.IsCheck = 9999
		   ,A.Result  = '이미 체크인이 되어 있는 프로시져입니다. (수정 및 삭제 불가)'
	   WHERE (InData_OperateFlag LIKE 'U');
       -- 체크종료 구문--------------------------------------------------------------------------
	   SET IsCheck		= (SELECT A.IsCheck FROM IsCheck_TEMP AS A);
	   SET Result		= (SELECT A.Result  FROM IsCheck_TEMP AS A);    
	   IF ((SELECT IsCheck) = (SELECT 1111)) THEN SET RETURN_OUT = IsCheck; -- IsCheck : '1111'일 경우 정상, '9999'일 경우 에러발생
	   ELSE SELECT Result AS Result; SET RETURN_OUT = IsCheck; END IF;-- 에러가 발생할 경우 메시지 출력
	   DROP TEMPORARY TABLE IsCheck_TEMP; -- 임시테이블 삭제
       LEAVE Error_Out; -- 프로시져 종료
       -- ------------------------------------------------------------------------------------
    END IF;
 
 
 
 	-- 체크아웃 되어있는 프로시져에 수정할 경우 에러발생(시도하는 유저와 같은 경우)----------------------------------------------------------------------------
    IF ((SELECT IFNULL(A.ProcedureSeq, 1111)  AS ProcedureSeq 
				FROM _TCBaseProcedure 		  AS A 
				RIGHT OUTER JOIN (SELECT '')  AS ERR_CHECK_1  ON A.CompanySeq       =    InData_CompanySeq
															 AND A.ProcedureName    =    InData_ProcedureName
                                                             AND A.CheckOutUserSeq  =    Login_UserSeq
                                                             AND A.IsCheckOut	    =    1	-- 이미 체크아웃이 되어있는지 체크
                                                             AND InData_IsCheckOut  =    1
															 AND (InData_OperateFlag LIKE 'U')
		limit 1
         ) = (SELECT 1111)) 
	THEN
	   -- TRUE
	   SET CompanySeq = InData_CompanySeq;
       
    ELSE
	   -- FALES
	   UPDATE IsCheck_TEMP AS A
	   SET  A.IsCheck = 9999
		   ,A.Result  = '이미 체크아웃을 했습니다. 작업이 가능합니다.'
	   WHERE (InData_OperateFlag LIKE 'U');
       -- 체크종료 구문--------------------------------------------------------------------------
	   SET IsCheck		= (SELECT A.IsCheck FROM IsCheck_TEMP AS A);
	   SET Result		= (SELECT A.Result  FROM IsCheck_TEMP AS A);    
	   IF ((SELECT IsCheck) = (SELECT 1111)) THEN SET RETURN_OUT = IsCheck; -- IsCheck : '1111'일 경우 정상, '9999'일 경우 에러발생
	   ELSE SELECT Result AS Result; SET RETURN_OUT = IsCheck; END IF;-- 에러가 발생할 경우 메시지 출력
	   DROP TEMPORARY TABLE IsCheck_TEMP; -- 임시테이블 삭제
       LEAVE Error_Out; -- 프로시져 종료
       -- ------------------------------------------------------------------------------------
    END IF;

  

 	-- 체크아웃이 되어있는 프로시져에 체크아웃을 시도할 경우 에러발생----------------------------------------------------------------------------
    IF ((SELECT IFNULL(A.ProcedureSeq, 1111)  AS ProcedureSeq 
				FROM _TCBaseProcedure 		  AS A 
				RIGHT OUTER JOIN (SELECT '')  AS ERR_CHECK_1  ON A.CompanySeq       =    InData_CompanySeq
															 AND A.ProcedureName    =    InData_ProcedureName
                                                             AND A.IsCheckOut	    =    0	-- 이미 체크인이 되어있는지 체크
                                                             AND InData_IsCheckOut  =    0
															 AND (InData_OperateFlag LIKE 'U')
		limit 1
         ) = (SELECT 1111)) 
	THEN
	   -- TRUE
	   SET CompanySeq = InData_CompanySeq;
       
    ELSE
	   -- FALES
	   UPDATE IsCheck_TEMP AS A
	   SET  A.IsCheck = 9999
		   ,A.Result  = '이미 체크인 되어있는 프로시져입니다. 작업할 수 없습니다.'
	   WHERE (InData_OperateFlag LIKE 'U');
       -- 체크종료 구문--------------------------------------------------------------------------
	   SET IsCheck		= (SELECT A.IsCheck FROM IsCheck_TEMP AS A);
	   SET Result		= (SELECT A.Result  FROM IsCheck_TEMP AS A);    
	   IF ((SELECT IsCheck) = (SELECT 1111)) THEN SET RETURN_OUT = IsCheck; -- IsCheck : '1111'일 경우 정상, '9999'일 경우 에러발생
	   ELSE SELECT Result AS Result; SET RETURN_OUT = IsCheck; END IF;-- 에러가 발생할 경우 메시지 출력
	   DROP TEMPORARY TABLE IsCheck_TEMP; -- 임시테이블 삭제
       LEAVE Error_Out; -- 프로시져 종료
       -- ------------------------------------------------------------------------------------
    END IF;
    
    
 
	-- 업데이트와 조회, 삭제 시 데이터가 없을 경우 에러발생 ----------------------------------------------------------------------------
    IF ((SELECT IFNULL(A.ProcedureSeq, 1111)  AS ProcedureSeq 
				FROM _TCBaseProcedure 		  AS A 
				RIGHT OUTER JOIN (SELECT '')  AS ERR_CHECK_1  ON A.CompanySeq       =    InData_CompanySeq
															 AND A.ProcedureName    =	 InData_ProcedureName
															 AND (InData_OperateFlag LIKE 'U' OR InData_OperateFlag LIKE 'Q')
		limit 1
         ) = (SELECT Var_ProcedureSeq))  -- 데이터가 존재하다면 수정하려는 Seq가 같은지 여부 확인
	THEN
	   -- TRUE
	   SET CompanySeq = InData_CompanySeq;
        
    ELSE
	   -- FALES
	   UPDATE IsCheck_TEMP AS A
	   SET  A.IsCheck = 9999
		   ,A.Result  = '해당 명의 프로시져가 존재하지 않습니다.'
	   WHERE (InData_OperateFlag LIKE 'U' OR InData_OperateFlag LIKE 'Q');
       -- 체크종료 구문--------------------------------------------------------------------------
	   SET IsCheck		= (SELECT A.IsCheck FROM IsCheck_TEMP AS A);
	   SET Result		= (SELECT A.Result  FROM IsCheck_TEMP AS A);    
	   IF ((SELECT IsCheck) = (SELECT 1111)) THEN SET RETURN_OUT = IsCheck; -- IsCheck : '1111'일 경우 정상, '9999'일 경우 에러발생
	   ELSE SELECT Result AS Result; SET RETURN_OUT = IsCheck; END IF;-- 에러가 발생할 경우 메시지 출력
	   DROP TEMPORARY TABLE IsCheck_TEMP; -- 임시테이블 삭제
       LEAVE Error_Out; -- 프로시져 종료
       -- ------------------------------------------------------------------------------------
    END IF;	
    
    
    
	DROP TEMPORARY TABLE IsCheck_TEMP; -- 임시테이블 삭제
END $$
DELIMITER ;