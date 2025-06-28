# Smart Airport Application - Ansible Deployment

This directory contains Ansible playbooks and roles for deploying the Smart Airport application to on-premises servers.

## Directory Structure

```
ansible/
├── ansible.cfg                 # Ansible configuration
├── inventory/
│   └── onprems                # On-premises inventory file
├── roles/
│   ├── docker_install/        # Docker installation role
│   ├── docker_compose/        # Docker Compose deployment role
│   └── deploy_dockercommunity/ # Docker Community modules deployment role
├── playbooks/
│   ├── deploy-full.yml        # Full deployment (Docker + App)
│   ├── deploy-app-only.yml    # Application update only
│   └── docker-community.yml   # Docker Community deployment
├── site.yml                   # Main deployment playbook
└── README.md                  # This file
```

## Prerequisites

1. **Ansible Control Node:**
   - Ansible 2.9+ installed
   - SSH access to target servers
   - Python 3.6+ installed

2. **Target Servers:**
   - Ubuntu 18.04+ or CentOS 7+
   - SSH access configured
   - Sudo privileges for the deployment user
   - Python 3.6+ installed

## Configuration

### 1. Update Inventory

Edit `inventory/onprems` to match your server configuration:

```ini
[on_prems]
server_01 ansible_host=YOUR_SERVER_IP ansible_user=YOUR_USER
```

### 2. SSH Key Setup

Ensure SSH key-based authentication is configured:

```bash
ssh-copy-id user@your-server-ip
```

### 3. Environment Variables

You can override default variables by:
- Editing inventory group variables
- Using command-line extra variables
- Creating host-specific variable files

## Deployment Options

### Option 1: Full Deployment (Recommended for new servers)

Installs Docker and deploys the application:

```bash
ansible-playbook playbooks/deploy-full.yml -i inventory/onprems
```

### Option 2: Application Update Only

Updates only the application (assumes Docker is installed):

```bash
ansible-playbook playbooks/deploy-app-only.yml -i inventory/onprems -e "build_number=v1.2.3"
```

### Option 3: Docker Community Deployment

Uses Docker Community collection modules:

```bash
ansible-playbook playbooks/docker-community.yml -i inventory/onprems
```

### Option 4: Custom Role Selection

Use the main site.yml with custom role selection:

```bash
ansible-playbook site.yml -i inventory/onprems -e "selected_roles=['docker_install','docker_compose']"
```

## Available Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `build_number` | `latest` | Docker image tag to deploy |
| `environment` | `production` | Deployment environment |
| `app_port` | `8000` | Application port |
| `nginx_port` | `80` | Nginx port |
| `cleanup_docker_images` | `true` | Clean up unused Docker images |
| `selected_roles` | `['docker_install', 'docker_compose']` | Roles to execute |

## Examples

### Deploy specific version:
```bash
ansible-playbook playbooks/deploy-full.yml -i inventory/onprems -e "build_number=v2.1.0"
```

### Deploy to staging environment:
```bash
ansible-playbook site.yml -i inventory/staging -e "environment=staging"
```

### Deploy with custom ports:
```bash
ansible-playbook playbooks/deploy-full.yml -i inventory/onprems -e "app_port=8080 nginx_port=8081"
```

## Roles Description

### docker_install
- Installs Docker CE and Docker Compose
- Configures Docker daemon
- Adds users to docker group
- Supports Ubuntu/Debian and CentOS/RHEL

### docker_compose
- Deploys application using Docker Compose
- Manages configuration files
- Handles service lifecycle
- Includes health checks

### deploy_dockercommunity
- Alternative deployment using Docker Community collection
- Direct container management
- Network and volume management

## Troubleshooting

### Check service status:
```bash
ansible on_prems -i inventory/onprems -m command -a "docker ps"
```

### View logs:
```bash
ansible on_prems -i inventory/onprems -m command -a "docker logs smart-airport-web"
```

### Restart services:
```bash
ansible-playbook playbooks/deploy-app-only.yml -i inventory/onprems --tags restart
```

## Security Considerations

1. Use SSH key authentication
2. Configure firewall rules appropriately
3. Regularly update Docker and system packages
4. Use secrets management for sensitive data
5. Enable Docker daemon logging

## Monitoring

After deployment, verify the application is running:

- Application: `http://your-server-ip:80`
- Direct app access: `http://your-server-ip:8000`
- Health check: `http://your-server-ip/health`

## Support

For issues or questions:
1. Check the Ansible logs: `tail -f ansible.log`
2. Verify inventory configuration
3. Ensure SSH connectivity
4. Check Docker service status on target servers
