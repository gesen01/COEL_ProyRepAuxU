SET DATEFIRST 7
SET ANSI_NULLS OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET LOCK_TIMEOUT -1
SET QUOTED_IDENTIFIER OFF
GO

IF EXISTS(SELECT * FROM sysobjects WHERE TYPE='fn' AND NAME='fnCOELSaldoSerieLote')
DROP FUNCTION fnCOELSaldoSerieLote
GO
CREATE FUNCTION fnCOELSaldoSerieLote(@FechaA DATETIME, @Articulo VARCHAR(20), @Almacen VARCHAR(15), @SerieLote VARCHAR(30))
RETURNS FLOAT
AS
BEGIN
	DECLARE @Resultado	FLOAT
	
	IF @Almacen='(TODOS)'
		SET @Almacen=NULL
		
	IF @SerieLote='(Todos)'
		SET @SerieLote=NULL
		
	SELECT @Resultado=SUM(Existencia)
	FROM vwCOELSerieLoteSaldos
	WHERE FechaEmision<=@FechaA
	AND Articulo=@Articulo
	AND (Almacen=@Almacen OR @Almacen IS NULL)
	AND (SerieLote=@SerieLote OR @SerieLote IS NULL)
	
	RETURN @Resultado
END
