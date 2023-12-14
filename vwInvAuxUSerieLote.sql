SET DATEFIRST 7
SET ANSI_NULLS OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET LOCK_TIMEOUT -1
SET QUOTED_IDENTIFIER OFF
GO

IF EXISTS(SELECT * FROM sysobjects WHERE TYPE='v' AND NAME='vwInvAuxUSerieLote')
DROP VIEW vwInvAuxUSerieLote
GO
CREATE VIEW vwInvAuxUSerieLote
AS
SELECT
InvAuxU.Articulo,
InvAuxU.ID,
InvAuxU.Empresa,
InvAuxU.Rama,
InvAuxU.Mov,
InvAuxU.MovID,
InvAuxU.Modulo,
InvAuxU.Moneda,
InvAuxU.Grupo,
InvAuxU.Cuenta,
InvAuxU.SubCuenta,
InvAuxU.Fecha,
InvAuxU.EsCancelacion,
InvAuxU.Sucursal,
Art.Descripcion1,
SerieLoteMov.SerieLote,
IIF(ISNULL(InvAuxU.CargoU,0)<>0,IIF(ISNULL(InvAuxU.CargoU,0)<0,SerieLoteMov.Cantidad*-1,SerieLoteMov.Cantidad),0) AS 'CargoS',
IIF(ISNULL(InvAuxU.AbonoU,0)<>0,IIF(ISNULL(InvAuxU.AbonoU,0)<0,SerieLoteMov.Cantidad*-1,SerieLoteMov.Cantidad),0) AS 'AbonoS',
SerieLoteMov.Cantidad
FROM
InvAuxU
RIGHT OUTER JOIN Art ON InvAuxU.Articulo=Art.Articulo
LEFT OUTER JOIN SerieLoteMov ON SerieLoteMov.Articulo = InvAuxU.Articulo AND SerieLoteMov.Modulo = InvAuxU.Modulo AND SerieLoteMov.Empresa = InvAuxU.Empresa AND SerieLoteMov.ID = InvAuxU.ModuloID

