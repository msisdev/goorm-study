# /team-eks

> AWS Management Console 또는 AWS CLI를 사용하여 Amazon EKS 클러스터를 생성합니다. 클러스터 구성 스크립트를 작성하여 자동화하고, 클러스터 관리 대시보드를 통해 클러스터 상태를 모니터링합니다. 생성된 클러스터의 리소스를 관리하고, 대시보드 스크린샷을 통해 관리 현황을 확인합니다.

## EKS

[Provision an EKS cluster (AWS)](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks)

[Example repo](https://github.com/hashicorp-education/learn-terraform-provision-eks-cluster)

Run
- `terraform apply -var-file=credentials.tfvars`
- `terraform destroy -var-file=credentials.tfvars`




## kubectl

Configure `aws`
- `aws configure`
  - AWS Access Key ID [****************FFEQ]: ...
  - AWS Secret Access Key [****************w7b8]: ...
  - Default region name [ap-northeast-2]: ap-northeast-1
  - Default output format [None]: JSON
- `aws configure list`

Add context to `kubectl`
- `aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)`
- `kubectl config view`

Play
- `kubectl cluster-info`
- `kubectl get nodes`


## Deploy App
[Deploying a Docker Image to AWS EKS](https://medium.com/@sejalmaniyar9/deploying-a-docker-image-to-aws-eks-504f4fec6fee)

Prepare `deployment.yaml`

Deploy
- `kubectl apply -f deployment.yaml`
- `kubectl get deployments`
- `kubectl get pods`

Connect to my app on local
- `kubectl port-forward MY_POD_NAME 8080:80`

View
- http://localhost:8080 (not working)
- `curl localhost:8080` (working)

Delete
- `kubectl delete -f deployment.yaml`


## What I learned
Terraform
- How to use credentials & variables

kubectl
- get context from aws
- deploy app
