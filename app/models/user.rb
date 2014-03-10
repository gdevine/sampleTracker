class User < ActiveRecord::Base
  has_many :sample_sets, :class_name => 'SampleSet', :foreign_key => 'owner_id', dependent: :destroy
  has_many :samples, :class_name => 'Sample', :foreign_key => 'owner_id', dependent: :destroy
  has_many :facilities, :class_name => 'Facility', :foreign_key => 'contact_id'
  
  before_save { self.email = email.downcase }
  before_create :create_remember_token
  
  validates :firstname, presence: true , length: { maximum: 50 }
  validates :surname, presence: true, length: { maximum: 50 }
  
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence:   true, 
                    format:     { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  
  validates :password, length: { minimum: 6 }
                    
  has_secure_password         
  
  def User.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def User.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s)
  end
  
  def my_sample_sets
    SampleSet.where("owner_id = ?", id)
  end
  
  def my_samples
    Sample.where("owner_id = ?", id)
  end

  private

    def create_remember_token
      self.remember_token = User.encrypt(User.new_remember_token)
    end           
end
