#TODO
#!/bin/bash

# Define Variables
NAMESPACE="sre"
DEPLOYMENT_NAME="swype-app"
MAX_RESTARTS=5

# Start an infinite loop
while true; do
    # Fetch the current number of restarts for the first pod in the deployment
    # Assuming pods can be identified uniquely by the start of their name with $DEPLOYMENT_NAME
    POD_NAME=$(kubectl get pods --namespace $NAMESPACE -l app=$DEPLOYMENT_NAME -o jsonpath="{.items[0].metadata.name}")
    CURRENT_RESTARTS=$(kubectl get pod $POD_NAME --namespace $NAMESPACE -o jsonpath="{.status.containerStatuses[0].restartCount}")

    # Display the current restart count
    echo "Current restart count for $POD_NAME: $CURRENT_RESTARTS"

    # Check if the current restart count exceeds the maximum allowed restarts
    if [[ $CURRENT_RESTARTS -gt $MAX_RESTARTS ]]; then
        echo "Pod $POD_NAME has restarted $CURRENT_RESTARTS times, scaling down deployment $DEPLOYMENT_NAME."
        
        # Scale down the deployment to zero replicas
        kubectl scale deployment $DEPLOYMENT_NAME --replicas=0 --namespace $NAMESPACE

        # Break the loop as the condition to scale down has been met
        break
    else
        # Pause the script for 60 seconds before the next check
        sleep 60
    fi
done
