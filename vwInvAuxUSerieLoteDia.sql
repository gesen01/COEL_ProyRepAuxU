SET DATEFIRST 7
SET ANSI_NULLS OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET LOCK_TIMEOUT -1
SET QUOTED_IDENTIFIER OFF
GO

IF EXISTS(SELECT * FROM sysobjects WHERE TYPE='v' AND NAME='vwInvAuxUSerieLoteDia')
DROP VIEW vwInvAuxUSerieLoteDia
GO
CREATE VIEW vwInvAuxUSerieLoteDia
AS
SELECT DISTINCT
AuxiliarU.ID,
AuxiliarU.Empresa,
AuxiliarU.Mov,
AuxiliarU.MovID,
AuxiliarU.Cuenta,
AuxiliarU.SubCuenta,
AuxiliarU.Fecha,
AuxiliarU.Grupo,
AuxiliarU.Rama,
AuxiliarU.EsCancelacion,
AuxiliarU.Moneda,
Art.Articulo,
Art.Descripcion1,
Art.PrecioLista,
'PrecioUnitario' = ISNULL(CASE AuxiliarU.Modulo           WHEN 'VTAS' THEN VentaD.Precio-(( VentaD.Precio * isnull(Ventad.Descuentolinea,0))/100) -  ( (VentaD.Precio-(( VentaD.Precio * isnull(Ventad.Descuentolinea,0))/100))*ISNULL(VENTA.DESCUENTOGLOBAL,0)/100)
WHEN 'COMS' THEN CompraD.Costo-(( CompraD.Costo * isnull(Comprad.Descuentolinea,0))/100) -  ( (CompraD.Costo-(( CompraD.Costo * isnull(Comprad.Descuentolinea,0))/100))*ISNULL(Compra.DESCUENTOGLOBAL,0)/100)
WHEN 'INV' THEN InvD.Costo END,0),
AuxiliarU.ModuloID,
SerieLoteMov.SerieLote,
IIF(ISNULL(AuxiliarU.CargoU,0)<>0,IIF(ISNULL(AuxiliarU.CargoU,0)<0,SerieLoteMov.Cantidad*-1,SerieLoteMov.Cantidad),0) AS 'CargoS',
IIF(ISNULL(AuxiliarU.AbonoU,0)<>0,IIF(ISNULL(AuxiliarU.AbonoU,0)<0,SerieLoteMov.Cantidad*-1,SerieLoteMov.Cantidad),0) AS 'AbonoS',
'CantidadSerie'=SerieLoteMov.Cantidad
FROM Art
LEFT OUTER JOIN AuxiliarU  ON Art.Articulo = AuxiliarU.Cuenta AND (CargoU IS NOT NULL OR AbonoU IS NOT NULL)
LEFT OUTER JOIN VentaD ON VentaD.ID=AuxiliarU.ModuloID  AND Art.Articulo = VentaD.Articulo AND AuxiliarU.Modulo = 'VTAS'
LEFT OUTER JOIN VENTA ON  VENTAD.ID=VENTA.ID
LEFT OUTER JOIN CompraD ON AuxiliarU.ModuloID = CompraD.ID AND Art.Articulo = CompraD.Articulo AND AuxiliarU.Modulo = 'COMS'
LEFT OUTER JOIN COMPRA  ON  COMPRAD.ID=COMPRA.ID
LEFT OUTER JOIN INVD ON AuxiliarU.ModuloID = InvD.ID AND Art.Articulo = InvD.Articulo AND AuxiliarU.Modulo = 'INV'
LEFT OUTER JOIN SerieLoteMov ON SerieLoteMov.Modulo = AuxiliarU.Modulo AND SerieLoteMov.Empresa = AuxiliarU.Empresa AND SerieLoteMov.Articulo=AuxiliarU.Cuenta AND SerieLoteMov.ID=AuxiliarU.ModuloID

