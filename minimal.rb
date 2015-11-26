run "rm Gemfile"
file 'Gemfile', <<-RUBY
source 'https://rubygems.org'
ruby '2.2.3'

gem 'rails', '4.2.5'
gem 'pg', '~> 0.18.4'
gem 'figaro', '~> 1.1', '>= 1.1.1'
gem 'jbuilder', '~> 2.3', '>= 2.3.2'

gem 'sass-rails', '~> 5.0', '>= 5.0.4'
gem 'jquery-rails', '~> 4.0', '>= 4.0.5'
gem 'uglifier', '~> 2.7', '>= 2.7.2'

# Scrapping gem
gem 'nokogiri', '~> 1.6', '>= 1.6.6.4'

# Front end gems
gem 'bootstrap-sass', '~> 3.3', '>= 3.3.6'
gem 'font-awesome-sass', '~> 4.4'
gem 'simple_form', '~> 3.2'
gem 'autoprefixer-rails'

# React and JS
gem 'react-rails', '~> 1.5.0'
gem 'js-routes', '~> 1.1', '>= 1.1.2'

# Geoloc gems
gem 'geocoder', '~> 1.2', '>= 1.2.12'
gem 'coffee-rails', '~> 4.1'
gem 'gmaps4rails', '~> 2.1', '>= 2.1.2'

# Users
gem 'devise', '~> 3.5', '>= 3.5.2' # Create user model, users controllers and views
gem 'pundit', '~> 1.0', '>= 1.0.1' # Handle rights
gem 'omniauth-facebook', '~> 3.0'

# Search
gem 'pg_search', '~> 1.0', '>= 1.0.5'

# Internationalization
gem 'rails-i18n', '~> 4.0', '>= 4.0.7'
gem 'devise-i18n-views', '~> 0.3.6'

# Image upload
gem 'aws-sdk', '~> 2.2', '>= 2.2.3'
gem 'paperclip', '~> 4.3', '>= 4.3.2'

group :development, :test do
  gem 'binding_of_caller'
  gem 'better_errors'
  gem 'quiet_assets'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'spring'
  gem 'letter_opener'
  gem 'i18n-tasks' # Allow to inspect i18n
end

group :production do
  gem 'rails_12factor'
  gem 'puma'
end

source 'https://rails-assets.org' do
  gem 'rails-assets-underscore'
  gem 'rails-assets-pubsub-js'
  gem 'rails-assets-classnames'
end

RUBY

file 'Procfile', <<-YAML
web: bundle exec puma -C config/puma.rb
YAML

file 'config/puma.rb', <<-RUBY
workers Integer(ENV['WEB_CONCURRENCY'] || 2)
threads_count = Integer(ENV['MAX_THREADS'] || 5)
threads threads_count, threads_count

preload_app!

rackup      DefaultRackup
port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'development'

on_worker_boot do
  # Worker specific setup for Rails 4.1+
  # See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
  ActiveRecord::Base.establish_connection
end
RUBY

generate(:controller, 'pages', 'home', '--no-helper', '--no-assets')
route "root to: 'pages#home'"

run "rm -rf app/assets/stylesheets"
run "curl -L https://github.com/lewagon/stylesheets/archive/master.zip > stylesheets.zip"
run "unzip stylesheets.zip -d app/assets && rm stylesheets.zip && mv app/assets/rails-stylesheets-master app/assets/stylesheets"

run 'rm app/assets/javascripts/application.js'
file 'app/assets/javascripts/application.js', <<-JS
//= require jquery
//= require jquery_ujs
//= require bootstrap-sprockets
//= require underscore
//= require js-routes
//= require gmaps/google
//= require_tree .
JS

run 'rm app/views/layouts/application.html.erb'
file 'app/views/layouts/application.html.erb', <<-HTML
<!DOCTYPE html>
<html>
  <head>
    <title>TODO</title>
    <%= stylesheet_link_tag    'application', media: 'all' %>
    <%= csrf_meta_tags %>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
  </head>
  <body>
    <%= render 'shared/navbar' %>
    <%= render 'shared/flashes' %>
    <%= yield %>
    <%= javascript_include_tag 'application' %>
    <%= yield(:after_js) %>
  </body>
