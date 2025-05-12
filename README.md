# Demo App

## About

Demo App is a Node.js application that showcases CI/CD practices and DevOps principles. It demonstrates continuous integration and deployment, with features such as security scanning, code quality analysis, and automated deployment.

## CI/CD Pipeline Overview

The project features a CI/CD pipeline implemented in Jenkins that automates the entire software delivery process. The pipeline is triggered on code changes and executes the following workflow:

### Continuous Integration

- **Version Management**: Automated retrieval of Git tags for semantic versioning
- **Parallel Processing**: Concurrent execution of tests and static code analysis for faster feedback
- **Quality Gates**: SonarQube analysis ensures code quality standards are met

### Continuous Delivery

- **Containerization**: Automated Docker image building with proper versioning
- **Security Assurance**: Vulnerability scanning with Snyk identifies security issues before deployment
- **Artifact Storage**: Images are pushed to AWS ECR, providing a secure and scalable registry

### Continuous Deployment

- **GitOps Approach**: Automated updates to Helm charts in a separate manifest repository
- **Traceability**: Full visibility of deployments via Slack notifications
- **Reliability**: Fail-fast approach with immediate feedback on pipeline failures
