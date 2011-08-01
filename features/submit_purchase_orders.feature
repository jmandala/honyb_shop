Feature: Submit Purchase Orders

  In order to ship orders to customers
  As an order manager
  I want to be able to submit purchase orders to Ingram

  Scenario: Create a Purchase Order
    Given the following Order exists:
      | completed_at  | shipment_state | payment_state |
      | 2011-07-30    | ready          | paid          |
    When I create a Purchase Order
    Then the Purchase Order should contain the given order
