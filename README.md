# IS-309-Bcycle-Assignment
A repo for the Bcycle Assignement in IS-309_26 at University of Agder


## Standarized formatting for values, mostly identifiers

| Table | Variable  | Format    | Example|
| :----: | :-------: | :-------: | :----: |
| station | station_id | \*program\*+ "_" + \*incrementing int\* | bcycle_bergen_0001|
| station_dock | station_dock_id | \*station_id\*+ "_" + \*incrementing int\* | bcycle_bergen_0001_1|
| station_status | station_status_id | "station_status_" + \*incrementing int\* | station_status_1 |
| bike_type | bike_type_id | \*first letter of the type\* + "b_" \*incrementing int\* | eb_01 / sb_02 |
| bike | bike_id | \*program_name\* + "\_bike\_" + \*first letter of biketype*\ + \*incrementing int\* | bergen_bike_e0001 / bergen_bike_s0004 |
| bike_status | bike_status_id | "bike_status_" + \*incrementing int\* | bike_status_5 |
| trip | trip_id | \*incrementing int\* | 1412 |
| user | user_id | \*incrementing int\* | 44 |
| bought | membership_id | \*incrementing int\* | 22 |