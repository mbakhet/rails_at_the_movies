require "csv"

Movie.delete_all
ProductionCompany.delete_all

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
  else
    puts "Invalid Production Company: #{m['production_company']} for movie #{m['original_title']} "
  end
end
puts "Created #{ProductionCompany.count} Production Companies"
puts "Created #{Movie.count} Movies"
