# Use Flutter SDK for building
FROM cirrusci/flutter:stable AS build

# Set working directory
WORKDIR /app

# Copy pubspec files
COPY pubspec.yaml pubspec.lock* ./

# Enable Flutter web and get dependencies
RUN flutter config --enable-web
RUN flutter pub get

# Copy the rest of the application
COPY . .

# Build Flutter web app
RUN flutter build web --release --base-href /

# Use nginx to serve the Flutter web app
FROM nginx:alpine

# Copy built files from Flutter build stage
COPY --from=build /app/build/web /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
