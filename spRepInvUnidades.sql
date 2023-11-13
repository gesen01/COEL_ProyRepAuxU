SET DATEFIRST 7
SET ANSI_NULLS OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET LOCK_TIMEOUT -1
SET QUOTED_IDENTIFIER OFF
GO

IF EXISTS(SELECT * FROM sysobjects WHERE TYPE='p' AND NAME='spRepInvUnidades')
DROP PROCEDURE spRepInvUnidades
GO
CREATE PROCEDURE spRepInvUnidades
@Empresa		    varchar(5),
@Estacion        int,
@FechaD			date,
@FechaA			date,
@ArticuloD		varchar(20),
@ArticuloA		varchar(20),
@SubCuenta		varchar(20),
@Moneda			varchar(20),
@ArtCat			varchar(20),
@ArtFam			varchar(20),
@ArtGrupo		varchar(20),
@Fabricante		varchar(20),
@Nivel          varchar(20),
@SerieloteA	 VARCHAR(25)
WITH ENCRYPTION
AS BEGIN
DECLARE @Articulo varchar(20),
@ArtID int,
@ArtDescripcion varchar(100),
@ArtCargoU money,
@ArtAbonoU money,
@ArtMoneda varchar(20),
@ArtSubCuenta varchar(20),
@ArtMovimiento varchar(100),
@ArtFecha datetime,
@ArtSaldoInicialUP money,
@ArtSaldoInicialU money,
@ArtSaldoFinalU money,
@ArtEjercicio int,
@ArtPeriodo	int,
@ArtEsMonetario	bit,
@ArtEsUnidades bit,
@ArtEsResultados bit,
@ArtCargoInicial money,
@ArtAbonoInicial money,
@ArtCargoInicialU float,
@ArtAbonoInicialU float,
@Ok INT,
@SerieLote	 VARCHAR(25)
DELETE RepInvUnidades  WHERE Estacion = @Estacion
DECLARE @RepInvUnidades TABLE(
ID			 int  NULL,
Articulo	     varchar(20) null,
Descripcion	 varchar(100) null,
SubCuenta	 varchar(50) null,
Movimiento    varchar(100) null,
SerieLote	    VARCHAR(25),
Fecha		 datetime null,
CargoU		 float null,
AbonoU		 float null,
Moneda        varchar(100) null)
DECLARE @RepInvUnidadesTmp TABLE(
ID           int  NULL,
Cuenta	    varchar(20) NULL,
Descripcion	varchar(100) null,
Movimiento   varchar(100)  null,
SerieLote	   VARCHAR(25),
Fecha		datetime null,
SaldoIniFec  money null,
SaldoInicial money null,
Cargo		float null,
Abono		float null,
SaldoFinal   money null)
IF UPPER(@ArtCat)     IN ('(Todos)') SELECT @ArtCat = NULL
IF UPPER(@ArtFam)     IN ('(Todos)') SELECT @ArtFam = NULL
IF UPPER(@ArtGrupo)   IN ('(Todos)') SELECT @ArtGrupo = NULL
IF UPPER(@Fabricante) IN ('(Todos)') SELECT @Fabricante = NULL
IF UPPER(@Moneda) 	  IN ('(Todos)') SELECT @Moneda = NULL
IF UPPER(@SubCuenta)  IN ('(TODAS)') SELECT @SubCuenta = NULL
IF UPPER(@SerieloteA)  IN ('(TODOS)') SELECT @SerieloteA = NULL
INSERT INTO @RepInvUnidades
SELECT InvAuxU.ID,
InvAuxU.Cuenta,
Art.Descripcion1,
InvAuxU.SubCuenta,
RTRIM(InvAuxU.Mov)+' '+RTRIM(InvAuxU.MovID),
s.SerieLote,
InvAuxU.Fecha,
InvAuxU.CargoU,
InvAuxU.AbonoU,
InvAuxU.Moneda
FROM InvAuxU (NOLOCK) 
RIGHT OUTER JOIN Art (NOLOCK) ON InvAuxU.Articulo=Art.Articulo
LEFT JOIN SerieLoteMov s ON InvAuxU.Modulo=s.Modulo AND s.Articulo = InvAuxU.Articulo
WHERE InvAuxU.Empresa = @Empresa
AND InvAuxU.Rama ='INV'
AND InvAuxU.Fecha BETWEEN @FechaD AND @FechaA
AND Art.Articulo BETWEEN @ArticuloD AND @ArticuloA
AND ISNULL(Art.Categoria,'')    = ISNULL(ISNULL(@ArtCat, Art.Categoria), '')
AND ISNULL(Art.Familia, '')     = ISNULL(ISNULL(@ArtFam, Art.Familia), '')
AND ISNULL(Art.Grupo, '')       = ISNULL(ISNULL(@ArtGrupo,Art.Grupo), '')
AND ISNULL(Art.Fabricante,'')   = ISNULL(ISNULL(@Fabricante,Art.Fabricante), '')
AND ISNULL(InvAuxU.Moneda,'')    = ISNULL(ISNULL(@Moneda,InvAuxU.Moneda), '')
AND ISNULL(InvAuxU.SubCuenta,'') = ISNULL(ISNULL(@SubCuenta,InvAuxU.SubCuenta), '')
AND ISNULL(s.SerieLote,'') = ISNULL(ISNULL(@SerieloteA,s.SerieLote), '')
ORDER BY Art.Articulo, InvAuxU.SubCuenta, InvAuxU.Fecha, InvAuxU.ID

