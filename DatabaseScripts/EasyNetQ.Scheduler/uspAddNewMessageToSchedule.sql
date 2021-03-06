/****** Object:  StoredProcedure [dbo].[usp_addNewMessageToScheduler]    Script Date: 11/25/2011 15:41:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[uspAddNewMessageToScheduler] 
	@WakeTime DATETIME,
	@BindingKey NVARCHAR(1000),
	@Message VARBINARY(MAX)
AS
/******************************************************************************
**		File: uspAddNewMessageToScheduler.sql
**		Name: uspAaddNewMessageToScheduler 
**		Desc: Dummy update script, to test concurrency on workItems table
**
**
**		Auth: Steve Smith
**		Date: 20111115
**
*******************************************************************************
**		Change History
*******************************************************************************
**		Date:		Author:				Description:
**		--------	--------			-------------------------------------------
**		20111115	Steve Smith			Original creation for demonstration
*******************************************************************************/

DECLARE @NewID INT

BEGIN TRANSACTION

INSERT INTO WorkItems (BindingKey, InnerMessage)
VALUES (@BindingKey,@Message )
-- get the ID of the inserted record for use in the child table
SELECT @NewID = SCOPE_IDENTITY()
IF @@ERROR > 0
	ROLLBACK TRANSACTION
ELSE
	-- only setup the child status record if the WorkItem insert succeeded
	BEGIN
		INSERT INTO WorkItemStatus (WorkItemID, [Status], WakeTime)
		OUTPUT INSERTED.WorkItemID, INSERTED.status, INSERTED.WakeTime
		VALUES (@NewID, 0, @WakeTime)
    	
		IF @@ERROR > 0 
			ROLLBACK TRANSACTION
		ELSE
			BEGIN
				 COMMIT TRANSACTION
			END 
	END 
--WAITFOR DELAY '00:00.005'  -- delay for use in throttling during testing
