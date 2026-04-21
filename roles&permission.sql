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