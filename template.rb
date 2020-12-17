# frozen_string_literal: true

# Name: Template Rails Haml React
# Author: Elly Veldriss
# Instructions: $  rails new app_name -m https://raw.githubusercontent.com/PixieStudio/rails_api_template/main/template.rb

# def source_paths
#   [__dir__]
# end

# Copied from: https://github.com/mattbrictson/rails-template
# Add this template directory to source_paths so that Thor actions like
# copy_file and template resolve against our source files. If this file was
# invoked remotely via HTTP, that means the files are not present locally.
# In that case, use `git clone` to download them to a local temporary dir.
def add_template_repository_to_source_path
  if __FILE__ =~ %r{\Ahttps?://}
    require 'tmpdir'
    source_paths.unshift(tempdir = Dir.mktmpdir('pixie-rails-template-'))
    at_exit { FileUtils.remove_entry(tempdir) }
    git clone: [
      '--quiet',
      'https://github.com/PixieStudio/rails_api_template.git',
      tempdir
    ].map(&:shellescape).join(' ')

    if (branch = __FILE__[%r{rails_api_template/(.+)/template.rb}, 1])
      Dir.chdir(tempdir) { git checkout: branch }
    end
  else
    source_paths.unshift(File.dirname(__FILE__))
  end
end

def add_gems
  gsub_file 'Gemfile',
            "# gem 'bcrypt', '~> 3.1.7'",
            "gem 'bcrypt', '~> 3.1.7'"
  gsub_file 'Gemfile',
            "# gem 'rack-cors'",
            "gem 'rack-cors'"
  gem_group :development, :test do
    gem 'rspec-rails', '~> 4.0.1'
  end
  gem 'aws-sdk-s3', require: false
  gem 'jwt'
end

def set_application_name
  environment 'config.application_name = Rails.application.class.module_parent_name'
end

def install_rspec
  generate 'rspec:install'
end

def add_users
  generate 'model', 'User username:string email:string password_digest:string reset_password_token:string admin:boolean'

  in_root do
    migration = Dir.glob('db/migrate/*').max_by { |f| File.mtime(f) }
    gsub_file migration, /:admin/, ':admin, default: false'
  end

  seed_content = <<~RUBY
    User.create!(
      username: 'Admin',
      email: 'admin@example.com',
      password: 'password',
      password_confirmation: 'password',
      admin: true
    )

    User.create!(
      username: 'User Lambda',
      email: 'user@example.com',
      password: 'password',
      password_confirmation: 'password',
    )
  RUBY
  append_to_file 'db/seeds.rb', seed_content
end

def add_routes
  route_content = <<~RUBY
    namespace :api do
      namespace :v1 do
        get 'users/:id', to: 'users#show'
        post 'auth/login', to: 'authentication#authenticate'
        post 'signup', to: 'users#create'
        post 'password/forgot', to: 'passwords#forgot'
        post 'password/reset', to: 'passwords#reset'
      end
    end
  RUBY
  route route_content
end

def copy_app_template
  directory 'app', force: true
  directory 'config', force: true
end

def stop_spring
  run 'spring stop'
end

# Main setup
# source_paths
add_template_repository_to_source_path

add_gems

after_bundle do
  stop_spring
  set_application_name
  add_users
  add_routes
  stop_spring

  copy_app_template
  # Migrate
  rails_command 'db:create'
  rails_command 'db:migrate'
  rails_command 'active_storage:install'
  rails_command 'db:migrate'
  rails_command 'db:seed'

  #   remove_app_css

  git :init
  git add: '.'
  git commit: %( -m "Initial commit" )
  git branch: %( -M main )

  say <<~EOS

    =========================================================================
    Vous pouvez changer le nom de l'application dans : ./config/application.rb

    Pour lancer l'application :
    $  cd #{app_name} && rails s -p 3001
    =========================================================================
  EOS
end
