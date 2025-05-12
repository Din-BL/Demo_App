# Demo App

## About

Demo App is a modern Node.js application showcasing enterprise-level CI/CD practices and DevOps principles. It represents a production-ready implementation of continuous integration and continuous deployment with security scanning, code quality analysis, and automated deployment capabilities.

## Repository Components

The repository is organized into the following key components:

```
├── .dockerignore      # Configuration for Docker build context
├── .gitignore         # Git version control exclusions
├── Dockerfile         # Container image specification
├── Jenkinsfile        # CI/CD pipeline definition
├── README.md          # Project documentation
├── index.html         # Web application entry point
├── package-lock.json  # Dependency lock file
├── package.json       # Node.js project metadata
├── primes.js          # Core application logic
├── server.js          # Node.js server implementation
└── spec/              # Test specifications
```

## CI/CD Pipeline Overview

The project features a sophisticated CI/CD pipeline implemented in Jenkins that automates the entire software delivery process. The pipeline is triggered on code changes and executes the following workflow:

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

## Security Features

Security is integrated throughout the pipeline:

- SonarQube identifies code vulnerabilities and quality issues
- Snyk performs container scanning with configurable severity thresholds
- Credential management via Jenkins credentials store
- Secure handling of sensitive information like API tokens and passwords

## DevOps Integration

The project demonstrates DevOps best practices:

- **Automation**: Full automation from code commit to deployment
- **Infrastructure as Code**: Pipeline and deployment configurations stored as code
- **Feedback Loops**: Fast feedback via parallel testing and Slack notifications
- **GitOps**: Declarative infrastructure updates via Git

## Environment Support

The pipeline supports multiple environments through branch-based workflows:

- Feature branches for development work
- Main branch for production releases
- Tag-based versioning for release management

## Monitoring and Notifications

The pipeline includes comprehensive monitoring and notification systems:

- Slack integration for real-time build status notifications
- Detailed logging throughout the pipeline execution
- Traceability from code commit to deployment
