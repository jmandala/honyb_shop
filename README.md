## Welcome to HonyB

HonyB is a back-end for affiliate bookstores.

It provides tools for seamless embedding within partner websites, and a fluid
checkout that keeps customers on the partner's website.


## Features

1. Order fulfillment with Ingram's CDF-lite program

2. Partner signup

3. Private site where partners can:
    * manage their payments
    * browse books to embed on their own site
    * see order history
    * download customer information

## Testing Setup

Before running tests, be sure to setup the test DB and the test config.yml.

  $> bundle exec rake db:migrate db:test:prepare
  $> cp cdf/config/config.yml.sample cdf/config/config.yml

Now you are ready to run tests:

  $> rspec spec

## Development Setup

1. bundle exec rake cdf:db:seed
2. bundle exec rails server

## Status

[6/25/2012]
  * Fullfilment integration is functional
  * Embed theme is functional
  * Basic affiliate reporting is working
  * Delayed Job is processing PoFiles automatically

[8/8/2011]
    Currently working on fulfillment integration
