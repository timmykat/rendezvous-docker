module VehicleTaxonomy

  VEHICLES = {
    marques: {
      "Citroen" => {

        categories: {
          "C2 / Traction Avant" => {
            models: [
              "C2",
              "Traction Avant (11)",
              "Traction Avant (15)"
            ]
          },
          "ID / DS" => {
            models: [
              "D (early)",
              "D (late)",
              "D (wagon)",
              "D (Chapron)"
            ]
          },
          "2CV / Truckette" => {
            models: [
              "2CV (sedan)",
              "2CV (truckette)"
            ]
          },
          "SM" => {
            models: [
              "SM"
            ]
          },
          "CX / CXA" => {
            models: [
              "CX (series 1)",
              "CX (series 2)",
              "CXA"
            ]
          },
          "Ami / Dyane / Mehari / Visa" => {
            models: [
              "Ami",
              "Dyane",
              "Mehari",
              "Visa"
            ]
          },
          "GS / GSA / XM / Xantia / C6 / H-Van" => {
            models: [
              "GS",
              "GSA",
              "XM",
              "Xantia",
              "C6",
              "H-Van"
            ]
          },
          "Rare Citroen Model" => { models: [ "Other" ] }
        }
      },
      "Panhard" => {
        categories: { "Other French" => { models: [] }}
      },
      "Peugeot" => {
        categories: { "Other French" => { models: [] }}
      },
      "Renault" => {
        categories: { "Other French" => { models: [] }}
      },               
      "Non-French" => {
        categories: { "Non-French" => { models: [] }}
      }
    }
  }

  def self.get_all_categories
    VEHICLES[:marques].values.flat_map do |marque_data|
      marque_data[:categories].keys
    end.uniq
  end

  def self.get_marques
    VEHICLES[:marques].keys
  end

  def self.get_citroen_models
    VEHICLES[:marques]["Citroen"][:categories].values.flat_map { |category| category[:models] }
  end

  def self.get_category(v)
    categories = VEHICLES.dig(:marques, v.marque, :categories)
    return "Non-French" if categories.nil?

    category = nil
    if v.marque != "Citroen" || (v.marque == "Citroen" && !get_citroen_models.include?(v.model))
      category = VEHICLES[:marques][v.marque][:categories].keys.first
    else
      return "Non-French" if v.model.nil?
      category = categories.find{ |category, data| data[:models].include?(v.model) }&.first
    end
  end
end