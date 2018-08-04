SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE PROCEDURE [dbo].[rptCust_EventTagBySeason_SSB]
    @Season VARCHAR(500)
  , @EventType VARCHAR(500)
  , @Venue VARCHAR(500)
AS
    BEGIN

        SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

        SET NOCOUNT ON

        SELECT  *
        FROM    ( SELECT DISTINCT
                            CASE WHEN event.TAG LIKE '%BWAY%' THEN 'BWAY'
                                 WHEN event.TAG LIKE '%HOUSE%' THEN 'HOUSE'
                                 WHEN event.TAG LIKE '%RESCO%' THEN 'RESCO'
                                 WHEN event.TAG LIKE '%4WALL%' THEN '4WALL'
                            END AS TAG
                          , CASE WHEN event.TAG LIKE '%BWAY%'
                                 THEN 'Broadway Performances'
                                 WHEN event.TAG LIKE '%HOUSE%'
                                 THEN 'House Presentations'
                                 WHEN event.TAG LIKE '%RESCO%'
                                 THEN 'Resident Companies'
                                 WHEN event.TAG LIKE '%4WALL%' THEN 'Rentals'
                            END AS EventTagName
                  FROM      dbo.TK_EVENT event
                            JOIN dbo.TK_SEASON season ON season.SEASON = event.SEASON
                  WHERE     event.SEASON IN (
                            SELECT  ITEM
                            FROM    [dbo].[SplitSSB](@Season, ',') )
                            AND event.ETYPE IN (
                            SELECT  ITEM
                            FROM    [dbo].[SplitSSB](@EventType, ',') )
                            AND event.TAG IS NOT NULL
                            AND event.FACILITY IN (
                            SELECT  ITEM
                            FROM    [dbo].[SplitSSB](@Venue, ',') )
                ) x
        WHERE   x.TAG IS NOT NULL
    END



GO
