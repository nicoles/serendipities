class Segment < ActiveRecord::Base
  belongs_to :storyline
  belongs_to :place
  has_many :activities
end
