run "rm Gemfile"
file 'Gemfile', <<-RUBY
source 'https://rubygems.org'
ruby '2.2.3'

gem 'rails', '4.2.3'
gem 'pg'
gem 'figaro'
gem 'jbuilder', '~> 2.0'

gem 'sass-rails', '~> 5.0'
gem 'jquery-rails'
gem 'uglifier'
gem 'bootstrap-sass'
gem 'font-awesome-sass'
gem 'simple_form'
gem 'devise'

group :development, :test do
  gem 'binding_of_caller'
  gem 'better_errors'
  gem 'quiet_assets'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'spring'
end

group :production do
  gem 'rails_12factor'
  gem 'puma'
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
  </body>
</html>
HTML

file 'app/views/shared/navbar.html.erb', <<-HTML
<nav class="navbar-wagon">
  <div class="container navbar-wagon-container">

    <a href="">
      <%= image_tag "logo.png" %>
    </a>

    <form action="" class="navbar-wagon-search">
      <input type="text" class="navbar-wagon-search-input" placeholder="Search for featured stuff">
      <button type="submit" class="navbar-wagon-search-btn">
        <i class="fa fa-search"></i>
      </button>
    </form>
    <hr>
    <% if user_signed_in? %>
      <%= link_to "#", class: "navbar-wagon-item navbar-wagon-link hidden-xs" do %>
        <div class="icon-badge-container">
          <i class="fa fa-envelope-o"></i>
          <div class="icon-badge icon-badge-blue">3</div>
        </div>
      <% end %>
      <hr>
      <div class="navbar-wagon-item">
        <div class="dropdown">
          <%= image_tag "http://placehold.it/30x30", class: "avatar dropdown-toggle", id: "navbar-wagon-menu", "data-toggle" => "dropdown" %>
          <ul class="dropdown-menu dropdown-menu-right navbar-wagon-dropdown-menu">
            <li>
              <%= link_to "#" do %>
                <i class="fa fa-user"></i> <%= t ".profile", default: "Profile" %>
              <% end %>
            </li>
            <li>
              <%= link_to "#" do %>
                <i class="fa fa-home"></i>  <%= t ".profile", default: "Home" %>
              <% end %>
            </li>
            <li>
              <%= link_to destroy_user_session_path, method: :delete do %>
                <i class="fa fa-sign-out"></i>  <%= t ".sign_out", default: "Log out" %>
              <% end %>
            </li>
          </ul>
        </div>
      </div>
    <% else %>
      <%= link_to t(".sign_in", default: "Login"), new_user_session_path, class: "navbar-wagon-item navbar-wagon-link" %>
    <% end %>
    <hr>
    <%= link_to t(".top_call_to_action", default: "Post stuff"), "#", class: "navbar-wagon-item navbar-wagon-button btn" %>
  </div>
</nav>
HTML

file 'app/views/shared/flashes.html.erb', <<-HTML
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

after_bundle do
  run "bundle exec figaro install"
  generate('simple_form:install', '--bootstrap')
  generate('devise:install')
  generate ('devise User')
  generate ('devise:views')
  git :init
  git add: "."
  git commit: %Q{ -m 'Initial commit with minimal template from https://github.com/JulianNacci/rails-templates' }
end
