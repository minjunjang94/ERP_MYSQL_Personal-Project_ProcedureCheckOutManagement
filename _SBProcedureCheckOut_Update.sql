drop PROCEDURE _SBProcedureCheckOut_Update;

DELIMITER $$
CREATE PROCEDURE _SBProcedureCheckOut_Update
	(
 		 InData_OperateFlag			CHAR(2)			-- 작업표시
		,InData_CompanySeq			INT				-- 법인내부코드
		,InData_ProcedureName		VARCHAR(200)	-- 프로시져명
		,InData_IsCheckOut			CHAR(1)			-- 체크아웃 여부
		,InData_Remark				VARCHAR(500)	-- 작업내용
		,Login_UserSeq	    		INT				-- 현재 로그인 중인 유저
    )
BEGIN

	-- 변수선언
	DECLARE Var_ProcedureSeq  			INT;
    DECLARE Var_ProcedureSerl 			INT;
	DECLARE Var_CheckOutStartDate		VARCHAR(100);
    DECLARE Var_CheckOutEndDate		    VARCHAR(100);
    

	SET Var_ProcedureSeq  = (SELECT ProcedureSeq FROM _TCBaseProcedure AS A WHERE A.CompanySeq = InData_CompanySeq AND A.ProcedureName = InData_ProcedureName);         
	SET Var_ProcedureSerl = (SELECT MAX(ProcedureSerl) + 1 AS ProcedureSerl FROM _TCBaseProcedureHist AS A WHERE A.CompanySeq = InData_CompanySeq AND A.ProcedureSeq = Var_ProcedureSeq); 
 	SET Var_CheckOutStartDate	= (SELECT DATE_FORMAT(NOW(), "%Y-%m-%d %H:%i:%s") AS GetDate);	-- Insert하는 기준의 일시부터 default 설정        
 	SET Var_CheckOutEndDate   	= (SELECT DATE_FORMAT(NOW(), "%Y-%m-%d %H:%i:%s") AS GetDate);	-- Insert하는 기준의 일시부터 default 설정       
   
   
    -- ---------------------------------------------------------------------------------------------------
    -- Update --
	IF( InData_OperateFlag = 'U' AND (SELECT A.IsCheckOut   
									    FROM _TCBaseProcedure AS A 			 
									   WHERE  A.CompanySeq	  = InData_CompanySeq 
										 AND  A.ProcedureSeq  = Var_ProcedureSeq limit 1) = (SELECT 1)
								 AND  InData_IsCheckOut = 0)  -- 체크인 할 경우
	THEN     
			UPDATE _TCBaseProcedure AS A
			   SET   A.IsCheckOut 		    = InData_IsCheckOut
                    ,A.CheckOutUserSeq		= 0
                    ,A.CheckOutEndDate      = Var_CheckOutEndDate
			 WHERE  A.CompanySeq			= InData_CompanySeq 
			   AND  A.ProcedureSeq			= Var_ProcedureSeq;
               
			INSERT INTO _TCBaseProcedureHist(CompanySeq, ProcedureSeq, ProcedureSerl, IsCheckOut, Remark, CheckOutUserSeq, CheckOutStartDate, CheckOutEndDate)
				 VALUES (InData_CompanySeq, Var_ProcedureSeq, Var_ProcedureSerl, InData_IsCheckOut, InData_Remark, Login_UserSeq, '', Var_CheckOutEndDate);

			SELECT '저장되었습니다.' AS Result; 
     
	ELSEIF( InData_OperateFlag = 'U' AND (SELECT A.IsCheckOut 
											FROM _TCBaseProcedure AS A 			 
										   WHERE  A.CompanySeq	  = InData_CompanySeq 
											 AND  A.ProcedureSeq  = Var_ProcedureSeq limit 1) = (SELECT 0)
								     AND  InData_IsCheckOut = 1)  -- 체크아웃 할 경우
	THEN
			UPDATE _TCBaseProcedure AS A
			   SET  A.IsCheckOut 		    = InData_IsCheckOut
                   ,A.CheckOutUserSeq		= Login_UserSeq
                   ,A.CheckOutStartDate     = Var_CheckOutStartDate
                   ,A.CheckOutEndDate       = '9999-12-31 00:00:00'
			 WHERE  A.CompanySeq			= InData_CompanySeq 
			   AND  A.ProcedureSeq			= Var_ProcedureSeq;

			INSERT INTO _TCBaseProcedureHist(CompanySeq, ProcedureSeq, ProcedureSerl, IsCheckOut, Remark, CheckOutUserSeq, CheckOutStartDate, CheckOutEndDate)
				 VALUES (InData_CompanySeq, Var_ProcedureSeq, Var_ProcedureSerl, InData_IsCheckOut, InData_Remark, Login_UserSeq, Var_CheckOutStartDate, '');
                 
			SELECT '저장되었습니다.' AS Result;   
            
	ELSE
			SELECT '저장이 완료되지 않았습니다.' AS Result;
	END IF;	


END $$
DELIMITER ;