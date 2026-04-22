-- Schema and tables first
-- Timezone
SET TIME ZONE 'Europe/Oslo';
-- Schema
CREATE SCHEMA IF NOT EXISTS bergen
    AUTHORIZATION pg_database_owner;

COMMENT ON SCHEMA bergen
    IS 'Schema for program "Bergen"';

GRANT USAGE ON SCHEMA bergen TO PUBLIC;
GRANT ALL ON SCHEMA bergen TO pg_database_owner;

-- Create all tables
CREATE TABLE IF NOT EXISTS bergen.program
(
	program_id character varying(100) COLLATE pg_catalog."default" NOT NULL UNIQUE PRIMARY KEY,
    country_code CHAR(2) NOT NULL,
    name character varying(30) COLLATE pg_catalog."default" NOT NULL,
    location character varying(20) COLLATE pg_catalog."default" NOT NULL,
    email character varying(40) COLLATE pg_catalog."default" NOT NULL,
    url character varying(100) COLLATE pg_catalog."default" NOT NULL,
    time_zone character varying(20) COLLATE pg_catalog."default" NOT NULL,
    phone character varying(20) COLLATE pg_catalog."default" NOT NULL,
	CONSTRAINT email_check CHECK (email ~* '^[A-Za-z0-9._+%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$')
);

CREATE TABLE IF NOT EXISTS bergen.station
(
    station_id character varying(100) COLLATE pg_catalog."default" NOT NULL PRIMARY KEY,
    program_id character varying(100) COLLATE pg_catalog."default" NOT NULL,
    name character varying(30) COLLATE pg_catalog."default" NOT NULL,
    address character varying(50) COLLATE pg_catalog."default" NOT NULL,
    postal_code SMALLINT NOT NULL,
    latitude numeric(9, 7) NOT NULL,
    longitude numeric(9, 7) NOT NULL,
    total_capacity INTEGER NOT NULL,
    available_docks INTEGER NOT NULL,
    creation_date TIMESTAMPTZ(3) DEFAULT CURRENT_TIMESTAMP NOT NULL,
	UNIQUE (station_id, program_id)
	--FOREIGN KEY (program_id) REFERENCES bergen.program (program_id),
	
);

CREATE TABLE IF NOT EXISTS bergen.station_dock
(
    dock_id character varying(100) COLLATE pg_catalog."default" NOT NULL PRIMARY KEY,
    station_id character varying(100) COLLATE pg_catalog."default" NOT NULL,
    dock_number INTEGER NOT NULL,
    bike_id character varying(100) COLLATE pg_catalog."default" , -- Not all docks have bikes
    bike_type character varying(50) COLLATE pg_catalog."default", -- Not all docks have bikes
    is_occupied boolean NOT NULL,
    is_accepting_returns boolean NOT NULL,
    is_accepting_renting boolean NOT NULL,
    last_updated TIMESTAMPTZ(3) DEFAULT CURRENT_TIMESTAMP NOT NULL,
	UNIQUE (dock_id, station_id, bike_id)
	--FOREIGN KEY (station_id) REFERENCES bergen.station (station_id),
	--FOREIGN KEY (bike_id) REFERENCES bergen.bike (bike_id)
);

CREATE TABLE IF NOT EXISTS bergen.station_status
(
    station_status_id character varying(100) COLLATE pg_catalog."default" NOT NULL PRIMARY KEY,
    station_id character varying(100) COLLATE pg_catalog."default" NOT NULL,
    dock_id character varying(100) COLLATE pg_catalog."default" NOT NULL,
    available_docks INTEGER NOT NULL,
    regular_bikes_available INTEGER NOT NULL,
    electric_bikes_available INTEGER NOT NULL,
    smart_bikes_available INTEGER NOT NULL,
    cargo_bikes_available INTEGER NOT NULL,
    is_accepting_returns boolean NOT NULL,
    is_accepting_renting boolean NOT NULL,
    last_updated TIMESTAMPTZ(3) DEFAULT CURRENT_TIMESTAMP NOT NULL,
	UNIQUE (station_status_id, station_id, dock_id)
	--FOREIGN KEY (station_id) REFERENCES bergen.station (station_id),
	--FOREIGN KEY (dock_id) REFERENCES bergen.station_dock (dock_id)
);

