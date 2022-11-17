---------------------------------------------------------- DATA
-- OVERALL LIGUE 1 DATA
SELECT *
FROM PortfolioProject.dbo.Ligue1
-- GOALKEEPING
SELECT *
FROM PortfolioProject.dbo.Goalkeeping
-- DEFENDING
SELECT *
FROM PortfolioProject.dbo.Defending
-- PASSING
SELECT *
FROM PortfolioProject.dbo.Passing
-- SHOOTING
SELECT *
FROM PortfolioProject.dbo.Shooting

-- CRITERIA: ALL PLAYERS NEED TO HAVE PLAYED THE EQUIVALENT OF FIVE FULL GAMES (90*5 MINUTES AT LEAST)


------------------------------------------------------------------- GOALKEEPERS
-- TABLE MANAGEMENT
DROP TABLE GoalkeepersTable
DROP TABLE GoalkeepersTable2
DROP TABLE GoalkeepersTable3
DROP TABLE FinalGoalkeeperTable

-- CREATE A TABLE FOR MIDFIELDERS WITH BASIC DATA
SELECT Player, Nation, Pos, Squad
INTO GoalkeepersTable
FROM PortfolioProject..Ligue1
WHERE Pos LIKE '%GK%'

-- FIRST CRITERIA: SAVE PERCENTAGE
SELECT GoalkeepersTable.*, def.[Performance Save%]/100 AS "SavePercentage"
INTO GoalkeepersTable2
FROM GoalkeepersTable
INNER JOIN PortfolioProject..Goalkeeping def
ON def.Player = GoalkeepersTable.Player AND def.Squad = GoalkeepersTable.Squad
WHERE def.[Playing Time 90s] > 5
-- SECOND CRITERIA: SHOTS ON TARGET AGAINST NORMALIZED BY HIGHEST VALUE
SELECT GoalkeepersTable2.*, def."Performance SoTA" / (SELECT MAX([Performance SoTA]) FROM PortfolioProject..Goalkeeping) AS "SOTA"
INTO GoalkeepersTable3
FROM GoalkeepersTable2
INNER JOIN PortfolioProject..Goalkeeping def
ON def.Player = GoalkeepersTable2.Player AND def.Squad = GoalkeepersTable2.Squad
--  CALCULATE FINAL SCORE AS THE PRODUCT OF SAVE PERCENTAGE AND SHOTS ON TARGET AGAINST
SELECT def.*, def.SavePercentage * def.SOTA AS "GoalkeepingScore"
INTO FinalGoalkeeperTable
FROM GoalkeepersTable3 def
ORDER BY 7 DESC

-- VISUALIZE TABLE
SELECT *
FROM FinalGoalkeeperTable
ORDER BY 7 DESC


------------------------------------------------------------------ DEFENDERS 
-- TABLE MANAGEMENT
DROP TABLE DefendersTable
DROP TABLE DefendersTable2
DROP TABLE DefendersTable3
DROP TABLE DefendersTable4
DROP TABLE DefendersTable5
DROP TABLE FinalDefendersTable

-- CREATE A TABLE FOR DEFENDERS WITH BASIC DATA
SELECT Player, Nation, Pos, Squad
INTO DefendersTable
FROM PortfolioProject..Ligue1
WHERE Pos LIKE '%DF%'

