# ===========================
# Common Base Image Setup
# ===========================
ARG BASE_IMAGE=almalinux:latest
FROM $BASE_IMAGE

# Pass BASE_IMAGE as an environment variable for the shell
ARG BASE_IMAGE
ENV BASE_IMAGE=$BASE_IMAGE

# ===========================
# Install Required Packages Based on Distribution
# ===========================
RUN if [ "$BASE_IMAGE" = "alpine:latest" ]; then apk update && apk add --no-cache openssh python3 bash; fi
RUN if [ "$BASE_IMAGE" = "archlinux:latest" ]; then pacman -Syu --noconfirm && pacman -S --noconfirm openssh python3; fi
RUN if [ "$BASE_IMAGE" = "almalinux:latest" ]; then yum update -y && yum install -y openssh-server; fi
RUN if [ "$BASE_IMAGE" = "ubuntu:latest" ]; then apt update && apt install -y openssh-server; fi

# ===========================
# SSH Configuration
# ===========================
# Initialize SSH server and update configuration
RUN mkdir /var/run/sshd && ssh-keygen -A

# Configure SSH settings
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Fix SSH login issue
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd || true

# Ensure SSH visibility in profiles
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

# ===========================
# Shell and Prompt Customization
# ===========================
RUN echo "PS1='\[\e[1;31m\][\[\e[32m\]\u\[\e[31m\]@\[\e[33m\]\h \[\e[34m\]\W\[\e[31m\]]\[\e[31m\]$\[\e[0m\] '" >> /etc/profile.d/ps1.sh

# ===========================
# Expose Ports and Start Services
# ===========================
EXPOSE 22

# Copy Entrypoint Script
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

## Start SSH and switch to the user with a proper shell
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
