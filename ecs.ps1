$json_data = aws ecs list-clusters
$list_arns = (ConvertFrom-Json $json_data).clusterArns

Write-Host "`nClusters:`n"
for ($i = 0; $i -lt $list_arns.Count; $i++) {
    $arn_parts = $list_arns[$i] -split '/'
    Write-Host "$i) $($arn_parts[1])"
}

$choice = Read-Host "Select cluster"
$cluster = $list_arns[$choice]

############## SERVICES ################
$json_data = aws ecs list-services --cluster $cluster
$list_arns = (ConvertFrom-Json $json_data).serviceArns

Write-Host "`nServices:`n"
for ($i = 0; $i -lt $list_arns.Count; $i++) {
    $arn_parts = $list_arns[$i] -split '/'
    Write-Host "$i) $($arn_parts[2])"
}

$choice = Read-Host "Select service"
$service = $list_arns[$choice]

############## TASKS ################
$json_data = aws ecs list-tasks --cluster $cluster --service-name $service
$list_arns = (ConvertFrom-Json $json_data).taskArns

Write-Host "`nTasks:`n"
for ($i = 0; $i -lt $list_arns.Count; $i++) {
    $arn_parts = $list_arns[$i] -split '/'
    Write-Host "$i) $($arn_parts[2])"
}

$choice = Read-Host "Select task"
$task = $list_arns[$choice]

############## CONTAINERS ################
$tasks = @($task)
$json_data = aws ecs describe-tasks --cluster $cluster --tasks $tasks
$list_names = (ConvertFrom-Json $json_data).tasks[0].containers.name

Write-Host "`nContainers:`n"
for ($i = 0; $i -lt $list_names.Count; $i++) {
    Write-Host "$i) $($list_names[$i])"
}

$choice = Read-Host "Select container"
$container = $list_names[$choice]

############ COMMAND ####################
$command = Read-Host "Type command to execute [default /bin/sh]"
if ([string]::IsNullOrWhiteSpace($command)) {
    $command = '/bin/sh'
}

############# EXECUTION ############
aws ecs execute-command `
--region $ENV:AWS_REGION `
--cluster $cluster `
--task $task `
--container $container `
--command $command `
--interactive