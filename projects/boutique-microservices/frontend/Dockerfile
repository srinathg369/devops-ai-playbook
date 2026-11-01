# Frontend Dockerfile

# Stage 1: build the React app
FROM node:20-alpine AS build

WORKDIR /app

COPY package*.json ./
RUN npm install --production=false

COPY . .

# Call the API on the same host (/api); nginx forwards it to the gateway.
ARG REACT_APP_API_URL=/api
ENV REACT_APP_API_URL=$REACT_APP_API_URL
RUN npm run build

# Stage 2: serve the built files with nginx
FROM nginx:alpine

# Same config as docker-compose: serves the app and proxies /api/ to the
# gateway service. Listen on 3000 to match the Kubernetes manifests.
COPY nginx.conf /etc/nginx/conf.d/default.conf
RUN sed -i 's/listen 80;/listen 3000;/' /etc/nginx/conf.d/default.conf

COPY --from=build /app/build /usr/share/nginx/html

EXPOSE 3000

CMD ["nginx", "-g", "daemon off;"]
