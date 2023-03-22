# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
users = [
  {
    first_name: 'Timothy',
    last_name: 'Kinnel',
    email: 'tim@wordsareimages.com',
    password: 'Rendezvous2016',
    password_confirmation: 'Rendezvous2016'
  },
  {
    first_name: 'Michaela',
    last_name: 'Hellman',
    email: 'hellman.michaela@gmail.com',
    password: 'Rendezvous2016',
    password_confirmation: 'Rendezvous2016'
  },
  {
    first_name: 'David',
    last_name: 'Cossitt Levy',
    email: 'david.cossitt.levy@gmail.com',
    password: 'Rendezvous2016',
    password_confirmation: 'Rendezvous2016'
  },
  {
    first_name: 'Christopher',
    last_name: 'Westfall',
    email: 'toaph@yahoo.com',
    password: 'Rendezvous2016',
    password_confirmation: 'Rendezvous2016'
  }
]
users.each do |user_params|
  u = User.new(user_params)
  u.roles = [:admin, :organizer]
  u.save(validate: false)
end