-- FIRST CRITERIA: NUMBER OF TACKLES AND INTERCEPTIONS STANDARDIZED BY THE HIGHEST VALUE
SELECT DefendersTable.*, def."Tkl+Int" / (SELECT MAX("Tkl+Int") FROM PortfolioProject..Defending) AS "Tackles+InterceptRatio"
INTO DefendersTable2
FROM DefendersTable
INNER JOIN PortfolioProject..Defending def
ON def.Player = DefendersTable.Player AND def.Squad = DefendersTable.Squad
WHERE def.[90s] > 5
-- SECOND CRITERIA: NUMBER OF CLEARANCES STANDARDIZED BY THE HIGHEST VALUE
SELECT DefendersTable2.*, def."Clr" / (SELECT MAX("Clr") FROM PortfolioProject..Defending) AS "ClearancesRatio"
INTO DefendersTable3
FROM DefendersTable2
INNER JOIN PortfolioProject..Defending def
ON def.Player = DefendersTable2.Player AND def.Squad = DefendersTable2.Squad
-- CALCULATE THE MEAN VALUE BETWEEN THE TWO PREVIOUS VALUES
SELECT def.*, ROUND((def.[Tackles+InterceptRatio]+def.ClearancesRatio)/2,2) AS "MeanDefRatio"
INTO DefendersTable4
FROM DefendersTable3 def
--  THIRD CRITERIA: PERCENTAGE COMPLETION OF PASSES
SELECT DefendersTable4.*, ROUND(def."Total Cmp%"/100,2) AS "PassCompRatio"
INTO DefendersTable5
FROM DefendersTable4
INNER JOIN PortfolioProject..Passing def
ON def.Player = DefendersTable4.Player AND def.Squad = DefendersTable4.Squad
--  CALCULATE FINAL SCORE WHERE THE WEIGHT OF DEFENDING VALUE IS 2 AND PASSING VALUE IS 1
SELECT def.*, ((def.MeanDefRatio*2) + (def.PassCompRatio))/3 AS "DefendingScore"
INTO FinalDefendersTable
FROM DefendersTable5 def
ORDER BY 9 DESC

-- VISUALIZE TABLE
SELECT *
FROM FinalDefendersTable


----------------------------------------------------------- DEFENDING MIDFIELDERS
-- TABLE MANAGEMENT
DROP TABLE DefMidTable
DROP TABLE DefMidTable2
DROP TABLE DefMidTable3
DROP TABLE DefMidTable4
DROP TABLE DefMidTable5
DROP TABLE FinalDefMidTable

-- CREATE A TABLE FOR MIDFIELDERS WITH BASIC DATA
SELECT Player, Nation, Pos, Squad
INTO DefMidTable
FROM PortfolioProject..Ligue1
WHERE Pos LIKE '%MF%'

-- FIRST CRITERIA: NUMBER OF TACKLES AND INTERCEPTIONS STANDARDIZED BY THE HIGHEST VALUE
SELECT DefMidTable.*, def."Tkl+Int" / (SELECT MAX("Tkl+Int") FROM PortfolioProject..Defending) AS "Tackles+InterceptRatio"
INTO DefMidTable2
FROM DefMidTable
INNER JOIN PortfolioProject..Defending def
ON def.Player = DefMidTable.Player AND def.Squad = DefMidTable.Squad
WHERE def.[90s] > 5
--  SECOND CRITERIA: PERCENTAGE COMPLETION OF PASSES
SELECT DefMidTable2.*, ROUND(def."Total Cmp%"/100,2) AS "PassCompRatio"
INTO DefMidTable3
FROM DefMidTable2
INNER JOIN PortfolioProject..Passing def
ON def.Player = DefMidTable2.Player AND def.Squad = DefMidTable2.Squad
--  THIRD CRITERIA: NUMBER OF PASSES THAT PROGRESS THE BALL AT LEAST 10 YARDS FORWARD
SELECT DefMidTable3.*, def."Prog" / (SELECT MAX("Prog") FROM PortfolioProject..Passing) AS "ProgressionRatio"
INTO DefMidTable4
FROM DefMidTable3
INNER JOIN PortfolioProject..Passing def
ON def.Player = DefMidTable3.Player AND def.Squad = DefMidTable3.Squad
--  CALCULATE PASSING SCORE WHERE THE WEIGHT OF PROGRESSION VALUE IS 2 AND PASS COMPLETION VALUE IS 1
SELECT def.*, (def.PassCompRatio + (ProgressionRatio*2))/3 AS "PassingScore"
INTO DefMidTable5
FROM DefMidTable4 def
--  CALCULATE FINAL SCORE WHERE THE WEIGHT OF DEFENDING VALUE AND PASSING ARE EQUAL
SELECT def.*, (def.[Tackles+InterceptRatio] + def.PassingScore)/2 AS "DefMidScore"
INTO FinalDefMidTable
FROM DefMidTable5 def
ORDER BY 9 DESC

