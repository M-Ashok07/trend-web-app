
# Stage 1: Build the Vite app
FROM node:20 AS build
WORKDIR /app
COPY Trend/package*.json ./
RUN npm ci
COPY Trend/. .
RUN npm run build

# Stage 2: Serve with Nginx
FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 3000
CMD ["nginx", "-g", "daemon off;"]
