# Set up for the application and database. DO NOT CHANGE. #############################
require "sequel"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB = Sequel.connect(connection_string)                                                #
#######################################################################################

DB.run "CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name varchar,
  email varchar,
  password varchar,
  created_at timestamp
);"

DB.run "CREATE TABLE items (
  id SERIAL PRIMARY KEY,
  item_name varchar,
  detail varchar,
  chain_id int,
  created_by int,
  created_at timestamp,
  status_id int,
  status_changed_by int,
  status_changed_at timestamp,
  status_changed_in int
);"

DB.run "CREATE TABLE chains (
  id SERIAL PRIMARY KEY,
  chain_name varchar
);"

DB.run "CREATE TABLE status (
  id SERIAL PRIMARY KEY,
  status_name varchar
);"

DB.run "CREATE TABLE stores (
  id SERIAL PRIMARY KEY,
  chain_id int,
  branch varchar,
  latitude float,
  longitude float
);"

DB.run "ALTER TABLE items ADD FOREIGN KEY (\"chain_id\") REFERENCES \"chains\" (\"id\");"

DB.run("ALTER TABLE items ADD FOREIGN KEY (\"created_by\") REFERENCES \"users\" (\"id\");"

DB.run("ALTER TABLE items ADD FOREIGN KEY (\"status_id\") REFERENCES \"status\" (\"id\");"

DB.run("ALTER TABLE items ADD FOREIGN KEY (\"status_changed_by\") REFERENCES \"users\" (\"id\");"

DB.run("ALTER TABLE items ADD FOREIGN KEY (\"status_changed_in\") REFERENCES \"stores\" (\"id\");"

DB.run("ALTER TABLE stores ADD FOREIGN KEY (\"chain_id\") REFERENCES \"chains\" (\"id\");"
