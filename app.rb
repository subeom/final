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

events_table = DB.from(:events)
rsvps_table = DB.from(:rsvps)
users_table = DB.from(:users)

before do
    # SELECT * FROM users WHERE id = session[:user_id]
    @current_user = users_table.where(:id => session[:user_id]).to_a[0]
    puts @current_user.inspect
end

get "/" do
    #view "login_form"
    view "home"
end

get "/login" do
    #view "home"
    view "login_form"
end

get "/login/action" do
    view "login_success"
    view "login_fail"
end

get "/signup" do
    view "signup_form"
end

get "/signup/action" do
    view "signup_success"
    view "signup_fail"
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
