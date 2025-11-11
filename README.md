DevOps Project – End-to-End CI/CD & Monitoring Setup

1. Initial Setup

  1.1 Install the required tools:
      - git
      - aws-cli
      - docker
      - terraform
      - kubectl
      - eksctl
      - Jenkins (Activated By Terraform)

2. Application Setup
  2.1 Fork and clone the repository
   
      git clone https://github.com/Vennilavan12/Trend.git
      cd Trend

  2.2 Create Dockerfile
  
  2.3 Add docker group access
  
      sudo usermod -aG docker $USER
      newgrp docker

  2.4 Build and run the app
  
      docker build -t trend-app .
      docker run -d -p 80:80 trend-app

  2.5 Configure AWS credentials
  
      aws configure

  2.6 Push image to DockerHub

      docker login
      docker tag trend-app sakthi312/trend-app:latest  #Change your DockerHub Username here <sakthi312>
      docker push sakthi312/trend-app:latest           #Change your DockerHub Username here <sakthi312>

3. Infrastructure with Terraform
  3.1 Create folder for Terraform configuration
      Files: main.tf, outputs.tf

  3.2 Run Terraform commands:

      terraform init
      terraform validate
      terraform plan
      terraform apply

  3.3 Confirm EC2 with Jenkins is created
      - Open necessary ports → 22 (SSH), 8080 (Jenkins), 80/443 (Web)
      - If Jenkins user data fails:
        sudo bash /var/lib/cloud/instance/scripts/part-001     #Apply this command to run the userdata script manually

4. EKS Cluster Setup
  4.1 Install kubectl & eksctl

  4.2 Create EKS Cluster:

      eksctl create cluster --name trend-cluster --region ap-south-1 --nodegroup-name trend-nodes --node-type t3.medium --nodes 2

  4.3 Verification of Cluster Creation:
  
      kubectl get nodes    #Should show 2 worker nodes in Ready state.

  4.5 Create Yaml Files (deployment.yaml & service.yaml)

  4.5 Deploy application:

      kubectl apply -f deployment.yaml
      kubectl apply -f service.yaml

  4.6 Verify:

    kubectl get pods 
    kubectl get svc         #Confirm LoadBalancer external IP → accessible in browser.

5. Jenkins Setup (Separate EC2 Created with terraform apply)
  5.1 Ensure the following tools are installed:
      - Jenkins
      - Docker
      - eksctl
      - kubectl
      - aws-cli

  5.2 Update kubeconfig:

      aws eks update-kubeconfig --region ap-south-1 --name trend-cluster
      kubectl get nodes         #Verify the same nodes are available in the Project EC2 also.

  5.3 Add permissions for Jenkins and Docker:

      sudo usermod -aG docker $USER
      newgrp docker
      sudo usermod -aG docker jenkins

  5.4 Configure AWS for Jenkins:

      sudo su - jenkins
      aws configure
      exit
      sudo systemctl restart jenkins

6. GitHub Setup
  6.1 Add .gitignore, .dockerignore, and Jenkinsfile

  6.2 Push code to GitHub

  6.3 For new EC2/IP changes:

      git remote set-url origin https://Sakthi-312:<Token>@github.com/Sakthi-312/devops-build.git
  
  6.4 Generate GitHub Personal Access Token

      Use this Token for changing Remote URL to push the files to youer Repo.
      Settings → devoloper Settings → Personal Access Tockens → Fine grained Tokens → Generate New Token
      Give a Token Name 
      Repository access → Only select repositories [Give the repo name]
      Persmissions → Contents (Read & Write)
                   → Metadata (Read Only) 

  6.5 Generate GitHub Personal Access Token (Clasic)
      Scopes → repo, admin:repo_hook, workflow

  6.6 Create GitHub Webhook:

      URL → http://<Jenkins-EC2-Public-IP>:8080/github-webhook/
      Content type → application/json
      Event → “Just the push event”

7. Jenkins Configuration
  7.1 Install Plugins:
      - Docker Pipeline
      - Git
      - Kubernetes CLI
      - Pipeline
      - GitHub Integration
  Restart Jenkins

  7.2 Add Credentials:

      dockerhub-creds → (DockerHub username/password)    #Dockerhub Username and Password 
      github-token    → (GitHub username/token)          #Github username and Personal Access Token (Clasic)

  7.3 Create Pipeline:
      - Name → Trend-CI-CD-Pipeline
      - Build Trigger → “GitHub hook trigger for GITScm polling”
      - Definition → “Pipeline script from SCM
      - SCM → Git
      - Repo URL → https://github.com/Sakthi-312/Trend.git   #Replace with your Repo URL
      - Credentials → GitHub token
      - Branch → */main
      - Script Path → Jenkinsfile
      - Save 

  7.4 Run the pipeline
      It should:
          - Build Docker image
          - Push to DockerHub
          - Deploy to EKS automatically
          - Gives the Loadbalancer IP

8. Monitoring Setup

  8.1 Install Prometheus + Grafana using kube-prometheus-stack (Helm)

  8.2 Verify pods in monitoring namespace:

      kubectl get pods -n monitoring

  8.3 Expose Grafana (port-forward or LoadBalancer)

  8.4 Access Grafana → Import dashboards:

      Node Exporter → ID: 1860
      Cluster Monitoring → ID: 315
      API Server → ID: 12006

  8.5 Check:
  . Pod health
  . Node metrics
  . Application uptime
  . Cluster performance

9. Create cleanup scripts [Optional]

  - terraform destroy
  - docker image prune -a
  - eksctl delete cluster --name trend-cluster

✅ Final Verification

    - Jenkins builds automatically on GitHub push
    - Docker image pushed to DockerHub
    - EKS deployment successful
    - LoadBalancer IP accessible in browser
    - Monitoring dashboards visible in Grafana
