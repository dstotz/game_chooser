require 'bundler/setup'
require 'shoes'
require 'lib/base'
require 'lib/game_collection'
require 'lib/game_chooser'
require 'lib/game_filter'
require 'lib/list_builder'
require 'fastimage'
require 'pry'
require 'yaml'
require 'logger'

LOG = Logger.new(STDOUT)

Shoes.app(width: 425, height: 825) do
  flow(margin_top: '30px', margin_bottom: '30px') do
    title "Lets Pick a Board Game!", align: 'center'
  end

  stack(left: '10px') do
    flow(height: '30px') do
      tagline 'BGG Username:', width: '200px'
      @username_line = edit_line
    end

    @connect_button = flow(left: '145px', margin_top: '10px', height: '40px') do
      button("Connect") { handle_initial_connection_button_press }
    end
  end

  @post_connection_flow = flow(hidden: true) do
    stack(left: '10px', margin_top: '40px') do
      flow(height: '30px') do
        tagline 'Time to play:', width: '200px'
        list = ['Any', '15 minutes', '30 minutes', '45 minutes', '1 hour', '2 hours', '3 hours']
        @gameplay_time_list = list_box items: list, choose: 'Any' do
          filter_games if @collection
        end
      end

      flow(height: '30px') do
        tagline 'Number of players:', width: '200px'
        list = ['Any'] + (1..24).to_a
        @number_of_players_list = list_box items: list, choose: 'Any' do
          filter_games if @collection
        end
      end

      flow(height: '30px') do
        tagline 'Game Category:', width: '200px'
        list = [nil]
        @category_list = list_box items: list do
          filter_games if @collection
        end
      end

      flow(height: '30px') do
        tagline 'Gameplay Mechanic:', width: '200px'
        list = [nil]
        @mechanic_list = list_box items: list do
          filter_games if @collection
        end
      end

      flow(height: '30px') do
        tagline 'Refresh collection:', width: '200px'
        @refresh_box = check
      end

      flow(height: '30px') do
        tagline 'Allow duplicate results:', width: '200px'
        @refresh_filter_box = check
      end
    end

    stack(top: '225px') do
      flow(height: '30px') { @game_count_line = tagline 'Found 0 games that meet your criteria', align: 'center' }
      flow(margin_left: '50px') do
        @choose_game_button = button("Choose Game") { handle_choose_game_button_press }
        @choose_game_button.focus
        @show_all_button = button("Show All", margin_left: '115px') { handle_show_all_button_press }
      end
    end

    stack(top: '280px', margin_top: '15px') do
      @game_tag_line = subtitle 'test', align: 'center'
      @game_text = subtitle '', align: 'center'
      flow(margin_top: '20px') { @game_image = image "resources/images/blank.png" }
    end
  end
end
