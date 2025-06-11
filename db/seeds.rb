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
Product.destroy_all

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

puts "Clients, users et sociétés créés"

# Create products associated with the company
products = [
  ["Peinture blanche mate", 9.00, "l"],
  ["Peinture acrylique couleur", 13.00, "l"],
  ["Sous-couche universelle", 5.00, "l"],
  ["Enduit de lissage", 3.00, "kg"],
  ["Enduit de rebouchage", 3.00, "kg"],
  ["Bande à joint", 0.30, "m"],
  ["Toile de verre à peindre", 1.00, "m²"],
  ["Primaire d’accrochage", 7.00, "l"],
  ["Peinture plafond blanche", 7.00, "l"],
  ["Peinture cuisine & bain", 16.00, "l"],
  ["Bâche de protection", 1.50, "m²"],
  ["Ruban de masquage", 0.07, "m"],
  ["Manche télescopique", 12.00, "u"],
  ["Rouleau à peinture", 7.90, "u"],
  ["Monture rouleau", 4.50, "u"],
  ["Bac à peinture", 3.90, "u"],
  ["Spalter (pinceau large)", 6.80, "u"],
  ["Grille essoreuse", 2.90, "u"],
  ["Cutter de chantier", 4.50, "u"],
  ["Combinaison jetable", 4.00, "u"],
  ["Préparation des murs", 40.00, "h"],
  ["Ponçage des murs", 35.00, "h"],
  ["Pose de bandes à joint", 38.00, "h"],
  ["Application d’enduit", 42.00, "h"],
  ["Ponçage après enduit", 35.00, "h"],
  ["Protection chantier", 30.00, "h"],
  ["Application de sous-couche", 45.00, "h"],
  ["Peinture (1re couche)", 50.00, "h"],
  ["Peinture (2e couche)", 45.00, "h"],
  ["Finitions et retouches", 40.00, "h"]
]

products.each do |name, price, unit|
  Product.create!(
    name: name,
    price: price,
    unit: unit,
    company: company
  )
end

puts "#{products.size} produits créés pour #{company.name}"
