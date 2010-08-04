OpenID Authentication for Hobo (VERSION 3)
==========================================

This plugin provides support for OpenID login. You can add OpenID login as
alternative login and registering method (and still allow login using
email + password).

Installing
===========

- Install Hobo gem
- Install the ruby-openid and ruby-yadis gems.
- Unpack the plugin in your vendor/plugins directory.


Setting up
==========

This plugin works basically the same way authenticated user support
works in Hobo. There are just a couple of extra things you will need
to set up. Here is the process in its entirety:


Modify user model
-------------------

The default hobo command now creates the User model - change User
as appropriate if you call it something else.

Open app/models/user.rb and add

    openid        :string

field.

Modify users controller
-------------------------

Open app/controllers/users_controller.rb and add follwing line to the controller class:

    openid_login({ :openid_opts => { :model => User } })


Create OpenID login page
------------------------

Create app/views/users/openid_login.dryml with following content:

    <login-page>
      <form:>
        <labelled-item-list>
               <labelled-item>
                 <item-label>OpenID</item-label>
                 <item-value><input type="text" name="login" id="login" class="string"/></item-value>
               </labelled-item>

               <labelled-item if="&Hobo::User.default_user_model.column_names.include?('remember_token')">
                 <item-label class="field-label">Remember me:</item-label>
                 <item-value><input type="checkbox" name="remember_me" id="remember-me"/></item-value>
               </labelled-item>
             </labelled-item-list>
             <set user="&Hobo::User.default_user_model"/>
             <div class="actions">
               <submit label='Log in'/>
             </div>
      </form:>
    </login-page>

Add links to OpenID login page on login and signup pages
--------------------------------------------------------

Create app/views/users/signup.dryml with content

    <signup-page>
      <append-body:>
        Or <a href="&openid_login_users_path">sign up using OpenID</a>.
      </append-body:>
    </signup-page>

and app/views/users/login.dryml with content

    <login-page>
      <append-body:>
        Or <a href="&openid_login_users_path">log in using OpenID</a>.
      </append-body:>
    </login-page>


Create routes
-------------

Add this lines to config/routes.rb:

    map.openid_login_users 'users/openid_login', :controller => 'users', :action => 'openid_login', :conditions => {:method => :get}
    map.complete_openid_users 'users/complete_openid', :controller => 'users', :action => 'complete_openid', :conditions => {:method => :get}


Simple Registration
===================

Currently unsupported.
