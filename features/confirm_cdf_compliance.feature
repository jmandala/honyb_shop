Feature: Confirm CDF-Lite Integration Compliance

  In order to ensure that Ingram CDF-Lite integration is in compliance
  As an order manager
  I want to be able to create the required test orders and verify the results

  Background: user is logged in to the admin site
    Given I sign in with email "admin@honyb.com" and password "password"
    And I go to the admin fulfillment dashboard page

  Scenario: generate test orders
    When I click the "System Check" link
    And I click the "Order Compliance Check" link
    And I check "single order/single line/single quantity"
    And I check "single order/single line/multiple quantity"
    And I check "single order/multiple lines/single quantity"
    And I check "single order/multiple lines/multiple quantity"
    And I press "Generate Test Orders"

  @wip
  Scenario: run compliance test
    Given I am on the CDF Compliance screen
    When I click the "perform compliance test" link
    Then test orders should be created
    And a PoFile should be submitted
    And a PoaFile should be imported
    And an AsnFile should be imported
    And a CdfInvoiceFile should be imported
    And a the original orders should have references to the PoFile, PoaFile, AsnFile, and CdfInvoiceFile
    