-- VISUALIZE TABLE
SELECT *
FROM FinalDefMidTable

----------------------------------------------------------- OFFENSIVE MIDFIELDERS
-- TABLE MANAGEMENT
DROP TABLE OffMidTable
DROP TABLE OffMidTable2
DROP TABLE OffMidTable3
DROP TABLE OffMidTable4
DROP TABLE OffMidTable5
DROP TABLE OffMidTable6
DROP TABLE OffMidTable7
DROP TABLE OffMidTable8
DROP TABLE OffMidTable9
DROP TABLE OffMidTable10
DROP TABLE OffMidTable11
DROP TABLE FinalOffMidTable

-- CREATE A TABLE FOR MIDFIELDERS WITH BASIC DATA
SELECT Player, Nation, Pos, Squad
INTO OffMidTable
FROM PortfolioProject..Ligue1
WHERE Pos LIKE '%MF%'

--  FIRST CRITERIA: PERCENTAGE COMPLETION OF PASSES
SELECT OffMidTable.*, ROUND(def."Total Cmp%"/100,2) AS "PassCompRatio"
INTO OffMidTable2
FROM OffMidTable
INNER JOIN PortfolioProject..Passing def
ON def.Player = OffMidTable.Player AND def.Squad = OffMidTable.Squad
WHERE def.[90s] > 5
-- SECOND CRITERIA: NUMBER OF ASSISTS STANDARDIZED BY THE HIGHEST VALUE
SELECT OffMidTable2.*, def."Ast" / (SELECT MAX("Ast") FROM PortfolioProject..Passing) AS "AssistRatio"
INTO OffMidTable3
FROM OffMidTable2
INNER JOIN PortfolioProject..Passing def
ON def.Player = OffMidTable2.Player AND def.Squad = OffMidTable2.Squad
-- THIRD CRITERIA: NUMBER OF ASSISTS THAT SHOULD LEAD TO EXPECTED GOALS STANDARDIZED BY THE HIGHEST VALUE
SELECT OffMidTable3.*, def."xA" / (SELECT MAX("xA") FROM PortfolioProject..Passing) AS "ExpAsstRatio"
INTO OffMidTable4
FROM OffMidTable3
INNER JOIN PortfolioProject..Passing def
ON def.Player = OffMidTable3.Player AND def.Squad = OffMidTable3.Squad
--  CALCULATE PASSING SCORE AS THE MEAN VAULE BETWEEN COMPLETION, ASSISTS, AND ASSISTS TO EXPECTED GOALS
SELECT def.*, (def.PassCompRatio + def.AssistRatio + def.ExpAsstRatio)/3 AS "PassingScore"
INTO OffMidTable5
FROM OffMidTable4 def
-- FOURTH CRITERIA: NUMBER OF SHOTS STANDARDIZED BY THE HIGHEST VALUE
SELECT OffMidTable5.*, def."Standard Sh" / (SELECT MAX("Standard Sh") FROM PortfolioProject..Shooting) AS "ShotsRatio"
INTO OffMidTable6
FROM OffMidTable5
INNER JOIN PortfolioProject..Shooting def
ON def.Player = OffMidTable5.Player AND def.Squad = OffMidTable5.Squad
-- FIFTH CRITERIA: PERCENTAGE OF SHOTS ON TARGET STANDARDIZED BY THE HIGHEST VALUE
SELECT OffMidTable6.*, def."Standard SoT%" / (SELECT MAX("Standard SoT%") FROM PortfolioProject..Shooting) AS "ShotsOnTargetRatio"
INTO OffMidTable7
FROM OffMidTable6
INNER JOIN PortfolioProject..Shooting def
ON def.Player = OffMidTable6.Player AND def.Squad = OffMidTable6.Squad
--  CALCULATE SHOOTING SCORE AS THE PRODUCT OF SHOTS AND PERCENTAGE SHOTS ON TARGET
SELECT def.*, (def.ShotsRatio * def.ShotsOnTargetRatio) AS "ShootingScore"
INTO OffMidTable8
FROM OffMidTable7 def
-- SIXTH CRITERIA: NUMBER OF GOALS DIVIDED BY EXPECTED GOALS
SELECT OffMidTable8.*, (def."Gls" / def."Expected xG") AS "Goals/xG"
INTO OffMidTable9
FROM OffMidTable8
INNER JOIN PortfolioProject..Shooting def
ON def.Player = OffMidTable8.Player AND def.Squad = OffMidTable8.Squad
WHERE def.[Expected xG]>0
-- STANDARDIZE PREVIOUS VALUE BY MAX VALUE
SELECT def.*, def."Goals/xG" / (SELECT MAX("Goals/xG") FROM OffMidTable9) AS "GoalsRatio"
INTO OffMidTable10
FROM OffMidTable9 def
--  CALCULATE SCORING SCORE AS THE PRODUCT OF SHOOTING SCORE ANDS GOALS/XGOALS
SELECT def.*, def."ShootingScore" * def.GoalsRatio AS "ScoringScore"
INTO OffMidTable11
FROM OffMidTable10 def
--  CALCULATE FINAL SCORE WHERE THE WEIGHT OF PASSING VALUE IS 2 AND SCORING VALUE IS 1
SELECT def.*, ((def.PassingScore *2) + def.ScoringScore)/3 AS "OffMidScore"
INTO FinalOffMidTable
FROM OffMidTable11 def
ORDER BY 12 DESC

