# ActivityWatch via Docker on Arch Linux

This project runs the ActivityWatch server inside a Docker container using an Arch Linux base image.

## Prerequisites

* [Docker](https://docs.docker.com/get-docker/)
* [Docker Compose](https://docs.docker.com/compose/install/) (usually included with Docker Desktop)

## Project Structure

```
.
├── docker-compose.yml
├── Dockerfile
└── aw-server.toml
```

## How to Run

1.  **Build and Run with Docker Compose (Recommended):**
    Open a terminal, and run the following command:
    ```bash
    docker-compose up -d
    ```
    * `up` will build the image (if it doesn't exist) and start the service.
    * `-d` (detached mode) will run the container in the background.

3.  **Access the Web UI:**
    Once the container is running, open your web browser and navigate to:
    **[http://localhost:5600](http://localhost:5600)**

    You should see the ActivityWatch web interface.

## Data Persistence

This setup uses named Docker volumes (`aw-data` and `aw-config`) to store your ActivityWatch data and configuration. This means your data will persist even if you stop or remove the container.

If you prefer to store the data in a specific directory on your host machine (e.g., in the current project folder), you can modify the `docker-compose.yml` file like this:

```yaml
# ... (rest of the file)
    volumes:
      - ./data:/root/.local/share/activitywatch
      - ./config:/root/.config/activitywatch
# ... (remove the top-level 'volumes' key)
```
This will create `data` and `config` folders in your project directory.

## Managing the Container

* **To stop the container:**
    ```bash
    docker-compose down
    ```

* **To view logs:**
    ```bash
    docker-compose logs -f
    ```
