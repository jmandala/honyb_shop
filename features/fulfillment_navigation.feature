Feature: Confirm CDF-Lite Integration Compliance

  In order to ensure that Ingram CDF-Lite integration is in compliance
  As an order manager
  I want to be able to create the required test orders and verify the results

  Background: user is logged in to the admin site
    Given I sign in with email "admin@honyb.com" and password "password"
    Then I should not see "Log In as Existing Customer"
    
  Scenario: visit the admin page should should correct navigation
    When I go to the admin page
    And I click the "Fulfillment" link
    Then I should see a link for "Dashboard"
    And I should see a link for "PO Files"
    And I should see a link for "POA Files"
    And I should see a link for "ASN Files"
    And I should see a link for "Invoice Files"
    
  Scenario: visit the CDF Compliance screen
#    When I sign in
#    And I visit the fulfillment management screen
#    Then I should see the CDF Compliance screen

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
    