-- VISUALIZE TABLE
SELECT *
FROM FinalOffMidTable




-------------------------------------------------------------- FORWARDS
-- TABLE MANAGEMENT
DROP TABLE ForwardTable
DROP TABLE ForwardTable2
DROP TABLE ForwardTable3
DROP TABLE ForwardTable4
DROP TABLE ForwardTable5
DROP TABLE ForwardTable6
DROP TABLE ForwardTable7
DROP TABLE ForwardTable8
DROP TABLE FinalForwardTable

-- CREATE A TABLE FOR FORWARDS WITH BASIC DATA
SELECT Player, Nation, Pos, Squad
INTO ForwardTable
FROM PortfolioProject..Ligue1
WHERE Pos LIKE '%FW%'

-- FIRST CRITERIA: NUMBER OF GOALS STANDARDIZED BY THE HIGHEST VALUE
SELECT ForwardTable.*, def."Gls" / (SELECT MAX("Gls") FROM PortfolioProject..Shooting) AS "GoalsRatio"
INTO ForwardTable2
FROM ForwardTable
INNER JOIN PortfolioProject..Shooting def
ON def.Player = ForwardTable.Player AND def.Squad = ForwardTable.Squad
WHERE def.[90s] > 5
-- SECOND CRITERIA: NUMBER OF GOALS DIVIDED BY EXPECTED GOALS
SELECT ForwardTable2.*, (def."Gls" / def."Expected xG") AS "Goals/xG"
INTO ForwardTable3
FROM ForwardTable2
INNER JOIN PortfolioProject..Shooting def
ON def.Player = ForwardTable2.Player AND def.Squad = ForwardTable2.Squad
WHERE def.[Expected xG]>0
-- STANDARDIZE PREVIOUS VALUE BY MAX VALUE
SELECT def.*, def."Goals/xG" / (SELECT MAX("Goals/xG") FROM ForwardTable3) AS "Goals/xGRatio"
INTO ForwardTable4
FROM ForwardTable3 def
-- CALCULATE SCORING SCORE AS PRODUCT OF GOALS AND GOALS/XG
SELECT def.*, def.GoalsRatio * def.[Goals/xGRatio] AS "ScoringScore"
INTO ForwardTable5
FROM ForwardTable4 def
-- THIRD CRITERIA: SHOTS STANDARDIZED BY THE HIGHEST VALUE
SELECT ForwardTable5.*, def."Standard Sh" / (SELECT MAX("Standard Sh") FROM PortfolioProject..Shooting) AS "Shots"
INTO ForwardTable6
FROM ForwardTable5
INNER JOIN PortfolioProject..Shooting def
ON def.Player = ForwardTable5.Player AND def.Squad = ForwardTable5.Squad
-- FOURTH CRITERIA: SHOTS ON TARGET PERCENTAGE
SELECT ForwardTable6.*, def."Standard SoT%" / 100 AS "ShotsOnTarget%"
INTO ForwardTable7
FROM ForwardTable6
INNER JOIN PortfolioProject..Shooting def
ON def.Player = ForwardTable6.Player AND def.Squad = ForwardTable6.Squad
-- CALCULATE SHOOTING SCORE AS PRODUCT OF SHOTS AND SOT%
SELECT def.*, def.Shots * def.[ShotsOnTarget%] AS "ShootingScore"
INTO ForwardTable8
FROM ForwardTable7 def
-- CALCULATE FINAL SCORE AS PRODUCT OF SHOOTING AND SCORING SCORES
SELECT def.*, def.ShootingScore * def.ScoringScore AS "ForwardScore"
INTO FinalForwardTable
FROM ForwardTable8 def
ORDER BY 12 DESC

