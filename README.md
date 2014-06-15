Registration Site
=================

Build Status on TravisCI: [![Build Status](https://travis-ci.org/rdunlop/unicycling-registration.png?branch=master)](https://travis-ci.org/rdunlop/unicycling-registration) [![Dependency Status](https://gemnasium.com/rdunlop/unicycling-registration.png)](https://gemnasium.com/rdunlop/unicycling-registration)
CodeClimate: [![Code Climate](https://codeclimate.com/github/rdunlop/unicycling-registration.png)](https://codeclimate.com/github/rdunlop/unicycling-registration)


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

How to contribute time/effort to the Registration Site
------------------------------------------------------

The following directions assume that you can use "google", and are willing to
read the instructions for github and heroku.

* Download the code from github
* Download the heroku tool
* Create a new heroku instance

    $ heroku apps:create uniregtest

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


Registration-Update Scheduler
------------------------------

In order to automatically update the registration period when the current period
ends, a scheduled task must be executed daily.

* Install the scheduling addon:

    $  heroku addons:add scheduler:standard

* Configure the scheduler via the webpage interface:

    $ heroku addons:open scheduler
    Add Job: "rake update_registration_period" - Daily - 05:00 UTC

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

    $ heroku addons:add memcachier

Database
--------

For any non-trivial number of registrations, you will quickly reach 10,000 rows in the database (each registrant is ~100 rows, due to one row per event choice, etc).
Heroku's 'dev' plan (free plan) allows 10,000 rows, so if you're hosting this for an event, you should upgrade to a paid tier database.
The 'basic' tier is $9, an allows 10,000,000 rows (many more than you're likely to need)

See https://devcenter.heroku.com/articles/upgrade-heroku-postgres-with-pgbackups

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
    or, if you want it to have a name as well as an e-mail:
    MAIL_FULL_EMAIL="NAUCC 2013 <unicycling@dunlopweb.com>"

On Non-GMail systems, you may need to set the MAIL_TLS=false variable too (see initializers/mailer.rb)

The following e-mail will receive a CC of every payment confirmation sent

    PAYMENT_NOTICE_EMAIL=robin+nauccpayments@dunlopweb.com

The following e-mail(s) will receive all error messages, "feedback", and other low-level messages

    ERROR_EMAIL=robin+nauccerrors@dunlopweb.com
    ERROR_EMAIL2=bob+nauccerrors@dunlopweb.com


The DOMAIN setting is used to build the links in the e-mails, set it to the hostname of the deployed application

    DOMAIN=uniregtest.herokuapp.com

If you want to host your system from a different URL (search heroku
documentation for details), you should set the DOMAIN to the URL that you will be using.

    Example custom domain:
    $ heroku domains:add reg.unicon17.ca


If you want to allow user accounts to be created WITHOUT requiring e-mail
confirmation, set the following variable:

    MAIL_SKIP_CONFIRMATION=true

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


AWS S3 Account
--------------

You should also create an Amazon S3 Account for storing files.
These files include:

 - The main app logo
 - Any uploaded Songs (if that feature is enabled)
 - [future feature] PDFs of results.

Specify your connection settings in the secrets.yml file:

    aws_bucket:
    aws_access_key:
    aws_secret_access_key:


Mixpanel Account
----------------

Mixpanel is a service for tracking the way that users interact with the site.

Adding a mixpanel token enables us to track the flow of users. This setting is
optional.

    MIXPANEL_TOKEN=<token>

NewRelic Account
----------------

NewRelic is a performance monitoring tool, install it via the addons page, or commmand line.

    heroku addons:add newrelic:stark --app <app name>


Set the following settings

    NEW_RELIC_LICENSE_KEY=<key>
    NEW_RELIC_APP_NAME=<name you would like to appear in NewRelic panel>

To View the local NewRelic Inforamtion

    `http://localhost:9292/newrelic` (when in development or caching modes)

Seed Data
---------

There are a number of tables which have non-user-editable data in them (such as
StandardSkillEntry). In order to initially populate these, please run db:seed

    $ rake db:seed

When running the system somewhere other than in vagrant,
you can use the db:setup command to create the database, tables, and seed:

    $ rake db:setup


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

If you want to enable normal users to create registrations (For Example: On-Site
Registration), set the following environment variable:

    ONSITE_REGISTRATION=true

========================================================================



Code Contribututions
--------------------

If you would like to contribute any work to the project, please:

* Check out this project, and use the provided vagrantbox to do development/testing
* Fork the project
* For any changes, include updated/added unit tests, and ensure that the whole suite runs
* Create a pull request

Translations
------------
If you would like to contribute language translations, please see:

* config/locale/en.yml - The english translation of the static text strings used
  in the site
* app/helpers/language_helper.rb - A place where each of the used languages is
  defined, so that the admin pages show form elements to set these language
  fields.

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


Setup the database
==================
    Copy `config/database_template.yml` to `config/database.yml`  and make
      any necessary adjustments for your local environment.

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
    $ echo "WEB_CONCURRENCY=1" >> .env

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

or to run each type of test separately

    cd workspace
    bundle exec rake spec:unit
    bundle exec rake spec:integration
    bundle exec rake spec:api



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

PDF Generation
==============

PDFs are generated using wicked_pdf. It is installed by a gem automatically.


To Run the Production setup locally
===================================

* Take a database snapshot
* Create a production database

    $ PGPASSWORD=password createdb -U postgres -h localhost app_production

* Import the data

    $ PGPASSWORD=password pg_restore --verbose --clean --no-acl --no-owner -h localhost -U postgres -d app_production latest.dump

* Set the .env file (only include the last option if you want dev like errors):

    PORT=9292
    RACK_ENV=production
    SECRET=< run `rake secret` >
    DEVELOPMENT_BANNER=false
    DISPLAY_PRODUCTION_ERRORS=true

* Precompile the assets

    $ rake assets:precompile

* Start the server

    $  foreman start web


..... Backing up the local postgres database:

    $ PGPASSWORD=password pg_dump -h localhost -U postgres -f test.dump -F t app_production

Setting the correct timezone
----------------------------

In order to have all printed reports have the correct timestamp on them, you
should set the timezone of the server.

* Run 'tzselect'
* After choosing the options, put the resulting line into ~/.profile
* Example:

    $ cat "TZ='America/New_York'; export TZ" >> ~/.profile

Comments on the database schema
===============================

The Base Schema (used for all other data)
-----------------------------------------

* EventConfiguration: Site-wide configuration table.
* Registrant: Holds Details on an individual registrant. They may be
  competitors, or non-competitors
* User: a log-in-able account email/passwordt

The Event-Registration Schema (for registration details)
--------------------------------------------------------
* RegistrationPeriod: the date-range that each registration price will be
  available

* AdditionalRegistrantAccess: allows sharing registration details between User
  accounts

* Category: Specifies the categories of events that will be offered (Racing,
  Artistic, etc)
* Event: An event that can be signed up for (100m, MUni Downhill, etc)
* EventCategory: the sub-classification of the Event that I have signed up for.
* EventChoice: Additional Options that are requested when registering for an
  event.
* RegistrantChoice: The EventChoice chosen for the event by the registrant.
* RegistrantEventSignUp: Indication that a registrant is choosing the event.

* ExpenseGroup: Name for a group of expense items (T-Shirts, Dinner Tickets,
  etc)
* ExpenseItem: Specific Items that registrants can buy.
* Payment: A payment that the registrant has created
* PaymentDetails: individual line-items in the payment
* RegistrantExpenseItem: Items that the registrant has chosen. BEFORE paying for
  them.

* StandardSkillEntry: A skill that can be chosen for Standard Skill
* StandardSkillRoutineEntry: Chosen skill for registrant's Standard Skill
  Routine
* StandardSkillRoutine: A Registrant's Standard Skill Routine

The Competition Results Data (for judging)
------------------------------------------
* AgeGroupType: A defined set of age ranges.
* AgeGroupEntries: Each age entry has a start-age and end-age.
* WheelSize: The wheel size that the age enty must use, and the competitor must
  use.
* Competitor: A grouping concept which associates registrants and
  EventCategories
* Competition: A list of competitors who are set for competing in a particular
  race/etc.
* JudgeType: describes the various types of judges that we have (Presentation,
  Technical, Street, etc) and their scoring behaviors.

* TimeResult: The results of a timed race for a registrant

Misc:
-----
* RailsAdminHistory: Supporting the railsAdmin console
* Roles: supporting Admin/Superadmin roles