CREATE TABLE IF NOT EXISTS bergen.bike_type
(
    bike_type_id character varying(100) COLLATE pg_catalog."default" NOT NULL PRIMARY KEY,
    program_id character varying(100) COLLATE pg_catalog."default" NOT NULL,
    maker character varying(20) COLLATE pg_catalog."default" NOT NULL,
    model character varying(20) COLLATE pg_catalog."default" NOT NULL,
    bike_type character varying(10) COLLATE pg_catalog."default" NOT NULL,
	UNIQUE (bike_type_id, program_id)
    --FOREIGN KEY (program_id) REFERENCES bergen.program (program_id)
	
);

CREATE TABLE IF NOT EXISTS bergen.bike
(
    bike_id character varying(100) COLLATE pg_catalog."default" NOT NULL PRIMARY KEY,
    dock_id character varying(100) COLLATE pg_catalog."default", -- Not always docked
    bike_type_id character varying(100) COLLATE pg_catalog."default" NOT NULL,
    date_acquired DATE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    UNIQUE (bike_id, bike_type_id, dock_id)
	--FOREIGN KEY (dock_id) REFERENCES bergen.station_dock (dock_id),
	--FOREIGN KEY (biketypebiketype_id) REFERENCES bergen.biketype (biketype_id)
);

CREATE TABLE IF NOT EXISTS bergen.bike_status
(
    bike_status_id character varying COLLATE pg_catalog."default" NOT NULL PRIMARY KEY,
    bike_id character varying COLLATE pg_catalog."default" NOT NULL,
    status character varying COLLATE pg_catalog."default" NOT NULL,
    latitude NUMERIC(9,7) NOT NULL,
    longitude NUMERIC(9,7) NOT NULL,
    battery INTEGER, -- Not all bikes have batteries
    remaining_range NUMERIC, -- Not all bikes have batteries to track remaining range
    total_distance NUMERIC NOT NULL,
    last_updated TIMESTAMPTZ(3) DEFAULT CURRENT_TIMESTAMP NOT NULL,
	UNIQUE (bike_status_id, bike_id)
	--FOREIGN KEY (bike_id) REFERENCES bergen.bike (bike_id)
);

CREATE TABLE IF NOT EXISTS bergen.trip
(
    ride_id VARCHAR(100) NOT NULL PRIMARY KEY,
    user_id VARCHAR(100) NOT NULL,
    bike_id character varying(100) COLLATE pg_catalog."default" NOT NULL,
    program_id character varying(100) COLLATE pg_catalog."default" NOT NULL,
    start_time TIMESTAMPTZ(3) NOT NULL,
    end_time TIMESTAMPTZ(3),
    start_station_id character varying(100) COLLATE pg_catalog."default" NOT NULL,
    end_station_id character varying(100) COLLATE pg_catalog."default",
    trip_distance NUMERIC,
    battery_start INTEGER,
    battery_end INTEGER,
    trip_cost NUMERIC(5, 2), -- Not all trips may have a cost due to a subscription model
    trip_duration interval,
    UNIQUE (ride_id, user_id, bike_id, program_id)
	--FOREIGN KEY (user_id) REFERENCES bergen.user_info (user_id),
	--FOREIGN KEY (bike_id) REFERENCES bergen.bike (bike_id),
	--FOREIGN KEY (program_id) REFERENCES bergen.program (program_id),
	--FOREIGN KEY (start_station_id) REFERENCES bergen.station (station_id),
	--FOREIGN KEY (end_station_id) REFERENCES bergen.station (station_id)
);

CREATE TABLE IF NOT EXISTS bergen.user_info
(
    user_id VARCHAR(100) NOT NULL PRIMARY KEY,
    name character varying COLLATE pg_catalog."default" NOT NULL,
    surname character varying COLLATE pg_catalog."default" NOT NULL,
    email character varying COLLATE pg_catalog."default" NOT NULL,
    date_of_birth DATE NOT NULL,
    address character varying COLLATE pg_catalog."default" NOT NULL,
    city character varying COLLATE pg_catalog."default" NOT NULL,
    postal_code SMALLINT NOT NULL,
    state character varying COLLATE pg_catalog."default" NOT NULL,
    total_trips INTEGER NOT NULL,
    creation_date TIMESTAMPTZ(3) DEFAULT CURRENT_TIMESTAMP NOT NULL,
	UNIQUE (user_id, email),
	CONSTRAINT email_check CHECK (email ~* '^[A-Za-z0-9._+%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$'),
	CONSTRAINT birthday_check CHECK (date_of_birth <= CURRENT_DATE),
	CONSTRAINT trips_check CHECK (total_trips >= 0)
);

