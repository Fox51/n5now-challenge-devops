# Deployment Environment Display

This project is a simple web application that displays the deployment environment. It uses Flask for the backend and nginx to serve the frontend. The application is deployed on AWS ECS and uses GitHub Actions for CI/CD, along with Terraform for infrastructure on AWS.

## Project Structure
```
project-root/
│
├── backend/
│ ├── app.py
│ ├── requirements.txt
│ ├── Dockerfile
│
├── frontend/
│ ├── index.html
│ ├── nginx.conf
│ ├── Dockerfile
│
├── terraform/
│ ├── main.tf
│ ├── provider.tf
│ ├── variables.tf
│ ├── outputs.tf
│
├── .github/
│ ├── workflows/
│ ├── ci-cd.yml
│
├── docker-compose.yml
├── .gitignore
└── README.md
```
## Backend

- **Framework**: Flask
- **Language**: Python
- **Dockerfile**: Defines the Docker image for the Flask backend.

## Frontend

- **Server**: nginx
- **HTML**: Simple HTML file that displays the deployment environment.
- **Dockerfile**: Defines the Docker image for the nginx server.

## Infrastructure with Terraform

- **Terraform**: Used to define and deploy the infrastructure on AWS.

## CI/CD with GitHub Actions

The CI/CD pipeline is configured in GitHub Actions to install dependencies, build the container image, publish the image to a container registry, and deploy the image on AWS ECS.

## Commands to Build, Deploy, and Test Locally

### Build and Run Containers Locally

1. **Set ENV variable**
   ```sh
   export DEPLOYMENT_ENV=Test
   ```

2. **Build and run the containers with Docker Compose:**
   ```sh
   docker-compose up --build
   ```
   
3. **Access the application:**
   Open your web browser and go to `http://localhost:8580`. You should see the deployment environment displayed on the screen.

### Deploy Infrastructure with Terraform

1. **Configure AWS CLI:**
   ```sh
   aws configure
   ```

2. **Initialize Terraform:**
   ```sh
   cd terraform
   terraform init
   ```

3. **Apply Terraform configuration:**
   ```sh
   terraform apply
   ```

## CI/CD Configuration with GitHub Actions

The GitHub Actions workflow file is located at `.github/workflows/ci-cd.yml`. This pipeline runs automatically on commits to either the `develop` or `testing` branches, setting the `ENVIRONMENT_NAME` environment variable based on the branch.

### Environment Variables

Make sure to set the following environment variables in your GitHub repository secrets (Settings > Secrets):

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_ACCOUNT_ID`
- `AWS_REGION`
- `AWS_ECR_REPOSITORY`
- `ECS_CLUSTER_NAME`
- `ECS_SERVICE_NAME`

## Additional Notes

- **Environment Variables:**
  - Ensure that environment variables are set correctly for both local development and AWS deployment.
- **AWS Credentials:**
  - Set up your AWS credentials in your local environment to allow Terraform and AWS commands to work correctly.
