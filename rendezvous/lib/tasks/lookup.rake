require "#{Rails.root}/app/helpers/application_helper"
include ApplicationHelper


namespace :users do
  desc "Look up a user in the database by email"
  task :lookup, [:email] => [:environment] do |t, args|
    puts '-----'
    u = User.find_by_email(args[:email])
    if u
      puts "ID: #{u.id}"
      puts "Name: #{u.full_name}"
      puts "Email: #{u.email}"
      puts "Created: #{u.created_at.strftime('%Y-%m-%d')}"
      if u.registrations.empty?
        puts 'Never registered for a Rendezvous'
      else
        puts "Years registered: #{u.registrations.all.map{ |r| r.year}.join(', ')}"
      end
    else
      puts "No user found for that email."
    end
    puts '-----'
  end

  desc "Delete user"
  task :delete, [:email] => [:environment] do |t, args|
    puts '-----'
    if args[:email]
      u = User.find_by_email(args[:email])
      if u
        puts "User will be deleted: #{u.full_name}, #{u.email}"

        puts "Are you sure?"
        reply = STDIN.gets.chomp
        if reply == 'y'
          u.delete
          puts "User deleted."
        end 
      else
        puts "No user found."
      end
    else 
      puts "No email given"
    end
  end

  desc "Look up all registrants. Defaults to the current year, but other years can be an argument"
  task :registered, [:year] => [:environment] do |t, args|
    year = args[:year] ? args[:year] : Date.current.year
    puts '-----'
    regs = Event::Registration.where(year: args[:year]).all.sort_by { |r| r.user.last_name.downcase }
    puts "Registrants:"
    regs.each { |r| puts r.user.last_name_first }
    puts '-----'
    puts "Total registrations for #{year}: #{regs.count}"
    puts '-----'
  end

  desc "Find users with no registrations"
  task weird: :environment do |t|
    users = User.where.missing(:registrations).where(city: nil).all
    puts "Weird Users:"
    puts '-----'
    users.each { |u| printf( "%-30s %-50s\n", u.email, u.last_name_first ) }
    puts '-----'
  end
end

