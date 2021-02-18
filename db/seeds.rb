require "csv"

MovieGenre.delete_all
Genre.delete_all
Page.delete_all
Movie.delete_all
ProductionCompany.delete_all

Page.create(
  title:     "About Us",
  content:   "This is all about us.",
  permalink: "about_us"
)
Page.create(
  title:     "Information about our data",
  content:   "We stole....um.. borrowed the data from Kaggle..",
  permalink: "data_info"
)
# Rails.root... 0/db/top_movies.csv
filename = Rails.root.join("db/top_movies.csv")

puts "Importing CSV data form: #{filename}"

csv_data = File.read(filename)
movies = CSV.parse(csv_data, headers: true, encoding: "utf-8")

movies.each do |m|
  production_company = ProductionCompany.find_or_create_by(name: m["production_company"])

  if production_company&.valid?
    movie = production_company.movies.create(
      title:        m["original_title"],
      year:         m["year"],
      duration:     m["duration"],
      description:  m["description"],
      average_vote: m["avg_vote"]
    )
    unless movie&.valid?
      puts "Invalid movie #{m['original_title']}"
      next
    end
    # split on the comma, remove the white spaces (trim and strip)
    genres = m["genre"].split(",").map(&:strip)
    genres.each do |genre_name|
      genre = Genre.find_or_create_by(name: genre_name)
      MovieGenre.create(movie: movie, genre: genre)
    end

  else
    puts "Invalid Production Company: #{m['production_company']} for movie #{m['original_title']} "
  end
end
puts "Created #{ProductionCompany.count} Production Companies"
puts "Created #{Movie.count} Movies"
puts "Created #{Page.count} Pages"
puts "Created #{Genre.count} Genres"
puts "Created #{MovieGenre.count} MovieGenres"
