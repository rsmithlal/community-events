class InvitationCategory < ActiveRecord::Base
  before_destroy :check_for_use

private

  def check_for_use
    if Person.where( :invitation_category_id => id ).exists?
      raise "can not delete an invitation category that is being used"
    end
  end
 
end
