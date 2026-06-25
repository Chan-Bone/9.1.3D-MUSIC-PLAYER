require './scripts/input_functions'
require './music_player'
#require './music_player_with_menu'
# you could use the input functions instead of puts and gets

def display_albums(library)

    if library != 0
      if library.albums.length() > 0
        finished = false
        begin 
          puts 'Display Albums Menu:'
          puts '1. Display All Albums'
          puts '2. Display Albums by Genre'
          puts '3. Return to Main Menu'
          choice = read_integer_in_range("Please enter your choice:", 1, 3)

          case choice
          when 1
            display_all_albums(library)
          when 2
            display_all_albums_by_genre(library)
          when 3
            finished = true
          else
            puts "Please select again"
          end 
        end until finished
      else
        puts("No albums found in library")
      end
    else
      puts("No Library loaded.")
    end
end

# For option 2
def display_all_albums(library)
  puts("")
  print_library(library)
end 

def display_all_albums_by_genre(library)
  genre_count = library.genres.length()
  if genre_count > 0
    index = 0
    puts("Available genres:")
    while index < genre_count
      puts("#{index+1}. #{Genre_names[library.genres[index]]}")
      index+=1
    end

    choice = read_integer_in_range("Please enter your choice:", 1, genre_count)
    puts("")
    print_library_by_genre(library, library.genres[choice-1])
  else
    puts("No genres found. Library is either invalid or has no albums")
  end
end 


def load_albums(library)
  path = read_string("Enter albums/library file path:").chomp()
  if File.exist?(path)
    library_file = File.new(path, "r")
    music_library = read_library(library_file)
    library_file.close()
    puts("Successfully loaded Library in path #{path}")
    #print_library(music_library)
    return music_library
  else
    puts("Cannot find File in path #{path}.")
    return 0
  end
end


def play_album(library)
  if (library != 0)
    if library.albums.length > 0
      choice = read_integer_in_range("Choose album by Id:", 1, library.albums.length)
      chosen_album = library.albums[choice-1]
      print_album_deep(chosen_album)
      if chosen_album.tracks.length > 0
        choice = read_integer_in_range("Choose track by Id:", 1, chosen_album.tracks.length) 
        this_track = chosen_album.tracks[choice-1]
        now_playing(this_track, chosen_album)
      else
        puts("This Album has no tracks. Skipping.")
      end
    else 
      puts("No albums found. Skipping.")
    end
  else 
    puts("No Library loaded.")
  end
end


def update_ratings(library)
  if (library != 0) 
      new_library = library
      finished = false
      begin
        puts 'Choose an album to Update Ratings:'
        album_count = new_library.albums.length
        index = 0
        while index < album_count
          puts("#{index+1}. \"#{new_library.albums[index].title}\" by #{new_library.albums[index].artist}  ")
          index+=1
        end
        puts "#{album_count+1}. Back to Main Menu" 
        choice = read_integer_in_range("Please enter your choice:", 1, album_count+1)
        if choice != album_count+1  
          new_library.albums[choice-1] = update_ratings_of_album(new_library.albums[choice-1])
        else
          finished = true
        end
      end until finished
      return new_library
    else 
    puts("No Library loaded.")
    return library
  end
end
    
def update_ratings_of_album(album)
  if album.tracks.length > 0
    new_album = album
    finished = false
    begin
      puts("Editing ratings of album \"#{new_album.title}\"")
      track_count = new_album.tracks.length
      index = 0
      while index < track_count
        puts("#{index+1}. \"#{new_album.tracks[index].name}\" [#{stars_of(new_album.tracks[index].rating)}]")
        index+=1
      end
      puts "#{track_count+1}. Select other albums/Return to menu" 
      choice = read_integer_in_range("Please enter your choice:", 1, track_count+1)
      if choice != track_count+1  
        new_album.tracks[choice-1].rating = read_float_in_range("Give new rating to #{new_album.tracks[choice-1].name} (0.0-5.0)", 0, 5)
      else
        finished = true
      end

    end until finished
    return new_album
  else
    puts("The Album \"#{album.title}\" has no tracks.")
    return album
  end
end


def main()
  finished = false
  library = 0
  begin
    puts 'Main Menu:'
    puts '1. Read in Albums'
    puts '2. Display Albums'
    puts '3. Select an Album to play'
    puts '4. Update Ratings'
    puts '5. Exit the application'
    choice = read_integer_in_range("Please enter your choice:", 1, 5)
    case choice
    when 1
      library = load_albums(library)
    when 2
      display_albums(library)
    when 3
      play_album(library)
    when 4
      library = update_ratings(library)
    when 5
      finished = true
    else
      puts "Please select again"
    end
  end until finished
end

main()
