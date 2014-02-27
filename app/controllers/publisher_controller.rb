#
#
#
require 'publish_job'

class PublisherController < PlannerController

  def index
    @publicationInfo = PublicationDate.last
  end
  
  # publish the selected program items
  def publish
    pubjob = PublishJob.new
    
    # Create a job that will be run seperately
    Delayed::Job.enqueue pubjob

    render status: :ok, text: {}.to_json
  end
  
  def publishPending
    jobs = Delayed::Job.all
    pending = jobs.find_index{ |j| (j.name == 'PublishJob') && !j.failed } != nil
    
    render json: {'pending' => pending.to_json}
  end
  
  def review
    pubjob = PublishJob.new
    @candidateNewItems      = pubjob.getNewProgramItems() # all unpublished programme items
    @candidateModifiedItems = pubjob.getModifiedProgramItems() # all programme items that have changes made (room assignment, added person, details etc)
    @candidateRemovedItems  = []
    @candidateRemovedItems.concat(pubjob.getRemovedProgramItems()) # all items that should no longer be published
    @candidateRemovedItems.concat(pubjob.getUnpublishedItems()) # all items that should no longer be published
    
    # Get a list of the people that have change since the past pub date
    lastPubDate = PublicationDate.find :first, :order => 'id desc'
    if (lastPubDate)
      @peopleChanged = PublishedProgramItemsService.getUpdatedPeople lastPubDate
    end
    
  end
  
end
