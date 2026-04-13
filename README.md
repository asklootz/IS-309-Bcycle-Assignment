# IS-309-Bcycle-Assignment
A repo for the Bcycle Assignement in IS-309_26 at University of Agder


## Standarized formatting for values, mostly identifiers:

| Table | Variable  | Format    | Example| Alt. Format | Alt. Example | Other info |
| :----: | :-------: | :------: | :----: | :---:       | :---:        | :---:      |
| station | station_id | \*program\* + "_" + \*incrementing int\* | bcycle_bergen_0001| \*program_name*\ + "\_station\_" + \*incrementing int\* | bergen_station_0001 | __Main difference being it specifing "station" in ID__ |
| station_dock | station_dock_id | \*station_id\* + "_" + \*incrementing int\* | bcycle_bergen_0001_1| \*station_id\* "_" \*incrementing int\* | bergen_station_0001_1 | __Should this containt dock?__ | 
| station_status | station_status_id | "station_status_" + \*incrementing int\* | station_status_1 | \*station_id\* + "\_status\_" + \*incrementing int\* | bergen_station_0001_status_1 | __General incremening ID or ID that increments for it's specific station?__ |
| bike_type | bike_type_id | \*first letter of the bike_type\* + "b_" \*incrementing int\* | eb_01 / sb_02 | \*bike_type\* + "_" \*incrementing int\* | electric_01 | __Try to keep the id simple and self-explanatory of type of bike / Does ID need to say it is a bike?__ |
| bike | bike_id | \*program_name\* + "\_bike\_" + \*first letter of biketype*\ + \*incrementing int\* | bergen_bike_e0001 / bergen_bike_s0004 | \*program_name\* + "\_" + \*bike_type\* + "\_" +  \*incrementing int\* | bergen_electric_0001 | __Does ID need to say it is a bike?__ |
| bike_status | bike_status_id | "bike_status_" + \*incrementing int\* | bike_status_5 | \*bike_id\* + \_status\_ + \*incrementing int\* | bergen_electric_0001_status_1 | __General incremening ID or ID that increments for it's specific station?__ |
| trip | trip_id | \*incrementing int\* | 1412 | "trip_" + \*incrementing int\* | trip_1412 | __More informative ID than just numbers__ |
| user | user_id | \*incrementing int\* | 44 | "user_" + \*incrementing int\* | user_44 | __More informative ID than just numbers__ |
| bought_membership | purchase_id | \*incrementing int\* | 22 | "purchase_" + \*incrementing int\* | purchase_22 | __More informative ID than just numbers__ |

### General questions and comments for formatting:
- Best way to keep the ID simple and informative/descriptive for different tables?
  - [ANSWER]
- Is self-explanatory ID important?
  - [ANSWER]
- The "0"s are not mandatory, can be done without and make the ID start with single digit.
  - [ANSWER]
- Maybe have the ID not just be number (user_id, trip_id and purchase_id)
  - [ANSWER]


## Work to do for finishing all the queries needed:  
### PLSQL
 - [ ] Add all the procedures we made for Assignment 2 into the "plsql.sql" file and make sure it runs properly.
### Other
 - [ ] Create a new file "view-quieries.sql" to save all the queries used to show the data we have made and other info about the database we need to show.
 - [ ] Create a sql-file to store all the different scripts in once place, and have them in the correct order (create scheam => create tables => create constraints => etc.)