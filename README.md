# Radius

Service to handle authentication and authorization of Internet Users

## Functionalities

1. create network policies
2. activate and deactivate users

## Environment Configuration

### Message Queues Configuration

| Queue Name/Consumer          | Routing Key             | Description                        |
| ---------------------------- | ----------------------- | ---------------------------------- |
| radius_plan_consumer         | rmq_plan_changes_rk     | Handle plan/packages notifications |
| radius_subscription_consumer | subscription_changes_rk | Internet Subscription notification |
|                              | router_changes_rk       | notifications for router changes   |

###
