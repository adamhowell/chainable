class User < ActiveRecord::Base
  has_many :posts

  include Chainable
end
