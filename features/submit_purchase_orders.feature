Feature: Submit Purchase Orders

  In order to ship orders to customers
  As an order manager
  I want to be able to submit purchase orders to Ingram

  Scenario Outline: submit purchase order
    Given <order count> orders exist
    And each order has <line item count> line item with a quantity of <quantity count>
    And each order is completed
    When I create a purchase order
    Then the purchase order should contain <order count> orders
    And the purchase order file name should be formatted hb-YYMMDDHHMMSS.fbo
  Examples:
    | order count | line item count | quantity count |
    | 1           | 1               | 1              |
    | 1           | 1               | 2              |
    | 1           | 2               | 1              |
    | 1           | 2               | 2              |
    | 3           | 2               | 2              |