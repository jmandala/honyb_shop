Feature: Submit Purchase Orders

  In order to ship orders to customers
  As an order manager
  I want to be able to submit purchase orders to Ingram

  Background: Current Fulfillment Settings
    Given CDF bill to account: 20N1031
    And CDF ship to account: 20N2730
    And CDF ship to password: MANDAFB3
    And CDF ftp server: ftp1.ingrambook.com
    And CDF ftp user: c20N2730
    And CDF ftp password: q3429czhvf
    And CDF test mode: true

  Scenario Outline: submit purchase order
    Given <order count> orders exist
    And each order has <line item count> line item with a quantity of <quantity count>
    And each order is completed
    When I create a purchase order
    Then the purchase order should contain <order count> orders
    And the purchase order file name should be formatted hb-YYMMDDHHMMSS.fbo
    And the purchase order file character count should be divisible by 80
  Examples:
    | order count | line item count | quantity count |
    | 1           | 1               | 1              |
    | 1           | 1               | 2              |
    | 1           | 2               | 1              |
    | 1           | 2               | 2              |
    | 3           | 2               | 2              |