CREATE TABLE IF NOT EXISTS bergen.user_auth
(
    user_id VARCHAR(100) NOT NULL PRIMARY KEY,
    hashsalt character varying COLLATE pg_catalog."default" NOT NULL,
    passhash character varying COLLATE pg_catalog."default" NOT NULL,
    email character varying COLLATE pg_catalog."default" NOT NULL,
    UNIQUE (user_id, email)
	--FOREIGN KEY (user_id) REFERENCES bergen.user_info (user_id)
);

CREATE TABLE IF NOT EXISTS bergen.membership
(
    membership_type character varying(100) COLLATE pg_catalog."default" NOT NULL UNIQUE PRIMARY KEY,
    price numeric(10, 2) NOT NULL,
    duration INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS bergen.bought_membership
(
    purchase_id VARCHAR(100) NOT NULL PRIMARY KEY,
    user_id VARCHAR(100) NOT NULL,
    membership_type character varying(100) COLLATE pg_catalog."default" NOT NULL,
    is_active boolean NOT NULL,
    purchase_time TIMESTAMPTZ(3) DEFAULT CURRENT_TIMESTAMP NOT NULL,
    activation_time TIMESTAMPTZ(3) NOT NULL, -- Can be a NULL value if the user has not set a specific activation time, but for simplicity we will set it to the purchase time in that case
    expiration_time TIMESTAMPTZ(3) NOT NULL,
	UNIQUE (purchase_id, user_id, membership_type)
	--FOREIGN KEY (user_id) REFERENCES bergen.user_info (user_id),
	--FOREIGN KEY (membership_type) REFERENCES bergen.membership (membership_type)
);

-- plsql second
-- SEQUENCES
CREATE SEQUENCE IF NOT EXISTS bergen.station_seq INCREMENT BY 1;
CREATE SEQUENCE IF NOT EXISTS bergen.station_status_seq INCREMENT BY 1;
CREATE SEQUENCE IF NOT EXISTS bergen.bike_type_seq INCREMENT BY 1;
--CREATE SEQUENCE IF NOT EXISTS bergen.bike_seq INCREMENT BY 1;
CREATE SEQUENCE IF NOT EXISTS bergen.bike_status_seq INCREMENT BY 1;



-- PLSQL_FUNCTIONS

-- SEQUENCES
CREATE SEQUENCE IF NOT EXISTS bergen.station_seq INCREMENT BY 1;
CREATE SEQUENCE IF NOT EXISTS bergen.station_status_seq INCREMENT BY 1;
CREATE SEQUENCE IF NOT EXISTS bergen.bike_type_seq INCREMENT BY 1;
--CREATE SEQUENCE IF NOT EXISTS bergen.bike_seq INCREMENT BY 1;
CREATE SEQUENCE IF NOT EXISTS bergen.bike_status_seq INCREMENT BY 1;



-- PLSQL_FUNCTIONS

-- Standalone stored function that can be called directly and will generate a new ID
CREATE OR REPLACE FUNCTION bergen.gen_station_id( --(Ask)
    program_name VARCHAR
)
RETURNS VARCHAR AS
$$
DECLARE 
	station_id VARCHAR;
BEGIN
station_id := program_name || '_station_' || nextval('bergen.station_seq');
    RETURN  station_id;
END;
$$ LANGUAGE plpgsql;



-- Trigger function that will be used on direct insert-statements for adding to the "station"-table. 
-- This function will only run if the data for new entry is empty, will therefor not interfere with "bergen.insert_new_station"
CREATE OR REPLACE FUNCTION bergen.trg_func_gen_station_id() --(Ask)
RETURNS TRIGGER AS
$$
DECLARE 
    program_name VARCHAR;
BEGIN
	IF NEW.station_id IS NULL OR NEW.station_id = '' THEN
    SELECT name INTO program_name FROM bergen.program WHERE program_id = NEW.program_id;
        NEW.station_id := program_name || '_station_' || nextval('bergen.station_seq');
        RETURN NEW;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger object for trigger function
CREATE TRIGGER trg_station_id
BEFORE INSERT ON bergen.station
FOR EACH ROW
EXECUTE FUNCTION bergen.trg_func_gen_station_id();


-- Trigger function that will be used on direct insert-statements for adding to the "bike"-table. 
-- This function will check that the date the bike was acquired is not in the future, and will raise an exception if it is.
CREATE OR REPLACE FUNCTION bergen.check_date_acquired() --(Ida)
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.date_acquired > CURRENT_DATE THEN
        RAISE EXCEPTION 'date_acquired cannot be in the future';
    END IF;

    RETURN NEW;
END;
$$;

-- Trigger object for trigger function
CREATE TRIGGER trg_check_date_acquired
BEFORE INSERT OR UPDATE ON bergen.bike
FOR EACH ROW
EXECUTE FUNCTION bergen.check_date_acquired();


-- Trigger function that will be used on direct insert-statements for adding to the "bike"-table. 
-- This function will simply raise a notice that an insert statement has been executed on the bike table
CREATE OR REPLACE FUNCTION bergen.bike_insert_statement_trigger() --(Ida)
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE NOTICE 'Insert statement executed on bike table';
    RETURN NULL;
END;
$$;

--Statement-level trigger
CREATE TRIGGER trg_bike_insert_statement
AFTER INSERT ON bergen.bike
FOR EACH STATEMENT
EXECUTE FUNCTION bergen.bike_insert_statement_trigger();



-- Trigger function that will be used on direct insert-statements for adding to the "bought_membership"-table. 
-- This function will check that the expiration time is later than the activation time, and will raise an exception if it is not.
CREATE OR REPLACE FUNCTION bergen.check_membership_dates() --(Rikke)
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.expiration_time <= NEW.activation_time THEN
        RAISE EXCEPTION 'Expiration time must be later than activation time';
    END IF;

    RETURN NEW;
END;
$$;

-- Row-level trigger
DROP TRIGGER IF EXISTS trg_check_membership_dates ON bergen.bought_membership;
CREATE TRIGGER trg_check_membership_dates
BEFORE INSERT OR UPDATE ON bergen.bought_membership
FOR EACH ROW
EXECUTE FUNCTION bergen.check_membership_dates();


-- Trigger function that will be used on direct insert-statements for adding to the "bought_membership"-table. 
-- This function will simply raise a notice that an insert statement has been executed on the bought_members table.
CREATE OR REPLACE FUNCTION bergen.membership_insert_statement_trigger() --(Rikke)
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE NOTICE 'Insert statement executed on bought_membership table';
    RETURN NULL;
END;
$$;

-- Statement-level trigger
DROP TRIGGER IF EXISTS trg_membership_insert_statement ON bergen.bought_membership;
CREATE TRIGGER trg_membership_insert_statement
AFTER INSERT ON bergen.bought_membership
FOR EACH STATEMENT
EXECUTE FUNCTION bergen.membership_insert_statement_trigger();


--PLSQL_PROCEDURES

-- Stored procedure that will create a new station filling in the remaining data
CREATE OR REPLACE PROCEDURE bergen.insert_new_station(  --(Ask)
    st_name VARCHAR, 
    st_address VARCHAR, 
    st_postal_code INT, 
    st_latitude NUMERIC, 
    st_longitude NUMERIC, 
    st_capacity INT 
) 
LANGUAGE plpgsql 
AS $$
DECLARE
    rows_affected INT;
BEGIN 
    INSERT INTO bergen.station (station_id ,program_id, name, address, postal_code, latitude, longitude, total_capacity, available_docks) 
    SELECT bergen.gen_station_id(name), program_id, st_name, st_address, st_postal_code, st_latitude, st_longitude, st_capacity, st_capacity
    FROM bergen.program 
    WHERE program_id = 'bcycle_bergen';

    GET DIAGNOSTICS rows_affected = ROW_COUNT;

    IF rows_affected > 0 THEN
        RAISE NOTICE 'Suksess: % rad(er) satt inn.', rows_affected;
    ELSE
        RAISE WARNING 'Ingen rader satt inn! Sjekk om program_id "bcycle_bergen" eksisterer i bergen.program.';
    END IF;
END;
$$;


-- Stored procedure that creates bikes
-- Stored procedure: create_bicycle_proc

CREATE OR REPLACE PROCEDURE bergen.create_bicycle_proc( --(Ida)
    IN p_bike_type_id VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_next_id INT;
    p_bike_id VARCHAR;
BEGIN
    -- Validate foreign key reference: bike type must exist
    PERFORM 1
    FROM bergen.bike_type
    WHERE bike_type_id = p_bike_type_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Invalid bike_type_id: % does not exist in bergen.bike_type', p_bike_type_id;
    END IF;

    -- Generate bike_id according to required format
    SELECT COUNT(*) + 1
    INTO v_next_id
    FROM bergen.bike;

    p_bike_id := 'bergen_bike_' || v_next_id;

    -- Insert bicycle
    INSERT INTO bergen.bike (bike_id, dock_id, bike_type_id)
    VALUES (p_bike_id, NULL, p_bike_type_id);

EXCEPTION
    WHEN unique_violation THEN
        RAISE EXCEPTION 'Duplicate value error while creating bicycle.';
    WHEN raise_exception THEN
        RAISE;
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Unexpected error in create_bicycle_proc: %', SQLERRM;
END;
$$;


-- Stored procedure that will create a purchase. 
CREATE OR REPLACE PROCEDURE bergen.purchase_membership_proc( --(Rikke)
    IN p_user_id VARCHAR,
    IN p_membership_type VARCHAR,
    IN p_is_active BOOLEAN,
    IN p_activation_time TIMESTAMPTZ DEFAULT NULL,
    INOUT p_purchase_id VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_next_id INT;
    v_duration INT;
    v_activation_time TIMESTAMPTZ;
    v_expiration_time TIMESTAMPTZ;
BEGIN
    -- Validate that membership type exists
    PERFORM 1
    FROM bergen.membership
    WHERE membership_type = p_membership_type;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Invalid membership type: % does not exist in bergen.membership', p_membership_type;
    END IF;

    -- Validate that user exists
    PERFORM 1
    FROM bergen.user_info
    WHERE user_id = p_user_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'User does not exist: user_id % was not found in bergen.user_info', p_user_id;
    END IF;

        -- Generate purchase_id according to required format
    SELECT COUNT(*) + 1
    INTO v_next_id
    FROM bergen.bought_membership;

    p_purchase_id := 'purchase_' || v_next_id;

    -- Get duration from membership table
    SELECT duration
    INTO v_duration
    FROM bergen.membership
    WHERE membership_type = p_membership_type;

    -- Use current timestamp if activation time is not provided
    v_activation_time := COALESCE(p_activation_time, CURRENT_TIMESTAMP);

    -- Derive expiration time from activation_time + duration
    v_expiration_time := v_activation_time + (v_duration || ' days')::INTERVAL;

    -- Insert purchase
    INSERT INTO bergen.bought_membership (
        purchase_id,
        user_id,
        membership_type,
        is_active,
        purchase_time,
        activation_time,
        expiration_time
    )
    VALUES (
        p_purchase_id,
        p_user_id,
        p_membership_type,
        p_is_active,
        CURRENT_TIMESTAMP,
        v_activation_time,
        v_expiration_time
    )
    RETURNING purchase_id INTO p_purchase_id;

EXCEPTION
    WHEN unique_violation THEN
        RAISE EXCEPTION 'Duplicate value caused a unique violation while purchasing membership';
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Unexpected error in purchase_membership_proc: %', SQLERRM;
END;
$$;

-- mock-data third

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
insert into bergen.station ( program_id, name, address, postal_code, latitude, longitude, total_capacity, available_docks)
values ('bcycle_bergen', 'Bryggen', 'Bryggen 1', 5003, 60.3961, 5.3228, 4, 2),
       ('bcycle_bergen', 'Torgallmenningen', 'Torgallmenningen 1', 5014, 60.3925, 5.3240, 3, 2),
       ('bcycle_bergen', 'Byparken', 'Byparken 1', 5015, 60.3910, 5.3215, 3, 2);

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



-- constraints next
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


-- roles and permissions next


-- Analysis last