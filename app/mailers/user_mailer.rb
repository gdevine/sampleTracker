class UserMailer < ActionMailer::Base
  default from: 'notifications@hie-sampletracker.com'
 
  def welcome_email(user)
    @user = user
    @url  = 'http://hie-sampletracker@uws.edu.au'
    mail(to: @user.email, subject: 'Welcome to the HIE Sample Tracker')
  end
  
  def new_user_waiting_for_approval(user)
    mail(to: 'g.devine@uws.edu.au', subject: 'Sample Tracker Registration Request')
  end
  
  def newss_email(sample_set)
    @sample_set = sample_set
    @owner = sample_set.owner
    @contact = sample_set.facility.contact
    @url  = 'http://hie-sampletracker@uws.edu.au'
    mail(to: @contact.email, subject: "NEW Sample Request Set (#{sample_set.id})")
  end
  
  def updatedss_email(sample_set)
    @sample_set = sample_set
    @owner = sample_set.owner
    @contact = sample_set.facility.contact
    @url  = 'http://hie-sampletracker@uws.edu.au'
    mail(to: @contact.email, subject: "UPDATED Sample Request Set (#{@sample_set.id})")
  end
end
