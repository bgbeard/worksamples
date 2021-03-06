USE [C56_Eleveight]
GO
/****** Object:  StoredProcedure [dbo].[AppLog_SelectAll]    Script Date: 8/24/2018 7:16:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Bryan Beard
-- Create date: 07/14/2018
-- Description:	This will select all items
-- =============================================
ALTER PROCEDURE  [dbo].[AppLog_SelectAll] 
	-- Add the parameters for the stored procedure here
	@PageSize int,
	@PageNumber int,
	@AppLogTypeId int
AS
BEGIN
/*
	EXEC	[dbo].[AppLog_SelectAll] @pagesize = 100, @pagenumber=1, @applogtypeid=1

*/
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @RecordCount int = (SELECT count(*) FROM dbo.AppLog WHERE AppLogTypeId = @AppLogTypeId)
	DECLARE @PageCount int = CEILING(@RecordCount / @PageSize)
	DECLARE @Remainder int = @RecordCount % @PageSize
	IF (@Remainder > 0) BEGIN
	SET @PageCount = @PageCount + 1
	END
	SELECT al.Id
	, al.Title
	, al.Message
	, al.StackTrace
	, al.AppLogTypeId
	, al.DateCreated
	, al.UserBaseId
	, alt.TypeName 
	, @PageCount as PageCount
	,
	CASE 
		WHEN al.UserBaseId = 0 THEN 'System'
		WHEN al.UserBaseId = Null THEN 'System' 
		ELSE CONCAT(up.firstName, ' ', up.lastName) END as fullName
	FROM dbo.AppLog as al
	JOIN dbo.AppLogType as alt
		on al.AppLogTypeId = alt.Id
	LEFT JOIN UserProfile up
		on up.UserBaseId = al.UserBaseId
	WHERE al.AppLogTypeId = @AppLogTypeId
	ORDER BY al.DateCreated DESC
	offset @PageSize * (@PageNumber - 1) ROWS
	FETCH NEXT @PageSize ROWS ONLY
END
