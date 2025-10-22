# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# db/seeds.rb

# -----------------------------
# Default user (Rails 8 auth)
# -----------------------------
user = User.find_or_initialize_by(email_address: "bnjtgly@gmail.com")
user.password = "abc123ABC"
user.password_confirmation = "abc123ABC"
user.save!
puts "Seeded user: #{user.email_address}"


# -----------------------------
# Patients
# -----------------------------
patients = [
  {
    first_name: "Ahyeon", last_name: "Jung",
    date_of_birth: Date.new(2007, 4, 11), gender: "female",
    email: "ahyeon@example.com", phone_number: "000-000-0001",
    address: "South Korea", city: "Seoul"
  },
  {
    first_name: "Pharita", last_name: "Boonpakdeethaveeyod",
    date_of_birth: Date.new(2005, 8, 26), gender: "female",
    email: "pharita@example.com", phone_number: "000-000-0002",
    address: "Thailand", city: "Bangkok"
  },
  {
    first_name: "Chiquita", last_name: "Phondechaphiphat",
    date_of_birth: Date.new(2009, 2, 17), gender: "female",
    email: "chiquita@example.com", phone_number: "000-000-0003",
    address: "Thailand", city: "Bangkok"
  },
  {
    first_name: "Rora", last_name: "Lee",
    date_of_birth: Date.new(2008, 8, 14), gender: "female",
    email: "rora@example.com", phone_number: "000-000-0004",
    address: "South Korea", city: "Seoul"
  },
  {
    first_name: "Asa", last_name: "Enami",
    date_of_birth: Date.new(2006, 4, 17), gender: "female",
    email: "asa@example.com", phone_number: "000-000-0005",
    address: "Japan", city: "Tokyo"
  }
]

patients.each do |attrs|
  p = Patient.find_or_initialize_by(email: attrs[:email])
  p.update!(attrs)
end
puts "Seeded #{Patient.count} patients."

# -----------------------------
# Medicines
# -----------------------------

# db/seeds.rb

puts "Seeding medicines..."

medicines = [
  { item_code: "MED-0001", drug_name: "Paracetamol",   generic_name: "Acetaminophen", form: "Tablet",    strength: "500 mg",     route: "PO", unit: "tab",    unit_price_cents: 150 },
  { item_code: "MED-0002", drug_name: "Ibuprofen",     generic_name: "Ibuprofen",     form: "Tablet",    strength: "200 mg",     route: "PO", unit: "tab",    unit_price_cents: 220 },
  { item_code: "MED-0003", drug_name: "Amoxicillin",   generic_name: "Amoxicillin",   form: "Capsule",   strength: "500 mg",     route: "PO", unit: "cap",    unit_price_cents: 850 },
  { item_code: "MED-0004", drug_name: "Cefuroxime",    generic_name: "Cefuroxime",    form: "Tablet",    strength: "500 mg",     route: "PO", unit: "tab",    unit_price_cents: 1650 },
  { item_code: "MED-0005", drug_name: "Metformin",     generic_name: "Metformin",     form: "Tablet",    strength: "500 mg",     route: "PO", unit: "tab",    unit_price_cents: 120 },
  { item_code: "MED-0006", drug_name: "Omeprazole",    generic_name: "Omeprazole",    form: "Capsule",   strength: "20 mg",      route: "PO", unit: "cap",    unit_price_cents: 300 },
  { item_code: "MED-0007", drug_name: "Salbutamol",    generic_name: "Albuterol",     form: "Nebule",    strength: "2.5 mg/2.5 mL", route: "INH", unit: "nebule", unit_price_cents: 950 },
  { item_code: "MED-0008", drug_name: "Hydrocortisone",generic_name: "Hydrocortisone",form: "Injection", strength: "100 mg/vial", route: "IV", unit: "vial",   unit_price_cents: 1850 },
  { item_code: "MED-0009", drug_name: "Diazepam",      generic_name: "Diazepam",      form: "Injection", strength: "10 mg/2 mL", route: "IV", unit: "amp",    unit_price_cents: 760 },
  { item_code: "MED-0010", drug_name: "ORS",           generic_name: "Oral Rehydration Salts", form: "Powder", strength: "1 sachet", route: "PO", unit: "sachet", unit_price_cents: 180 }
]

