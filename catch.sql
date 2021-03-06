USE [AdventureWorks2017]
GO
/****** Object:  StoredProcedure [dbo].[spCommit]    Script Date: 2018/10/29 上午 06:04:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER    PROCEDURE [dbo].[spCommit] 	--創建SP名稱
AS
   begin try
   declare @Date as date,@int as int = 0, @price as int = 0
   declare @OraIndex as int = 0, @Ora_Price as int = 0
   declare test 
   cursor for
   (select
   a.ProductID
   ,a.ListPrice
    from Production.Product a
	where a.ListPrice > 20 and a.ProductID in (776) )
	
	open test
	FETCH NEXT FROM test INTO @OraIndex , @Ora_Price
	WHILE @@FETCH_STATUS = 0
	BEGIN
	--select @price = a.ListPrice from Production.Product a where a.ProductID = @int

	declare @Fix_Qty as int = 0,@Fix_PID as int = 0,@Fix_UPrice as int = 0, @Fix_LTotal as int = 0, @MoDate as date = GetDate()
	declare @SaleOrID as int = 0
	declare @ERROR AS INT = 0
	select 
	@Fix_Qty = a.OrderQty
	--,@Fix_PID = a.ProductID
	--,@Fix_UPrice = a.UnitPrice
	--,@Fix_LTotal = a.LineTotal
	,@MoDate = a.ModifiedDate
	--,@SaleOrID = a.SalesOrderDetailID
	from Sales.SalesOrderDetail a where a.ProductID = @OraIndex

	--select a.ListPrice, a.ProductID from Production.Product a where a.ProductID = 514

	if @MoDate >= '1998/'
	begin
		Begin Transaction						--	開始交易
		--set @Fix_UPrice = exec
		--set @Fix_UPrice = exec dbo.FixPrice @Ora_Price	--	取得新價錢

		select @Fix_UPrice = dbo.FixPrice(@Ora_Price)
		update Sales.SalesOrderDetail 
		set UnitPrice = @Fix_UPrice				--	產品價格與
		--,LineTotal = @Ora_Price * @Fix_Qty		--	訂單價格更新
		where ProductID = @OraIndex
		
		set @ERROR = @@ERROR
		if(@ERROR>0)
			rollback
		else
			commit
	end
	--update Production.Product set ListPrice = @price where ProductID = @int
	FETCH NEXT FROM test INTO @OraIndex , @Ora_Price

	END
	close test

	deallocate test
	end try
	begin catch
		print 'Catch Error'
	end catch;
