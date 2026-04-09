-- SEQUENCES
CREATE SEQUENCE IF NOT EXISTS bergen.station_seq INCREMENT BY 1;
CREATE SEQUENCE IF NOT EXISTS bergen.bike_seq INCREMENT BY 1;

-- PLSQL_FUNCTIONS

-- Standalone stored function that can be called directly and will generate a new ID
CREATE OR REPLACE FUNCTION bergen.gen_station_id(
    program_id VARCHAR
)
RETURNS VARCHAR AS
$$
DECLARE 
	station_id VARCHAR;
BEGIN
    station_id := program_id || '_' || LPAD(nextval('bergen.station_seq')::text, 4, '0');
    RETURN  station_id;
END;
$$ LANGUAGE plpgsql;



-- Trigger function that will be used on direct insert-statements for adding to the "station"-table. 
-- This function will only run if the data for new entry is empty, will therefor not interfere with "bergen.insert_new_station"
CREATE OR REPLACE FUNCTION bergen.trg_func_gen_station_id()
RETURNS TRIGGER AS
$$
BEGIN
    IF NEW.station_id IS NULL OR NEW.station_id = '' THEN
        NEW.station_id := NEW.program_id || '_' || LPAD(nextval('bergen.station_seq')::text, 4, '0');
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
CREATE OR REPLACE FUNCTION bergen.gen_bike_id()
RETURNS TRIGGER AS
$$
BEGIN
	IF NEW.bike_id IS NULL OR NEW.bike_id = '' THEN
		NEW.bike_id := NEW.bike_type_id || '_' || LPAD(nextval('bergen.bike_seq')::text, 4, '0');
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_bike_id
BEFORE INSERT ON bergen.bike
FOR EACH ROW
EXECUTE FUNCTION bergen.gen_bike_id();


--PLSQL_PROCEDURES

-- Stored procedure that will create a new station filling in the remaining data
CREATE OR REPLACE PROCEDURE bergen.insert_new_station( 
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
    INSERT INTO bergen.station (station_id ,program_id, name, address, postal_code, latitude, longitude, capacity) 
    SELECT bergen.gen_station_id(program_id), program_id, st_name, st_address, st_postal_code, st_latitude, st_longitude, st_capacity 
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