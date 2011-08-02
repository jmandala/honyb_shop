Feature: Submit Purchase Orders

  In order to ship orders to customers
  As an order manager
  I want to be able to submit purchase orders to Ingram

  Scenario: Create a Purchase Order
    Given a completed order exists
    When I create a purchase order
    Then the purchase order should contain the given order
