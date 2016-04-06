require 'bundler/setup'
require 'bgg'
require 'pry'
require 'logger'

class GameFilter
  LOG = Logger.new(STDOUT)

  attr_reader :collection, :games, :num_players, :gameplay_time, :mechanic, :category

  def initialize(collection: nil, num_players: nil, max_gameplay_time: nil, mechanic: nil, category: nil)
    @collection = collection
    @num_players = number_of_players(num_players)
    @gameplay_time = parse_gameplay_time(max_gameplay_time)
    @mechanic = mechanic
    @category = category
    @games = {}
    filter_games
  end

  private

  def number_of_players(num_players)
    if num_players == 0 || num_players == 'All'
      return nil
    end
    num_players
  end

  def parse_gameplay_time(max_gameplay_time)
    if max_gameplay_time.nil? || max_gameplay_time == 'Any'
      time = 1000
    elsif max_gameplay_time.downcase.include?('minutes')
      time = max_gameplay_time.downcase.delete('minutes').strip.to_i
    elsif max_gameplay_time.downcase.include?('hour')
      time = max_gameplay_time.downcase.delete('+hours').strip.to_i * 60
    end
    time
  end

  def filter_games
    players = num_players || 'All'
    time = gameplay_time
    time = 'Any' if time == 1000
    build_game_list
    LOG.info "Filtering games; Players: #{players}, Gameplay: #{time}, Category: #{category}, Mechanic: #{mechanic}. Found #{games.count} matching games."
  end

  def build_game_list
    collection.each do |name, details|
      next if disqualified?(details)
      games[name] = details
    end
  end

  def disqualified?(game)
    return true if num_players && num_players < game[:min_players] && game[:min_players] > 0
    return true if num_players && num_players > game[:max_players] && game[:max_players] > 0
    return true if !mechanic.nil? && mechanic != 'Any' && !game[:mechanics].include?(mechanic)
    return true if !category.nil? && category != 'Any' && !game[:category].include?(category)
    return true if gameplay_time && gameplay_time < game[:play_time]
    false
  end
end
