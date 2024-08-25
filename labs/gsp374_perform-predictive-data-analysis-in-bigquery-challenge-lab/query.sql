-- Task 2. Analyze soccer data
-- Build a query that shows the success rate on penalty kicks by each player.
SELECT
  playerId,
  (Players.firstName || ' ' || Players.lastName) AS playerName,
  COUNT(id) AS numPKAtt,
  SUM(IF(101 IN UNNEST(tags.id), 1, 0)) AS numPKGoals,
  SAFE_DIVIDE(
    SUM(IF(101 IN UNNEST(tags.id), 1, 0)),
    COUNT(id)
  ) AS PKSuccessRate
FROM
  `soccer.events662` Events -- Change event name (events662) with your variable
LEFT JOIN
  `soccer.players` Players ON Events.playerId = Players.wyId
WHERE
  eventName = 'Free Kick' AND
  subEventName = 'Penalty'
GROUP BY
  playerId, playerName
HAVING
  numPkAtt >= 5
ORDER BY
  PKSuccessRate DESC, numPKAtt DESC


-- Task 3. Gain insight by analyzing soccer data
-- Create a new query to analyze shot distance. For shots, use (x, y) values from the positions field in the events662 table.

WITH Shots AS (
  SELECT
    *,
    -- Check if the shot is a goal using Tag 101
    (101 IN UNNEST(tags.id)) AS isGoal,
    -- Calculate shot distance using translated (x, y) coordinates
    SQRT(
      POW((100 - positions[ORDINAL(1)].x) * 120/60, 2) + -- Change X and Y (120/60) value with your variable
      POW((60 - positions[ORDINAL(1)].y) * 116/68, 2) -- Change X and Y (116/68) value with your variable
    ) AS shotDistance
  FROM
    `soccer.events662`
  WHERE
    -- Include both open play and free kick shots (including penalties)
    eventName = 'Shot' OR
    (eventName = 'Free Kick' AND subEventName IN ('Free kick shot', 'Penalty'))
)

SELECT
  ROUND(shotDistance, 0) AS ShotDistRound0,
  COUNT(*) AS numShots,
  SUM(IF(isGoal, 1, 0)) AS numGoals,
  AVG(IF(isGoal, 1, 0)) AS goalPct
FROM
  Shots
WHERE
  shotDistance <= 50
GROUP BY
  ShotDistRound0
ORDER BY
  ShotDistRound0;


-- Task 4. Create a regression model using soccer data
-- Create some user-defined functions in BigQuery that help with shot distance and angle calculations, which help to prepare the soccer event data for eventual use in an ML model.

-- Note, change this name with yours:
    -- GetShotDistanceToGoal662
    -- GetShotAngleToGoal662
    -- xg_logistic_reg_model_662

-- Calculate shot distance from (x,y) coordinates
CREATE FUNCTION `soccer.GetShotDistanceToGoal662`(x INT64, y INT64)
RETURNS FLOAT64
AS (
 /* Translate 0-100 (x,y) coordinate-based distances to absolute positions
 using "average" field dimensions of 116x68 before combining in 2D dist calc */
 SQRT(
   POW((120 - x) * 116/100, 2) +
   POW((60 - y) * 68/100, 2)
   )
 );

-- Calculate shot angle from (x,y) coordinates
CREATE FUNCTION `soccer.GetShotAngleToGoal662`(x INT64, y INT64)
RETURNS FLOAT64
AS (
 SAFE.ACOS(
   /* Have to translate 0-100 (x,y) coordinates to absolute positions using
   "average" field dimensions of 116x68 before using in various distance calcs */
   SAFE_DIVIDE(
     ( /* Squared distance between shot and 1 post, in meters */
       (POW(116 - (x * 116/100), 2) + POW(34 + (7.32/2) - (y * 68/100), 2)) +
       /* Squared distance between shot and other post, in meters */
       (POW(116 - (x * 116/100), 2) + POW(34 - (7.32/2) - (y * 68/100), 2)) -
       /* Squared length of goal opening, in meters */
       POW(7.32, 2)
     ),
     (2 *
       /* Distance between shot and 1 post, in meters */
       SQRT(POW(116 - (x * 116/100), 2) + POW(34 + 7.32/2 - (y * 68/100), 2)) *
       /* Distance between shot and other post, in meters */
       SQRT(POW(116 - (x * 116/100), 2) + POW(34 - 7.32/2 - (y * 68/100), 2))
     )
    )
  /* Translate radians to degrees */
  ) * 180 / ACOS(-1)
 )
