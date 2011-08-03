Feature: Submit Purchase Orders

  In order to ship orders to customers
  As an order manager
  I want to be able to submit purchase orders to Ingram

  Scenario: Single order/single line with single quantity
    Given an order exists
    And the order has 1 line item with a quantity of 1
    And the order is completed
    When I create a purchase order
    Then the purchase order should contain the given order

  Scenario: Single order/single line with multiple quantity
    Given an order exists
    And the order has 1 line item with a quantity of 2
    And the order is completed
    When I create a purchase order
    Then the purchase order should contain the given order

  Scenario: Single order/multiple lines with single quantity
    Given an order exists
    And the order has 2 line items with a quantity of 1
    And the order is completed
    When I create a purchase order
    Then the purchase order should contain the given order

  Scenario: Single order/multiple lines with multiple quantity
    Given an order exists
    And the order has 2 line items with a quantity of 2
    And the order is completed
    When I create a purchase order
    Then the purchase order should contain the given order

  Scenario: Multiples orders/single line with single quantity
    Given 3 orders exist
    And the orders have 1 line item with a quantity of 1
    And the orders are completed
    When I create a purchase order
    Then the purchase order should contain the 3 given orders
