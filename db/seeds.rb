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
Quote.destroy_all

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
clients = [
  { first_name: 'Jean',      last_name: 'Durand',     address: '8 rue des Lilas',            city: 'Lyon',       postal_code: '69000' },
  { first_name: 'Claire',    last_name: 'Martin',     address: '12 avenue de la République', city: 'Paris',      postal_code: '75011' },
  { first_name: 'Thomas',    last_name: 'Lemoine',    address: '45 boulevard des Belges',    city: 'Lille',      postal_code: '59000' },
  { first_name: 'Sophie',    last_name: 'Moreau',     address: '78 rue Lafayette',           city: 'Toulouse',   postal_code: '31000' },
  { first_name: 'Luc',       last_name: 'Petit',      address: '5 impasse des Fleurs',       city: 'Marseille',  postal_code: '13006' },
  { first_name: 'Isabelle',  last_name: 'Bernard',    address: '33 rue du Faubourg',         city: 'Strasbourg', postal_code: '67000' },
  { first_name: 'Nicolas',   last_name: 'Roux',       address: '14 rue Victor Hugo',         city: 'Grenoble',   postal_code: '38000' },
  { first_name: 'Julie',     last_name: 'Blanc',      address: '21 allée des Cerisiers',     city: 'Nantes',     postal_code: '44000' },
  { first_name: 'Antoine',   last_name: 'Girard',     address: '9 rue de la Liberté',        city: 'Dijon',      postal_code: '21000' },
  { first_name: 'Camille',   last_name: 'Fabre',      address: '17 rue des Écoles',          city: 'Bordeaux',   postal_code: '33000' }
]

clients.each do |attrs|
  Client.create!(attrs.merge(company_id: company.id))
end

puts "Clients, users et sociétés créés"

# Create products associated with the company
# products = [
#   ["Peinture blanche mate", 9.00, "l"],
#   ["Peinture acrylique couleur", 13.00, "l"],
#   ["Sous-couche universelle", 5.00, "l"],
#   ["Enduit de lissage", 3.00, "kg"],
#   ["Enduit de rebouchage", 3.00, "kg"],
#   ["Bande à joint", 0.30, "m"],
#   ["Toile de verre à peindre", 1.00, "m²"],
#   ["Primaire d’accrochage", 7.00, "l"],
#   ["Peinture plafond blanche", 7.00, "l"],
#   ["Peinture cuisine & bain", 16.00, "l"],
#   ["Bâche de protection", 1.50, "m²"],
#   ["Ruban de masquage", 0.07, "m"],
#   ["Manche télescopique", 12.00, "u"],
#   ["Rouleau à peinture", 7.90, "u"],
#   ["Monture rouleau", 4.50, "u"],
#   ["Bac à peinture", 3.90, "u"],
#   ["Spalter (pinceau large)", 6.80, "u"],
#   ["Grille essoreuse", 2.90, "u"],
#   ["Cutter de chantier", 4.50, "u"],
#   ["Combinaison jetable", 4.00, "u"],
#   ["Préparation des murs", 40.00, "h"],
#   ["Ponçage des murs", 35.00, "h"],
#   ["Pose de bandes à joint", 38.00, "h"],
#   ["Application d’enduit", 42.00, "h"],
#   ["Ponçage après enduit", 35.00, "h"],
#   ["Protection chantier", 30.00, "h"],
#   ["Application de sous-couche", 45.00, "h"],
#   ["Peinture (1re couche)", 50.00, "h"],
#   ["Peinture (2e couche)", 45.00, "h"],
#   ["Finitions et retouches", 40.00, "h"]
# ]

# products.each do |name, price, unit|
#   Product.create!(
#     name: name,
#     price: price,
#     unit: unit,
#     company: company
#   )
# end

# puts "#{products.size} produits créés pour #{company.name}"


quotes_data = [
  { title: 'Rénovation cuisine',         validity_duration: '30 jours', execution_delay: '2 semaines', payment_terms: '30% à la commande, solde à la livraison' },
  { title: 'Peinture appartement',       validity_duration: '15 jours', execution_delay: '1 semaine',  payment_terms: '50% à l’avance, 50% fin de chantier' },
  { title: 'Installation parquet',       validity_duration: '20 jours', execution_delay: '10 jours',   payment_terms: 'Paiement à réception' },
  { title: 'Isolation combles',          validity_duration: '30 jours', execution_delay: '3 semaines', payment_terms: '30% acompte, 70% fin travaux' },
  { title: 'Création salle de bain',     validity_duration: '45 jours', execution_delay: '1 mois',     payment_terms: '50/50' },
  { title: 'Pose carrelage terrasse',    validity_duration: '20 jours', execution_delay: '2 semaines', payment_terms: 'Paiement à la fin' },
  { title: 'Ravalement façade',          validity_duration: '30 jours', execution_delay: '3 semaines', payment_terms: '40% à la commande, reste à la fin' },
  { title: 'Remplacement fenêtres',      validity_duration: '15 jours', execution_delay: '2 semaines', payment_terms: '100% à la fin' },
  { title: 'Climatisation maison',       validity_duration: '30 jours', execution_delay: '1 mois',     payment_terms: 'Paiement en 2 fois' },
  { title: 'Terrassement jardin',        validity_duration: '25 jours', execution_delay: '10 jours',   payment_terms: '30/70' }
]

clients = Client.all

quotes_data.each_with_index do |quote_attrs, index|
  Quote.create!(
    title: quote_attrs[:title],
    client_id: clients[index].id,
    company_id: clients[index].company_id,
    status: 0, # ou un autre statut si tu en as d’autres
    validity_duration: quote_attrs[:validity_duration],
    execution_delay: quote_attrs[:execution_delay],
    payment_terms: quote_attrs[:payment_terms]
  )
end

# --- Crée 10 produits s’il n’y en a pas encore ---
if Product.count == 0
  product_data = [
    { name: 'Pose de carrelage', price: 80, unit: 'm²' },
    { name: 'Peinture murale', price: 25, unit: 'm²' },
    { name: 'Installation parquet', price: 70, unit: 'm²' },
    { name: 'Main d’œuvre', price: 50, unit: 'h' },
    { name: 'Isolation thermique', price: 60, unit: 'm²' },
    { name: 'Dépose revêtement', price: 30, unit: 'm²' },
    { name: 'Raccord plomberie', price: 90, unit: 'u' },
    { name: 'Nettoyage chantier', price: 120, unit: 'u' },
    { name: 'Installation WC suspendu', price: 350, unit: 'u' },
    { name: 'Cloison placo', price: 45, unit: 'm²' }
  ]

  product_data.each do |prod|
    Product.create!(
      name: prod[:name],
      price: prod[:price],
      unit: prod[:unit],
      company_id: Company.first.id
    )
  end
end

products = Product.all
quotes = Quote.all

quotes.each_with_index do |quote, index|
  # Crée une section pour chaque devis
  section = Section.create!(
    quote_id: quote.id,
    description: "Travaux - Lot ##{index + 1}"
  )

  # Ajoute 5 lignes de produits à cette section
  5.times do
    product = products.sample
    quantity = rand(1..10)

    LineItem.create!(
      section_id: section.id,
      description: product.name,
      quantity: quantity,
      unit: product.unit,
      price_per_unit: product.price,
      price: (product.price * quantity).round(2)
    )
  end
end
