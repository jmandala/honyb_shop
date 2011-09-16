Feature: Import POA (Purchase Order Acknowledgement) Files

  In order to acknowledge that Ingram has received our Purchase Orders
  As an order manager
  I want to be able to import POA files

  Background: Current Fulfillment Settings
    Given CDF bill to account: 20N1031
    And CDF ship to account: 20N2730
    And CDF ship to password: MANDAFB4
    And CDF ftp server: ftp1.ingrambook.com
    And CDF ftp user: c20N2730
    And CDF ftp password: q3429czhvf

  Scenario Outline: submit an order and retrieve a POA file
    Given a purchase order was submitted with <order count> order and <line count> line item with a quantity of <quantity> each
    And a POA file exists on the FTP server
#    When I download a POA
#    And I import all POA files
#    Then there should be no more files to download
#    And I should have downloaded 1 file
#    And the POA file should be named according to the PO File
#    And the PO File should reference the POA
#    And the POA Type should be valid
#    And the POA should reference the orders in the PO File
  Examples:
    | order count | line count | quantity |
    | 1           | 1          | 1        |

#    | 1           | 1          | 2        |
#    | 1           | 2          | 1        |
#    | 1           | 2          | 2        |
#    | 2           | 1          | 1        |
#    | 2           | 1          | 2        |
#    | 2           | 2          | 1        |
#    | 2           | 2          | 2        |
