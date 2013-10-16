# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.create(
  email: 'kitty',
  password: 'codefu',
  password_verify: 'codefu'
)

guest = User.create(
  email: 'guest@strello.heroku.com',
  password: 'password',
  password_verify: 'password'
)