;

-- Create an expected goals model using BigQuery ML
CREATE MODEL `soccer.xg_logistic_reg_model_662`
OPTIONS(
  model_type = 'LOGISTIC_REG',
  input_label_cols = ['isGoal']
) AS
SELECT
  Events.subEventName AS shotType,
  -- Check if the shot is a goal using Tag 101
  (101 IN UNNEST(Events.tags.id)) AS isGoal,
  -- Calculate shot distance and angle using the specified functions
  soccer.GetShotDistanceToGoal662(Events.positions[ORDINAL(1)].x, Events.positions[ORDINAL(1)].y) AS shotDistance,
  soccer.GetShotAngleToGoal662(Events.positions[ORDINAL(1)].x, Events.positions[ORDINAL(1)].y) AS shotAngle
FROM
  `soccer.events662` Events
LEFT JOIN
  `soccer.matches` Matches ON Events.matchId = Matches.wyId
LEFT JOIN
  `soccer.competitions` Competitions ON Matches.competitionId = Competitions.wyId
WHERE
  -- Filter out World Cup matches for model fitting purposes
  Competitions.name != 'World Cup' AND
  -- Include both open play and free kick shots (including penalties)
  (
    eventName = 'Shot' OR
    (eventName = 'Free Kick' AND subEventName IN ('Free kick shot', 'Penalty'))
  ) AND
  `soccer.GetShotAngleToGoal662`(Events.positions[ORDINAL(1)].x, Events.positions[ORDINAL(1)].y) IS NOT NULL;


-- Task 5. Make predictions from new data with the BigQuery model
SELECT
  predicted_isGoal_probs[ORDINAL(1)].prob AS predictedGoalProb,
  * EXCEPT (predicted_isGoal, predicted_isGoal_probs)
FROM
  ML.PREDICT(
    MODEL `soccer.xg_logistic_reg_model_662`, 
    (
      SELECT
        Events.playerId,
        CONCAT(Players.firstName, ' ', Players.lastName) AS playerName,
        Teams.name AS teamName,
        CAST(Matches.dateutc AS DATE) AS matchDate,
        Matches.label AS match,
        -- Convert match period and event seconds to minute of match
        CAST(
          (CASE
            WHEN Events.matchPeriod = '1H' THEN 0
            WHEN Events.matchPeriod = '2H' THEN 45
            WHEN Events.matchPeriod = 'E1' THEN 90
            WHEN Events.matchPeriod = 'E2' THEN 105
            ELSE 120
          END) + CEILING(Events.eventSec / 60) AS INT64
        ) AS matchMinute,
        Events.subEventName AS shotType,
        -- Check if the shot is a goal using Tag 101
        (101 IN UNNEST(Events.tags.id)) AS isGoal,
        -- Calculate shot distance and angle using the specified functions
        soccer.GetShotDistanceToGoal662(Events.positions[ORDINAL(1)].x, Events.positions[ORDINAL(1)].y) AS shotDistance,
        soccer.GetShotAngleToGoal662(Events.positions[ORDINAL(1)].x, Events.positions[ORDINAL(1)].y) AS shotAngle
      FROM
        `soccer.events662` Events
      LEFT JOIN
        `soccer.matches` Matches ON Events.matchId = Matches.wyId
      LEFT JOIN
        `soccer.competitions` Competitions ON Matches.competitionId = Competitions.wyId
      LEFT JOIN
        `soccer.players` Players ON Events.playerId = Players.wyId
      LEFT JOIN
        `soccer.teams` Teams ON Events.teamId = Teams.wyId
      WHERE
        -- Focus only on World Cup matches for predictions
        Competitions.name = 'World Cup' AND
        -- Include both open play and free kick shots (excluding penalties)
        (
          eventName = 'Shot' OR
          (eventName = 'Free Kick' AND subEventName IN ('Free kick shot'))
        ) AND
        -- Filter only to goals scored
        (101 IN UNNEST(Events.tags.id))
    )
  )
ORDER BY
  predictedGoalProb;