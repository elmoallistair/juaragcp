-- Engineer Data in Google Cloud: Challenge Lab 
-- https://www.qwiklabs.com/focuses/12379?parent=catalog


-- Setup:
    -- go to bigquery

-- Task 1: Clean your training data
    -- Make sure:
        -- Target column is called fare_amount
    -- Data Cleaning Tasks:
        -- Keep rows for trip_distance > 0
        -- Remove rows for fare_amount > 2.5
        -- Ensure that the latitudes and longitudes are reasonable for the use case. ??
        -- Create a new column called total_amount from tolls_amount + fare_amount
        -- Sample the dataset < 1,000,000 rows
        -- Only copy fields that will be used in your model

-- 1.1 clean data, run this query:
-- start query
#standardSQL
SELECT
    pickup_datetime,
    pickup_longitude AS pickuplon,
    pickup_latitude AS pickuplat,
    dropoff_longitude AS dropofflon,
    dropoff_latitude AS dropofflat,
    passenger_count AS passengers,
    ( tolls_amount + fare_amount ) AS fare_amount
FROM
    `<your_gcp_project_id>.taxirides.historical_taxi_rides_raw` -- change this
WHERE
    trip_distance > 0
    AND fare_amount >= 2.5
    AND passenger_count > 0
    AND pickup_longitude BETWEEN -75 AND -73
    AND dropoff_longitude BETWEEN -75 AND -73
    AND pickup_latitude BETWEEN 40 AND 42
    AND dropoff_latitude BETWEEN 40 AND 42
    AND RAND() < 999999 / 1031673361
-- end query

-- 1.2 save query, follow this:
    - click SAVE RESULT under query editor, choose BiQquery table
    - input taxi_training_data as table name
    - save and check your first progress

--------------------------------------------------------------------------------

-- Task 2: Create a BQML model called taxirides.fare_model
    -- build a BQML model that predicts fare_amount. 
    -- call the model taxirides.fare_model. 
    -- your model will need an RMSE of 10 or less to complete the task.

-- 2.1 create a model, run this query:

-- start query
#standardSQL
CREATE or REPLACE MODEL
    taxirides.fare_model OPTIONS (model_type='linear_reg', labels=['fare_amount']) AS
WITH taxitrips AS (
    SELECT *, ST_Distance(ST_GeogPoint(pickuplon, pickuplat), ST_GeogPoint(dropofflon, dropofflat)) AS euclidean
    FROM `taxirides.taxi_training_data` 
)
        
SELECT * FROM taxitrips
-- expected output: This statement created a new model named <your_gcp_project_id>:taxirides.fare_model. 
-- end query

-- 2.2 evaluate model, run this query:
-- start query
#standardSQL
SELECT
    SQRT(mean_squared_error) AS rmse
FROM
    ML.EVALUATE (
        MODEL taxirides.fare_model, (
            WITH taxitrips AS (
                SELECT *, ST_Distance(ST_GeogPoint(pickuplon, pickuplat), ST_GeogPoint(dropofflon, dropofflat)) AS euclidean
                FROM `taxirides.taxi_training_data`
            ) SELECT * FROM taxitrips 
        )
    )
-- expected result (rmse): 4.870798438873309
-- end query	
-- check your second progress

--------------------------------------------------------------------------------

-- Task 3: Perform a batch prediction on new data
    -- Make sure you store the results in a table called 2015_fare_amount_predictions.

-- 3.1 run his query:
-- start query	
#standardSQL
CREATE or REPLACE MODEL taxirides.fare_model OPTIONS (
    model_type='linear_reg',
    labels=['fare_amount']
) AS WITH taxitrips AS (
    SELECT
        *,
        ST_Distance(ST_GeogPoint(pickuplon, pickuplat), ST_GeogPoint(dropofflon, dropofflat)) AS euclidean
    FROM
        `taxirides.taxi_training_data` 
)
SELECT * FROM taxitrips
-- end query	

-- 3.2 evaluate model

-- start query	
#standardSQL
SELECT
    *
FROM
    ML.PREDICT(
        MODEL `taxirides.fare_model`,(
            WITH taxitrips AS (
                SELECT *, ST_Distance(ST_GeogPoint(pickuplon, pickuplat)   , ST_GeogPoint(dropofflon, dropofflat)) AS    euclidean
                FROM `taxirides.report_prediction_data` 
            ) SELECT * FROM taxitrips 
        )
    )
-- end query	

-- 3.3 save result, repeat step 1.2 step with table name: 2015_fare_amount_predictions
-- check your third progress
