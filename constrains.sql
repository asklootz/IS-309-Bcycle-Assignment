
-- CONSTRAINTS
ALTER TABLE IF EXISTS bergen.station
	ADD CONSTRAINT program_fk FOREIGN KEY (program_id) REFERENCES bergen.program (program_id);

ALTER TABLE IF EXISTS bergen.station_status
	ADD CONSTRAINT station_fk FOREIGN KEY (station_id) REFERENCES bergen.station (station_id),
	ADD CONSTRAINT dock_fk FOREIGN KEY (dock_id) REFERENCES bergen.station_dock (dock_id);

ALTER TABLE IF EXISTS bergen.station_dock
	ADD CONSTRAINT station_fk FOREIGN KEY (station_id) REFERENCES bergen.station (station_id),
	ADD CONSTRAINT bike_fk FOREIGN KEY (bike_id) REFERENCES bergen.bike (bike_id);

ALTER TABLE IF EXISTS bergen.bike_type
	ADD CONSTRAINT program_fk FOREIGN KEY (program_id) REFERENCES bergen.program (program_id);

ALTER TABLE IF EXISTS bergen.bike
	ADD CONSTRAINT dock_fk FOREIGN KEY (dock_id) REFERENCES bergen.station_dock (dock_id),
	ADD CONSTRAINT bike_type_fk FOREIGN KEY (bike_type_id) REFERENCES bergen.bike_type (bike_type_id);

ALTER TABLE IF EXISTS bergen.bike_status
	ADD CONSTRAINT bike_fk FOREIGN KEY (bike_id) REFERENCES bergen.bike (bike_id);

ALTER TABLE IF EXISTS bergen.trip
	ADD CONSTRAINT user_fk FOREIGN KEY (user_id) REFERENCES bergen.user_info (user_id),
	ADD CONSTRAINT bike_fk FOREIGN KEY (bike_id) REFERENCES bergen.bike (bike_id),
	ADD CONSTRAINT program_fk FOREIGN KEY (program_id) REFERENCES bergen.program (program_id),
	ADD CONSTRAINT start_station_fk FOREIGN KEY (start_station_id) REFERENCES bergen.station (station_id),
	ADD CONSTRAINT end_station_fk FOREIGN KEY (end_station_id) REFERENCES bergen.station (station_id);

ALTER TABLE IF EXISTS bergen.user_auth
	ADD CONSTRAINT user_fk FOREIGN KEY (user_id) REFERENCES bergen.user_info (user_id);

ALTER TABLE IF EXISTS bergen.bought_membership
	ADD CONSTRAINT user_fk FOREIGN KEY (user_id) REFERENCES bergen.user_info (user_id),
	ADD CONSTRAINT membership_fk FOREIGN KEY (membership_type) REFERENCES bergen.membership (membership_type);