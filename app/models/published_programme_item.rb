#
#
#
class PublishedProgrammeItem < ActiveRecord::Base
  attr_accessible :lock_version, :short_title, :title, :precis, :duration,
                  :pub_reference_number, :mobile_card_size, :audience_size, :participant_notes,
                  :format_id, :is_break, :start_offset

  audited :allow_mass_assignment => true

  # default sort children
  has_many   :children, :dependent => :destroy, :class_name => 'PublishedProgrammeItem', foreign_key: "parent_id" do
    def ordered_by_offset
      order("start_offset asc, title asc")
    end
  end
  
  belongs_to :parent,   :class_name => 'PublishedProgrammeItem' 

  has_many  :published_programme_item_assignments, :dependent => :destroy do #, :class_name => 'Published::ProgrammeItemAssignment'
    def role(r) # get the people with the given role
      where(['role_id = ?', r.id]).order('published_programme_item_assignments.sort_order asc')
    end
  end
  has_many  :people, :through => :published_programme_item_assignments

  acts_as_taggable

  themed

  belongs_to :format 
  
  has_one :published_room_item_assignment, :dependent => :destroy
  has_one :published_room, :through => :published_room_item_assignment
  has_one :published_time_slot, :through => :published_room_item_assignment, :dependent => :destroy

  # The relates the published programme item back to the original programme item
  has_one :publication, :foreign_key => :published_id, :as => :published, :dependent => :destroy
  has_one :original, :through => :publication,
          :source => :original,
          :source_type => 'ProgrammeItem'

  # TODO - check
  has_many  :external_images, :as => :imageable,  :dependent => :delete_all do
    def use(u) # get the image for a given use (defined as a string)
      find(:all, :conditions => ['external_images.use = ?', u])
    end
  end
  
  def sorted_published_item_assignments
    assignments = []
    [PersonItemRole["Moderator"],PersonItemRole["Participant"]].each do |role|
      assignments.concat published_programme_item_assignments.role(role).rank(:sort_order)
    end
    assignments
  end

  def duration
    _duration = read_attribute(:duration)
    _duration = self.parent.duration if self.parent && (_duration == nil || _duration == 0)
    _duration
  end

  def start_time
    if self.parent
      _start_time = self.parent.published_time_slot.start
      _start_time = self.parent.published_time_slot.start + self.start_offset.minutes if self.start_offset
    else
      _start_time = self.published_time_slot.start
    end
    _start_time
  end
  
  def end_time
    if self.parent
      _end_time = self.parent.published_time_slot.end
      _end_time = self.parent.published_time_slot.start + self.start_offset.minutes + self.duration.minutes if self.start_offset
    else
      _end_time = self.published_time_slot.end
    end
    _end_time
  end
  
end
