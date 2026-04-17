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
