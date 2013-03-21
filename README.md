Registration Site
=================

Build Status on TravisCI: [![Build Status](https://travis-ci.org/rdunlop/unicycling-registration.png?branch=master)](https://travis-ci.org/rdunlop/unicycling-registration) [![Dependency Status](https://gemnasium.com/rdunlop/unicycling-registration.png)](https://gemnasium.com/rdunlop/unicycling-registration)


Welcome to the Unicycling Registration Application.
==================================================

This application is designed to be used to receive and process online
registration for unicycling competitions/conventions.

I hope that it can be used for unicycling conventions around the world.

Its features include:
* Automatic increases of expenses based on registration periods (Early
  Registration, Late Registration)
* Customizable configuration of offered events, allowing detailed information
  gathering of the events that competitors will be competing in.
* Customizable configuration of expense items that can be offered for sale along
  with registration fees
* Integration with PayPal in order to receive payment of registration fee, and
  other expenses
* Administrative data reports which show the event sign-up details (how many
  people have signed up for each event)
* Administrative data reports which show the payment receipt details
* Administrative data-download options, which provide easy export of event sign
  up details.


This documentation is broken into 2 sections:
* How to use the site for your own convention
* How to contribute time/effort to improving the application


How to use the site for your own convention
===========================================

The following instructions detail how to create/launch your own copy of the
registration site. These instructions can be used as many times as you would
like. It is recommended that you launch 2 copies, one for "test" purposes, and
one for "live" information gathering.

The following instructions use "uniregtest.herokuapp.com" as the URL for all
"hosted site" instructions. You should replace this with
<yoursite>.herokuapp.com



"production"

How to contribute time/effort to the Registration Site
------------------------------------------------------

The following directions assume that you can use "google", and are willing to
read the instructions for github and heroku.

* Download the code from github
* Download the heroku tool
* Create a new heroku instance

    $ heroku create cedar uniregtest

* Upload the code

    $ git push heroku master

* Configure the Base Settings for the application (see below)
* Configure the Event Configuration (offered events/prices) (see below)


Base Settings
-------------

The 'Base Settings' are set once by the Site Administrator, and are not able to
be changed by any users of the system (neither normal users, nor admins).
These settings are base settings such as security keys (secret hash), usernames/passwords for
e-mail system integration, and paypal account details.

    heroku config:add <variable>=<value>

Eventually, these may be replaced using thor:
http://blog.leshill.org/blog/2010/11/02/heroku-environment-variables.html


Secret Hash
-----------

The 'Secret' key is required in order to generate secure cookies. With this in place, users can return to the site and have their accounts still logged in (this is a good thing).

    SECRET=<run rake secret on the command line>

(I use 'rake secret' (from my development environment) to generate a random secure value. I only run it once, and it should be a different value for each of your system). If you don't have a development environment, type approximately a  hundred numbers as your "SECRET"

Production flag
---------------

Setting this flag will remove the "Development Site" banner

    DEVELOPMENT_BANNER=false

Memcache
--------

When deploying, please install a memcache client on your heroku instance:

    $ heroku addons:add memcache

Email System integration
------------------------

Without a configured e-mail address, the system is unable to send confirmation
e-mails to new registrants.
The following is used to configure the outgoing e-mail system.
Specify a real email account, with username and password.
The "Full E-mail" will be the e-mail address in the "From" line.

    MAIL_SERVER=smtp.gmail.com
    MAIL_PORT=587
    MAIL_DOMAIN=dunlopweb.com
    MAIL_USERNAME=robin@dunlopweb.com
    MAIL_PASSWORD=something
    MAIL_FULL_EMAIL=robin@dunlopweb.com

On Non-GMail systems, you may need to set the MAIL_TLS=false variable too (see initializers/mailer.rb)

The following e-mail will receive a CC of every payment confirmation sent

    PAYMENT_NOTICE_EMAIL=robin+nauccpayments@dunlopweb.com

The following e-mail will receive all error messages, "feedback", and other low-level messages

    ERROR_EMAIL=robin+nauccerrors@dunlopweb.com


The DOMAIN setting is used to build the links in the e-mails, set it to the hostname of the deployed application

    DOMAIN=uniregtest.herokuapp.com

If you want to host your system from a different URL (search heroku
documentation for details), you should set the DOMAIN to the URL that you will be using.


Paypal Account
--------------

Specify the paypal account "Merchant Account" that will be paid.

    PAYPAL_ACCOUNT=robin@dunlopweb.com

Specify whether to use the LIVE or TEST PAYPAL Site (default: Test)

    PAYPAL_TEST=false


Paypal Settings required for proper integration:

Configure your paypal account to send out IPN notifications;
  The <notification url> will be the hosted website URL, with /payments/notification at the end. 
  Example: http://uniregtest.herokuapp.com/payments/notification

. Login to the PayPal merchant account -> Profile -> Instant Payment Notification Preferences -> Enter <notification url> and select radio button “Receive IPN messages” -> Save

Enable Auto Return:
  <return_url> will be http://uniregtest.herokuapp.com/payments/

  "My Account -> Profile -> Sellers Preferences -> Website Payment Preferences -> Payment Data Transfer On), Auto Return ON: Return URL: <return_url>

Set the "PayPal Account Optional" setting on so that people don't have to have a paypal account to pay
  "My Account -> Profile -> Sellers Preferences -> Website Payment Preferences -> PayPal Account Optional (On) -> save"

Mixpanel Account
----------------

Mixpanel is a service for tracking the way that users interact with the site.

Adding a mixpanel token enables us to track the flow of users. This setting is
optional.

    MIXPANEL_TOKEN=<token>


Seed Data
---------

There are a number of tables which have non-user-editable data in them (such as
StandardSkillEntry). In order to initially populate these, please run db:seed

    $ rake db:seed


Event Configuration
-------------------

Once you have the application configured for e-mail and other 'Base Settings',
you need to configure the events offered at this particular competition, as well
as the expense details for registration.

* Create an account (using the "Sign Up" page)
* Use the "heroku console" to set this user as "super_admin: true"

     u = User.find(1); u.add_role :super_admin;

* Log into the site
 * Create an "Event Configuration" with your basic details, which includes the
   Name of the competition as well as logo and URL links to supporting
   information.
* Create some Expense Groups and Expense Items
 * Create some Registration Periods
 * Create some Categories, and Events within those categories.


========================================================================



Code Contribututions
--------------------

If you would like to contribute any work to the project, please:

* Check out this project, and use the provided vagrantbox to do development/testing
* Fork the project
* For any changes, include updated/added unit tests, and ensure that the whole suite runs
* Create a pull request

Idea Contributions
------------------

* If you have an improvement, feel free to send me a message via github

Development Setup instructions:
-------------------------------
The Registration codebase includes a vagrantbox for local development and testing.

To use this, you must checkout and build the vagrantbox.


Getting Started with Development
================================

Set your local git credentials
------------------------------

    $ cd ~/unicycling-registration/ (Or wherever the working directory is)

    $ git config --local user.name "Robin Dunlop" (Enter YOUR name instead)
    $ git config --local user.email robin@dunlopweb.com (Enter YOUR email instead)

Install the required software
-----------------------------

* Sun Virtualbox (www.virtualbox.org)
* Vagrantbox (vagrantup.com)

Start the Development Environment
=================================

    cd vagrant_postgres91_utf8_rails
    vagrant up (this will also create the databases, and run the bundler)
    vagrant ssh

Start the local server
----------------------

(inside the VM) Create a local .env file. This file will contain all of the base
settings, as well as some others that need to be configured properly:

    cd workspace
    $ echo "PORT=9292" > .env
    $ echo "RACK_ENV=development" >> .env

Each of the settings in the "Base Settings" section above will need to be
configured. Some of these settings should be configured differently:

    PAYPAL_TEST=true

 * causes the paypal "sandbox" to be the destination for payments

    DOMAIN=localhost:9292

 * causes "Confirmation" e-mails to have links which you can click on which will
   validate your e-mail address.


Other notes about the differences between "Development" and "Production"
instances:

* On "production", all exceptions are e-mailed to the ERROR_EMAIL address.
  (Via the exception-logging gem)
* NOTE: In development, ALL E-MAIL will be sent to the ERROR_EMAIL address, 
  but in production it will flow as expected.


Start the server:

    $ foreman start (this will not return)

SERVER RUNNING
--------------

* When the server is running, you can access it at http://localhost:9292

Email-Service
-------------

* The server /may/ need an outgoing e-mail account in order to function nicely.

To Stop the server
------------------

* Press Ctrl-C on the Server console

    exit
    vagrant halt


If making changes to the logic
==============================

Migrate the database
--------------------
This step is necessary if you make changes to the db schema in development, or if you plan on running the server locally

(inside the VM)

    cd workspace
    rake db:migrate
    RAILS_ENV=test rake db:migrate

To Run the test suite
---------------------

(inside the VM)

    cd workspace
    rspec spec



In order to create a database backup from heroku for use on your development
system (if so desired):
* Install the pgbackups addon (so that you can take backups/dumps)

    $ heroku addons:add pgbackups

* Create a snapshot

    $ heroku pgbackups:capture --expire

* Download the backup

    $ curl -o latest.dump `heroku pgbackups:url`

* Import the data (from inside your VM)

    $ PGPASSWORD=password dropdb -U postgres -h localhost app_development
    $ PGPASSWORD=password createdb -U postgres -h localhost app_development
    $ PGPASSWORD=password pg_restore --verbose --clean --no-acl --no-owner -h localhost -U postgres -d app_development latest.dump
