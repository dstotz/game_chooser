require 'bundler/setup'
require 'bgg'
require 'pry'
require 'logger'

class GameFilter
  LOG = Logger.new(STDOUT)

  attr_reader :collection, :games, :num_players, :gameplay_time

  def initialize(collection: nil, num_players: nil, max_gameplay_time: nil)
    @collection = collection
    @num_players = num_players
    @gameplay_time = parse_gameplay_time(max_gameplay_time) if max_gameplay_time
    @games = {}
    filter_games
  end

  private

  def parse_gameplay_time(max_gameplay_time)
    if max_gameplay_time.downcase.include?('minutes')
      time = max_gameplay_time.downcase.delete('minutes').strip.to_i
    elsif max_gameplay_time.downcase.include?('hour')
      time = max_gameplay_time.downcase.delete('+hours').strip.to_i * 60
      time = 1000 if time > 120
    end
    time
  end

  def filter_games
    LOG.info "Filtering games. Number of players: #{num_players}. Gameplay time: #{gameplay_time}"
    build_game_list
  end

  def build_game_list
    collection.each do |name, details|
      next if disqualified?(details)
      games[name] = details
    end
  end

  def disqualified?(game)
    if num_players
      return true if num_players < game[:min_players] && game[:min_players] > 0
      return true if num_players > game[:max_players] && game[:max_players] > 0
    end
    return true if gameplay_time && gameplay_time < game[:play_time]
    false
  end
end
