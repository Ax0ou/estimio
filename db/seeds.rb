# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ['Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

Client.destroy_all
User.destroy_all
Company.destroy_all

company = Company.create!(
  name: 'Toitures Alvarade',
  siret: '12345678900013',
  tva_number: 'FR12345678901',
  number_of_employees: 10,
  address: '12 rue du zinc, 75000 Paris',
  city: 'Paris',
  postal_code: '75000'
)

# Create a user associated with the company
User.create!(
  email: 'test@testor.com',
  password: '123456',
  first_name: 'Jean',
  last_name: 'Alvarade',
  phone_number: '+33612345678',
  company_id: company.id
)

# Create a client associated with the user
Client.create!(
  first_name: 'Jean',
  last_name: 'Durand',
  address: '8 rue des Lilas, 69000 Lyon',
  city: 'Lyon',
  postal_code: '69000',
  company_id: company.id
)
