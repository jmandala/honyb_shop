Feature: Submit Purchase Orders

  In order to ship orders to customers
  As an order manager
  I want to be able to submit purchase orders to Ingram

  Scenario: Create a Purchase Order
    Given the following Order exists:
      | completed at  | shipment state |
      | 2011-07-30    | ready          |
    When I create a Purchase Order
    Then the Purchase Order should contain the given Order
    And the given Order should have a shipment state of "ready"
