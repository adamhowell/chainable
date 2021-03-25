# Represents a chain of calendar days as computed
# by a date column on an association.
#
# So for example if you have a User that has_many :posts, then
# +chain.new(user, :posts, :created_at).length+ will tell you how many
# consecutive days a given user created posts.
class Chain
  # the base ActiveRecord object instance for this chain calculation
  attr_reader :instance

  # the AR association through which we want to grab a column to caculate a chain
  attr_reader :association

  # an AR column resolving to a date. the column that we want to calculate a calendar date chain against
  attr_reader :column

  # whether to include today in the chain length 
  # calculation or not. If this is true, then you are assuming there 
  # is still time today for the chain to be extended
  attr_reader :except_today

  # Creates a new chain
  # 
  # @param [ActiveRecord::Base] instance an ActiveRecord object instance
  # @param [Symbol] association a key representing the ActiveRecord association on the instance
  # @param [Symbol] column a key representing the column on the association that you want to calculate the chain against
  # @param [Boolean] except_today whether to include today in the chain length calculation or not. If this is true, then you are assuming there is still time today for the chain to be extended
  def initialize(instance, association, column, except_today: false)
    @instance = instance
    @association = association
    @column = column
    # Don't penalize the current day being absent when determining chains
    @except_today = except_today
  end

  # Calculate the length of this calendar day chain
  # 
  # @param [Boolean] longest if true, calculate the longest day chain in the sequence, 
  # not just the current one
  def length(longest: false)
    # no chains
    if chains.empty?
      0

    # calculate the longest one?
    elsif longest
      chains.sort do |x, y|
        y.size <=> x.size
      end.first.size

    # default chain calculation
    else
      # pull the first chain
      chain = chains.first
      
      # either the chain includes today,
      # or we don't care about today and it includes yesterday
      if chain.include?(Date.current) || except_today && chain.include?(Date.current - 1.day)
        chain.size
      else
        0
      end
    end
  end

  # Get a list of all calendar day chains, sorted descending 
  # (from most recent to farthest away)
  # Includes 1-day chains. If you want to filter
  # the results further, for example if you want 2 only
  # include 2+ day chains, you'll have to filter on the result
  def chains
    return [] if days.empty?

    chains = []
    chain = []
    days.each.with_index do |day, i|
      # first day
      if i == 0
        # since this is the first one,
        # push to our new chain
        chain << day

      # consecutive day, the previous day was "tomorrow" 
      # relative to day (since we're date descending)
      elsif days[i-1] == (day+1.day)
        # push to existing chain
        chain << day

      # chain was broken
      else
        # push our current chain
        chains << chain

        # start a new chain
        # and push day to our new chain
        chain = []
        chain << day
      end

      # the jig is up, push the current chain
      if i == (days.size-1) 
        chains << chain 
      end
    end
   
    chains
  end

  # TODO: add class methods/scopes to calculate chains, days
  # scrap code from old method below:
  # 
  # date_strings = instance.send(association).order(column => :desc).pluck(column)
  # dates = date_strings.map(&:to_date)
  # dates.sort.reverse.uniq

  private
    def days
      @days ||= begin
        instance.send(association).map do |x|
          x.send(column).in_time_zone.to_date
        end.sort do |x, y|
          x <=> y
        end.reverse.uniq
      end
    end
end