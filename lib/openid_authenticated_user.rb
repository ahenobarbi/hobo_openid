module Hobo

  module OpenidAuthenticatedUser

    AUTHENTICATION_FIELDS = [:remember_token, :remember_token_expires_at]

    # Extend the base class with OpenidAuthenticatedUser functionality
    # This includes:
    # - login token for rembering a login during multiple browser sessions
    def self.included(base)
      # a nasty hack, but it works
      Hobo::User.module_eval do
        @user_models << base.name
      end

      base.class_eval do
	extend ClassMethods 

	fields do
          remember_token            :string
          remember_token_expires_at :datetime
        end
        
        never_show *AUTHENTICATION_FIELDS
        attr_protected *AUTHENTICATION_FIELDS
      end
    end

    # Additional class methods for OpenidAuthenticatedUser
    module ClassMethods
      
      def login_attribute=(attr, validate=true)
        @login_attribute = attr = attr.to_sym
        unless attr == :login
          alias_attribute(:login, attr)
          declare_attr_type(:login, attr_type(attr)) if table_exists? # this breaks if the table doesn't exist
        end
        
        if validate
          validates_presence_of   attr
          validates_length_of     attr, :within => 3..100
          validates_uniqueness_of attr, :case_sensitive => false
        end
      end
      attr_reader :login_attribute

      def set_simple_registration_mappings(mappings=nil)
        if block_given?
          mappings = yield
        end
        if @sreg_mappings.blank?
          @sreg_mappings = mappings
        else
          @sreg_mappings.merge!(mappings || {})
        end
      end
      def simple_registration_mappings; @sreg_mappings; end

      def find_by_identity_url(url)
        find(:first, :conditions => ["#{login_attribute} = ?", url])
      end

    end #end ClassMethods

    # Do we still need to remember the login token, or has it expired?
    def remember_token?
      remember_token_expires_at && Time.now.utc < remember_token_expires_at
    end

    # These create and unset the fields required for remembering users between browser closes
    def remember_me
      self.remember_token_expires_at = 2.weeks.from_now.utc
      self.remember_token            = encrypt("#{login}--#{remember_token_expires_at}")
      save(false)
    end

    # Expire the login token, resulting in a forced login next time.
    def forget_me
      self.remember_token_expires_at = nil
      self.remember_token            = nil
      save(false)
    end

    def guest?
      false
    end
    
    def signed_up?
      true
    end

  end

end
