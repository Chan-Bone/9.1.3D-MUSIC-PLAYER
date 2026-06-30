require 'rubygems'
require 'gosu'
require './scripts/music_player.rb'

TOP_COLOR = Gosu::Color.new(0xFF1EB1FA)
BOTTOM_COLOR = Gosu::Color.new(0xFF1D4DB5)

class MenuMode
	BROWSE_ALBUMS = 0
	BROWSE_TRACKS = 1
end

class ArtWork
	attr_accessor :bmp, :x, :y, :width

	def initialize (file, x, y, width)
		@bmp = Gosu::Image.new(file)
		@x, @y = x, y
		@width = width
	end

	def draw(player)
		draw_image_consistent(@x, @y, @width)
	end

	def draw_image_consistent(x, y, target_width)
	    # Calculate a uniform scale based on the target width
	    scale_factor = target_width.to_f / @bmp.width
	    new_height = @bmp.height * scale_factor

	    @bmp.draw(x, y, 1, scale_factor, scale_factor)
	end
end

# Put your record definitions here

class MusicPlayerMain < Gosu::Window
	attr_accessor :album_show_limit 

	def initialize
	    super 600, 800
	    self.caption = "Music Player"
		lib_path = "albums.txt"
		
		

		@track_font = Gosu::Font.new(20)

		@button_sets = []
		#Position = Top left of image
		@album_arts = []
		#@album_arts << ArtWork.new("album/moe shop/moe_shop.png", 0, 100, 200)
		
		library_file = File.new(lib_path, "r")
		@music_library = read_library(library_file)
		library_file.close()
		
		@album_show_limit = [0, 4]
		display_albums()
 

		@song = 0
		@menu_mode = MenuMode::BROWSE_ALBUMS
		
		@background_color = Gosu::Color.new(255, 20, 20, 20) 

		
		
		print_library(@music_library)
		# Reads in an array of albums from a file and then prints all the albums in the
		# array to the terminal
	end

  # Put in your code here to load albums and tracks

  # Draws the artwork on the screen for all the albums

  def display_albums()
	@button_sets.clear
	index = @album_show_limit[0]
	total = [@music_library.albums.length, @album_show_limit[1]].min
	
	while index < total
		this_album = @music_library.albums[index]

		if (index % 2 ) == 0 #is even -> right
			x_pos = 310
		else
			x_pos = 40
		end
		y_off = index -  @album_show_limit[0]
		y_pos = 40
		while y_off >= 2
			y_pos += 270
			y_off -= 2
		end
		#@button_sets << AlbumButton.new(40, 80, 250, "ado", "album/ado/cover.png")
		#@button_sets << AlbumButton.new(310, 80, 250, "ado", "album/ado/cover.png")

		@button_sets << AlbumButton.new(
			x_pos, y_pos, 
			250, #width
			this_album.title, 
			this_album.album_art,
			index
		)


		if @album_show_limit[1] < @music_library.albums.length 
			@button_sets << Next.new(800-100)
		end
		if @album_show_limit[0] > 0
			@button_sets << Previous.new(800-100)
		end
		index += 1
	end
  end

  def display_an_album(album_idx)
	this_album = @music_library.albums[album_idx]
	@button_sets.clear
	#print_album_deep(this_album)
	length = this_album.tracks.length
	index = 0
	topY = 20
	while index < length
		this_track = this_album.tracks[index]
		@button_sets << SongButton.new(topY, this_track.name, this_track.location)
		topY+= 40
		index+=1
	end

	@button_sets << GoBackAlbums.new(800-50)
	#SongButton.new(topY, song_title ,song_location)

  end

  
  def is_within(leftX, topY, rightX, bottomY)
	within = false
	if (mouse_x >= leftX) && (mouse_x <= rightX) && (mouse_y >= topY) && (mouse_y <= bottomY)
		within = true
	end
	return within
  end

  def display_text(title, xpos, ypos)
  	@track_font.draw_text(title, xpos, ypos, 2, 1.0, 1.0, Gosu::Color::BLACK)
  end


  # Takes a track index and an Album and plays the Track from the Album

  def playTrack(track_path, name)
  	 # complete the missing code
		@song = Gosu::Song.new(track_path)
		@song.play(false)

		@button_sets.delete(@button_sets.find { |obj| obj.is_a?(NowPlaying) })
		@button_sets << NowPlaying.new(800-100, name)
    # Uncomment the following and indent correctly:
  	#	end
  	# end
  end

  def stop_music()
	if @song != 0
		@song.stop
	end
  end
# Draw a coloured background using TOP_COLOR and BOTTOM_COLOR

	def draw_background
		Gosu::draw_quad(
			0, 0, 
			@background_color, 
			
			600, 0, 
			@background_color, 
			
			600, 800, 
			@background_color, 
			
			0, 800, 
			@background_color, 
		1)
	end

