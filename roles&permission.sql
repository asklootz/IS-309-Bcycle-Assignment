-- The roles specified in assignment 3:
-- Role: bcycle_user
-- Pass: bcycle_user_pass
-- DROP ROLE IF EXISTS bcycle_user;
CREATE ROLE bcycle_user WITH LOGIN NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS
PASSWORD 'bcycle_user_pass';
GRANT pg_read_all_data TO bcycle_user WITH INHERIT OPTION, SET OPTION;
-- GRANT SELECT ON ALL TABLES IN SCHEMA bergen TO bcycle_user; => Alternative way to give read access to 


-- Role: bcycle_admin
-- Pass: bcycle_admin_pass
-- DROP ROLE IF EXISTS bcycle_admin;
CREATE ROLE bcycle_admin LOGIN NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS
PASSWORD 'bcycle_admin_pass';

GRANT bcycle_user TO bcycle_admin WITH INHERIT OPTION, SET OPTION;
-- ALTER DEFAULT PRIVILEGES IN SCHEMA bergen GRANT EXECUTE ON ROUTINES TO bcycle_admin; => Be able to automatically get access to future procedures. 
GRANT EXECUTE ON ALL PROCEDURES IN SCHEMA bergen TO bcycle_admin;


-- Role: account_admin
-- Pass: account_admin_pass
-- DROP ROLE IF EXISTS account_admin;
CREATE ROLE account_admin LOGIN NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS
PASSWORD 'account_admin_pass';

GRANT bcycle_user TO account_admin WITH INHERIT OPTION, SET OPTION;
GRANT EXECUTE ON PROCEDURE bergen.create_account_sp TO account_admin;
GRANT EXECUTE ON PROCEDURE bergen.purchase_membership_proc TO account_admin;
GRANT EXECUTE ON PROCEDURE bergen.start_trip_sp TO account_admin;

-- Alter PROCEDURE so the different roles can use it
-- This is necessary since the procedures were created before the roles, and thus only have permissions for the role that created them (in this case, the default postgres role).
ALTER PROCEDURE bergen.purchase_membership_proc
security definer SET search_path = postgres, pg_temp;

ALTER PROCEDURE bergen.create_account_sp
security definer SET search_path = postgres, pg_temp;

ALTER PROCEDURE bergen.start_trip_sp
security definer SET search_path = postgres, pg_temp;

ALTER PROCEDURE bergen.insert_new_station
security definer SET search_path = postgres, pg_temp;

ALTER PROCEDURE bergen.create_bicycle_proc
security definer SET search_path = postgres, pg_temp;

-- Role: customer_support
-- DROP ROLE IF EXISTS customer_support;
CREATE ROLE customer_support WITH
    NOLOGIN
    NOSUPERUSER
    INHERIT
    NOCREATEDB
    NOCREATEROLE
    NOREPLICATION
    NOBYPASSRLS;

-- Role: operations_tech_team
-- DROP ROLE IF EXISTS operations_tech_team;
CREATE ROLE operations_tech_team WITH
    NOLOGIN
    NOSUPERUSER
    INHERIT
    NOCREATEDB
    NOCREATEROLE
    NOREPLICATION
    NOBYPASSRLS;

-- Role: station_manager
-- DROP ROLE IF EXISTS station_manager;
CREATE ROLE station_manager WITH
    NOLOGIN
    NOSUPERUSER
    INHERIT
    NOCREATEDB
    NOCREATEROLE
    NOREPLICATION
    NOBYPASSRLS;

-- Role: system_admin
-- DROP ROLE IF EXISTS system_admin;
CREATE ROLE system_admin WITH
    LOGIN
    NOSUPERUSER
    INHERIT
    NOCREATEDB
    NOCREATEROLE
    NOREPLICATION
    NOBYPASSRLS
    PASSWORD 'system_admin_pass';

-- Granting permissions to the different roles.
GRANT SELECT, INSERT, UPDATE ON bergen.station, bergen.station_dock, bergen.station_status TO station_manager;
GRANT SELECT ON bergen.user_info, bergen.trip, bergen.bought_membership TO customer_support;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA bergen TO system_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA bergen TO system_admin;
GRANT SELECT, INSERT, UPDATE ON 
    bergen.station,
    bergen.station_dock,
    bergen.station_status,
    bergen.bike,
    bergen.bike_status,
    bergen.bike_type
TO operations_tech_team;

-- To view grantings
SELECT grantee, table_name AS object_name, privilege_type, 'TABLE' AS object_type
FROM information_schema.role_table_grants 
WHERE grantee IN (
    'station_manager', 
    'customer_support',
    'operations_tech_team',
    'system_admin'
)

UNION ALL

SELECT grantee, object_name, privilege_type, 'SEQUENCE' AS object_type
FROM information_schema.usage_privileges
WHERE object_type = 'SEQUENCE'
AND grantee IN (
    'station_manager', 
    'customer_support',
    'operations_tech_team',
    'system_admin'
)

ORDER BY grantee, object_type, object_name, privilege_type;