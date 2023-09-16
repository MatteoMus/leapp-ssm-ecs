#! /bin/bash

print_list_1() {
    local list_arns=("${@:2}")
    local segment=$1
    i=0
    for arn in "${list_arns[@]}"; do
        IFS='/'
        arn_parts=($arn)
        unset IFS
        echo "$i) ${arn_parts[$segment]}"
        i=$((i+1))
    done
}

print_list_2() {
    local list_names=("${@}")
    i=0
    for name in "${list_names[@]}"; do
        echo "$i) $name"
        i=$((i+1))
    done
}

############### CLUSTERS ################
json_data=$(aws ecs list-clusters)
list_arns=($(echo "$json_data" | jq -r '.clusterArns[]'))
echo "\nClusters:\n"
print_list_1 1 "${list_arns[@]}"
echo ""
read -p "Select cluster: " choice
cluster=${list_arns[$choice]}

############## SERVICES ################
json_data=$(aws ecs list-services --cluster "$cluster")
list_arns=($(echo "$json_data" | jq -r '.serviceArns[]'))
echo "\nServices:\n"
print_list_1 2 "${list_arns[@]}"
echo ""
read -p "Select service [Leave blank to no filter by services]: " choice
choice="${choice:-null}"
if [ "$choice" != "null" ]; then
    service=${list_arns[$choice]}
else
    service=null
fi

############## TASKS ################
if [ "$service" != "null" ]; then
    json_data=$(aws ecs list-tasks --cluster "$cluster" --service-name "$service")
else
    json_data=$(aws ecs list-tasks --cluster "$cluster")
fi

list_arns=($(echo "$json_data" | jq -r '.taskArns[]'))
echo "\nTasks:\n"
print_list_1 2 "${list_arns[@]}"
echo ""
read -p "Select task: " choice
task=${list_arns[$choice]}

############## CONTAINERS ################
tasks=("$task")
json_data=$(aws ecs describe-tasks --cluster "$cluster" --tasks "$tasks")
list_names=($(echo "$json_data" | jq -r '.tasks[0].containers[].name'))
echo "\nContainers:\n"
print_list_2 "${list_names[@]}"
echo ""
read -p "Select container: " choice
container=${list_names[$choice]}

############ COMMAND ####################
echo ""
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
