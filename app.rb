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
        view "home"
    else
        view "login_form"
    end
end

get "/login" do
    if @current_user
        view "home"
    else
        view "login_form"
    end
end

post "/login/action" do
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
            view "home"
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
get "/logout" do
    session[:user_id] = nil
    view "logout"
end

get "/signup" do
    if @current_user
        @error_message = "You are currently logged in with email address #{@current_user[:email]}. Please log out first."
        view "signup_fail"
    else
        view "signup_form"
    end
end

post "/signup/action" do
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

get "/list" do
    view "list_view"
end

get "/list/map" do
    view "list_map_view"
end

get "/add/item" do
    @chains = DB.from(:chains)
    view "add_item_form"
end

post "/add/item/action" do
    @error_message = nil
    @message = nil

    if uuid_check params["uuid"]
        if params["item_name"] == "" || params["detail"] == ""
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
            @items_created = get_items "Created"

            twilio_meesage "Item #{ params["item_name"] } was added."

            view "list_view"
        end
    else
        @message = "Item #{ params["item_name"] } was already added."
        @items_created = get_items "Created"
        view "list_view"
    end
end

get "/history" do
    view "history_list_view"
end

get "/history/calendar" do
    view "history_calendar_view"
end

def get_items (param_status_name = "Created")
   return DB["select items.*, status_name, chain_name, user_name, email from items, status, chains, users where created_by=users.id and chain_id=chains.id and status_id=status.id and status.status_name=?", param_status_name]
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

    puts param_message
    puts account_sid
    puts auth_token

    client = Twilio::REST::Client.new(account_sid, auth_token)
    client.messages.create(
        from: "+12028041068",
        to: "+18156185603",
        body: param_message
    )
end