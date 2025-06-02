1# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

user = User.create!(
  email: "test@test.com",
  password: "123456",
  first_name: "Jean",
  last_name: "Alvarade",
  siret: "12345678900013",
  company_name: "Toitures Alvarade",
  address: "12 rue du zinc, 75000 Paris",
  phone_number: "+33612345678"
)

client = Client.create!(
  first_name: "Jean",
  last_name: "Durand",
  address: "8 rue des Lilas, 69000 Lyon",
  user_id: user.id
)
