class ProgrammeItem < ActiveRecord::Base
  validates_presence_of :title
  has_many  :programme_item_assignments
  has_many  :people, :through => :programme_item_assignments
  
  #
  acts_as_taggable
  acts_as_taggable_on :streams
  
  # TODO: Add event substitutions, people that can be added to an event
  # if person is removed from event then user is asked if the person should be added to subs
  
  belongs_to   :room
  has_one   :time_slot
end
