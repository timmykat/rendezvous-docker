class AddCodeToVehicles < ActiveRecord::Migration[7.1]

  def up  
    add_column :vehicles, :code, :string
    add_index :vehicles, :code

    Vehicle.reset_column_information
    Vehicle.find_each do |vehicle|
      loop do
        code = generate_code.upcase
        unless Vehicle.exists?(code: code)
          vehicle.update!(code: code)
          break
        end
      end
    end
  end

  def down
    remove_column :vehicles, :code
  end

  def generate_code(length = 6)
    chars = %w[A C D E F G H J K L M N P Q R T U V W X Y Z 1 2 3 4 5 6 7 8 9] # User friendly characters
    Array.new(length) { chars.sample }.join
  end
end
