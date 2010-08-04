require 'openid'
require 'openid/extensions/sreg'
require 'openid/store/memory'
module Hobo
  module OpenidController
    # Login action for controller. Parameters:
    # Recognized options are:
    #   :model      - class of your user model (default User)
    #   :login      - field of params where users provide openIDs (default :login)
    #   :return_to  - page to return
    def hobo_openid_login(request, options = {})
      options.reverse_merge!(:success_notice => "You have logged in",
	  	      :failure_notice => "Verification failed",
	  	      :cancellation_notice => "Verification cancelled",
	  	      :setup_needed_notice => "OpenID server reports setup is needed",
	  	      :new_user_failure_notice => "Could not create a new user account",
	  	      :redirect_to => { :controller => "front", :action => "index" },
            :model => User,
            :openid_field => :openid,
            :mappings => [])
      options.reverse_merge!(:return_to => url_for(:action => :complete_openid),
                              :model => User, :login => :login)

      return unless request.post?

      openid = params[options[:login]]

      begin
        oidreq = openid_consumer.begin openid
      rescue => e
        flash[:error] = "Discovery failed: #{e}"
        redirect_to homepage(request) and return
      end

      redirect_to oidreq.redirect_url(homepage(request), options[:return_to])
    end

    # Complete user login. Recognized options:
    #   :model          - class of your user model
    #   :openid_field   - field of your user model that stores openID
    #   :mappings       - simple registration mappings (currently unsupported)
	  #	  :redirect_to    - where to redirect after success
    #	  :*_notice       - failure, cancellation, setup_needed, new_user_failure
    def hobo_openid_complete(options={})
      options.reverse_merge!(:success_notice => "You have logged in",
	  	      :failure_notice => "Verification failed",
	  	      :cancellation_notice => "Verification cancelled",
	  	      :setup_needed_notice => "OpenID server reports setup is needed",
	  	      :new_user_failure_notice => "Could not create a new user account",
	  	      :redirect_to => { :controller => "front", :action => "index"},
            :model => User,
            :openid_field => :openid,
            :mappings => [])

      user = nil
      current_url = url_for(:action => 'complete_openid', :only_path => false)

      # un-munge params array
      parameters  = params.reject{|k,v|request.path_parameters[k]}
      response    = openid_consumer.complete parameters, current_url

      case response.status
      when OpenID::Consumer::SUCCESS
	      openid = response.identity_url
    	  user = model.first :conditions => { options[:openid_field] => openid }

	      if user #user exists
          hobo_openid_complete_user_exists(user, options)
        else
          hobo_openid_complete_new_user(response, openid, options)
      	end

      when OpenID::Consumer::FAILURE
      	flash[:notice] = options[:failure_notice]

      when OpenID::Consumer::CANCEL
      	flash[:notice] = options[:cancellation_notice]

      when OpenID::Consumer::SETUP_NEEDED
      	flash[:notice] = options[:setup_needed_notice]

      else
      	flash[:notice] = "Unknown response from OpenID server."
      end

      redirect_to :action => :openid_login unless performed?

    end

    def openid_logout(options={})
      options = options.reverse_merge(:notice => "You have been logged out.",
                                      :redirect_to => base_url)

      current_user.forget_me if logged_in?
      cookies.delete :auth_token
      reset_session
      flash[:notice] = options[:notice]
      redirect_back_or_default(options[:redirect_to])
    end

    private
      # Get the OpenID::Consumer object.
      def openid_consumer
        @@openid_consumer ||= OpenID::Consumer.new(session, OpenID::Store::Memory.new)
      end

      # Helper function for Openid::Controller#complete.
      # handles existing users that successfully authorized.
      # user is user to be logged in. Recognized option :success_notice.
      # If you provide block taking user as argument it will be used to determine
      # if user can login.
      def hobo_openid_complete_user_exists(user, options = {})
	      # If supplied, a block can be used to test if this user is
      	# allowed to log in (e.g. the account may be disabled)
        return if block_given? && !yield(user)

        # Change current_user
        self.current_user = user

  	    if params[:remember_me] == "1"
	        current_user.remember_me
	        create_auth_cookie
    	  end

  	    flash[:notice] ||= options[:success_notice]

	      redirect_back_or_default(options[:redirect_to] || homepage(request)) unless performed?
      end

      # Helper function for Openid::Controller#complete
      # handles new users that successfully authorized.
      # user    - user to be logged in.
      # respose - response of openID provider
      # Recognized options are (if they are missing function may fail):
      #   :model, :openid_field, :mappings
      def hobo_openid_complete_new_user(response, openid, options = {})
        # Generate parameters for new user record
        user_attrs = {options[:openid_field] => openid}
        sreg = OpenID::SReg::Response.from_success_response(response)

        unless sreg.empty?
          options[:mappings].each do |set,mappings|
            mappings.each do |key,col|
         		  user_attrs[col] = sreg[key.to_s]
            end
  	      end
        end

        user = options[:model].new(user_attrs)
        logger.info user_attrs

        flash[:notice] = options[:new_user_failure_notice] unless user.save false

        self.current_user = user
        redirect_to(:action => "edit", :id => user.id)
      end

      # If I call it home_page it'll break cucumbers
      def homepage(request)
        "#{request.protocol}#{request.host}:#{request.port}"
      end
  end
end
