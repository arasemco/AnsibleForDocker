# ===========================
# Common Base Image Setup
# ===========================
ARG BASE_IMAGE=almalinux:latest
FROM $BASE_IMAGE

# ===========================
# Install Required Packages Based on Distribution
# ===========================
RUN sh -c 'pm=$(command -v pacman || command -v yum || command -v apk || command -v apt) && \
    case "$pm" in \
        *pacman) pacman -Syu --noconfirm && pacman -S --noconfirm openssh python ;; \
        *yum) yum update -y && yum install -y openssh-server python3.12 ;; \
        *apk) apk update && apk add --no-cache openssh python3 bash ;; \
        *apt) apt update && apt install -y openssh-server python3 ;; \
        *) echo "Unsupported package manager" && exit 1 ;; \
    esac'

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
