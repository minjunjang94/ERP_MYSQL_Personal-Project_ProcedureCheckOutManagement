drop PROCEDURE _SBProcedureCheckOut_Query;

DELIMITER $$
CREATE PROCEDURE _SBProcedureCheckOut_Query
	(
		 InData_CompanySeq			INT				-- 법인내부코드
		,InData_ProcedureName		VARCHAR(200)	-- 프로시져명
		,Login_UserSeq				INT				-- 현재 로그인 중인 유저
    )
BEGIN    

	IF (InData_ProcedureName 	IS NULL OR InData_ProcedureName 	LIKE ''	) THEN	SET InData_ProcedureName 	= '%'; END IF;

    -- ---------------------------------------------------------------------------------------------------
    -- Query --
 
    set session transaction isolation level read uncommitted; 
    -- 최종조회 --
    SELECT 
		 A.CompanySeq
		,A.ProcedureSeq
		,A.ProcedureSerl
		,B.ProcedureName
		,A.IsCheckOut
		,A.Remark
		,C.UserName						AS CheckOutUserName
		,A.CheckOutUserSeq
		,A.CheckOutStartDate
		,A.CheckOutEndDate
	FROM _TCBaseProcedureHist 			AS A
    LEFT OUTER JOIN _TCBaseProcedure 	AS B	ON B.CompanySeq 		= A.CompanySeq
											   AND B.ProcedureSeq 		= A.ProcedureSeq
	LEFT OUTER JOIN _TCBaseUser			AS C    ON C.CompanySeq			= A.CompanySeq
											   AND C.UserSeq		    = A.CheckOutUserSeq
    WHERE A.CompanySeq    			=    InData_CompanySeq
      AND B.ProcedureName 			LIKE InData_ProcedureName
	  AND A.CheckOutUserSeq			like Login_UserSeq;

	set session transaction isolation level repeatable read;
    
END $$
DELIMITER ;