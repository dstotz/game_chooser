require 'bundler/setup'
require 'pry'

class GameChooser
  attr_reader :games, :previously_picked_games, :game, :total_count

  def initialize(games)
    @games = games
    @total_count = games.count
    @previously_picked_games = {}
  end

  def new_game
    @game = pick_game || game_not_found
  end

  private

  def pick_game
    pick = games.keys.sample
    chosen_game = games[pick]
    previously_picked_games[chosen_game]
    games.delete(pick)
    chosen_game
  end

  def game_not_found
    { name: 'None! No Games Found', image: './resources/images/poop.png' }
  end
end
