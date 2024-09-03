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
docker build -t iik-dev-efs-ecs-demo-task:test .

# Start the Docker image with the docker run command.
docker run --env-file .env iik-dev-efs-ecs-demo-task:test

# Test your application locally using the RIE
curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{}'

# Deploy
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 924586450630.dkr.ecr.us-east-1.amazonaws.com
aws ecr create-repository --repository-name iik-dev-efs-ecs-demo-task --image-scanning-configuration scanOnPush=true --image-tag-mutability MUTABLE
docker tag iik-dev-efs-ecs-demo-task:latest 924586450630.dkr.ecr.us-east-1.amazonaws.com/iik-dev-efs-ecs-demo-task:latest
docker push 924586450630.dkr.ecr.us-east-1.amazonaws.com/iik-dev-efs-ecs-demo-task:latest
```
