require 'open-uri'
require 'bgg'

def fetch_collection(refresh: false)
  filename = "./tmp/#{@username}.yml"
  if File.exists?(filename) && refresh == false
    collection = restore_collection(filename)
  else
    collection = refresh_collection
    backup_collection(filename, collection) if collection
  end
  @list_builder = ListBuilder.new(collection)
  collection
end

def refresh_collection
  refresh_games
  refresh_images if @collection
  @collection
end

def refresh_games
  if confirm("Would you like to refresh your collection?\nThis can take a few minutes")
    LOG.info 'Refreshing collection'
    @collection = GameCollection.new(username: @username).game_collection
    @list_builder = ListBuilder.new(@collection)
    LOG.info 'Refresh complete'
  end
end

def refresh_images
  if confirm("Would you like to back up images?\nThis can take a few minutes")
    backup_collection_images(@collection)
  end
end

def restore_collection(filename)
  LOG.info 'Backup found, restoring backup'
  YAML.load_file(filename)
end

def backup_collection(filename, collection)
  LOG.info 'Backing up collection'
  output = File.open(filename, 'w')
  output.write collection.to_yaml
end

def local_image_filepath(url)
  dir = './tmp/images'
  filename = url.split('/').last
  "#{dir}/#{filename}"
end

def local_image_file(url)
  filepath = local_image_filepath(url)
  return nil unless File.exists? filepath
  filepath
end

def backup_collection_images(collection)
  LOG.info 'Backing up item images'
  collection.each do |name, details|
    next unless details[:image]
    filepath = local_image_filepath(details[:image])
    next if File.exists? filepath
    LOG.info "Backing up image for #{name} to #{filepath}"
    File.open(filepath, 'wb') { |fo| fo.write open(details[:image]).read }
  end
  LOG.info 'Backup of item images complete'
end

def calculate_new_size(big, small, max: 300)
  diff = max.to_f / big
  small = (small * diff).round(0).to_i
  big = max
  [big, small]
end

def resize_image(image: nil, max: 300)
  image = @game_chooser.game[:image] if image.nil? && @game_chooser
  width, height = FastImage.size(image)
  if width > height
    new_width, new_height = calculate_new_size(width, height, max: max)
  else
    new_height, new_width = calculate_new_size(height, width, max: max)
  end
  [new_width, new_height]
end

def filter_games
  @num_players = @number_of_players_list.text.to_i
  @gameplay_time = @gameplay_time_list.text
  @category = @category_list.text
  @mechanic = @mechanic_list.text
  @games = GameFilter.new(
    collection: @collection,
    num_players: @num_players,
    max_gameplay_time: @gameplay_time,
    mechanic: @mechanic,
    category: @category
  )
  @game_chooser = GameChooser.new(@games.games)
  update_filter_text
  ensure_all_games_images_removed
  set_default_image
end

def center(elem, vertical: false)
  left = (elem.parent.width - elem.width) / 2
  if vertical
    top = (elem.parent.height - elem.height) / 2 if vertical
    elem.move(left, top)
  else
    elem.move(left, 0)
  end
end

def set_default_image
  @game_tag_line.text = ''
  @game_text.text = ''
  @game_image.path = "./resources/images/blank.png"
end

def update_game_image
  width, height = resize_image
  @game_image.update_style(height: height, width: width)
  game = @game_chooser.game
  @game_image.path = local_image_file(game[:image]) || game[:image]
  center(@game_image)
end

def update_filter_text
  @game_count_line.text = "Found #{@game_chooser.total_count} games. There are #{@game_chooser.games.count} remaining."
end

def ensure_all_games_images_removed
  if @all_game_stack
    @all_game_stack.hide; @game_image.show; @game_text.show
    @all_game_stack.contents { |e| e.remove }
  end
end

def validate_username
  return true if File.exists?("./tmp/#{@username}.yml")
  begin
    return true if Bgg::User.find_by_name(@username)
  rescue
  end
  alert("Unable to find BGG username #{@username}.\nPlease try again.")
  false
end

def handle_initial_connection_button_press
  @username = @username_line.text
  if validate_username
    @collection = fetch_collection
    @post_connection_flow.show
    @connect_button.hide
    filter_games
    @category_list.items = ['Any'] + @list_builder.categories
    @category_list.choose = 'Any'
    @mechanic_list.items = ['Any'] + @list_builder.mechanics
    @mechanic_list.choose = 'Any'
  end

end

def handle_show_all_button_press
  if @collection.nil?
    alert("You must do Choose Game first")
    return
  end
  ensure_all_games_images_removed
  filter_games
  @game_image.hide; @game_text.hide
  @game_tag_line.text = 'Here are all of the available games!'
  @all_game_stack = stack(top: '435px') do
    sorted_games = @game_chooser.games.sort
    sorted_games.each do |name, game|
      flow do
        image_path = local_image_file(game[:image]) || game[:image]
        width, height = resize_image(image: image_path)
        game_image = image image_path, height: height, width: width, margin_top: '15px'
        center(game_image)
      end
    end
  end
end

def handle_choose_game_button_press
  ensure_all_games_images_removed
  if @collection.nil? || @username_line.text != @username || @refresh_box.checked?
    @username = @username_line.text
    @refresh_collection = @refresh_box.checked?
    @collection = fetch_collection(refresh: @refresh_collection)
    return if @collection.nil?
    filter_games
  elsif @num_players != @number_of_players_list.text.to_i || @gameplay_time != @gameplay_time_list.text || @refresh_filter_box.checked?
    filter_games
  end

  @game_chooser.new_game
  update_filter_text
  @game_tag_line.text = 'Your Chosen Game Is...'
  @game_text.text = @game_chooser.game[:name]
  update_game_image
end