Medicine.transaction do
  medicines.each do |attrs|
    med = Medicine.find_or_initialize_by(item_code: attrs[:item_code])
    med.assign_attributes(attrs.merge(active: true))
    med.save!
  end
end

puts "Seeded #{Medicine.count} medicines total."

# -----------------------------
# Charge Categories & Items
# -----------------------------

def seed_category(name, items, position)
  key = name.parameterize.underscore
  category = ChargeCategory.find_or_create_by!(key: key) do |c|
    c.name = name
    c.position = position
  end
  # keep name/position up to date if changed
  category.update!(name: name, position: position) if category.name != name || category.position != position

  items.each_with_index do |item_name, idx|
    ChargeItem.find_or_create_by!(charge_category_id: category.id, name: item_name) do |item|
      item.unit = ""                    # set default (e.g., "pc") if desired
      item.default_price_cents = rand(1000..10000)
      item.position = idx + 1
      item.active = true
    end
  end
end

SECTIONS = [
  ["Prep", [
    "Skin Prep",
    "Betadine Prep S/M/L",
    "Prep Tray",
    "Cutasept / use",
    "Disp. Razor",
    "Gloves Examination",
    "Lubricating Gel / use"
  ]],
  ["Anesthesia - General", [
    "Airway - plastic",
    "Anesthesia Circuit",
    "Anesthesia Face Mask",
    "Anesthesia Machine",
    "Breathing Bag",
    "Endotracheal Tube",
    "Laryngoscope / use",
    "Sevorane / cc",
    "Sodasorb / use",
    "Suction Catheter Fr.",
    "IV Cannula G.",
    "Macro Set",
    "Micro Set"
  ]],
  ["Anesthesia - Spinal/Epidural", [
    "Epidural Cath. w/ Needle G18",
    "Spinal Needle G__",
    "Sensocaine 0.5% Heavy",
    "Spinal Pack",
    "Urine Container Sterile"
  ]],
  ["Gloves", [
    "6",
    "6 1/2",
    "7",
    "7 1/2",
    "8",
    "Ortho",
    "Powder Free"
  ]],
  ["Pack/Set", [
    "Excision Pack",
    "Minor Pack",
    "Major Pack",
    "Excision Set",
    "Minor Set",
    "Major Set"
  ]],
  ["Gases", [
    "Oxygen",
    "Carbon Dioxide"
  ]],
  ["Supplies", [
    "Asepto Syringe",
    "Blood Set: Sangofix",
    "ECG Electrodes",
    "Elastic Bandage",
    "Eyepads",
    "Leukoplast",
    "Micropore",
    "Nasal Cannula - Adult",
    "Opsite",
    "Skin Stapler",
    "Sodium Chloride",
    "Irrigation",
    "Sterile H2O Gallon",
    "Sterilization (Cidex)",
    "Sterilization (Autoclave)",
    "Surgical Blade",
    "Tiny Strips"
  ]],
  ["Needles", [
    "G12",
    "G19",
    "G20",
    "G22",
    "G23",
    "G25",
    "G27"
  ]],
  ["Syringes", [
    "1 cc",
    "3 cc",
    "5 cc",
    "10 cc",
    "20 cc",
    "30 cc",
    "50 cc"
  ]],
  ["Sponges", [
    "Gauze Sponge 4x4",
    "Gauze Balls",
    "Gauze Rolls",
    "Gauze Sponge 5x60",
    "Peanuts",
    "Cottonoids"
  ]],
  ["Equipments", [
    "Cardiac Monitor",
    "Cautery Machine",
    "Cautery Cord",
    "Ground Pad",
    "Suction Machine"
  ]],
  ["Tubes/Drains", [
    "Connecting Tube",
    "Foley Catheter Fr.",
    "Penrose Drain",
    "Jackson Pratt",
    "Urine Bag"
  ]],
  ["Sutures", [
    "ETHILON",
    "VICRYL",
    "SILK",
    "CHROMIC",
    "PROLENE"
  ]],
  ["Medicines", []],
  ["IVFs", []],
  ["Others", []],
  ["Laboratory Request", []]
].freeze

ActiveRecord::Base.transaction do
  SECTIONS.each_with_index { |(name, items), idx| seed_category(name, items, idx + 1) }
end

puts "Seeded #{ChargeCategory.count} categories and #{ChargeItem.count} items."