# Not used? Everything depends on mouse actions.

	def update
		@button_sets.each do |button|
			button.is_being_hovered(self)
		end
	end

 # Draws the album images and the track list for the selected album

	def draw

		# Draw background
		draw_background

		@button_sets.each do |button|
			button.draw(self)
		end

		@album_arts.each do |art|   
			art.draw(self)
		end
		#draw_background
	end

 	def needs_cursor?; true; end

	# If the button area (rectangle) has been clicked on change the background color
	# also store the mouse_x and mouse_y attributes that we 'inherit' from Gosu
	# you will learn about inheritance in the OOP unit - for now just accept that
	# these are available and filled with the latest x and y locations of the mouse click.

	def button_down(id)
		case id
		when Gosu::MsLeft
			@button_sets.each do |button|
				if button.is_being_hovered(self) == true then
					button.on_clicked(self)
				end
			end
		when Gosu::KB_ESCAPE
			close #Shut the player
		end
	end

end

class Button 
	attr_accessor :leftX, :topY, :rightX, :bottomY, :is_hovered, :is_clicked
	def initialize(leftX, topY, rightX, bottomY)

		@leftX, @topY, @rightX, @bottomY = leftX, topY, rightX, bottomY
		
		@neutral_color = Gosu::Color.new(255, 100, 100, 100) 
		@hover_color   = Gosu::Color.new(255, 165, 165, 165) 
		@pressed_color = Gosu::Color.new(255, 230, 230, 230) 

		@is_clicked, @is_hovered = false, false
		@clicked_duration = 100

		@click_start_time = Gosu.milliseconds - @clicked_duration
	end

	def is_being_hovered(player)
		hover = player.is_within(@leftX, @topY, @rightX, @bottomY)
		@is_hovered = hover
		return hover
  	end

	def on_clicked(player)
		@click_start_time = Gosu.milliseconds
		puts("#{self} was clicked")
	end

	def was_clicked
        elapsed = (Gosu.milliseconds - @click_start_time)
		am_i_still_click = false
		
		if elapsed <= @clicked_duration then
			am_i_still_click = true
		end
        return am_i_still_click
    end

	def draw(player)
		_color = @neutral_color
		if @is_hovered then 
			_color = @hover_color
		end
		if was_clicked then
			_color = @pressed_color
		end

		Gosu::draw_quad(
			leftX, topY, 
			_color, 
			
			rightX, topY, 
			_color, 
			
			rightX, bottomY, 
			_color, 
			
			leftX, bottomY, 
			_color, 
		1)
	end
end

class AlbumButton < Button
	attr_accessor :title, :y, :album, :artwork, :index_id

	def initialize(leftX, topY, width, album, artwork_path, index_id)
		@leftX, @topY, @rightX, @bottomY = leftX, topY, leftX+width, topY+width
		@album = album
		# file, x, y, width
		@artwork = ArtWork.new(artwork_path, leftX, topY, width)
		@index_id = index_id
	end

	def on_clicked(player)
		@click_start_time = Gosu.milliseconds
		player.display_an_album(index_id)

		puts("Selected album #{@album}")
	end

	def draw(player)
		@artwork.draw(player)
	end
end

class SongButton < Button
	attr_accessor :title, :y, :location
	
	def initialize(topY, song_title ,song_location)

		@title = song_title
		@location = song_location.to_s

		_side_padding = 10
		_height = 30
		@leftX, @topY, @rightX, @bottomY = _side_padding, topY, 600-_side_padding, topY+_height
		
		@neutral_color = Gosu::Color.new(255, 100, 100, 100) 
		@hover_color   = Gosu::Color.new(255, 165, 165, 165) 
		@pressed_color = Gosu::Color.new(255, 230, 230, 230) 

		@is_clicked, @is_hovered = false, false
		@clicked_duration = 100

		@click_start_time = Gosu.milliseconds - @clicked_duration
	end

	def draw(player)

		player.display_text(@title, 20, @topY+8)
		_color = @neutral_color
		if @is_hovered then 
			_color = @hover_color
		end
		if was_clicked then
			_color = @pressed_color
		end

		Gosu::draw_quad(
			leftX, topY, 
			_color, 
			
			rightX, topY, 
			_color, 
			
			rightX, bottomY, 
			_color, 
			
			leftX, bottomY, 
			_color, 
		1)
	end

	def on_clicked(player)
		@click_start_time = Gosu.milliseconds
		
		player.playTrack(@location, @title)
		puts("Started playing #{@title}")
	end

	

end

