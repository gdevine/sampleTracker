class User < ActiveRecord::Base
  before_save { self.email = email.downcase }
  
  validates :firstname, presence: true , length: { maximum: 50 }
  validates :surname, presence: true, length: { maximum: 50 }
  
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence:   true, 
                    format:     { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  
  validates :password, length: { minimum: 6 }
                    
  has_secure_password                    
end
