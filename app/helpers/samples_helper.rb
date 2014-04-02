module SamplesHelper
  def is_primarysample?(sample)
    !sample.sample_set_id.nil?
  end  
end