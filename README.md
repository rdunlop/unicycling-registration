Registration Site
=================

How to contribute time/effort to the Registration Site
------------------------------------------------------

* Check out this project, and use the provided vagrantbox to do development/testing
* For any changes, include updated/added unit tests, and ensure that the whole suite runs
* Push changes to bitbucket
* Request that the changes be pushed to the 'prod' site by robin

Development Setup instructions:
-------------------------------
The Registration codebase includes a vagrantbox for local development and testing.

To use this, you must checkout and build the vagrantbox.


Getting Started
===============

Set your local git credentials
------------------------------

* `$ git config --local user.name "Robin Dunlop" (Enter YOUR name instead)`
* `$ git config --local user.email robin@dunlopweb.com (Enter YOUR email instead)`

Install the required software
-----------------------------

* Sun Virtualbox (www.virtualbox.org)
* Vagrantbox (vagrantup.com)

Start the Development Environment
=================================

* `cd vagrant_postgres91_utf8_rails`
* `vagrant up (this will also create the databases, and run the bundler)`
* `vagrant ssh`

Start the local server
----------------------

(inside the VM) Create a local .env file:

* `cd workspace`
* `$ echo "PORT=9292" > .env`
* `$ echo "RACK_ENV=development" >> .env`

Start the server:

* `$ foreman start` (this will not return)

To Stop the server
------------------

* Press Ctrl-C on the Server console
* `exit`
* `vagrant halt`


If making changes to the logic
==============================

Migrate the database
--------------------
This step is necessary if you make changes to the db schema in development, or if you plan on running the server locally

(inside the VM)

* `cd workspace`
* `rake db:migrate`
* `RAILS_ENV=test rake db:migrate`

Run the test suite
------------------

(inside the VM)

* `cd workspace`
* `rspec spec`

