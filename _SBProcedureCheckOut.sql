drop PROCEDURE _SBProcedureCheckOut;

DELIMITER $$
CREATE PROCEDURE _SBProcedureCheckOut
	(
		 InData_OperateFlag			CHAR(2)			-- 작업표시
		,InData_CompanySeq			INT				-- 법인내부코드
		,InData_ProcedureName		VARCHAR(100)	-- 프로시져 내부코드
        ,InData_IsCheckOut			CHAR(1)			-- 체크아웃 여부
        ,InData_Remark				VARCHAR(500)	-- 작업내용
        ,Login_UserSeq				INT  			-- 현재 로그인 중인 유저
    )
BEGIN
    
    DECLARE State INT;
    
    -- ---------------------------------------------------------------------------------------------------
    -- Check --
	call _SBProcedureCheckOut_Check
		(
			 InData_OperateFlag			
			,InData_CompanySeq		
			,InData_ProcedureName		
			,InData_IsCheckOut		
			,InData_Remark
			,Login_UserSeq	
			,@Error_Check
		);
    

	IF( @Error_Check = (SELECT 9999) ) THEN
		
        SET State = 9999; -- Error 발생
        
	ELSE

	    SET State = 1111; -- 정상작동
        
		-- ---------------------------------------------------------------------------------------------------
		-- Update --
		IF( InData_OperateFlag = 'U' AND STATE = 1111 ) THEN
			call _SBProcedureCheckOut_Update
				(
					 InData_OperateFlag			
					,InData_CompanySeq		
					,InData_ProcedureName		
					,InData_IsCheckOut		
					,InData_Remark
					,Login_UserSeq	
				);
		END IF;	    

	END IF;
    
    
END $$
DELIMITER ;