# Set up for the application and database. DO NOT CHANGE. #############################
require "sinatra"                                                                     #
require "sinatra/reloader" if development?                                            #
require "sequel"                                                                      #
require "logger"                                                                      #
require "geocoder"                                                                    #
require "bcrypt"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB ||= Sequel.connect(connection_string)                                              #
DB.loggers << Logger.new($stdout) unless DB.loggers.size > 0                          #
def view(template); erb template.to_sym; end                                          #
use Rack::Session::Cookie, key: 'rack.session', path: '/', secret: 'secret'           #
before { puts; puts "--------------- NEW REQUEST ---------------"; puts }             #
after { puts; }                                                                       #
#######################################################################################

require "securerandom"
#SecureRandom.uuid # => "96b0a57c-d9ae-453f-b56f-3b154eb10cda"

require "twilio-ruby"

# heroku login
# git remote add heroku https://git.heroku.com/calm-stream-67688.git

# events_table = DB.from(:events)
# rsvps_table = DB.from(:rsvps)

users_table = DB.from(:users)

before do
    # SELECT * FROM users WHERE id = session[:user_id]
    @current_user = users_table.where(:id => session[:user_id]).first
end

get "/" do
    if @current_user

        @stores_created = get_stores "Created"
        @chains_created = get_chains "Created"
        @items_created = get_items "Created"

        view "list_view"
    else
        view "login_form"
    end
end

get %r{/login/{0,1}} do
    if @current_user

        @stores_created = get_stores "Created"
        @chains_created = get_chains "Created"
        @items_created = get_items "Created"

        view "list_view"
    else
        view "login_form"
    end
end

post %r{/login/action/{0,1}} do
    email_entered = params["email"]
    password_entered = params["password"]

    @error_message = nil

    # SELECT * FROM users WHERE email = email_entered
    user = users_table.where(:email => email_entered).first
    if user
        # test the password against the one in the users table
        if BCrypt::Password.new(user[:password]) == password_entered
            session[:user_id] = user[:id]
            @current_user = user

            @stores_created = get_stores "Created"
            @chains_created = get_chains "Created"
            @items_created = get_items "Created"
    
            view "list_view"
        else
            @error_message = "Incorrect Password."
            view "login_fail"
        end
    else 
        @error_message = "User #{params["email"]} does not exist."
        view "login_fail"
    end
end

# Logout
get %r{/logout/{0,1}} do
    if @current_user
        session[:user_id] = nil
        @current_user = nil
        view "logout"
    else
        view "login_form"
    end
end

get %r{/signup/{0,1}} do
    if @current_user
        @error_message = "You are currently logged in with email address #{@current_user[:email]}. Please log out first."
        view "signup_fail"
    else
        view "signup_form"
    end
end

post %r{/signup/action/{0,1}} do
    if uuid_check params["uuid"]
        encrypted_password = BCrypt::Password.create(params["password"])

        @error_message = nil

        if params["name"] == "" || params["email"] == "" || params["password"] == ""
            @error_message = "At least one of the required fields is empty."
            view "signup_fail"        
        elsif users_table.where(email: params["email"]).first
            @error_message = "The email address, #{params["email"]}, already exists."
            view "signup_fail"        
        else
            users_table.insert(:user_name => params["name"],
                            :email => params["email"],
                            :password => encrypted_password)

            user = users_table.where(email: params["email"], password: encrypted_password).select(:email).first

            if user
                @email_signed_up = user[:email]
                view "signup_success"
            else
                @error_message = "Unknown error occurred. Please try to sign up later."
                view "signup_fail"
            end
        end
    else
        @error_message = "Don't refresh your page."
        view "signup_fail"
    end
end

get %r{/list/{0,1}} do
    if @current_user

        @stores_created = get_stores "Created"
        @chains_created = get_chains "Created"
        @items_created = get_items "Created"

        view "list_view"
    else
        view "login_form"
    end
end

get %r{/list/map/{0,1}} do
    if @current_user

        @stores_created = get_stores "Created"
        @chains_created = get_chains "Created"
        @items_created = get_items "Created"

        view "list_map_view"
    else
        view "login_form"
    end
end

post %r{/change/status/{0,1}} do
    if @current_user
        item_id = params[:item_id]
        status_id = nil
        if params[:deleted] == "true"
            status_id = 3
        else
            status_id = 1
        end

        DB.run "update items set status_id=#{status_id}, status_changed_at=current_timestamp, status_changed_by=#{ @current_user[:id] } where id=#{item_id}"

        "update items set status_id=#{status_id}, status_changed_at=current_timestamp, status_changed_by=#{ @current_user[:id] } where id=#{item_id}"
    else
        view "login_form"
    end
end

get %r{/add/item/{0,1}} do
    if @current_user
        @chains = DB.from(:chains)
        view "add_item_form"
    else
        view "login_form"
    end
end

