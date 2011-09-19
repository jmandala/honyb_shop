Feature: Configure Fulfillment Settings
  
  In order to setup CDF Fulfillment with the correct settings
  As an order manager
  I want to be able to view and modify the settings
  
  Background: user is logged in to the admin site
    Given I sign in with email "admin@honyb.com" and password "password"
    Then I should not see "Log In as Existing Customer"
    
  Scenario: visit the settings display page
    When I go to the admin fulfillment settings page
    Then I should see "Cdf Ship To Password"
    And I should see "Cdf Ship To Account"
    And I should see "Cdf Bill To Account"
    And I should see "Cdf Ftp Server"
    And I should see "Cdf Ftp User"
    And I should see "Cdf Ftp Password"
    And I should see "Cdf Run Mode"
    
  Scenario: visit the settings edit page
    When I go to the admin fulfillment settings page
    And I click "Edit"
    Then I should see "Cdf Ship To Password"
    And I should see "Cdf Ship To Account"
    And I should see "Cdf Bill To Account"
    And I should see "Cdf Ftp Server"
    And I should see "Cdf Ftp User"
    And I should see "Cdf Ftp Password"
    And I should see "Cdf Run Mode"
    And the "preferences_cdf_run_mode" drop-down should contain the option "test"
    
  Scenario: modify the settings edit page
    When I go to the admin fulfillment settings page
    And I click "Edit"
    And I fill in the following:
     | Cdf Ship To Password | ship_to_password |
     | Cdf Ship To Account  | ship_to_account  |
     | Cdf Bill To Account  | bill_to_account  |
     | Cdf Ftp Server       | ftp_server       |
     | Cdf Ftp User         | ftp_user         |
     | Cdf Ftp Password     | ftp_password     |
    And I select "mock" from "Cdf Run Mode"
    And I press "Update"
    Then I should see "ship_to_password"
    And I should see "ship_to_account"
    And I should see "bill_to_account"
    And I should see "ftp_server"
    And I should see "ftp_user"
    And I should see "******"
    And I should see "mock"