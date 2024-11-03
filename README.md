# Radius

Service to handle authentication and authorization of Internet Users

## Functionalities

1. create network policies
2. activate and deactivate users

## Environment Configuration

### Message Queues Configuration

| Queue Name/Consumer                  | Routing Key                     | Description                                |
| ------------------------------------ | ------------------------------- | ------------------------------------------ |
| radius_plan_consumer                 | rmq_plan_changes_rk             | Handle plan/packages notifications         |
| radius_hotspot_subscription_consumer | hotspot_subscription_changes_rk | Internet Hotspot Subscription notification |
| radius_ppoe_subscription_consumer    | ppoe_subscription_changes_rk    | Internet Pppoe Subscription notification   |
|                                      | router_changes_rk               | notifications for router changes           |

###
