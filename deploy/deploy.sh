echo "welcome to dify! choose from an option below:"
echo "a) install"
echo "b) upgrade"
echo "c) start"
echo "d) stop"
echo "e) restart"

read -p "Enter your choice: " choice

case $choice in
  a | i | install)
    echo "Starting installation..."
    # Download docker-compose.yaml
    if curl -o docker-compose.yaml https://github.com/langgenius/dify/blob/main/docker/docker-compose.yaml; then
      echo "docker-compose.yaml downloaded successfully."
    else
      echo "Failed to download docker-compose.yaml."
      exit 1
    fi

    # Download docker-compose.https.yaml
    if curl -o docker-compose.https.yaml https://github.com/langgenius/dify/blob/main/docker/docker-compose.https.yaml; then
      echo "docker-compose.https.yaml downloaded successfully."
    else
      echo "Failed to download docker-compose.https.yaml."
      exit 1
    fi

    # Download nginx config
    if mkdir -p nginx && cd nginx && curl -L https://github.com/langgenius/dify/tree/main/docker/nginx | tar -xz --strip=1; then
      echo "Nginx directory downloaded successfully."
      cd ..
    else
      echo "Failed to download nginx directory."
      exit 1
    fi

    # Download .env example and rename it
    if curl -o .env https://github.com/langgenius/dify/tree/main/docker/env/.env.example; then
      echo ".env configuration file downloaded and renamed successfully."
    else
      echo "Failed to download .env configuration file."
      exit 1
    fi

    echo "Installation complete."
    ;;
  b | u | upgrade)
    echo "Upgrade option selected."
    echo "Stopping all services..."
    docker-compose down
    echo "Downloading the latest docker-compose.yaml..."
    if curl -o docker-compose.yaml https://github.com/langgenius/dify/blob/main/docker/docker-compose.yaml; then
      echo "docker-compose.yaml updated successfully."
    else
      echo "Failed to update docker-compose.yaml."
      exit 1
    fi
    echo "Downloading the latest docker-compose.https.yaml..."
    if curl -o docker-compose.https.yaml https://github.com/langgenius/dify/blob/main/docker/docker-compose.https.yaml; then
      echo "docker-compose.https.yaml updated successfully."
    else
      echo "Failed to update docker-compose.https.yaml."
      exit 1
    fi
    echo "Downloading latest .env.example..."
    if curl -o .env https://github.com/langgenius/dify/tree/main/docker/env/.env.example; then
      echo ".env configuration file updated successfully."
    else
      echo "Failed to update .env configuration file."
      exit 1
    fi
    echo "Downloading the latest nginx configs..."
    cd nginx
    if curl -L https://github.com/langgenius/dify/tree/main/docker/nginx | tar -xz --strip=1; then
      echo "Nginx directory updated successfully."
      cd ..
    else
      echo "Failed to update nginx directory."
      exit 1
    fi
    cd ..

    echo "Upgrade complete."
    ;;
  c | s | start)
    echo "Start option selected."
    echo "Starting all services..."
    if [ -f .env ]; then
      DIFY_HTTPS_ENABLED=$(grep -oP '^HTTPS_ENABLED=\K.*' .env)
    fi

    if [ "${DIFY_HTTPS_ENABLED}" = "true" ]; then
      if ! docker-compose -f docker-compose.yaml -f docker-compose.https.yaml up -d; then
        echo "Failed to start services with HTTPS enabled."
        exit 1
      fi
    else
      if ! docker-compose up -d; then
        echo "Failed to start services."
        exit 1
      fi
    fi
    echo "Dify has been started successfully."
    ;;
  d | stop)
    echo "Stop option selected."
    echo "Stopping all services..."
    docker-compose down
    echo "Dify has been stopped successfully."
    ;;
  e | r | restart)
    echo "Restart option selected."
    echo "Stopping all services..."
    docker-compose down
    echo "Starting all services..."
    if [ -f .env ]; then
      DIFY_HTTPS_ENABLED=$(grep -oP '^HTTPS_ENABLED=\K.*' .env)
    fi
    if [ "${DIFY_HTTPS_ENABLED:-false}" = "true" ]; then
      docker-compose -f docker-compose.yaml -f docker-compose.https.yaml up -d
    else
      docker-compose up -d
    fi
    echo "Dify has been restarted successfully."
    ;;
  *)
    echo "Invalid option selected."
    ;;
esac
