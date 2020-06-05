# Set up for the application and database. DO NOT CHANGE. #############################
require "sequel"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB = Sequel.connect(connection_string)                                                #
#######################################################################################

if DB.table_exists?(:items)
    DB.drop_table :items
end
if DB.table_exists?(:users)
    DB.drop_table :users
end
if DB.table_exists?(:stores)
    DB.drop_table :stores
end
if DB.table_exists?(:chains)
    DB.drop_table :chains
end
if DB.table_exists?(:status)
    DB.drop_table :status
end

# Database schema - this should reflect your domain model
DB.create_table :status do
  primary_key :id
  String :status_name, null: false
end

DB.create_table :chains do
  primary_key :id
  String :chain_name, null: false
end

DB.create_table :stores do
  primary_key :id
  foreign_key :chain_id, :chains
  String :branch, null: false
  String :address, null: false
  Float :latitude, null: false
  Float :longitude, null: false
end

DB.create_table :users do
  primary_key :id
  String :user_name, null: false
  String :email, unique: true, null: false
  String :password, null: false
  Timestamp :created_at, default: Sequel::CURRENT_TIMESTAMP, null: false
end

DB.create_table :items do
  primary_key :id
  String :item_name, null: false
  String :detail, null: false
  foreign_key :chain_id, :chains, null: false
  foreign_key :created_by, :users, null: false
  Timestamp :created_at, default: Sequel::CURRENT_TIMESTAMP, null: false
  foreign_key :status_id, :status, default: 1, null: false
  foreign_key :status_changed_by, :users, null: false
  Timestamp :status_changed_at, default: Sequel::CURRENT_TIMESTAMP, null: false
end

DB.create_table! :uuids do
    String :uuid, unique: true
end

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