</html>
HTML

file 'app/views/shared/_navbar_boostrap.html.erb', <<-HTML
<nav class="navbar navbar-default navbar-bootstrap-wagon" role="navigation">
  <div class="container-fluid">
    <!-- Brand and toggle get grouped for better mobile display -->
    <div class="navbar-header">
      <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#bs-example-navbar-collapse-1">
        <span class="sr-only">Toggle navigation</span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
      </button>
      <a class="navbar-brand" href="/">
        <%= image_tag "logo.png" %>
      </a>
    </div>

    <!-- Collect the nav links, forms, and other content for toggling -->
    <div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
      <ul class="nav navbar-nav navbar-right">
        <% if user_signed_in? %>
          <li>
            <%= link_to "#" do %>
              <i class="fa fa-envelope-o"></i> <%= t(".messages", default: "Messages") %>
            <% end %>
          </li>
          <li class="dropdown">
            <%= link_to "#", {class: "dropdown-toggle", "data-toggle" => "dropdown", "role" => "button", "aria-expanded" => "false"} do %>
              <%= image_tag "http://placehold.it/30x30", class: "img-avatar" %>
              Profile <span class="caret"></span>
            <% end %>
            <ul class="dropdown-menu" role="menu">
              <li>
                <%= link_to "#" do %>
                  <i class="fa fa-user"></i> <%= t ".profile", default: "Profile" %>
                <% end %>
              </li>
              <li>
                <%= link_to "#" do %>
                  <i class="fa fa-home"></i>  <%= t ".profile", default: "Flat" %>
                <% end %>
              </li>
              <li>
                <%= link_to destroy_user_session_path, method: :delete do %>
                  <i class="fa fa-sign-out"></i>  <%= t ".sign_out", default: "Sign out" %>
                <% end %>
              </li>
            </ul>
          </li>
        <% else %>
          <li>
            <%= link_to t(".sign_up", default: "Sign up"), new_user_registration_path %>
          </li>
          <li>
            <%= link_to t(".sign_in", default: "Sign in"), new_user_session_path %>
          </li>
        <% end %>
        <li>
          <%= link_to t(".top_call_to_action", default: "Rent your flat"), "#", class: "btn" %>
        </li>
      </ul>
    </div><!-- /.navbar-collapse -->
  </div><!-- /.container-fluid -->
</nav>
HTML

