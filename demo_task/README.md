# demo_task

Demo ECS instance which mounts an EFS system and performs perfunctory I/O

---

## Manually Deploying

Ordinarily you'd use an automated, cloud-based CI/CD system (e.g. CodePipeline). But if you're in a hurry or trying to save a buck...

```
./scripts/docker_push_lambda.sh 1
```

## Docker

```
# Build the Docker image
docker build -t ik-dev-efs-ecs-demo-task:test .

# Start the Docker image with the docker run command.
docker run -e EFS_MOUNT_POINT="/tmp"  ik-dev-efs-ecs-demo-task:test

# Test your application locally using the RIE
curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{}'
```

---

## Running the Task

To manually run the Task as an ECS Standalone Task, you can use the AWS CLI:

```
./scripts/run_task.sh

```

Ordinarily this type of "job"-style Task would be triggered by some sort of event. For demo purposes we just manually start the Task via the AWS CLI.
