Description
===========

Add/Use a Virtual Development Environment for your Ruby on Rails project.

Vagrant box (pecise64) ready to use with PostgreSQL 9.1 (configured to default to UTF-8 Encoding)
Also installs bundler, and runs bundle install in your Ruby on Rails directory.
then runs "rake db:create" and "rake db:migrate".

Assumptions
===========

* The password for the postgres server is 'password'
* The Ruby on Rails project is using postgres for all of its instances
* The project is using foreman (though this is easily configured in the start.sh)
* Ruby 1.9.1p0 is sufficient


SETUP
=====

OPTION 1: Starting a new Rails project
======================================

* Create a new project directory
 * `mkdir my_app`
 * `cd my_app`
 * `git init .`
* Export this project into your new Rails git repo
 * `git clone git@github.com:rdunlop/vagrant_postgres91_utf8_rails.git`
 * `rm -Rf vagrant_postgres91_utf8_rails/.git` (removes this from separate git tracking)
* copy the initial Gemfile example into your project directory
 * `cp vagrant_postgres91_utf8_rails/example/Gemfile .`
* Follow some of the 'Common Setup' instructions below (Note: you can't do the 'rails project' ones yet)
* Start the Vagrantbox (see directions below, stopping before 'foreman start')
 * Create a new rails project
  * Once logged into the vagrant box
  * `cd workspace`
  * `rails new .`
* Follow more of the 'Common Setup' instructions below (as you see fit, now the "RAILS" ones can be done)


OPTION 2: Adding this development environment to an existing project
====================================================================

* cd into your existing rails directory (the directory which contains your app/ directory)
* Export this project into your new Rails git repo
 * `git clone git@github.com:rdunlop/vagrant_postgres91_utf8_rails.git`
 * `rm -Rf vagrant_postgres91_utf8_rails/.git` (removes this from separate git tracking)
* You may want to copy the example/Procfile so that you can use foreman
* Modify your database configuration file to use postgres
 * see the `example/database.yml` for example settings

Common setup
============

* You should set your git repo to store your username/email. This way if you do 'git commit' from inside the VM, you'll have the correct username/password
 * from your project repo:
  * `git config user.name "Robin Dunlop"`
  * `git config user.email "rdunlop@thoughtworks.com"`
  * `cat .git/config` to confirm that they are stored
* copy the Procfile, for foreman control
 * `cp vagrant_postgres91_utf8_rails/example/Procfile .`
* copy the .env, so that we set our local instance to 'development' on port 9292
 * `cp vagrant_postgres91_utf8_rails/example/dot_env .env`
* copy the .gitignore, so that we have some temporary files not-tracked-by-git
 * `cp vagrant_postgres91_utf8_rails/example/dot_gitignore .gitignore`
 * copy the .watchr, for configuration of our rspec test monitor (started by foreman)
 * `cp vagrant_postgres91_utf8_rails/example/dot_watchr .watchr`

Common Setup (requires a Rails project)
=======================================

* Set up your rails project to use the Exception Notifier, to send you e-mail whenever an exception occurs in production:
 * see the example/production.rb for an example how to set the settings (NOTE: Requires that you have the mailer already configured for your app)
 * modify your app's config/environments/production.rb to have the ExceptionNotifier block

Starting up the Vagrantbox
==========================

* `cd vagrant_postgres91_utf8_rails` (move into the project directory)
* `vagrant up` (start the VM, and also run rake db:create and rake db:migrate)
 * NOTE: This will "fail" the first time if you don't already have a Ruby on Rails project existing (that's OK)
* `vagrant ssh`
 * `cd workspace`
 * `foreman start` (Starts the server, assuming your application uses foreman for development)
 * `<ctrl-C>` (stop the server)
 * `exit` (leave the VM)
* `vagrant halt` (shut down the VM)


Modifying the vagrant to suit your project needs
================================================

* You will likely find that your rails project requires different gems/dependencies/packages/tools
* To add those to your project, modify the following files:
 * `vagrant_postgres91_utf8_rails/vagrant/roles/vagrant_postgres91_utf8_rails.json`
  * This file defines the `run_list` of cookbooks
 * `vagrant_postgres91_utf8_rails/vagrant/cookbooks/workstation/recipes/default.rb`
  * This is where you can put any packages that you need installed (will be managed by apt-get)

License and Author
==================

Author:: Robin Dunlop (<rdunlop@thoughtworks.com>)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
