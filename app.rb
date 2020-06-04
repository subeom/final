# Set up for the application and database. DO NOT CHANGE. #############################
require "sinatra"                                                                     #
require "sinatra/reloader" if development?                                            #
require "sequel"                                                                      #
require "logger"                                                                      #
require "twilio-ruby"                                                                 #
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

# heroku login
# git remote add heroku https://git.heroku.com/calm-stream-67688.git

# events_table = DB.from(:events)
# rsvps_table = DB.from(:rsvps)

users_table = DB.from(:users)

before do
    # SELECT * FROM users WHERE id = session[:user_id]
    @current_user = users_table.where(:id => session[:user_id]).to_a[0]
    puts @current_user.inspect
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

get "/login/action" do
    puts params
    email_entered = params["email"]
    password_entered = params["password"]
    # SELECT * FROM users WHERE email = email_entered
    user = users_table.where(:email => email_entered).to_a[0]
    if user
        puts user.inspect
        # test the password against the one in the users table
        if user[:password] == password_entered
            session[:user_id] = user[:id]
            view "login_success"
        else
            view "login_fail"
        end
    else 
        view "create_login_failed"
    end
end

get "/signup" do
    view "signup_form"
end

post "/signup/action" do
    encrypted_password = BCrypt::Password.create(params["password"])

    @error_message = nil

    if users_table.where(email: params["email"]).first
        @error_message = "The email address, #{params["email"]}, already exists."
        view "signup_fail"        
    else
        users_table.insert(:user_name => params["name"],
                        :email => params["email"],
                        :password => encrypted_password)

        user = users_table.where(email: params["email"], password: encrypted_password).select(:email).first

        if user
            @email_signed_up = user[:email]
            puts @email_signed_up.inspect
            view "signup_success"
        else
            @error_message = "Unknown error occurred. Please try to sign up later."
            view "signup_fail"
        end
    end
end

get "/list" do
    view "list_view"
end

get "/list/map" do
    view "list_map_view"
end

get "/add/item" do
    view "add_item_form"
end

get "/add/item/action" do
    view "list_view"
end

get "/history" do
    view "history_list_view"
end

get "/history/calendar" do
    view "history_calendar_view"
end
