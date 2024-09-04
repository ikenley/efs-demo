#!/bin/sh

# Script that runs when Docker container runs
echo "Task started. Running demo ECS EFS job."
echo "EFS_MOUNT_POINT=$EFS_MOUNT_POINT"

echo "Creating an example file"
TIMESTAMP=$(date "+%y-%m-%d_%H-%M-%S")
FILE_NAME="demo_file_${TIMESTAMP}.txt"
FILE_PATH="${EFS_MOUNT_POINT}/$FILE_NAME"
echo "FILE_PATH=$FILE_PATH"
echo "This file was created on ${TIMESTAMP}" > $FILE_PATH
echo "Outputting file contents"
cat $FILE_PATH

echo "Listing files in $EFS_MOUNT_POINT"
ls $EFS_MOUNT_POINT