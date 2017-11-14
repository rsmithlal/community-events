module Sociable
  # A comment that a user submits related to a model.
  # This can include ProgrammeItem, PublishedProgrammeItem, Document, etc.
  class Comment < ActiveRecord::Base
    belongs_to :owner, polymorphic: true
    belongs_to :link, polymorphic: true
    belongs_to :parent, class_name: 'Sociable::Comment'
    has_many :children, class_name: 'Sociable::Comment'

    def self.deleted
      where.not(deleted_at: nil)
    end

    def self.not_deleted
      where(deleted_at: nil)
    end

    def self.top_level
      where(parent_id: nil)
    end

    def self.by_date(dir: 'DESC')
      order("#{table_name}.created_at #{dir}")
    end

    def self.by_link_type
      order(:link_type)
    end

    def self.linked_to_pub_items
      where(link_type: 'PublishedProgrammeItem')
    end

    def self.linked_to_items
      where(link_type: 'ProgrammeItem')
    end

    # def self.linked_to_documents
    #   where(link_type: 'PlannerDocs::Document')
    # end

    def self.owned_by_people
      where(owner_type: 'Person')
    end

    def self.owned_by_planners
      owner_type = arel_table[:owner_type]
      owner_query = owner_type.eq('User').or(
        owner_type.eq('SupportUser')
      )
      where(owner_query)
    end

    # TODO: Add status enums
  end
end
