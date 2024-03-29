# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :user, aliases: [:admin, :registrant] do
    sequence(:email) { |i| "user-#{i}@example.com" }
    first_name { 'Benoit'  }
    last_name { 'DuToit'  }
    password { 'password'}
    address1 { '43 Rue Goncourt'  }
    state_or_province { 'QC'  }
    postal_code { 'A7U 4D9'  }
    country { 'Canada'  }
  end
end
