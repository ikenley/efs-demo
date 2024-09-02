# EFS Demo

Terraform code which demonstrates how to create a secure, HIPAA-compliant, highly available, multi-region [AWS Elastic File System (EFS)](https://docs.aws.amazon.com/efs/latest/ug/getting-started.html) cluster.

It will also create example EC2 and ECS compute resources which automatically mount to EFS.

---

## Getting started

```
cd iac/projects/dev
terraform init
terraform apply
```

---

## Related Resources

- Coming soon?

---

## TODO

- multi-region (requires refactoring core module a bit)

```
#cloud-config
package_update: true
package_upgrade: true
runcmd:
- yum install -y amazon-efs-utils
- apt-get -y install amazon-efs-utils
- yum install -y nfs-utils
- apt-get -y install nfs-common
- file_system_id_1=fs-0abeb6e3380474bfa
- efs_mount_point_1=/mnt/efs/fs1
- mkdir -p "${efs_mount_point_1}"
- test -f "/sbin/mount.efs" && printf "\n${file_system_id_1}:/ ${efs_mount_point_1} efs tls,_netdev\n" >> /etc/fstab || printf "\n${file_system_id_1}.efs.us-east-1.amazonaws.com:/ ${efs_mount_point_1} nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport,_netdev 0 0\n" >> /etc/fstab
- test -f "/sbin/mount.efs" && grep -ozP 'client-info]\nsource' '/etc/amazon/efs/efs-utils.conf'; if [[ $? == 1 ]]; then printf "\n[client-info]\nsource=liw\n" >> /etc/amazon/efs/efs-utils.conf; fi;
- retryCnt=15; waitTime=30; while true; do mount -a -t efs,nfs4 defaults; if [ $? = 0 ] || [ $retryCnt -lt 1 ]; then echo File system mounted successfully; break; fi; echo File system not available, retrying to mount.; ((retryCnt--)); sleep $waitTime; done;
```

```
sudo mount -t efs -o tls,iam fs-0abeb6e3380474bfa /mnt/efs/fs1
```

```
sudo -i
mkdir -p /mnt/efs/fs1/test
echo "Open the pod bay doors, HAL" > /mnt/efs/fs1/test/hello-demo.txt
echo "I'm afraid I can't let you do that, Dave" > /mnt/efs/fs1/test/HAL.txt
ls /mnt/efs/fs1/test
cat /mnt/efs/fs1/test/hello-demo.txt
cat /mnt/efs/fs1/test/HAL.txt
```
