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
Quote.destroy_all
Section.destroy_all
LineItem.destroy_all
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

# Create products associated with the company
products = [
  ["Peinture blanche mate", 50, "l"],
  ["Peinture acrylique couleur", 40, "l"],
  ["Sous-couche universelle", 54, "l"],
  ["Enduit de lissage", 32, "kg"],
  ["Enduit de rebouchage", 54, "kg"],
  ["Bande à joint", 32, "m"],
  ["Toile de verre à peindre", 142, "m²"]
]

products.each do |name, price, unit|
  Product.create!(
    name: name,
    price: price,
    unit: unit,
    company: company
  )
end

# Create 10 clients
clients = [
  { first_name: 'Jean', last_name: 'Durand', address: '8 rue des Lilas', city: 'Lyon', postal_code: '69000', phone_number: '+33612345678', email: 'jean.durand@email.com' },
  { first_name: 'Marie', last_name: 'Martin', address: '15 avenue des Roses', city: 'Paris', postal_code: '75001', phone_number: '+33623456789', email: 'marie.martin@email.com' },
  { first_name: 'Pierre', last_name: 'Dubois', address: '23 rue des Chênes', city: 'Marseille', postal_code: '13001', phone_number: '+33634567890', email: 'pierre.dubois@email.com' },
  { first_name: 'Sophie', last_name: 'Leroy', address: '45 boulevard des Fleurs', city: 'Bordeaux', postal_code: '33000', phone_number: '+33645678901', email: 'sophie.leroy@email.com' },
  { first_name: 'Lucas', last_name: 'Moreau', address: '12 rue des Oliviers', city: 'Nice', postal_code: '06000', phone_number: '+33656789012', email: 'lucas.moreau@email.com' },
  { first_name: 'Emma', last_name: 'Petit', address: '78 avenue des Pins', city: 'Toulouse', postal_code: '31000', phone_number: '+33667890123', email: 'emma.petit@email.com' },
  { first_name: 'Thomas', last_name: 'Robert', address: '34 rue des Platanes', city: 'Lille', postal_code: '59000', phone_number: '+33678901234', email: 'thomas.robert@email.com' },
  { first_name: 'Julie', last_name: 'Richard', address: '56 boulevard des Tilleuls', city: 'Nantes', postal_code: '44000', phone_number: '+33689012345', email: 'julie.richard@email.com' },
  { first_name: 'Nicolas', last_name: 'Simon', address: '89 rue des Érables', city: 'Strasbourg', postal_code: '67000', phone_number: '+33690123456', email: 'nicolas.simon@email.com' },
  { first_name: 'Laura', last_name: 'Michel', address: '67 avenue des Châtaigniers', city: 'Montpellier', postal_code: '34000', phone_number: '+33601234567', email: 'laura.michel@email.com' }
]

clients.each do |client_data|
  Client.create!(
    client_data.merge(company_id: company.id)
  )
end

# Create quotes for each client
quote_titles = [
  'Rénovation complète',
  'Travaux de peinture',
  'Rénovation cuisine',
  'Travaux salle de bain',
  'Rénovation salon',
  'Travaux chambre',
  'Rénovation bureau',
  'Travaux couloir',
  'Rénovation entrée',
  'Travaux divers'
]

Client.all.each do |client|
  quote = Quote.create!(
    title: quote_titles.sample,
    client: client,
    company: company,
    status: [0, 1, 2].sample,
    validity_duration: '30 jours',
    execution_delay: '2 semaines',
    payment_terms: 'À 30 jours'
  )

  # Create a section for each quote
  section = Section.create!(
    quote: quote,
    description: "Section principale - #{quote.title}"
  )

  # Create 5 line items for each section
  5.times do |i|
    product = Product.all.sample
    quantity = rand(5..10)
    price_per_unit = product.price
    total_price = price_per_unit * quantity

    LineItem.create!(
      section: section,
      description: product.name,
      quantity: quantity,
      price: total_price,
      price_per_unit: price_per_unit,
      position: i + 1,
      unit: product.unit
    )
  end
end

puts "Seed completed successfully!"
puts "#{Client.count} clients created"
puts "#{Quote.count} quotes created"
puts "#{Section.count} sections created"
puts "#{LineItem.count} line items created"
