Factory.define :user do |f|
  f.sequence(:email) { |n| "foo#{n}@example.com" }
  f.sequence(:username) { |n| "foo#{n}" }
  f.password "secret"
end

Factory.define :post do |f|
  f.sequence(:title) { |n| "Title #{n}" }
  f.sequence(:description) { |n| "Description #{n}" }
end
