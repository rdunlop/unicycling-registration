Registration Site
=================

[![Circle CI](https://circleci.com/gh/rdunlop/unicycling-registration.svg?style=svg)](https://circleci.com/gh/rdunlop/unicycling-registration)
[![Dependency Status](https://gemnasium.com/rdunlop/unicycling-registration.png)](https://gemnasium.com/rdunlop/unicycling-registration)
[![Code Climate](https://codeclimate.com/github/rdunlop/unicycling-registration.png)](https://codeclimate.com/github/rdunlop/unicycling-registration)
[![Test Coverage](https://codeclimate.com/github/rdunlop/unicycling-registration/badges/coverage.svg)](https://codeclimate.com/github/rdunlop/unicycling-registration/coverage)

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
* Judging and scoring systems for various competition types
* Multi-Language support, to allow the registration system to be enabled in any language


This documentation is broken into 2 sections:
* How to use the site for your own convention
* How to contribute time/effort to improving the application


How to use the site for your own convention
===========================================

The application is capable of running multiple conventions on a single server,
and no longer needs each convention to manage its own servers/hosting.

Contact Robin (robin@dunlopweb.com) in order to create a new convention. Generally you
will also want to use a 'test' instance in order to test/explore features without affecting your "live" site.


How to add/improve Translations
-------------------------------
If you would like to contribute language translations, the first step is to ask for a "translator" account. See the instructions in the footer of the website for more details.

Once you have a translator account, a "Translation" menu item will appear, which will allow you to see/adjust/improve the translations for any language (except English).

- If you find that there is any text which only appears in English, or where the English is incorrect, please use the "Feedback" form to let us know, and we'll enable it in the translation system.


If we want to add a new language to the list of possible translations:

1. First create a root-level `base.en.yml` file, and set the "language_name" (this should be the only entry in the file)

2. Add the language to the `available_locales` in the config/application.rb

2a. At this point, you can publish the changes, and translators can create the translations as necessary

3. Add the language to the `all_available_languages` in the EventConfiguration class

4. Add the language to the select2_locale_* in application.js
4. Choose the language in your Event Configuration.

* app/views/layouts/application.rb - Ensure that the 'lang' attribute is appropriately set.

* app/views/layouts/_footer.html.haml - Ensure that the link to the language is appropriately tagged/translated.

* Once the language has been somewhat translated, make it the default via EventConfiguration#init function

Technical Details
-----------------
Each time that a deployment occurs, the translation files in /config/locales will be loaded into the database.

Since the English translations are considered the "base locale", changes to those entries have specific impacts.

* If an English phrase is _added_, the db will have a new entry added, and marked so that non-English translations can be provided.

* If an English phrase is _updated_, the db will be marked so that the non-English phrases can be reviewed to ensure that they still make sense.

* If an English phrase is _deleted_, the db ...I don't know, I haven't done this yet.


Deploying code with new translations needed
--------------------------------------------

When you perform a `cap stage deploy` it will automatically run `rake import_translations_from_yml` and `rake write_tolk_to_disk` which will update the existing Tolk translations with any new/changed keys. No further steps should be necessary.

You may need to clear the translation cache in order for the existing cached pages to be cleared.

Downloading new translations from Tolk
--------------------------------------
Extracting the new translations out of the system, and back into the source-code

1. Use the "Apply" button in the translation system to write all Tolk Translations to disk (and apply them to the front-end)

2. Use the "Clear Translations Cache" button to cause all cached pages to be cleared, and new ones generated.

3. Copy the changed yml files down to your local machine:

    `cap stage translation:download`
    or
    `cap prod translation:download`

    this will copy the remote `config/locales` onto your local machine's `config/locales`

4. Examine the changes, to ensure that you aren't accidentally removing changes which you want.

5. Commit the changes.


Other Commands available (useful for testing:
---------------------------------------------

* Clear the current loaded Tolk Content (** This is a very destructive step. Be warned! **)

    `rake clear_translations`

    This command can also be useful if you want to remove invalid translations from the tolk db, and reload from disk.

* Load all translations from config/locales:

    `rake import_translations_from_yml`

* Restart the server


How to contribute time/effort to the Registration Site
======================================================

The following directions assume that you can use "google", and are willing to
read the instructions for github.

* Download the code from github
* Configure the Base Settings for the application (see below)
* Configure the Event Configuration (offered events/prices) (see below)


Base Settings
-------------

The 'Base Settings' are set once by the Site Administrator, and are not able to
be changed by any users of the system (neither normal users, nor admins).
These settings are base settings such as security keys (secret hash), usernames/passwords for
e-mail system integration, AWS S3 storage integration.

Registration-Update Scheduler
------------------------------

In order to automatically update the registration period when the current period
ends, a scheduled task must be executed daily. This is done with the 'whenever' gem
which schedules the task to run daily

Caching
--------

When deploying, we use a redis caching server

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


The `domain` setting is used to build the links in the e-mails, set it to the hostname of the deployed application

    domain: regtest.unicycling-software.com

If you want to allow user accounts to be created WITHOUT requiring e-mail
confirmation, set the following variable, or "Authorize the laptop":

    mail_skip_confirmation: true

Paypal Account
--------------

Specify the paypal account "Merchant Account" that will be paid.
Set these in your "Base Configuration" (EventConfiguration table)

  Paypal Account

Specify whether to use the LIVE or TEST PAYPAL Site (default: Test)

    Paypal Test Mode

Paypal Settings required for proper integration:

Instant Payment Notification (IPN)

We used to think that the Paypal account had to have IPN settings enabled through the UI (Instructions from paypal: https://developer.paypal.com/docs/classic/ipn/integration-guide/IPNSetup/).

  The <notification url> will be the hosted website URL, with /payments/notification at the end.
  Example: https://registrationtest.unicycling-software.com/payments/notification

NOTE: We no longer believe that this is necessary. When a user is sent to paypal to pay, that request includes the necessary IPN `notify_url` so that we will receive a message. The following settings may be necessary though:

Auto-Return

Enable Auto Return:
  <return_url> will be https://registrationtest.regtest.unicycling-software.com/payments/


 New UI: Click on the person icon top right next to sign out -> Profile and settings -> My selling tools -> Selling Online -> Website preferences -> ...

 Old UI:  "My Account -> Profile -> Sellers Preferences -> Website Payment Preferences -> ...

Set the "PayPal Account Optional" setting on so that people don't have to have a paypal account to pay
  "My Account -> Profile -> Sellers Preferences -> Website Payment Preferences -> PayPal Account Optional (On) -> save"


AWS S3 Account
--------------

You should also create an Amazon S3 Account for storing files.
These files include:

 - The main app logo
 - Any uploaded Songs (if that feature is enabled)
 - PDFs of results.

Specify your connection settings in the secrets.yml file:

    aws_bucket:
    aws_access_key:
    aws_secret_access_key:


Google Analytics Account
----------------

Google Analytics is a service for tracking the way that users interact with the site.

Adding a google Analytics token enables us to track the flow of users. This setting is
optional.

    google_analytics_tracking_id=<token>

NewRelic Account
----------------

NewRelic is a performance monitoring tool.

Set the following settings

    NEW_RELIC_LICENSE_KEY=<key>
    NEW_RELIC_APP_NAME=<name you would like to appear in NewRelic panel>

To View the local NewRelic Information

    `http://localhost:9292/newrelic` (when in development or caching modes)

Seed Data
---------

There are a number of tables which have non-user-editable data in them (such as
StandardSkillEntry). In order to initially populate these, please run db:seed

    $ rake db:seed

you can use the db:setup command to create the database, tables, and seed:

    $ rake db:setup


Event Configuration
-------------------

Once you have the application configured for e-mail and other 'Base Settings',
you need to configure the events offered at this particular competition, as well
as the expense details for registration.

* Create an account (using the "Sign Up" page)
* Use the console to set this user as "super_admin: true"

     u = User.find(1); u.add_role :super_admin;

* Log into the site
 * Create an "Event Configuration" with your basic details, which includes the
   Name of the competition as well as logo and URL links to supporting
   information.
* Create some Expense Groups and Expense Items
 * Create some Registration Periods
 * Create some Categories, and Events within those categories.

Authorizing a laptop
--------------------
If you want to enable normal users to create registrations (For Example: On-Site
Registration). Go to /permissions/acl and authorize the browser.

This allows creation/modification of user-accounts/registrations for 24 hours from
this laptop.

Administrators will have access to the key necessary to enable this feature.

========================================================================



Code Contributions
--------------------

If you would like to contribute any work to the project, please:

* Check out this project from github
* Fork the project
* For any changes, include updated/added unit tests, and ensure that the whole suite runs
* Create a pull request

Idea Contributions
------------------

* If you have an improvement, feel free to send me a message via github

Development Setup instructions:
-------------------------------

To use this, you must install a local postgres database server.


Getting Started with Development
================================

Set your local git credentials
------------------------------

    $ cd ~/unicycling-registration/ (Or wherever the working directory is)

    $ git config --local user.name "Robin Dunlop" (Enter YOUR name instead)
    $ git config --local user.email robin@dunlopweb.com (Enter YOUR email instead)

Setup the database
==================
    Copy `config/database_template.yml` to `config/database.yml`  and make
      any necessary adjustments for your local environment.

Start the local server
----------------------

Create a local .env file. This file will contain some base settings.

    cd workspace
    $ echo "PORT=9292" > .env
    $ echo "RACK_ENV=development" >> .env
    $ echo "WEB_CONCURRENCY=1" >> .env

Each of the settings in the settings.yml file will need to be
configured. Some of these settings should be configured differently:

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

    cd workspace
    rspec spec

or to run each type of test separately

    cd workspace
    bundle exec rake spec:unit
    bundle exec rake spec:integration
    bundle exec rake spec:api



In order to create a database backup from production for use on your development
system (if so desired):

    Instructions missing

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

Setting up the Production Server
================================

This application is designed to be run in production using nginx and unicorn.

An nginx configuration template can be found at [/server_config/nginx-server.conf.template](/server_config/nginx-server.conf.template).

It will need to be modified according to the exact layout of your application server. It can be set up to serve
http, https, or both.

Amazon Server Setup
-------------------

- Create a new "Small" instance, be sure to attach the correct SSH key.
- Add the new server's address to the config/deploy/stage.rb (or production.rb)
- SSH into that instance, and update packages `sudo yum update`
- install rvm
  - `gpg2 --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
  - `\curl -sSL https://get.rvm.io | bash -s stable`
- `cap stage deploy` (or `cap prod deploy`)
  - NOTE: this will fail because the configuration files aren't present...but it will create the necessary directory structure
- Copy the configuration files (eye.yml database.yml, secrets.yml, newrelic.yml)
- copy the robots.txt file (public/robots.txt)
- install the correct ruby version `rvm install ruby-2.2.3` (check Gemfile for the correct ruby version)
- install PostgreSQL `sudo yum install postgresql94 postgresql94-devel`
- install bundler `gem install bundler`
- install a JavaScript runtime
  - See http://stackoverflow.com/questions/27350634/how-to-yum-install-node-js-on-amazon-linux#answer-32664598
  - e.g. `curl https://nodejs.org/dist/v4.2.4/node-v4.2.4-linux-x64.tar.gz > node.tgz`
  - `tar xvf node.tgz`
  - echo 'export PATH="$PATH:/home/ec2-user/node-v4.2.4-linux-x64/bin"' >> ~/.bashrc
- Install a redis-server on the server:
  - See https://gist.github.com/four43/e00d01ca084c5972f229
  - `./install-redis.sh`
- KNOWN ISSUE: unable to write to /etc/nginx/conf.d files. (worked around using `chmod o+w /etc/nginx/conf.d/`)
- install and configure nginx
  - `sudo yum install nginx`
  - set the `/etc/nginx/nginx.conf` to be `user ec2-user`
  - update the tmp folder permissions `chown -R ec2-user /var/lib/nginx`
  - create a new nginx `registration.conf` using the rake command `sudo rake update_nginx_config`
  - `sudo service start nginx`
- At this point, point your DNS to this server, so that all requests go through this server
- Set up the server to automatically start eye on restart
  + Copy the `server_config/registration` file to `/etc/init.d/registration`
  + run `chkconfig registration on`

Redis Configuration:
- Adjust the redis.conf file so that it has a maxmemory of 256000000, and a eviction policy of volatile-lru.
- Redis says: "WARNING overcommit_memory is set to 0! Background save may fail under low memory condition. To fix this issue add 'vm.overcommit_memory = 1' to /etc/sysctl.conf and then reboot or run the command 'sysctl vm.overcommit_memory=1' for this to take effect."
- Read http://redis.io/topics/admin ...perhaps disable huge pages?

SSL Certificates
----------------

**Note: This section is under construction **

In order to provide a secure connection, we are using [letsencrypt.org](https://letsencrypt.org) to
automatically create ssl certificates for the various domains which the server will run on. But, we are doing the validation/registration through the `acme-client` gem instead of using the lets-encrypt binary.

Every night, we check all configured domains, and re-configure the nginx server to properly respond to any newly configured domain names. If we have a new domain name, we also request a new SSL certificate, enabling HTTPS for that domain.

How the Encryption process works:
---------------------------------

1. A list of domains which are served by this server is created.
2. The list of all these domains is used to determine which ones are properly configured in DNS.
3. We `authorize` each domain with LetsEncrypt
4. A new SSL certificate is requested and installed
5. Nginx is restarted to pick up the new certificate.
6. An e-mail is sent to the ERROR_EMAILS list if any issues occur.

Setting up crypto the first time:
---------------------------------

1. `rake create_crypto_client` - Register an account with LetsEncrypt
2. `rake renew_and_update_certificate` - Authorize/create certificates
3. `rake update_nginx_config` - re-write the nginx file to point at the certificates

At this point, the only thing necessary is to run `rake renew_and_update_certificate` on a regular basis, which will find new domains, authorize them, and get new SSL certs for them.

Log Rotation settings:
----------------------

It is assumed that the server is running logrotate.
In order to have the production logs backed up in a rotating basis, install the logrotation file `server_config/unicorn-unicycling-registration-logs` into the `/etc/logrotate.d/` directory.

Comments on the database schema
===============================

The Base Schema (used for all other data)
-----------------------------------------

* EventConfiguration: Site-wide configuration table.
* Registrant: Holds Details on an individual registrant. They may be
  competitors, or non-competitors
* User: a log-in-able account email/password

The Event-Registration Schema (for registration details)
--------------------------------------------------------
* RegistrationCost: the date-range that each registration price will be
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
* WheelSize: The wheel size that the age entry must use, and the competitor must
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

