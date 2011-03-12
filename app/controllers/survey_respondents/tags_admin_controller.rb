#
#
#
class SurveyRespondents::TagsAdminController < PlannerController
  # The start page, we start with a hash of the tag contexts and their associated tags
  def index
    taggings = ActsAsTaggableOn::Tagging.find :all,
                  :select => "DISTINCT(context)",
                  :conditions => "taggable_type like 'SurveyRespondent'"
                  
    @tagContexts = Array.new

    # for each context get the set of tags (sorted), and add them to the collection for display on the page
    taggings.each do |tagging|
      @tagContexts << tagging.context
    end
  end

  #
  def update
    # First get the operation
    operation = params[:tag][:operation]
    destination = params[:tag][:destination]
    old_value = params[:original_tag].strip
    new_value = params[:new_tag].strip
    context = params[:context]
    
    new_value = toUpperCase(new_value)

    # Then depending on the op do an edit/move/delete
    case operation
      when 'edit' then edit(context, old_value, new_value)
      when 'move' then move(context, old_value, destination)
      when 'delete' then delete(context, old_value)
    end
    
    render :layout => 'content'
  end

private

  def toUpperCase(str)
    str = str.split(' ').map {|w|
      w[0] = w[0].chr.upcase
      w }.join(' ')
    return str;  
  end

  # Mapping from the tag context to the survey question id
  def initialize
    @tagContexts = {
      'scienceItems'  => 'g7q1',
      'literature'    => 'g7q2',
      'art'           => 'g7q3',
      'media'         => 'g7q4',
      'fandom'        => 'g7q5',
      'nevada'        => 'g7q6',
      'othertopics'   => 'g7q7',
      'authors'       => 'g8q1'
    }
  end
  
  def edit(context, old_value, new_value)
    respondents = SurveyRespondent.tagged_with(old_value, :on => context)
    questionId = @tagContexts[context]
    
    respondents.each do |respondent|
      tags = respondent.tag_counts_on(context)
    
      new_tags = tags.collect {|tag| (tag.name == old_value) ? new_value : tag.name }
      
      respondent.set_tag_list_on(context, new_tags.join(",") )

      smerf_forms_surveyrespondent = SmerfFormsSurveyrespondent.find_user_smerf_form(respondent.id, 1)
      if smerf_forms_surveyrespondent
        str = smerf_forms_surveyrespondent.responses[questionId]
        str = str.split(',').collect { |val| (val.strip.downcase == old_value.downcase) ? new_value : (val.strip == ',' || val.strip == '') ? nil : val.strip}
        smerf_forms_surveyrespondent.responses[questionId] = str.compact.join(',')
      
        smerf_forms_surveyrespondent.save
      end
      
      respondent.save
    end
  end
  
  def move(context, old_value, destination)
    respondents = SurveyRespondent.tagged_with(old_value, :on => context)
    srcQuestionId = @tagContexts[context]
    destQuestionId = @tagContexts[destination]
    
    respondents.each do |respondent|
      tags = respondent.tag_counts_on(context)
    
      new_tags = tags.collect {|tag| tag.name}
      new_tags.delete(old_value)
      
      respondent.set_tag_list_on(context, new_tags.join(",") )
      
      dest = respondent.tag_counts_on(destination)
      dest_tags = dest.collect {|tag| tag.name}
      dest_tags.push(old_value)

      respondent.set_tag_list_on(destination, dest_tags.join(",") )

      smerf_forms_surveyrespondent = SmerfFormsSurveyrespondent.find_user_smerf_form(respondent.id, 1)
      
      if smerf_forms_surveyrespondent
        str = smerf_forms_surveyrespondent.responses[srcQuestionId]
        str = str.split(',').collect { |val| (val.strip.downcase == old_value.downcase) ? nil : (val.strip == ',' || val.strip == '') ? nil : val.strip}
        smerf_forms_surveyrespondent.responses[srcQuestionId] = str.compact.join(',')

        str = smerf_forms_surveyrespondent.responses[destQuestionId]
        smerf_forms_surveyrespondent.responses[destQuestionId] = (str && str.strip != '') ? str + "," + old_value : old_value

        smerf_forms_surveyrespondent.save
      end

      respondent.save
    end
  end
  
  def delete(context, old_value)
    respondents = SurveyRespondent.tagged_with(old_value, :on => context)
    questionId = @tagContexts[context]
    
    respondents.each do |respondent|
      tags = respondent.tag_counts_on(context)
    
      new_tags = tags.collect {|tag| tag.name}
      new_tags.delete(old_value)
      
      respondent.set_tag_list_on(context, new_tags.join(",") )
      
      smerf_forms_surveyrespondent = SmerfFormsSurveyrespondent.find_user_smerf_form(respondent.id, 1)
      
      if smerf_forms_surveyrespondent
        str = smerf_forms_surveyrespondent.responses[questionId]
        str = str.split(',').collect { |val| (val.strip.downcase == old_value.downcase) ? nil : (val.strip == ',' || val.strip == '') ? nil : val.strip}
        smerf_forms_surveyrespondent.responses[questionId] = str.compact.join(',')

        smerf_forms_surveyrespondent.save
      end
    
      respondent.save
    end
  end

end
