CREATE TABLE [dbo].[RepInvUnidades](
	[ID] [int] NOT NULL,
	[Cuenta] [varchar](20) NOT NULL,
	[Estacion] [int] NOT NULL,
	[IdMovAux] [int] NULL,
	[Descripcion] [varchar](100) NULL,
	[Movimiento] [varchar](100) NULL,
	[Fecha] [datetime] NULL,
	[SaldoUIniFec] [money] NULL,
	[SaldoUInicial] [money] NULL,
	[CargoU] [money] NULL,
	[AbonoU] [money] NULL,
	[SaldoFinal] [money] NULL,
 CONSTRAINT [priRepInvUnidades] PRIMARY KEY CLUSTERED 
(
	[ID] ASC,
	[Cuenta] ASC,
	[Estacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


