-- SEQUENCES
CREATE SEQUENCE IF NOT EXISTS bergen.station_seq INCREMENT BY 1;
CREATE SEQUENCE IF NOT EXISTS bergen.station_status_seq INCREMENT BY 1;
CREATE SEQUENCE IF NOT EXISTS bergen.bike_type_seq INCREMENT BY 1;
CREATE SEQUENCE IF NOT EXISTS bergen.bike_seq INCREMENT BY 1;
CREATE SEQUENCE IF NOT EXISTS bergen.bike_status_seq INCREMENT BY 1;



-- PLSQL_FUNCTIONS

-- Standalone stored function that can be called directly and will generate a new ID
CREATE OR REPLACE FUNCTION bergen.gen_station_id(
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
CREATE OR REPLACE FUNCTION bergen.trg_func_gen_station_id()
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
CREATE OR REPLACE FUNCTION bergen.gen_bike_id()
RETURNS TRIGGER AS
$$
BEGIN
	IF NEW.bike_id IS NULL OR NEW.bike_id = '' THEN
		NEW.bike_id := NEW.bike_type_id || '_' || (nextval('bergen.bike_seq');
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


-- Stoored procedure that creates bikes
CREATE OR REPLACE PROCEDURE bergen.create_bicycle_proc(
    IN out p_bike_id VARCHAR DEFAULT NULL,
    IN p_dock_id VARCHAR,
    IN p_biketype_id VARCHAR,
    IN p_year_acquired INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_next_id INT;
BEGIN
    -- Validate foreign key reference: dock must exist
    PERFORM 1
    FROM bergen.station_dock
    WHERE dock_id = p_dock_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Invalid dock_id: % does not exist in bergen.station_dock', p_dock_id;
    END IF;

    -- Validate foreign key reference: bike type must exist
    PERFORM 1
    FROM bergen.bike_type
    WHERE biketype_id = p_biketype_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Invalid biketype_id: % does not exist in bergen.bike_type', p_biketype_id;
    END IF;

    -- Generate bike_id according to required format
    SELECT COUNT(*) + 1
    INTO v_next_id
    FROM bergen.bike;

    p_bike_id := 'bergen_bike_' || v_next_id;

    -- Insert bicycle
    INSERT INTO bergen.bike (bike_id, dock_id, biketype_id, year_acquired)
    VALUES (p_bike_id, p_dock_id, p_biketype_id, p_year_acquired);

EXCEPTION
    WHEN unique_violation THEN
        RAISE EXCEPTION 'Duplicate value error while creating bicycle.';
    WHEN raise_exception THEN
        RAISE;
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Unexpected error in create_bicycle_proc: %', SQLERRM;
END;
$$;