file 'app/assets/stylesheets/layout/_navbar.css.scss', <<-CSS
  /* -------------------------------------
   * Colors & Fonts
   * ------------------------------------- */
  $navbar-color: black;
  $navbar-hover-color: $yellow;
  $navbar-font-family: $header-font;
  $navbar-bg: white;

  /* -------------------------------------
   * Box model
   * ------------------------------------- */
  $navbar-height: 50px;
  $navbar-vertical-padding: 5px;
  $navbar-horizontal-padding: 20px;
  $navbar-border-bottom-width: 0;
  $navbar-border-bottom-color: grey;

  /* -------------------------------------
   * Navbar button
   * ------------------------------------- */
  $navbar-btn-height: 40px;
  $navbar-btn-bg: lightgrey;
  $navbar-btn-color: white;
  $navbar-btn-horizontal-padding: 10px;
  $navbar-btn-radius: 2px;

  /* -------------------------------------
   * Navbar profile picture
   * ------------------------------------- */
  $navbar-profile-radius: 50%;
  $navbar-profile-border-color: white;
  $navbar-profile-border-width: 2px;

  /* -------------------------------------
   * SCSS code
   * ------------------------------------- */
  .navbar-bootstrap-wagon {
    background: $navbar-bg;
    font-family: $navbar-font-family;
    border: none;
    font-weight: 400;
    padding-left: $navbar-horizontal-padding;
    padding-right: $navbar-horizontal-padding;
    border-bottom: $navbar-border-bottom-width solid $navbar-border-bottom-color;
    min-height: 0;
    transition: background 0.4s ease;

    .navbar-nav > li > a,
    .navbar-nav > .open > a,
    .navbar-nav > li > a:focus,
    .navbar-nav > .open > a:focus {
      outline: none;
      color: $navbar-color;
      line-height: $navbar-height;
      padding-top: $navbar-vertical-padding;
      padding-bottom: $navbar-vertical-padding;
      background-color: transparent;
    }

    .navbar-nav > li > a:hover,
    .navbar-nav > .open > a:hover {
      color: $navbar-hover-color;
      background-color: transparent;
    }

    .navbar-brand,
    .navbar-brand:hover {
      outline: none;
      color: $navbar-color;
      padding-top: $navbar-vertical-padding;
      padding-bottom: $navbar-vertical-padding;
    }

    .navbar-nav > li > a.btn {
      line-height: $navbar-btn-height;
      padding: 0 $navbar-btn-horizontal-padding;
      color: $navbar-btn-color;
      border-radius: $navbar-btn-radius;
      margin-top: ($navbar-height + 2 * $navbar-vertical-padding - $navbar-btn-height) / 2;
      margin-bottom: ($navbar-height + 2 * $navbar-vertical-padding - $navbar-btn-height) / 2;
      font-weight: bold;
      background-color: $navbar-btn-bg;
      font-size: 12px;
      &:hover{
        background-color: darken($navbar-btn-bg, 30%);
      }
    }

    .navbar-brand img, .navbar-brand svg {
      height: $navbar-height;
      padding: 0px;
    }

    .img-avatar{
      border: $navbar-profile-border-width solid $navbar-profile-border-color;
      box-shadow: 0 0 2px rgb(200, 200, 200);
      height: $navbar-height - (2 * $navbar-profile-border-width);
      margin-right: 10px;
      border-radius: $navbar-profile-radius;
    }

    .navbar-toggle {
      border-color: #dddddd;
      width: 45px;
      background: transparent;
    }

    .navbar-nav > li > .dropdown-menu{
      border-radius: 0;
      margin-top: 10px;
    }

    .navbar-nav > li > .dropdown-menu:before{
      position: absolute;
      background: white;
      height: 10px;
      width: 10px;
      content: "\00a0";
      display: block;
      left: 50%;
      margin-left: -5px;
      top: -5px;
      transform: rotate(45deg);
      border-top: 1px solid #e6e6e6;
      border-left: 1px solid #e6e6e6;
      z-index: -1;
    }
  }

  /* -------------------------------------
   * Navbar profile picture
   * ------------------------------------- */

  @media screen and (max-width: 768px) {
    .navbar-bootstrap-wagon {
      .navbar-brand img, .navbar-brand svg {
        height: 50px;
      }
      .navbar-brand, .navbar-brand:hover
       {
        display: block;
        color: $navbar-color;
        padding-top: 0;
        padding-bottom: 0;
      }
    }
  }
CSS

file 'app/assets/stylesheets/application.css.scss', <<-CSS
  @import "layout/index";
CSS

file 'app/assets/stylesheets/layout/_index.css.scss', <<-CSS
  @import "navbar";
  @import "footer";
  @import "sidebar";
CSS


file 'app/views/shared/_flashes.html.erb', <<-HTML
<% if notice %>
  <div class="alert alert-info alert-dismissible" role="alert">
    <button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>
    <%= notice %>
  </div>
<% end %>
<% if alert %>
  <div class="alert alert-warning alert-dismissible" role="alert">
    <button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>
    <%= alert %>
  </div>
<% end %>
HTML


file 'config/initializers/geocoder.rb', <<-RUBY
Geocoder.configure(
  lookup:    :google,
  api_key:   ENV['GOOGLE_API_KEY'],
  use_https: true,
  units:     :km       # :km for kilometers or :mi for mile
)
RUBY


after_bundle do
  run "bundle exec figaro install"
  generate('simple_form:install', '--bootstrap')
  generate('devise:install')
  generate ('devise User')
  generate ('devise:views:i18n_templates')
  generate ('pundit:install')
  generate('react:install')
  environment 'config.action_mailer.default_url_options = { host: "http://localhost:3000" }', env: 'development'
  environment 'config.action_mailer.default_url_options = { host: "http://TODO_PUT_YOUR_DOMAIN_HERE" }', env: 'production'
  rake 'db:drop db:create db:migrate'
  git :init
  git add: "."
  git commit: %Q{ -m 'Initial commit with minimal template from https://github.com/JulianNacci/rails-templates' }
end