post %r{/add/item/action/{0,1}} do
    @error_message = nil
    @message = nil

    if uuid_check params["uuid"]
        if params["item_name"] == ""
            @error_message = "At least one of the required fields is empty."
            view "add_item_fail"        
        else
            items_table = DB.from(:items)

            #DB.create_table :items do
            #  primary_key :id
            #  String :item_name, null: false
            #  String :detail, null: false
            #  foreign_key :chain_id, :chains, null: false
            #  foreign_key :created_by, :users, null: false
            #  Timestamp :created_at, default: Sequel::CURRENT_TIMESTAMP, null: false
            #  foreign_key :status_id, :status, default: 1, null: false
            #  foreign_key :status_changed_by, :users, null: false
            #  Timestamp :status_changed_at, default: Sequel::CURRENT_TIMESTAMP, null: false
            #end

            items_table.insert(:item_name => params["item_name"],
                            :detail => params["detail"],
                            :chain_id => params["chain_id"],
                            :created_by => session[:user_id],
                            :status_changed_by => session[:user_id])

            @message = "Item #{ params["item_name"] } was added successfully."

            @stores_created = get_stores "Created"
            @chains_created = get_chains "Created"
            @items_created = get_items "Created"
    
            twilio_meesage "Item #{ params["item_name"] } was added."

            view "list_view"
        end
    else
        @message = "Item #{ params["item_name"] } was already added."

        @stores_created = get_stores "Created"
        @chains_created = get_chains "Created"
        @items_created = get_items "Created"

        view "list_view"
    end
end

get %r{/history/{0,1}} do
    if @current_user
        @stores_all = get_stores "ALL"
        @chains_all = get_chains "ALL"
        @items_all = get_items "ALL"

        view "history_list_view"
    else
        view "login_form"
    end
end

get %r{/stores/{0,1}} do
    if @current_user
        results = Geocoder.search("2211 Campus Dr, Evanston, IL 60208")
        @lat_long = results.first.coordinates.join(",")
        @stores_all = get_stores "ALL"
        @chains_all = get_chains "ALL"

        view "stores_view"
    else
        view "login_form"
    end
end

get %r{/history/calendar/{0,1}} do
    if @current_user
        view "history_calendar_view"
    else
        view "login_form"
    end
end

def get_items (param_status_name = "Created")
    if param_status_name == "ALL"
        #return DB["select items.*, status_name, chains.id as chain_id, chain_name, user_name, email, status.status_name from items, status, chains, users where created_by=users.id and chain_id=chains.id and status_id=status.id order by status_changed_at desc"]
        return DB["select items.*, u1.user_name as created_by_name, u2.user_name as status_changed_by_name, chains.id as chain_id, chain_name, status.status_name from items join status on items.status_id = status.id join chains on items.chain_id = chains.id join users as u1 on items.created_by = u1.id join users as u2 on items.status_changed_by = u2.id order by status_changed_at desc"]
    else
        #return DB["select items.*, status_name, chains.id as chain_id, chain_name, user_name, email from items, status, chains, users where created_by=users.id and chain_id=chains.id and status_id=status.id and ((items.status_changed_at > current_timestamp + '-1 week') or status.status_name=?) order by items.id", param_status_name]
        return DB["select items.*, u1.user_name as created_by_name, u2.user_name as status_changed_by_name, chain_name, status.status_name from items join status on items.status_id = status.id join chains on items.chain_id = chains.id join users as u1 on items.created_by = u1.id join users as u2 on items.status_changed_by = u2.id where ((items.status_changed_at > current_timestamp + '-1 week') or status.status_name=?) order by status_id, items.id", param_status_name]
    end
end

def get_stores (param_status_name = "Created")
    if param_status_name == "ALL"
        return DB["select distinct stores.id as store_id, branch, address, latitude, longitude, chains.id as chain_id, chain_name from chains, stores where stores.chain_id = chains.id order by stores.id"]
    else
        return DB["select distinct stores.id as store_id, branch, latitude, longitude, chains.id as chain_id, chain_name from items, chains, status, stores where items.chain_id=chains.id and stores.chain_id = chains.id and status_id=status.id and ((items.status_changed_at > current_timestamp + '-1 week') or status.status_name=?) order by stores.id", param_status_name]
    end
end

def get_chains (param_status_name = "Created")
    if param_status_name == "ALL"
        return DB["select distinct chains.id as chain_id, chain_name from chains order by chains.id"]
    else
        return DB["select distinct chains.id as chain_id, chain_name from items, chains, status where items.chain_id=chains.id and status_id=status.id and ((items.status_changed_at > current_timestamp + '-1 week') or status.status_name=?) order by chains.id", param_status_name]
    end
end

def uuid_check (param_uuid)
    uuids = DB["select * from uuids where uuid=?", param_uuid]
    uuid_count = uuids.count

    if uuid_count == 0
        uuids_table = DB.from(:uuids)
        uuids_table.insert(:uuid => param_uuid)
        return true
    else
        return false
    end
end

def twilio_meesage (param_message)
    account_sid = ENV["TWILIO_ACCOUNT_SID"]
    auth_token = ENV["TWILIO_AUTH_TOKEN"]

    client = Twilio::REST::Client.new(account_sid, auth_token)
    client.messages.create(
        from: "+12028041068",
        to: "+18156185603",
        body: param_message
    )
end