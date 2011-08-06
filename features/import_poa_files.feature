Feature: Import POA (Purchase Order Acknowledgement) Files

  In order to acknowledge that Ingram has received our Purchase Orders
  As an order manager
  I want to be able to import POA files

  Background: Current Fulfillment Settings
    Given CDF bill to account: 20N1031
    And CDF ship to account: 20N2730
    And CDF ship to password: MANDAFB3
    And CDF ftp server: ftp1.ingrambook.com
    And CDF ftp user: c20N2730
    And CDF ftp password: q3429czhvf

  Scenario: retrieve all POA files
    Given 1 purchase order was submitted
    And a POA file exists on the FTP server
    When I download a POA
    Then the POA will reference the purchase order