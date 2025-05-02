# Use the official Node.js 20 image as the base
FROM node:20

# Set working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json first
COPY package*.json ./

# Install app dependencies
RUN npm install

# Install the static file server globally
RUN npm install -g serve

# Copy the rest of your app and build it
COPY . .
RUN npm run build

# Expose port 80
EXPOSE 80

# Start the app using 'serve' on port 80
CMD ["serve", "-s", "build", "-l", "80"]

