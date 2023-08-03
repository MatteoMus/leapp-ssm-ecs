import subprocess
import sys
import os
import boto3
from botocore.config import Config


my_config = Config(region_name=os.environ["AWS_REGION"])

ecs = boto3.client('ecs', config=my_config)
if __name__ == '__main__':

    clusters = ecs.list_clusters(maxResults=100)["clusterArns"]
    if not clusters:
        print("No ECS clusters")
        exit(0)

    print("\nClusters: ")
    i = 0
    for x in clusters:
        print(f"{i}) {x.split('/')[1]}")
        i = i +1

    cluster = clusters[int(input("Select cluster: "))]

    services = ecs.list_services(cluster=cluster)["serviceArns"]
    if not services:
        print("No available services")
        exit(0)
    print("\nServices:")
    i = 0
    for x in services:
        print(f"{i}) {x.split('/')[2]}")
        i = i + 1

    service = services[int(input("Select service: "))]

    tasks = ecs.list_tasks(cluster=cluster, serviceName=service)["taskArns"]
    if not tasks:
        print("No available tasks")
        exit(0)
    print("\nTasks:")
    i = 0
    for x in tasks:
        print(f"{i}) {x.split('/')[2]}")
        i = i + 1

    task = tasks[int(input("Select task: "))]

    containers = ecs.describe_tasks(cluster=cluster, tasks=[task])["tasks"][0]["containers"]
    if not containers:
        print("No available containers")
        exit(0)
    print("\nContainers:")
    i = 0
    for x in containers:
        print(f"{i}) {x['name']}")
        i = i + 1

    container = containers[int(input("Select container: "))]["name"]
    command = input("\nType command to execute [default /bin/sh]: ") or "/bin/sh"

    subprocess.run([
        "aws", "ecs", "execute-command",
        "--region", os.environ["AWS_REGION"],
        "--cluster", cluster,
        "--task", task,
        "--container", container,
        "--interactive",
        "--command", command
    ])