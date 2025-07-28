# --- Stage 1: Builder ---
# This stage will build the application. It contains all the build tools
# but will be discarded after the build is complete.
FROM archlinux:latest AS builder

# Set a label for the maintainer
LABEL maintainer="Gemini"

# Install build dependencies
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm base-devel git sudo && \
    pacman -Scc --noconfirm

# Create a non-root user 'builder' to build the AUR package
RUN useradd --system --create-home builder && \
    echo "builder ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/builder

# Switch to the builder user
USER builder
WORKDIR /home/builder

# Clone and build the activitywatch-bin package.
# The AUR package conveniently installs all files into /opt/activitywatch
RUN git clone https://aur.archlinux.org/activitywatch-bin.git && \
    cd activitywatch-bin && \
    makepkg -si --noconfirm


# --- Stage 2: Final Image ---
# This is the final, lightweight image. It starts from a fresh base
# and only copies the application files from the builder stage.
FROM archlinux:latest

# Set a label for the maintainer
LABEL maintainer="Gemini"

# Update the system, install runtime dependencies, and then clean up.
# Cleaning the pacman cache in the same RUN command reduces image size.
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm nss && \
    pacman -Scc --noconfirm && \
    rm -rf /var/cache/pacman/pkg/* /var/lib/pacman/sync/*

# Copy the installed ActivityWatch application from the builder stage
COPY --from=builder /opt/activitywatch /opt/activitywatch

# Create and set permissions for data and config directories
RUN mkdir -p /root/.config/activitywatch && \
    mkdir -p /root/.local/share/activitywatch

# Copy the custom server configuration into the container
COPY aw-server.toml /root/.config/activitywatch/aw-server.toml

# Expose the default ActivityWatch port
EXPOSE 5600

# Define volumes for data and configuration persistence
VOLUME ["/root/.config/activitywatch", "/root/.local/share/activitywatch"]

# Set the working directory
WORKDIR /opt/activitywatch

# The command to run when the container starts.
# Corrected to point to the executable inside the subdirectory.
CMD ["./aw-server/aw-server", "--host=0.0.0.0", "--cors-origins=*"]
