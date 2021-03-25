require "chainable/chain"
require "active_record"

# Let's say I have a +User+ that +has_many+ posts:
# 
#   class User < ActiveRecord::Base
#     has_many :posts
#   end
#
# I want to track how many days in a row that each user wrote a post. I just have to +include Chainable+ in the model:
# 
#   class User < ActiveRecord::Base
#     include Chainable
#   end
#
# Now I can display the user's chain:
#   user.chain(:posts) # => number of days in a row that this user wrote a post (as determined by the created_at column, by default)
# 
# The +chain+ instance method can be called with any association:
#   user.chain(:other_association)
# 
# And you can change the column the chain is calculated on:
#   user.chain(:posts, :updated_at)
# 
# Don't penalize the current day being absent when determining chains (the User could write another Post before the day ends):
#   user.chain(:posts, except_today: true)
module Chainable
  def self.included(klass)
    klass.class_eval do
      include InstanceMethods
    end
  end

  module InstanceMethods # :nodoc:
    # Calculate a calendar chain. That is to say, the number of consecutive
    # days that exist for some date column, on an asociation with this object.
    #
    # For example if you have a User with many :posts, and one was created
    # today that would be a chain of 1. If that user also created a Post yesterday,
    # then the chain would be 2. If he created another Post the day before that one,
    # he'd have a chain of 3, etc.
    # 
    # On the other hand imagine that the User hasn't created a Post yet today, but
    # he did create one yesterday. Is that a chain? By default, it would be a chain of 0,
    # so no. If you want to exclude the current day from this calculation, and count from
    # yesterday, set +except_today+ to +true+.
    # 
    # @param [Symbol] association the ActiveRecord association on the instance
    # @param [Symbol] column the column on the association that you want to calculate the chain against.
    # @param [Boolean] except_today whether to include today in the chain length calculation or not. If this is true, then you are assuming there is still time today for the chain to be extended
    # @param [Boolean] longest if true, calculate the longest day chain in the sequence, not just the current one
    def chain(association, column=:created_at, except_today: false, longest: false)
      build_chain(association, column, except_today: except_today).length(longest: longest)
    end

    # Calculate all calendar chains. Returns a list of Date arrays. That is to say, a listing of consecutive
    # days counts that exist for some date column, on an asociation with this object.
    # 
    # @param [Symbol] association the ActiveRecord association on the instance
    # @param [Symbol] column the column on the association that you want to calculate the chain against.
    # @param [Boolean] except_today whether to include today in the chain length calculation or not. If this is true, then you are assuming there is still time today for the chain to be extended
    # @param [Boolean] longest if true, calculate the longest day chain in the sequence, not just the current one
    def chains(association, column=:created_at)
      build_chain(association, column, except_today: true).chains
    end

    private
      def build_chain(association, column, except_today:)
        Chain.new(self, association, column, except_today: except_today)
      end
  end
end