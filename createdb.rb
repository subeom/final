# Set up for the application and database. DO NOT CHANGE. #############################
require "sequel"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB = Sequel.connect(connection_string)                                                #
#######################################################################################

DB.run "DROP TABLE items;"
DB.run "DROP TABLE users;"
DB.run "DROP TABLE stores;"
DB.run "DROP TABLE chains;"
DB.run "DROP TABLE status;"

DB.run "CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  user_name varchar,
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

DB.run "CREATE TABLE stores (
  id SERIAL PRIMARY KEY,
  chain_id int,
  branch varchar,
  address varchar,
  latitude float,
  longitude float
);"

DB.run "CREATE TABLE status (
  id SERIAL PRIMARY KEY,
  status_name varchar
);"

DB.run "ALTER TABLE items ADD FOREIGN KEY (\"chain_id\") REFERENCES \"chains\" (\"id\");"

DB.run "ALTER TABLE items ADD FOREIGN KEY (\"created_by\") REFERENCES \"users\" (\"id\");"

DB.run "ALTER TABLE items ADD FOREIGN KEY (\"status_id\") REFERENCES \"status\" (\"id\");"

DB.run "ALTER TABLE items ADD FOREIGN KEY (\"status_changed_by\") REFERENCES \"users\" (\"id\");"

DB.run "ALTER TABLE items ADD FOREIGN KEY (\"status_changed_in\") REFERENCES \"stores\" (\"id\");"

DB.run "ALTER TABLE stores ADD FOREIGN KEY (\"chain_id\") REFERENCES \"chains\" (\"id\");"


# Insert initial (seed) data
status_table = DB.from(:status)
status_table.insert(status_name: 'Created')
status_table.insert(status_name: 'Bought')
status_table.insert(status_name: 'Deleted')

chains_table = DB.from(:chains)
chains_table.insert(chain_name: 'Costco')
chains_table.insert(chain_name: 'Korean')
chains_table.insert(chain_name: 'Trader Joe\'s')

stores_table = DB.from(:stores)
stores_table.insert(chain_id: 1,
                    branch: 'Niles',
                    address: '7311 N Melvina Ave, Niles, IL 60714',
                    latitude: 42.014820,
                    longitude: -87.780430)
stores_table.insert(chain_id: 2,
                    branch: 'H Mart Niles',
                    address: '801 Civic Center Dr, Niles, IL 60714',
                    latitude: 42.025261,
                    longitude: -87.801460)
stores_table.insert(chain_id: 2,
                    branch: 'Joong Boo Market Glenview',
                    address: '670 Milwaukee Ave, Glenview, IL 60025',
                    latitude: 42.067520,
                    longitude: -87.850700)
stores_table.insert(chain_id: 3,
                    branch: 'Evanston',
                    address: '1211 Chicago Ave, Evanston, IL 60202',
                    latitude: 42.039940,
                    longitude: -87.680080)

