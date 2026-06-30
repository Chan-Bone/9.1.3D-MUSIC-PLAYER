#require './input_functions'
#require './menu'

# Use the code from last week's tasks to complete this:
# eg: 6.2, 3.1T




module Genre
  POP, CLASSIC, JAZZ, ROCK = *1..4
end

Genre_names = ['Null', 'Pop', 'Classic', 'Jazz', 'Rock'].freeze

class Library 
    attr_accessor :albums, :genres
    
    def initialize (albums) 
      @albums = albums
      @genres = []
    end

    def add_genre(genre)
      if !@genres.include?(genre)
        @genres << genre
      end
      ## Ignore otherwise if already included
    end
end

class Album
# NB: you will need to add tracks to the following and the initialize()
	attr_accessor :title, :artist, :genre, :tracks, :recording_type, :album_art

# complete the missing code:
	def initialize (artist, title, recording_type, genre, tracks, album_art)
		@artist = artist
    @title = title
		@recording_type = recording_type
    @genre = genre
    @tracks = tracks
    @album_art = album_art
	end
end

class Track
	attr_accessor :name, :location, :duration, :rating

	def initialize (name, location, rating )
		@name = name
		@location = location
    @duration = "3:00" 
    @rating = rating
	end
end

# Reads in and returns a single track from the given file

def read_track(music_file)
	contents = [music_file.gets().to_s().chomp, music_file.gets().chomp.to_s, music_file.gets().chomp.to_f]
  return Track.new(contents[0], contents[1], contents[2])
end

# Returns an array of tracks read from the given file

def read_tracks(music_file)
	count = music_file.gets().to_i()
  tracks = Array.new()
  index = 0
  while index < count
# Put a while loop here which increments an index to read the track
    track = read_track(music_file)
    tracks << track
    index+=1
  end
	return tracks
end

# Takes an array of tracks and prints them to the terminal  

def print_tracks(tracks)
	# print all the tracks use: tracks[x] to access each track.
  track_count = tracks.length
  puts("#{track_count} tracks :")
  index = 0
  while index < track_count 
    puts("[ Track #{index+1} ]")
    current_track = tracks[index]
    print_track(current_track)
    index+=1
  end
end

# Takes a single track and prints it to the terminal
def print_track(track)
  puts(" | Name     : #{track.name} [#{stars_of(track.rating)}]")
  puts(" | Duration : #{track.duration}")
  puts(" | Location : #{track.location}")
end

def stars_of(rating)
  star_count = [rating.round(), 5].min
  empty = 5-star_count
  output = "#{format("%.1f", rating)} "
  while star_count > 0
    output += "✭"
    star_count-=1
  end
  while empty > 0
    output += "✰"
    empty-=1
  end
  return output

end

# Reads in and returns a single album from the given file, with all its tracks

def read_album(music_file)
  
  album_artist = music_file.gets().to_s().chomp
  album_title = music_file.gets().to_s().chomp 
  recording_type = music_file.gets().to_s().chomp 
  album_genre = music_file.gets().chomp().to_i
  album_art = music_file.gets().to_s().chomp 
  tracks = read_tracks(music_file)
  # read in all the Album's fields/attributes including all the tracks
  # complete the missing code

	album = Album.new(album_artist, album_title, recording_type, album_genre, tracks, album_art)
	return album
end

def get_album_average_rating(album)
  avg_rating = 0

  count = album.tracks.length
  index = 0

  while index < count
    avg_rating += album.tracks[index].rating
    index+=1
  end

  if avg_rating > 0
    avg_rating /= count
  end
  
  return avg_rating
end

# Takes a single album and prints it to the terminal along with all its tracks
def print_album(album)
  puts("Title  : #{album.title} [#{stars_of(get_album_average_rating(album))}]")
  puts("Artist : #{album.artist}")
	puts("Genre  : #{Genre_names[album.genre]} (Code #{album.genre.to_s})")
	puts("Length : #{album.tracks.length()} Track(s)")
  puts("")
end

def print_album_deep(album)
  puts("Title  : #{album.title} [#{stars_of(get_album_average_rating(album))}]")
  puts("Artist : #{album.artist}")
	puts("Genre  : #{Genre_names[album.genre]} (Code #{album.genre.to_s})")
	puts("Length : #{album.tracks.length()} Track(s)")
  print_tracks(album.tracks)
  puts("")
end

# Reads in an album from a file and then print the album to the terminal

def read_library(library_file) 
  albums_library = []

  number_of_albums = library_file.gets().chomp.to_i
  index = 0
  while index < number_of_albums 
	  album = read_album(library_file)
    albums_library << album 
    index+=1
  end

  lib = Library.new(albums_library)
  index = 0
  while index < number_of_albums
    alb = lib.albums
    current_album = alb[index]
    lib.add_genre(current_album.genre)
    index+=1
  end
	return lib
end

def print_library(library) 
    albums = library.albums
    count = albums.length()
    index = 0
    while index < count
      this_album = albums[index]
      puts("{ ALBUM #{index+1} }")
      print_album(this_album)
      index+=1
    end
end



def print_library_by_genre(library, genre) 
    albums = library.albums
    count = albums.length()
    index = 0
    puts("Albums with genre \"#{Genre_names[genre]}\":")
    while index < count
      this_album = albums[index]
      if this_album.genre == genre
        puts("{ ALBUM #{index+1} }")
        print_album(this_album)
      end
      index+=1
    end
end

def now_playing(track, album)
  puts("Playing track \"#{track.name}\" from album \"#{album.title}\".")
  puts("")
  sleep(3)
end

def test()
	library_file = File.new("albums.txt", "r")
  music_library = read_library(library_file)
  library_file.close()

	print_library(music_library)
end