#! /bin/bash

json_data=$(aws ecs list-clusters)
#json_data='
#{
#    "clusterArns": [
#        "arn:aws:ecs:eu-west-1:111192885848:cluster/futurefashion-wp",
#        "arn:aws:ecs:eu-west-1:111192885848:cluster/futurefashion-wpp"
#    ]
#}
#'
list_arns=($(echo "$json_data" | jq -r '.clusterArns[]'))
#first_element=${cluster_arns[1]}
#echo "First element: $first_element"
echo "\nClusters:\n"
i=0
for arn in "${list_arns[@]}"; do
    IFS='/'
    arn_parts=($arn)
    unset IFS
    echo "$i) ${arn_parts[1]}"
    i=$((i+1))
done
echo ""

cluster=${list_arns[$(read -p "Select cluster: " choice; echo $choice)]}

############## SERVICES ################
json_data=$(aws ecs list-services --cluster "$cluster")
list_arns=($(echo "$json_data" | jq -r '.serviceArns[]'))

echo "\nServices:\n"
i=0
for arn in "${list_arns[@]}"; do
    IFS='/'
    arn_parts=($arn)
    unset IFS
    echo "$i) ${arn_parts[2]}"
    i=$((i+1))
done
#echo "$i) No service"
echo ""

service=${list_arns[$(read -p "Select service: " choice; echo $choice)]}

############## TASKS ################
json_data=$(aws ecs list-tasks --cluster "$cluster" --service-name "$service")
list_arns=($(echo "$json_data" | jq -r '.taskArns[]'))

echo "\nTasks:\n"
i=0
for arn in "${list_arns[@]}"; do
    IFS='/'
    arn_parts=($arn)
    unset IFS
    echo "$i) ${arn_parts[2]}"
    i=$((i+1))
done
echo ""

task=${list_arns[$(read -p "Select task: " choice; echo $choice)]}
#echo $task

############## CONTAINERS ################
tasks=("$task")
json_data=$(aws ecs describe-tasks --cluster "$cluster" --tasks "$tasks")
list_names=($(echo "$json_data" | jq -r '.tasks[0].containers[].name'))

echo "\nContainers:\n"
i=0
for name in "${list_names[@]}"; do
    echo "$i) $name"
    i=$((i+1))
done
echo ""

container=${list_names[$(read -p "Select container: " choice; echo $choice)]}

############ COMMAND ####################
read -p "Type command to execute [default /bin/sh]: " command
command="${command:-/bin/sh}"

############# EXECUTION ############
aws ecs execute-command \
--region $AWS_REGION \
--cluster $cluster \
--task $task \
--container $container \
--command $command \
--interactive
