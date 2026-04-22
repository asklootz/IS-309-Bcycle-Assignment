# IS-309-Bcycle-Assignment
A repo for the Bcycle Assignement in IS-309_26 at University of Agder


## Standarized formatting for values, mostly identifiers:

| Table | Variable  | Format    | Example| Other info |
| :----: | :-------: | :------: | :----: | :---:      |
| station | station_id | \*program_name*\ + "\_station\_" + \*incrementing int\* | bergen_station_1 | __Main difference being it specifing "station" in ID__ |
| station_dock | station_dock_id | \*station_id\* + "_" + \*incrementing int\* | bergen_station_1_1 | __One extra int seperated by an underscoure to count the dock__ | 
| station_status | station_status_id | "station_status_" + \*incrementing int\* | station_status_1 | __General incremening ID for all updates__ |
| bike_type | bike_type_id | \*bike_type\* + "_" + \*incrementing int\* | electric_1 | __Try to keep the id simple and self-explanatory of type of bike__ |
| bike | bike_id | \*program_name\* + "\_bike\_" + \*incrementing int\* | bergen_bike_1 | __Same logic as station_id__ |
| bike_status | bike_status_id | "bike_status_" + \*incrementing int\* | bike_status_5 | __General incremening ID for all updates__ |
| trip | trip_id | "trip_" + \*incrementing int\* | trip_1412 | __More informative ID than just numbers__ |
| user | user_id | "user_" + \*incrementing int\* | user_44 | __More informative ID than just numbers__ |
| bought_membership | purchase_id | "purchase_" + \*incrementing int\* | purchase_22 | __More informative ID than just numbers__ |

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
 - [ ] Update the create station procedure so it will automatically create docks on creation
 - [ ] Make sure it will update station if you also add more docks. 
 - [ ] Automation for generating user_id
 - [ ] Automation for generating trip_id
 - [ ] Automation for generating purchase_id
### Other
 - [ ] Create a new file "view-quieries.sql" to save all the queries used to show the data we have made and other info about the database we need to show.
 - [ ] Create a sql-file to store all the different scripts in once place, and have them in the correct order (create scheam => create tables => create constraints => etc.)