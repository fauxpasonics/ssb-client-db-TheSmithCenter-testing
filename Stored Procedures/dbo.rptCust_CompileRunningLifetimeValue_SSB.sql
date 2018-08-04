SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE proc [dbo].[rptCust_CompileRunningLifetimeValue_SSB]
		 as
		 
		 drop table dbo.rpt_RunningLifetimeValue

		 select trans.Customer,trans.date,sum(e_oqty_tot) e_oqty_tot, sum(e_oqty_tot*e_price) e_price into #hivalcust from
		 dbo.TK_TRANS_ITEM_EVENT trans       
		 where trans.E_OQTY_TOT <> 0
		 group by trans.Customer, trans.date
		 

		 select h1.Customer,h1.date,sum(h2.e_oqty_tot) e_oqty_tot, sum(h2.e_price) e_price into dbo.rpt_RunningLifetimeValue
		 from (select distinct h1.customer, h1.date from #hivalcust h1) h1 join #hivalcust h2 on h1.Customer = h2.Customer and cast(h2.date as date) < cast(h1.date as date)		 
		 group by h1.date, h1.Customer
		 order by customer,h1.date
		 
GO