-- VISUALIZE TABLE
SELECT *
FROM FinalForwardTable


---------------------------------------------------------------------- OUTPUT BEST SQUAND
DROP TABLE BestCurrentSquad

CREATE TABLE BestCurrentSquad (
Player varchar(255),
Nation varchar(255),
Pos varchar(255),
Squad varchar(255),
Score float)

-- ADD BEST GOALKEEPER
INSERT INTO BestCurrentSquad (Player, Nation, Pos, Squad, Score)
SELECT TOP 1 Player, Nation, Pos, Squad, GoalkeepingScore
FROM FinalGoalkeeperTable
ORDER BY 5 DESC
-- ADD FOUR BEST DEFENDERS
INSERT INTO BestCurrentSquad (Player, Nation, Pos, Squad, Score)
SELECT TOP 4 Player, Nation, Pos, Squad, DefendingScore
FROM FinalDefendersTable
ORDER BY 5 DESC
-- ADD TWO BEST DEFENDIND MIDFIELDERS
INSERT INTO BestCurrentSquad (Player, Nation, Pos, Squad, Score)
SELECT TOP 2 Player, Nation, Pos, Squad, DefMidScore
FROM FinalDefMidTable
WHERE NOT(Player IN (SELECT Player FROM BestCurrentSquad))
ORDER BY 5 DESC
-- ADD TWO BEST OFFENSIVE MIDFIELDERS
INSERT INTO BestCurrentSquad (Player, Nation, Pos, Squad, Score)
SELECT TOP 2 Player, Nation, Pos, Squad, OffMidScore
FROM FinalOffMidTable
WHERE NOT(Player IN (SELECT Player FROM BestCurrentSquad))
ORDER BY 5 DESC
-- ADD TWO BEST FORWARDS
INSERT INTO BestCurrentSquad (Player, Nation, Pos, Squad, Score)
SELECT TOP 2 Player, Nation, Pos, Squad, ForwardScore
FROM FinalForwardTable
WHERE NOT(Player IN (SELECT Player FROM BestCurrentSquad))
ORDER BY 5 DESC

-- VISUALIZE TABLE
SELECT *
FROM BestCurrentSquad
