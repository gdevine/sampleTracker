module SamplesHelper
  
  def is_membersample?(sample)
    !sample.sample_set_id.nil?
  end
      
end