require 'rubygems'
require 'sinatra'

set :sessions, true

# any methods defined within the helpers block is available
# in both main.rb and any of the view templates
helpers do
  def calculate_total(cards) # cards is array: [['D', '3'], ['S', 'K']...]
    # calculate_total(session[:dealers_cards])
    arr = cards.map{|element| element[1]}
      # extract values of nested arrays into new array

    total = 0
    arr.each do |a|
      if a == "A"  # if Ace, increment by 11
        total += 11
      else
        total += a.to_i == 0 ? 10 : a.to_i
          # if value is not integer increment by 10, else increment by integer
      end
    end

    # correct for aces
    arr.select{|element| element == "A"}.count.times do
        # select Ace values out of array and count occurances
        # for each Ace, if total < 21 break, else subtract 10 to make Ace equal to 1
      break if total <= 21
      total -= 10
    end

    total
  end
end
get '/' do # handles default route localhost:9393
  if session[:player_name] # progress to the game
    redirect '/game' # redirect is a get - below
  else
    redirect '/new_player' # redirect to new route to display form
  end
end

get '/new_player' do
  erb :new_player
end

post '/new_player' do
  session[:player_name] = params[:player_name]
  # progress to the game above
  redirect '/game'
end

# A before filter runs before every single one of the actions that follow it.
# It lets us dry up some code that needs to executed before every single action.
before do
  @show_hit_or_stay_buttons = true
end

get '/game' do
  # When I hit 'game' route redeal and start a new game
  # set up initial game values
  # create a deck and put it in session with key of 'deck'
  suits = ['H', 'D', 'C', 'S']
  values = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']
  session[:deck] = suits.product(values).shuffle! #[['D', '3'], ['S', 'K']...]

  # deal cards
  session[:dealer_cards] = []
  session[:player_cards] = []
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop

  erb :game
end

post '/game/player/hit' do
  session[:player_cards] << session[:deck].pop
  if calculate_total(session[:player_cards]) > 21
    # Here we use instance vars to effect the logic of the view templates.
    # This error instance var goes away when the template is rendered again:
    @error= "Sorry, it looks like you busted."

    # Use instance vars to effect the view of the templates by letting us
    # conditionally display messages, error messages, or success messages, and
    # conditionally toggling the visability of certain elements on the page
    # based off the setting of certain instance vars.

    # Player busted, so don't show Hit or Stay buttons
    @show_hit_or_stay_buttons = false
  end

  # don't redirect to game here...will reset the deck and start another round
  # just render the template again instead to take us to game.erb template:
  erb :game
end

post '/game/player/stay' do
  @success = "You have chosen to stay."
  @show_hit_or_stay_buttons = false # Stayed, so don't show buttons
  erb :game
end
