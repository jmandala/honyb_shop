Feature: Confirm CDF-Lite Integration Compliance

  In order to ensure that Ingram CDF-Lite integration is in compliance
  As an order manager
  I want to be able to create the required test orders and verify the results

  Background: user is logged in to the admin site
    Given I sign in with email "admin@honyb.com" and password "password"
    And CDF run mode: mock
    Then I should not see "Log In as Existing Customer"
    
    
  Scenario: visit the admin page should should correct navigation
    When I go to the admin fulfillment dashboard page
    Then I should see a link for "Dashboard"
    And I should see a link for "PO Files"
    And I should see a link for "POA Files"
    And I should see a link for "ASN Files"
    And I should see a link for "Invoice Files"
    And I should see a link for "Testing"
   