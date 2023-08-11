require 'bundler'
Bundler.require

require_relative '../lib/dog'

DB = { conn: SQLite3::Database.new("db/dogs.db") }

def reset_database
  Dog.drop_table
  Dog.create_table
end

reset_database

# Dog.create name: "Tonka", breed: "Collie"
# Dog.create name: "Lola", breed: "German Shepard"
# Dog.create name: "Lady Kay", breed: "Collie"

# binding.pry
# 0