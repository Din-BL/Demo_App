FROM node:18-alpine

# Set the working directory for all subsequent operations
WORKDIR /app

# Copy package files first for better layer caching
COPY package*.json ./

# Install only production dependencies with exact versions from package-lock.json
RUN npm ci

# Copy the application code after installing dependencies
COPY . .

# Document that the application listens on port 3000
EXPOSE 3000

# Create a non-root user and set appropriate file ownership for security
RUN adduser -D app_user && chown -R app_user:app_user /app

# Switch to non-privileged user for security best practices
USER app_user

# Define the command to start the Node.js application
CMD ["node", "server.js"]