INSERT INTO @RepInvUnidades( Articulo, Descripcion, SubCuenta, Moneda, SerieLote, CargoU, AbonoU)
SELECT Art.Articulo, Art.Descripcion1, InvAuxU.SubCuenta, InvAuxU.Moneda,s.SerieLote,
sum(CASE WHEN InvAuxU.Fecha >= @FechaD AND InvAuxU.Fecha <= @FechaA THEN ISNULL(InvAuxU.CargoU,0) ELSE 0 END),
sum(CASE WHEN InvAuxU.Fecha >= @FechaD AND InvAuxU.Fecha <= @FechaA THEN ISNULL(InvAuxU.AbonoU,0) ELSE 0 END)
FROM InvAuxU (NOLOCK)
RIGHT OUTER JOIN Art (NOLOCK) ON InvAuxU.Articulo=Art.Articulo
LEFT JOIN SerieLoteMov s ON InvAuxU.Modulo=s.Modulo AND s.Articulo = InvAuxU.Articulo
WHERE InvAuxU.Empresa = @Empresa
AND InvAuxU.Rama ='INV'
AND Art.Articulo BETWEEN @ArticuloD AND @ArticuloA
AND ISNULL(Art.Categoria,'')    = ISNULL(ISNULL(@ArtCat, Art.Categoria), '')
AND ISNULL(Art.Familia, '')     = ISNULL(ISNULL(@ArtFam, Art.Familia), '')
AND ISNULL(Art.Grupo, '')       = ISNULL(ISNULL(@ArtGrupo,Art.Grupo), '')
AND ISNULL(Art.Fabricante,'')   = ISNULL(ISNULL(@Fabricante,Art.Fabricante), '')
AND ISNULL(InvAuxU.Moneda,'')    = ISNULL(ISNULL(@Moneda,InvAuxU.Moneda), '')
AND ISNULL(InvAuxU.SubCuenta,'') = ISNULL(ISNULL(@SubCuenta,InvAuxU.SubCuenta), '')
AND ISNULL(s.SerieLote,'') = ISNULL(ISNULL(@SerieloteA,s.SerieLote), '')
GROUP BY Art.Articulo, Art.Descripcion1, InvAuxU.SubCuenta, InvAuxU.Moneda,s.SerieLote
EXCEPT
SELECT Articulo, Descripcion, SubCuenta, Moneda,SerieLote, SUM(ISNULL(CargoU,0)), SUM(ISNULL(AbonoU,0))
FROM @RepInvUnidades
GROUP BY Articulo, Descripcion, SubCuenta, Moneda,SerieLote

