require 'bundler/setup'
require 'shoes'
require 'lib/base'
require 'lib/game_collection'
require 'lib/game_chooser'
require 'lib/game_filter'
require 'fastimage'
require 'pry'
require 'yaml'
require 'logger'

LOG = Logger.new(STDOUT)

Shoes.app(width: 425, height: 825) do
  flow do
    title "\nLets Pick a Board Game!\n", align: 'center'
  end

  stack(left: '10px') do
    flow(height: '40px') do
      tagline 'BGG Username:', width: '200px'
      @username_line = edit_line
      @username_line.text = 'okiedokieiguess'
    end

    flow(height: '40px') do
      tagline 'Time to play:', width: '200px'
      @gameplay_time_list = list_box items: [nil, '15 minutes', '30 minutes', '45 minutes', '1 hour', '2 hours', '3+ hours'] do
        filter_games if @collection
      end
    end

    flow(height: '40px') do
      tagline 'Number of players:', width: '200px'
      @number_of_players_list = list_box items: ([nil] + (1..24).to_a) do
        filter_games if @collection
      end
    end

    flow(height: '40px') do
      tagline 'Refresh collection:', width: '200px'
      @refresh_box = check
    end

    flow(height: '40px') do
      tagline 'Allow duplicate results:', width: '200px'
      @refresh_filter_box = check
    end
  end

  stack(top: '320px') do
    flow(height: '40px', margin_top: '10px') { @game_count_line = tagline 'Found 0 games that meet your criteria', align: 'center' }
    flow(margin_top: '10px', margin_left: '50px') do
      @choose_game_button = button("Choose Game") { handle_choose_game_button_press }
      @show_all_button = button("Show All", margin_left: '115px') { handle_show_all_button_press }
    end
  end

  stack(top: '400px', margin_top: '15px') do
    @game_tag_line = subtitle 'test', align: 'center'
    @game_text = subtitle '', align: 'center'
    flow(margin_top: '10px') { @game_image = image "resources/images/blank.png" }
  end
end
