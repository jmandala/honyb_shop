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
    Then I should see "Fulfillment Dashboard"
    And page should have following links:
      | url                                  | text          | within    |
      | /admin/fulfillment/dashboard         | Dashboard     | #sub-menu |
      | /admin/fulfillment/po_files          | PO Files      | #sub-menu |
      | /admin/fulfillment/poa_files         | POA Files     | #sub-menu |
      | /admin/fulfillment/asn_files         | ASN Files     | #sub-menu |
      | /admin/fulfillment/cdf_invoice_files | Invoice Files | #sub-menu |
      | /admin/fulfillment/system_check      | System Check  | #sub-menu |
    When I follow "System Check"
    Then page should have following links:
      | url                                        | text        | within   |
      | /admin/fulfillment/system_check            | Dashboard   | #content |
      | /admin/fulfillment/system_check/order_test | Test Orders | #content |
      | /admin/fulfillment/system_check/ftp        | FTP         | #content |