IF UPPER(@Nivel) = 'CONCENTRADO'
BEGIN
DECLARE crInvAcum CURSOR FOR
SELECT Articulo, SubCuenta, Descripcion, SUM(CargoU), SUM(AbonoU), Moneda,SerieLote
FROM @RepInvUnidades
GROUP BY Articulo, SubCuenta, Descripcion, Moneda,SerieLote
OPEN crInvAcum
FETCH NEXT FROM crInvAcum INTO @Articulo, @ArtSubCuenta, @ArtDescripcion, @ArtCargoU, @ArtAbonoU, @ArtMoneda,@SerieLote
WHILE @@FETCH_STATUS <> -1
BEGIN
IF @@FETCH_STATUS <> -2
BEGIN
SELECT @SubCuenta = NULLIF(RTRIM(@SubCuenta), '')
SELECT @SubCuenta = NULLIF(@SubCuenta, '0')
SELECT @ArtEsMonetario  = EsMonetario,
@ArtEsUnidades   = EsUnidades,
@ArtEsResultados = EsResultados
FROM Rama (NOLOCK)
WHERE Rama = 'Inv'
EXEC spPeriodoEjercicio @Empresa, 'Inv', @FechaD, @ArtPeriodo OUTPUT, @ArtEjercicio OUTPUT, @Ok OUTPUT
EXEC spSaldoInicial @Empresa, 'Inv', @Moneda, @ArtGrupo, @Articulo, @SubCuenta, @FechaD, @ArtEsMonetario, @ArtEsUnidades, @ArtEsResultados,
@ArtCargoInicial OUTPUT, @ArtAbonoInicial OUTPUT, @ArtCargoInicialU OUTPUT, @ArtAbonoInicialU OUTPUT,
@Ok OUTPUT 
SELECT @ArtSaldoInicialU = CONVERT(float, ISNULL(@ArtCargoInicialU, 0.0) - ISNULL(@ArtAbonoInicialU, 0.0))
SELECT @ArtSaldoFinalU   = @ArtSaldoInicialU + (ISNULL(@ArtCargoU, 0.0) -ISNULL(@ArtAbonoU, 0.0))
INSERT INTO @RepInvUnidadesTmp(Cuenta, Descripcion, SaldoInicial, Cargo, Abono, SaldoFinal,SerieLote)
VALUES (@Articulo, @ArtDescripcion, @ArtSaldoInicialU, ISNULL(@ArtCargoU, 0.0), ISNULL(@ArtAbonoU, 0.0), @ArtSaldoFinalU,@Serielote)
END
FETCH NEXT FROM crInvAcum INTO @Articulo, @ArtSubCuenta, @ArtDescripcion, @ArtCargoU, @ArtAbonoU, @ArtMoneda,@SerieLote
END  
CLOSE crInvAcum
DEALLOCATE crInvAcum
END
IF UPPER(@Nivel) IN ('DESGLOSADO','DESGLOSADO POR DIA')
BEGIN
DECLARE crInvAcum CURSOR FOR
SELECT ID, Articulo, Movimiento, Fecha, SubCuenta, Descripcion, CargoU, AbonoU, Moneda,SerieLote
FROM @RepInvUnidades
ORDER BY   Articulo, Fecha
OPEN crInvAcum
FETCH NEXT FROM crInvAcum INTO @ArtID, @Articulo, @ArtMovimiento, @ArtFecha, @ArtSubCuenta, @ArtDescripcion, @ArtCargoU, @ArtAbonoU, @ArtMoneda,@SerieLote
WHILE @@FETCH_STATUS <> -1
BEGIN
IF @@FETCH_STATUS <> -2
BEGIN
SELECT @ArtSaldoInicialU =
ISNULL(SUM(ISNULL(CargoU,0))- SUM(ISNULL(AbonoU,0)),0)
FROM AuxiliarU (NOLOCK)
WHERE Empresa   = @Empresa
AND Rama      = 'Inv'
AND ISNULL(Moneda,'') = ISNULL(ISNULL(@ArtMoneda,Moneda), '')
AND Cuenta    = @Articulo
AND ISNULL(SubCuenta,'') = ISNULL(ISNULL(@ArtSubCuenta,SubCuenta), '')
AND ID < @ArtID
AND Ejercicio =  DATEPART(year, @FechaD)
INSERT INTO @RepInvUnidadesTmp(Cuenta, ID, Descripcion, Movimiento, Fecha, SaldoInicial, Cargo, Abono, SaldoFinal,SerieLote)
VALUES (@Articulo, @ArtID, @ArtDescripcion, @ArtMovimiento, @ArtFecha, @ArtSaldoInicialU, ISNULL(@ArtCargoU, 0.0), ISNULL(@ArtAbonoU, 0.0),  @ArtSaldoInicialU + (ISNULL(@ArtCargoU, 0.0) -ISNULL(@ArtAbonoU, 0.0)),@SerieLote)
IF @ArtID = (select MAX(ID) FROM @RepInvUnidades where Articulo = @Articulo)
BEGIN
SELECT @ArtSaldoInicialUP = ISNULL(SUM(ISNULL(CargoU,0))- SUM(ISNULL(AbonoU,0)),0)
FROM AuxiliarU (NOLOCK)
WHERE Empresa   = @Empresa
AND Rama      = 'Inv'
AND ISNULL(Moneda,'') = ISNULL(ISNULL(@ArtMoneda,Moneda), '')
AND Cuenta    = @Articulo
AND ISNULL(SubCuenta,'') = ISNULL(ISNULL(@ArtSubCuenta,SubCuenta), '')
AND Fecha < @FechaD
AND Ejercicio =  DATEPART(year, @FechaD)
IF @ArtID IS NULL
UPDATE @RepInvUnidadesTmp SET SaldoIniFec= @ArtSaldoInicialUP, SaldoInicial = @ArtSaldoInicialUP WHERE  Cuenta = @Articulo AND ID = @ArtID
ELSE
UPDATE @RepInvUnidadesTmp SET SaldoIniFec= @ArtSaldoInicialUP WHERE  Cuenta = @Articulo AND ID = @ArtID
END
END
FETCH NEXT FROM crInvAcum INTO @ArtID, @Articulo, @ArtMovimiento, @ArtFecha, @ArtSubCuenta, @ArtDescripcion, @ArtCargoU, @ArtAbonoU, @ArtMoneda,@SerieLote
END  
CLOSE crInvAcum
DEALLOCATE crInvAcum
END
INSERT RepInvUnidades(ID, Cuenta, Estacion, IdMovAux, Descripcion, Movimiento,SerieLote, Fecha, SaldoUIniFec, SaldoUInicial, CargoU, AbonoU, SaldoFinal)
SELECT ROW_NUMBER() OVER(ORDER BY Cuenta),Cuenta, @Estacion, ID, Descripcion, Movimiento,SerieLote, Fecha, SaldoIniFec, SaldoInicial, Cargo, Abono, SaldoFinal
FROM @RepInvUnidadesTmp
END
GO