class GoBackAlbums < Button
	attr_accessor :title, :y
	
	def initialize(topY)
		@topY = topY
		@title = "Return to Albums"

		_side_padding = 10
		_height = 30
		@leftX, @topY, @rightX, @bottomY = _side_padding, topY, 600-_side_padding, topY+_height
		
		@neutral_color = Gosu::Color.new(255, 100, 100, 100) 
		@hover_color   = Gosu::Color.new(255, 165, 165, 165) 
		@pressed_color = Gosu::Color.new(255, 230, 230, 230) 

		@is_clicked, @is_hovered = false, false
		@clicked_duration = 100

		@click_start_time = Gosu.milliseconds - @clicked_duration
	end
	

	def on_clicked(player)
		@click_start_time = Gosu.milliseconds
		
		player.display_albums()
		player.stop_music()
		puts("Return to album")
	end

	def draw(player)

		player.display_text(@title, 20, @topY+8)
		_color = @neutral_color
		if @is_hovered then 
			_color = @hover_color
		end
		if was_clicked then
			_color = @pressed_color
		end

		Gosu::draw_quad(
			leftX, topY, 
			_color, 
			
			rightX, topY, 
			_color, 
			
			rightX, bottomY, 
			_color, 
			
			leftX, bottomY, 
			_color, 
		1)
	end

end


class NowPlaying < Button
	attr_accessor :title, :y
	
	def initialize(topY, title)
		@topY = topY
		@title = "Now playing #{title}."

		_side_padding = 10
		_height = 30
		@leftX, @topY, @rightX, @bottomY = _side_padding, topY, 600-_side_padding, topY+_height

		@clicked_duration = 100
		@click_start_time = Gosu.milliseconds - @clicked_duration
		@is_clicked, @is_hovered = false, false
		
		@neutral_color = Gosu::Color.new(255, 100, 100, 100) 
	end
	

	def on_clicked(player)

	end

	def draw(player)

		player.display_text(@title, 20, @topY+8)

		_color = @neutral_color

		Gosu::draw_quad(
			leftX, topY, 
			_color, 
			
			rightX, topY, 
			_color, 
			
			rightX, bottomY, 
			_color, 
			
			leftX, bottomY, 
			_color, 
		1)
	end

end



class Previous < Button
	attr_accessor :title, :y
	
	def initialize(topY)
		@topY = topY
		@title = "<"

		_side_padding = 10
		_height = 30
		# WIdth 600
		@leftX, @topY, @rightX, @bottomY = _side_padding, topY, _side_padding+_height, topY+_height

		@is_clicked, @is_hovered = false, false
		@clicked_duration = 100

		@click_start_time = Gosu.milliseconds - @clicked_duration
		@neutral_color = Gosu::Color.new(255, 100, 100, 100) 
		@hover_color   = Gosu::Color.new(255, 165, 165, 165) 
		@pressed_color = Gosu::Color.new(255, 230, 230, 230) 

		

		@click_start_time = Gosu.milliseconds - @clicked_duration
	end
	

	def on_clicked(player)
		#[4, 8]
		
			player.album_show_limit[0] -= 4
			player.album_show_limit[1] -= 4
		
		player.display_albums()
	end

	def draw(player)

		player.display_text(@title, 20, @topY+8)

		_color = @neutral_color
		if @is_hovered then 
			_color = @hover_color
		end
		if was_clicked then
			_color = @pressed_color
		end

		Gosu::draw_quad(
			leftX, topY, 
			_color, 
			
			rightX, topY, 
			_color, 
			
			rightX, bottomY, 
			_color, 
			
			leftX, bottomY, 
			_color, 
		1)
	end

end

class Next < Button
	attr_accessor :title, :y
	
	def initialize(topY)
		@topY = topY
		@title = ">"

		_side_padding = 10
		_height = 30
		# WIdth 600
		@leftX, @topY, @rightX, @bottomY = 600- _height -_side_padding, topY, 600 -_side_padding, topY+_height

		@clicked_duration = 100
		@click_start_time = Gosu.milliseconds - @clicked_duration
		@neutral_color = Gosu::Color.new(255, 100, 100, 100) 
		@hover_color   = Gosu::Color.new(255, 165, 165, 165) 
		@pressed_color = Gosu::Color.new(255, 230, 230, 230) 

		@is_clicked, @is_hovered = false, false
		

		@click_start_time = Gosu.milliseconds - @clicked_duration
	end
	

	def on_clicked(player)
		#[4, 8]
		
			player.album_show_limit[0] += 4
			player.album_show_limit[1] += 4
		
		player.display_albums()
	end

	def draw(player)

		player.display_text(@title, 600-30, @topY+8)

		_color = @neutral_color
		if @is_hovered then 
			_color = @hover_color
		end
		if was_clicked then
			_color = @pressed_color
		end

		Gosu::draw_quad(
			leftX, topY, 
			_color, 
			
			rightX, topY, 
			_color, 
			
			rightX, bottomY, 
			_color, 
			
			leftX, bottomY, 
			_color, 
		1)
	end

end



# Show is a method that loops through update and draw

MusicPlayerMain.new.show if __FILE__ == $0
