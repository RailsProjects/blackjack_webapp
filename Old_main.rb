require 'rubygems'
require 'sinatra'

set :sessions, true

  # Use the Session to detect whether or not we have a user.
  # Since we aren't worrying about a persistent data store in this app we are
  # using the Session to capture and maintain the state of the game so we want
  # to put everything that requries state maintenence across requests to the
  # Session hash.  In web apps every request comes in not knowing about the
  # previous state of the previous request so whenever we have a new request
  # we must reconstitute/reestablish the state of the app for that particular
  # user.  We do that with session using a cookie to keep track of semi-persistent
  # state, as long as I don't erase my cookies

  # My logic in Pseudocode:
  #   if user?
  #     progress to the game
  #   else
  #     redirect to new player form

get '/' do # handles default route localhost:9393
  if session[:player_name] # progress to the game
    # redirect '/game' # redirect is a get - below
  else
    redirect '/new_player' # redirect to new route
  end
end

get '/new_player' do
  erb :capture_name
end

# post '/new_player' do
#   # params hash is reset with every request, so save values inputed from form
#   # into session. Then,progress to the game with a redirect to another path: /game
#   session[:player_name] = params[:player_name]
#   redirect '/game'
# end

# get '/game' do
#   # set up initial game values

#   erb :game
# end



# get '/form' do
#   erb :templateform
#   # (template that will show the form: it will look for a template templateform.erb in views dir)
# end

# post '/myaction' do
#   puts params['username']  # we named it username in the form, so use that name to retrieve it here
#                            # from the params hash after it was submitted by the form
#                            # (output shows up in console).
# end






