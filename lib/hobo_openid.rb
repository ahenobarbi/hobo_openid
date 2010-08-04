require 'hobo'
require 'openid'
require 'openid_controller'

class ActionController::Base

  # Recognized options
  #   :login_action     - default :openid_login
  #   :complete_action  - default :complete_openid
  #   :openid_opts      - forwarded to hobo_openid_login, hobo_openid_complete
  #   :openid_opts recognizes
  #     :model        - class of your user model (required)
  #     :login        - field of params where users provide openIDs (default :login)
  #     :return_to    - page to return after OpenID auth. -> should point to action executing hobo_openid_complete
  #     :openid_field - field of your user model that stores openID
  #     :mappings       - simple registration mappings (currently unsupported)
  #     :redirect_to    - where to redirect after success
  #     :*_notice       - failure, cancellation, setup_needed, new_user_failure
  def self.openid_login(options = {})
    options.reverse_merge!(:login_action => :openid_login,
                            :complete_action => :complete_openid,
                            :openid_opts => Hash.new)

    include Hobo::OpenidController

    define_method(options[:complete_action]) do
      hobo_openid_complete(options[:openid_opts])
    end

    define_method(options[:login_action]) do
      hobo_openid_login(request, options[:openid_opts])
    end

  end
end
