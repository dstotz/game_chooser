class ListBuilder
  attr_reader :collection, :categories, :mechanics, :play_times, :min_players, :max_players
  def initialize(collection)
    @collection = collection
    @categories = []
    @mechanics = []
    @play_times = []
    @min_players = []
    @max_players = []
    process_collection
    finalize_lists
  end

  private

  def process_collection
    collection.each do |game, details|
      begin
        @categories += details[:category]
        @mechanics += details[:mechanics]
        play_times << details[:play_time]
        min_players << details[:min_players]
        max_players << details[:max_players]
      rescue => err
        binding.pry
      end
    end
  end

  def finalize_lists
    categories.uniq!.sort!
    mechanics.uniq!.sort!
    play_times.uniq!.sort!
    min_players.uniq!.sort!
    max_players.uniq!.sort!
  end
end
