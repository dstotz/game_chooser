require 'bundler/setup'
require 'bgg'
require 'pry'
require 'logger'

class GameCollection
  LOG = Logger.new(STDOUT)

  attr_reader :username, :include_expansions, :collection, :game_collection

  def initialize(username: nil, percent: nil)
    @username = username
    @percent = percent
    @game_collection = {}
    find_games
  end

  private

  def find_games
    LOG.info 'Fetching collection'
    fetch_collection
    LOG.info 'Building game list'
    build_game_list(collection.boardgames)
  end

  def build_game_list(collection_list)
    collection_list.each do |item|
      sleep 0.5
      LOG.info "Collecting data for #{item.name}"
      begin
        game = item.game
        game_collection[game.name] = data_collector(game)
      rescue
        LOG.warn "Unable to collect game data for #{item.name}"
        next
      end
    end
  end

  def data_collector(game)
    {
      id: game.id,
      name: game.name,
      image: "http://#{game.image.gsub('//', '')}",
      min_players: game.min_players,
      max_players: game.max_players,
      category: game.categories,
      description: game.description,
      mechanics: game.mechanics,
      play_time: game.playing_time
    }
  end

  def fetch_collection
    retry_count = 0
    begin
      @collection ||= Bgg::Collection.find_by_username(username)
    rescue
      retry_count += 1
      retry if retry_count <= 5
    end
  end
end
