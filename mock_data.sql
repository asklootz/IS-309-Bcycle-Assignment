-- Mock data

-- For program-table:
insert into  bergen.program (program_id, country_code, name, location, email, url, time_zone, phone)
values ('bcycle_bergen', 'NO', 'bergen', 'bergen', 'support@bergen.bycle.com', 'bergen.bcycle.com', 'Europe/Oslo', '+47 12345678');

-- For bike_type-table:
insert into bergen.bike_type (bike_type_id, program_id, maker, model, bike_type)
values ('regular_1', 'bcycle_bergen', 'Trek', 'FX3', 'regular'),
       ('electric_1', 'bcycle_bergen', 'Trek', 'FX3e', 'electric'),
       ('smart_1', 'bcycle_bergen', 'Smart Co', 'SX1', 'smart'),
       ('cargo_1', 'bcycle_bergen', 'Riese', 'Multicharger', 'cargo');

-- For bike-table:
insert into bergen.bike (bike_id, bike_type_id, dock_id, date_acquired)
values ('bergen_bike_1', 'electric_1', 'bergen_station_1_1', '2023-01-15'),
       ('bergen_bike_2', 'electric_1', NULL, '2023-02-20'),
       ('bergen_bike_3', 'regular_1', 'bergen_station_2_1', '2023-03-10'),
       ('bergen_bike_4', 'smart_1', NULL, '2023-04-05'),
       ('bergen_bike_5', 'cargo_1', 'bergen_station_3_1', '2023-05-12');

-- For bike_status-table:
insert into bergen.bike_status (bike_status_id, bike_id, status, latitude, longitude, battery, remaining_range, total_distance)
values ('bike_status_1', 'bergen_bike_1', 'available', 60.3913, 5.3221, 85, 50, 1200),
       ('bike_status_2', 'bergen_bike_2', 'in_use', 60.3920, 5.3230, 60, 35, 800),
       ('bike_status_3', 'bergen_bike_3', 'available', 60.3915, 5.3225, NULL, NULL, 500),
       ('bike_status_4', 'bergen_bike_4', 'maintenance', 60.3918, 5.3228, 67, 69, 300),
       ('bike_status_5', 'bergen_bike_5', 'available', 60.3922, 5.3232, NULL, NULL, 700);

-- For station-table:
insert into bergen.station (station_id, program_id, name, address, postal_code, latitude, longitude, total_capacity, available_docks)
values ('bergen_station_1', 'bcycle_bergen', 'Bryggen', 'Bryggen 1', 5003, 60.3961, 5.3228, 4, 2),
       ('bergen_station_2', 'bcycle_bergen', 'Torgallmenningen', 'Torgallmenningen 1', 5014, 60.3925, 5.3240, 3, 2),
       ('bergen_station_3', 'bcycle_bergen', 'Byparken', 'Byparken 1', 5015, 60.3910, 5.3215, 3, 2);

-- For station_dock-table:
insert into bergen.station_dock (dock_id, station_id, dock_number, bike_id, bike_type, is_occupied, is_accepting_returns, is_accepting_renting)
values ('bergen_station_1_1', 'bergen_station_1', 1, 'bergen_bike_1', 'electric', true, false, true),
       ('bergen_station_1_2', 'bergen_station_1', 2, NULL, NULL, false, true, false),
       ('bergen_station_1_3', 'bergen_station_1', 3, NULL, NULL, false, true, false),
       ('bergen_station_1_4', 'bergen_station_1', 4, NULL, NULL, false, true, false),
       ('bergen_station_2_1', 'bergen_station_2', 1, 'bergen_bike_3', 'regular', true, false, true),
       ('bergen_station_2_2', 'bergen_station_2', 2, NULL, NULL, false, true, false),
       ('bergen_station_2_3', 'bergen_station_2', 3, NULL, NULL, false, true, false),
       ('bergen_station_3_1', 'bergen_station_3', 1, 'bergen_bike_5', 'cargo', true, false, true),
       ('bergen_station_3_2', 'bergen_station_3', 2, NULL, NULL, false, true, false),
       ('bergen_station_3_3', 'bergen_station_3', 3, NULL, NULL, false, true, false);

-- For station_status-table:
insert into bergen.station_status (station_status_id, station_id, dock_id, available_docks, regular_bikes_available, electric_bikes_available, smart_bikes_available, cargo_bikes_available, is_accepting_returns, is_accepting_renting)
values ('station_status_1', 'bergen_station_1', 'bergen_station_1_1', 3, 0, 1, 0, 0, true, true),
       ('station_status_2', 'bergen_station_2', 'bergen_station_2_1', 2, 1, 0, 0, 0, true, true),
       ('station_status_3', 'bergen_station_3', 'bergen_station_3_1', 2, 0, 0, 0, 1, true, true);

-- For user_info-table:
insert into bergen.user_info (user_id, name, surname, email, date_of_birth, address, city, postal_code, state, total_trips)
values ('user_1', 'Dennis', 'Hayakawa', 'dennis.hayakawa@example.com', '1980-09-12', 'Motorsagens gate 1', 'Bergen', 5003, 'Hordaland', 14),
       ('user_2', 'Charli', 'XCX', 'charli.xcx@example.com', '1992-08-02', 'Bratgaten 2', 'Bergen', 5003, 'Hordaland', 8);

-- For user_auth-table:
insert into bergen.user_auth (user_id, hashsalt, passhash, email)
values ('user_1', 'random_salt_1', 'hashed_password_1', 'dennis.hayakawa@example.com'),
('user_2', 'random_salt_2', 'hashed_password_2', 'charli.xcx@example.com');

-- For membership-table:
insert into bergen.membership (membership_type, price, duration)
values ('daily', 10, 1), ('weekly', 30, 7), ('monthly', 100, 30), ('yearly', 300, 365);

-- For bought_membership-table:
insert into bergen.bought_membership (purchase_id, user_id, membership_type, is_active, purchase_time, activation_time, expiration_time)
values ('purchase_1', 'user_1', 'monthly', true, '2024-01-01 12:11:34.132', '2026-09-01 15:00:00', '2026-10-01 15:00:00'),
('purchase_2', 'user_2', 'weekly', false, '2024-01-15 11:22:45.678', '2026-04-09 12:00:00', '2026-04-16 12:00:00');

-- For trip-table:
insert into bergen.trip (ride_id, user_id, bike_id, program_id, start_time, end_time, start_station_id, end_station_id, trip_distance, battery_start, battery_end, trip_cost, trip_duration)
values ('trip_1', 'user_1', 'bergen_bike_1', 'bcycle_bergen', '2024-01-10 08:00:00', '2024-01-10 08:30:00', 'bergen_station_1', 'bergen_station_2', 5.0, 85, 60, NULL, '00:30:00'),
('trip_2', 'user_2', 'bergen_bike_3', 'bcycle_bergen', '2026-04-30 09:15:00', '2026-04-30 09:45:00', 'bergen_station_2', NULL, NULL, NULL, NULL, NULL, NULL);