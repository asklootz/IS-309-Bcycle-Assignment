-- SEQUENCES
CREATE SEQUENCE IF NOT EXISTS bergen.station_seq INCREMENT BY 1;


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


-- Stored procedure that will create a new account.
CREATE OR REPLACE PROCEDURE bergen.create_account_sp( --(Jimmy)
    IN p_name character varying,
    IN p_surname character varying,
    IN p_email character varying,
    IN p_date_of_birth date,
    IN p_street character varying,
    IN p_city character varying,
    IN p_postal_code int,
    IN p_state character varying,
    IN p_hashsalt character varying,
    IN p_passhash character varying,
    INOUT p_user_id character varying default NULL)
LANGUAGE 'plpgsql'
    SECURITY DEFINER 
    SET search_path=postgres, pg_temp
AS $BODY$
DECLARE
    v_user_id VARCHAR;
    v_next_id INT;
BEGIN
    SELECT COUNT(*) + 1
    INTO v_next_id
    FROM bergen.user_info;

    p_user_id := 'user_' || v_next_id;

    INSERT INTO bergen.user_info ( user_id,
        name, surname, email, date_of_birth,
        address, city, postal_code, state,
        total_trips, creation_date
    )
    VALUES ( p_user_id,
        p_name, p_surname, p_email, p_date_of_birth,
        p_street, p_city, p_postal_code, p_state,
        0, CURRENT_TIMESTAMP
    )
    RETURNING user_id INTO v_user_id;

    INSERT INTO bergen.user_auth (
        user_id, hashsalt, passhash, email
    )
    VALUES (
        v_user_id, p_hashsalt, p_passhash, p_email
    );

    p_user_id := v_user_id;

    RAISE NOTICE 'Account created successfully with user_id: %', v_user_id;

EXCEPTION
    WHEN unique_violation THEN
        RAISE EXCEPTION 'An account with email % already exists.', p_email;
    WHEN OTHERS THEN
        RAISE EXCEPTION 'An error occurred: %', SQLERRM;
END;
$BODY$;



-- How to call the procedures:
-- CALL bergen.insert_new_station('Nygaten', 'Nygaten 1', 5003, 60.3920, 5.3210, 4);
-- CALL bergen.create_bicycle_proc('electric_1');
-- CALL bergen.purchase_membership_proc('user_1', 'monthly', 'true', '2026-05-22 09:45:00');
-- CALL bergen.create_account_sp('Grizzly', 'Bjørn', 'grizzly.bjorn@example.com', '1980-01-01', 'Bamsegaten 12', 'Bergen', 5003, 'Hordaland', 'random_salt_3', 'hashed_password_3', NULL);
-- call bergen.create_account_sp('Charli', 'XCX', 'charli.xcx@example.com', '1992-08-02', 'Bratgaten 2', 'Bergen', 5003::smallint, 'Hordaland', 'salty', 'hashy');