class User < ActiveRecord::Base
  has_paper_trail
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  #devise :database_authenticatable, :registerable,
  #       :recoverable, :rememberable, :trackable, :validatable
  # Setup accessible (or protected) attributes for your model
  has_many :posts
  has_many :comments
  has_many :attachments
  has_many :votes
  has_many :connections
  has_many :sent_messages,     :class_name => "Message"
  has_many :received_messages, :class_name => "Message", :as => :recipient

  attr_accessor :email
  attr_accessor :password

  attr_accessible :email
  attr_accessible :username
  attr_accessible :password
  attr_accessible :remember_me
  attr_accessible :temporary_email

  before_validation :encrypt_password
  before_validation :default_values
  before_create :generate_tokens, :load_language_from_locale

  email_regex    = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  username_regex = /\A[a-z\d]+\z/i
  # validates_confirmation_of :password
  # validates_acceptance_of :privacy_agreement, :message => I18n.t(:you_must_must_agree_to_the_privacy_policy), :allow_nil => true
  # attr_accessible :privacy_agreement

  def default_values
    self.subtype ||= "registered"
    self.status  ||= "NEW"
  end  

  with_options :if => :registered? do |user|
    user.validates :password_salt,   :presence   => true
    user.validates :password_hash,   :presence   => true
    user.validates :email,           :format     => { :with => email_regex }
    user.validates :encrypted_email, :uniqueness => true
    user.validates :username,        :uniqueness => {:case_sensitive => false}, :format => { :with => username_regex }
  end

  with_options :if => :temporary? do |user|
    user.validates :temporary_email, :format => { :with => email_regex }
  end

  scope :visible, lambda { where('status = ? or status = ?', :NEW, :APPROVED) } 
  def visible?; status == "NEW" or status == "APPROVED" end

  # Following is from http://asciicasts.com/episodes/192-authorization-with-cancan
  scope :with_role, lambda { |role| {:conditions => "roles_mask & #{2**ROLES.index(role.to_s)} > 0 "} }  
  ROLES = %w[admin moderator author editor]  


  def email
    if self.encrypted_email.nil?
      return nil 
    elsif self.encrypted_email == ""      
      return ""  
    else
      return User.decrypt(self.encrypted_email)
    end
  end

  def email=(value)
    if value.nil?
      self.encrypted_email = nil
    elsif value == ""
      self.encrypted_email = ""
    else
      self.encrypted_email = User.encrypt(value.downcase)
    end
  end

  def generate_tokens
    generate_token(:auth_token)
    generate_token(:messages_token)
  end

  def load_language_from_locale
    self.locale = I18n.locale
  end

  def admin?
    return true if self.email == "l.mugnaini@gmail.com"
    return false
  end

  def username_for_display
    if registered?
      if username.blank?
        return "User#{id}"
      else
        return username
      end
    else
      return I18n.t(:anonymous)
    end
  end

  def nobody? # is a non existing user, only created new for temporary use
    self.new_record?
  end

  def guest? # email and temporary_email are blank
    self.subtype == "guest"
    # self.email.blank? and self.temporary_email.blank? and (not self.id.blank?)
  end

  def temporary?  # email is empty and temporary email is not
    self.subtype == "temporary"
    # self.email.blank? and (not self.temporary_email.blank?)
  end
  
  def registered? # Registered but email not confirmed
    self.subtype == "registered"
    # not self.email.blank?
  end

  def roles=(roles)  
    self.roles_mask = (roles & ROLES).map { |r| 2**ROLES.index(r) }.sum  
  end  
  def roles  
    ROLES.reject { |r| ((roles_mask || 0) & 2**ROLES.index(r)).zero? }  
  end  
  def role?(role)  
    roles.include? role.to_s  
  end  
  def strong?
    return self.strong
  end


  def send_email_confirmation(area, website)
    generate_token(:email_confirmation_token)
    save
    UserMailer.email_confirmation(self, area, website).deliver
  end

  def send_password_reset(area, website)
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    save!
    UserMailer.password_reset(self, area, website).deliver
  end

  def generate_token(column)
    begin
      # self[column] = SecureRandom.urlsafe_base64
      # Changed this line because "undefined method `urlsafe_base64' for SecureRandom:Module"
      # http://railscasts.com/episodes/274-remember-me-reset-password?view=comments
      self[column] = SecureRandom.base64.tr("+/", "-_")
    end while User.exists?(column => self[column])
  end      

  def encrypt_password
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
      # self.password_salt = Base64.encode64(OpenSSL::PKey::RSA.new("-----BEGIN RSA PUBLIC KEY-----\nMIGJAoGBAOhYHv4sYmVIXwv+gdn5MFAsI7rV9TwG8WajE8+hxqWX0lanQuOp035h\ndw2Ff1aZHN9lbWpasIctmEAGEBNEwcvHHx9ou1PIBaC/RrTOyf12mMZRm+NX/buN\nrBLlcyvhyqplgOUh2HFSG2IzJJgxWPKfnbRy8QjUCdKW+guVVpgjAgMBAAE=\n-----END RSA PUBLIC KEY-----").send("public_encrypt", password))
      # self.password_hash = Digest::SHA2.hexdigest("#{password}:#{self.password_salt}")
    end
  end

  def self.authenticate(email_to_search, password)
    user = find_by_encrypted_email( User.encrypt(email_to_search) )
    if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt) && user.visible?
      user
    else
      nil
    end
  end

  def authenticate?(password)
    if (self.password_hash == BCrypt::Engine.hash_secret(password, self.password_salt)) && self.visible?
      true
    else
      false
    end
  end

  def self.encrypt(value)
    key = Digest::SHA1.hexdigest("Debaptisms")
    iv  = "This is the web site of Debaptisms"
    c   = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
    c.encrypt
    c.key = key
    c.iv = iv
    e = c.update(value)
    e << c.final
    enc = Base64.encode64(e).chomp
    return enc
  end
  def self.decrypt(value)
    key = Digest::SHA1.hexdigest("Debaptisms")
    iv  = "This is the web site of Debaptisms"
    c   = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
    c.decrypt
    c.key = key
    c.iv = iv
    e = Base64.decode64(value)
    d = c.update(e)
    d << c.final
    return d
  end
end
