SET DATEFIRST 7
SET ANSI_NULLS OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET LOCK_TIMEOUT -1
SET QUOTED_IDENTIFIER OFF
GO
IF EXISTS(SELECT * FROM sysobjects WHERE TYPE='v' AND NAME='vwCOELSerieLoteSaldos')
DROP VIEW vwCOELSerieLoteSaldos
GO
CREATE VIEW vwCOELSerieLoteSaldos
AS
SELECT d.Articulo,v.almacen,s.SerieLote,v.empresa,v.sucursal,SUM(s.Cantidad)*-1 AS 'Existencia',v.FechaEmision
FROM Venta v
JOIN VentaD d ON v.ID=d.ID
JOIN SerieLoteMov s ON s.ID=d.ID AND s.Articulo=d.Articulo AND d.RenglonID=s.RenglonID
JOIN MovTipo m ON v.Mov=m.Mov AND m.Modulo='VTAS' AND m.Clave IN ('VTAS.F','VTAS.D')
WHERE v.Estatus IN ('CONCLUIDO','PENDIENTE')
GROUP BY d.Articulo,v.almacen,s.SerieLote,v.empresa,v.sucursal,v.FechaEmision
UNION ALL
SELECT d.Articulo,IIF(Mov IN ('Recibo Traspaso','Transf Sucursal'),v.AlmacenDestino,v.Almacen),s.SerieLote,v.empresa,v.sucursal
	  ,SUM(IIF(v.Mov IN ('Salida Traspaso'),d.Cantidad*-1,IIF(d.Cantidad<0,s.Cantidad*-1,s.cantidad))) AS 'Existencia',v.FechaEmision
FROM Inv v
JOIN InvD d ON v.ID=d.ID
JOIN SerieLoteMov s ON s.ID=d.ID AND s.Articulo=d.Articulo AND d.RenglonID=s.RenglonID 
WHERE v.Estatus IN ('CONCLUIDO','PENDIENTE')
AND v.Mov NOT IN ('Transf Sucursal')
GROUP BY d.Articulo,v.almacen,s.SerieLote,v.empresa,v.sucursal,v.Mov,v.AlmacenDestino,v.FechaEmision
UNION ALL
SELECT d.Articulo,c.almacen,s.SerieLote,c.empresa,c.sucursal,SUM(s.Cantidad) AS 'Existencia',c.FechaEmision
FROM Compra c
JOIN CompraD d ON c.ID=d.ID
JOIN SerieLoteMov s ON s.ID=d.ID AND s.Articulo=d.Articulo AND d.RenglonID=s.RenglonID 
WHERE c.Estatus IN ('CONCLUIDO','PENDIENTE')
GROUP BY d.Articulo,c.almacen,s.SerieLote,c.empresa,c.sucursal,c.FechaEmision

