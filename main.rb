require 'rubygems'
require 'sinatra'

set :sessions, true

BLACKJACK_AMOUNT = 21
DEALER_MIN_HIT = 17
INITIAL_POT_AMOUNT = 500
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
      break if total <= BLACKJACK_AMOUNT
      total -= 10
    end

    total
  end

  # This case statement will return the suit based on the value of element 1.
  # Set a var 'suit' to this and return it for retrieval below.
  def card_image(card) # ['H', '5']
    suit = case card[0]
      when 'H' then 'hearts' # when it's 'H' then return 'hearts'
      when 'D' then 'diamonds'
      when 'C' then 'clubs'
      when 'S' then 'spades'
    end

    # If the value of the second element is J, Q, K, A turn it into that word
    # (if this array 'card' has this value J, Q, K, A then re-map the value).
    value = card[1]
    if ['J', 'Q', 'K', 'A'].include?(value)
      value = case card[1]
        when 'j' then 'jack'
        when 'Q' then 'queen'
        when 'K' then 'king'
        when 'A' then 'ace'
      end
    end

    # Now we have the right values for both the suit and the value so now we can
    # build our URL.  Return a string with an image tag:

    # The html img tag has an attribute called 'source'.  The value of source needs
    # to be wrapped around either single or double quotes.  However, double quote
    # is already being used by us to capture this larger string which represents
    # this larger tag, so we use single quotes.  The reason we can use string
    # interpolation here is because of the outer double quotes.
    "<img src='/images/cards/#{suit}_#{value}.jpg' class ='card_image'>"
  end

    # Use instance vars to effect the logic of the view templates by letting us
    # conditionally display messages, error messages, or success messages, and
    # conditionally toggling the visability of certain elements on the page
    # based off the setting of certain instance vars.  This error instance var
    # goes away when the template is rendered again.
    # @success gives green box, @error gives red box
  def winner!(message)
    @play_again = true
    @show_hit_or_stay_buttons = false # Hide action buttons
    session[:player_pot] = session[:player_pot] + session[:player_bet]
    @success = "<strong>#{session[:player_name]} wins!  </strong>#{message}"
  end

  def loser!(message)
    @play_again = true
    @show_hit_or_stay_buttons = false
    session[:player_pot] = session[:player_pot] - session[:player_bet]
    @error = "<strong>#{session[:player_name]} loses.  </strong> #{message}"
  end

  def tie!(message)
    @play_again = true
    @show_hit_or_stay_buttons = false
    @success = "<strong>It's a push.  </strong> #{message}"
  end
end

# A before filter runs before every single one of the actions that follow it.
# It lets us dry up some code that needs to executed before every single action.
before do
  @show_hit_or_stay_buttons = true
end

get '/' do # handles default route localhost:9393
  if session[:player_name] # progress to the game
    redirect '/game' # redirect is a get - below
  else
    redirect '/new_player' # redirect to new route to display form
  end
end

get '/new_player' do
  # Initialize player's pot to $500
  session[:player_pot] = INITIAL_POT_AMOUNT
  erb :new_player
end

post '/new_player' do
  if params[:player_name].empty?
    @error = "Name is required"
    # Stop action from furthering execution.  Don't execute anything below this,
    # don't continue the action, but render the new_player template again. This
    # is used to force the player to input a name, because if a player does not
    # give a name the grammer on the page does not make sense.
    halt erb(:new_player)
  end
     session[:player_name] = params[:player_name]
    # progress to the betting form
    redirect '/bet'
end

get '/bet' do
  session[:player_bet] = nil  # Clear the bet to play over
  erb :bet
end

post '/bet' do # pull bet_amount from params hash posted by bet.erb in STREAMS, so:
  # If  params[:bet_amount] use quotes to compare to string of zero ('0')
      # if params[:bet_amount].nil? || params[:bet_amount] == '0'
  # or use to_i to compare to integer:
      # if params[:bet_amount].nil? || params[:bet_amount].to_i == 0
  if params[:bet_amount].nil? || params[:bet_amount].to_i == 0
    @error = "#{session[:player_name]} must make a bet."
    halt erb(:bet) #Halt execution and go to erb
    #Check if bet if > player_pot.  We don't need to call to_i on player_pot because
    # it's already an integer, vs. bet_amount which is a string sent by form bet.erb
  elsif
    params[:bet_amount].to_i < 0
    @error = "#{session[:player_name]} must make a valid bet."
    halt erb(:bet) #Halt execution and go to erb
  elsif params[:bet_amount].to_i > session[:player_pot]
    @error = "Bet amount cannot be greater than your money on the table: ($#{session[:player_pot]})"
    halt erb(:bet) #Halt execution and go to erb
  else
    session[:player_bet] = params[:bet_amount].to_i
    redirect '/game'
  end
end

get '/game' do
  # Create Turn key and set to player's name at start of new game
  session[:turn] = session[:player_name]

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

  player_total = calculate_total(session[:player_cards])
  if player_total == BLACKJACK_AMOUNT # If player hits 21
    winner!("#{session[:player_name]} hit Blackjack!")
  elsif player_total > BLACKJACK_AMOUNT # If player busts
    loser!("It looks like #{session[:player_name]} busted at #{player_total}.")
  end

  # don't redirect to game here...will reset the deck and start another round
  # just render the template again instead to take us to game.erb template:
  erb :game
end

post '/game/player/stay' do
  @success = "#{session[:player_name]} has chosen to stay."
  @show_hit_or_stay_buttons = false # Stayed, so don't show buttons
  redirect '/game/dealer'
  #erb :game
end

get '/game/dealer' do
  # Overwrite session key 'turn' to value "dealer"
  session[:turn] = "dealer"

  @show_hit_or_stay_buttons = false

  # decision tree
  dealer_total = calculate_total(session[:dealer_cards])

  if dealer_total == BLACKJACK_AMOUNT
    loser!("Dealer hit Blackjack.")
  elsif dealer_total > BLACKJACK_AMOUNT
    winner!("Dealer busted at #{dealer_total}")
  elsif dealer_total >= DEALER_MIN_HIT # 17, 18, 19, 20
    #dealer stays
    redirect '/game/compare'
  else
    #dealer hits
    @show_dealer_hit_button = true
  end

  erb :game
end

post '/game/dealer/hit' do
  session[:dealer_cards] << session[:deck].pop  # deal a card
  redirect '/game/dealer' # Go back to decision tree
end

get '/game/compare' do
  @show_hit_or_stay_buttons = false # Hide buttons

  player_total = calculate_total(session[:player_cards])
  dealer_total = calculate_total(session[:dealer_cards])

  if player_total < dealer_total
    loser!("#{session[:player_name]} stayed at #{player_total}, and the dealer stayed at #{dealer_total}.")
  elsif player_total > dealer_total
    winner!("#{session[:player_name]} stayed at #{player_total}, and the dealer stayed at #{dealer_total}.")
  else
    tie!("Both #{session[:player_name]} and the Dealer stayed at #{dealer_total}.")
  end

  erb :game
end

get '/game_over' do
  erb :game_over
end
