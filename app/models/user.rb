class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :sample_sets, :class_name => 'SampleSet', :foreign_key => 'owner_id', dependent: :destroy
  has_many :samples, :class_name => 'Sample', :foreign_key => 'owner_id', dependent: :destroy
  has_many :facilities, :class_name => 'Facility', :foreign_key => 'contact_id'
  has_many :storage_locations, :class_name => 'StorageLocation', :foreign_key => 'custodian_id'
  has_many :containers, :class_name => 'Container', :foreign_key => 'owner_id'
  
  before_save { self.email = email.downcase }
  # before_create :create_remember_token
  
  after_create :send_admin_mail
  
  validates :firstname, presence: true , length: { maximum: 50 }
  validates :surname, presence: true, length: { maximum: 50 }
  
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence:   true, 
                    format:     { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
#   
  # validates :password, length: { minimum: 6 }    
  
  # def User.new_remember_token
    # SecureRandom.urlsafe_base64
  # end

  # def User.encrypt(token)
    # Digest::SHA1.hexdigest(token.to_s)
  # end
  
  def my_sample_sets
    SampleSet.where("owner_id = ?", id)
  end
  
  def my_samples
    Sample.where("owner_id = ?", id)
  end
  
  def active_for_authentication? 
    super && approved? 
  end 

  def inactive_message 
    if !approved? 
      :not_approved 
    else 
      super # Use whatever other message 
    end 
  end
  
  def send_admin_mail
    UserMailer.new_user_waiting_for_approval(self).deliver
  end

  # private
# 
    # def create_remember_token
      # self.remember_token = User.encrypt(User.new_remember_token)
    # end           
end
