ActionMailer::Base.smtp_settings = {
  :address              => "smtp.gmail.com",
  :port                 => 587,
  :domain               => "hiesampletracker.com",
  :user_name            => "hiedatamanager",
  :password             => "DM_Hawkesbury1",
  :authentication       => "plain",
  :enable_starttls_auto => true
}