# Test: Nginx + PHP-FPM, Terraform, Ansible

[![Terraform CI](https://github.com/vladfreishmidt/sysadmin-infra-homework/actions/workflows/terraform.yml/badge.svg)](https://github.com/vladfreishmidt/sysadmin-infra-homework/actions/workflows/terraform.yml)
[![Ansible CI](https://github.com/vladfreishmidt/sysadmin-infra-homework/actions/workflows/ansible.yml/badge.svg)](https://github.com/vladfreishmidt/sysadmin-infra-homework/actions/workflows/ansible.yml)

This repository is a **template** for completing the test assignment. Full description is in [INSTRUCTIONS.md](./INSTRUCTIONS.md).

## What's already included

- Directory structure for Terraform/Ansible.
- Basic GitHub Actions workflows: `terraform.yml`, `ansible.yml`.
- Template files for `web` role (Ansible) and minimal Terraform configs.

## What the candidate needs to implement (briefly)

1. **Terraform**: describe `nginx` and `php-fpm` containers (docker provider), network and volume, variables and outputs.
2. **Ansible**: `web` role should deploy Nginx config, index.php, enable `nginx` and `php-fpm`, add logrotate.
3. Clean up and complete workflows (fmt/validate/plan + ansible-lint), optionally add Molecule tests for the role.
4. **README**: complete the steps below for running and testing (see "Local Run" section).

---

## Local Run

### Prerequisites

Ensure you have the following installed:
- **Docker** (20.10+): `docker --version`
- **Terraform** (1.6.0+): `terraform --version`
- **Ansible** (2.9+, optional): `ansible --version`

### Method 1: Terraform Deployment (Docker Containers)

```bash
# Clone repository
git clone https://github.com/vladfreishmidt/sysadmin-infra-homework.git
cd sysadmin-infra-homework

# Navigate to terraform directory
cd terraform

# Initialize Terraform
terraform init

# Validate configuration
terraform fmt -check
terraform validate

# Deploy infrastructure
terraform apply -auto-approve

# Wait for containers to fully start
sleep 15

# Clean up when done
terraform destroy -auto-approve
```

### Method 2: Ansible Deployment (Bare-Metal)

```bash
# Navigate to ansible directory
cd ansible

# Check syntax (optional)
ansible-playbook --syntax-check playbooks/site.yml

# Run playbook (requires sudo)
sudo ansible-playbook playbooks/site.yml

# Test idempotency - run again, should show changed=0
sudo ansible-playbook playbooks/site.yml
```

---

## Testing

### Health Check Endpoint

**For Terraform deployment**:
```bash
curl http://localhost:8080/healthz
```

Expected JSON:
```json
{"status":"ok","service":"nginx","env":"test"}
```

**For Ansible deployment**:
```bash
curl http://localhost/healthz
```

Expected JSON:
```json
{"status":"ok","service":"nginx","env":"dev"}
```

### Main Application Endpoint

**For Terraform**:
```bash
curl http://localhost:8080/
```

**For Ansible**:
```bash
curl http://localhost/
```

Expected response includes: message, environment, php_version, timestamp.

### Verify Containers/Services

**Terraform**:
```bash
docker ps
# Should show: test_assignment-nginx and test_assignment-php-fpm
```

**Ansible**:
```bash
sudo systemctl status nginx
sudo systemctl status php8.3-fpm
```

### Idempotency Verification

**Terraform**:
```bash
cd terraform
terraform plan
# Expected: "No changes. Your infrastructure matches the configuration."
```

**Ansible**:
```bash
cd ansible
sudo ansible-playbook playbooks/site.yml
# Second run should show: changed=0 in PLAY RECAP
```

---

## CI/CD

- **Actions** tab should be green: Terraform (fmt/validate/plan) and ansible-lint pass.
- View workflow runs: [GitHub Actions](https://github.com/vladfreishmidt/sysadmin-infra-homework/actions)

### Successful Workflow Runs

✅ **Terraform CI**: Format check, initialization, validation, and plan generation with artifact upload  
✅ **Ansible CI**: ansible-lint validation and syntax check

Both workflows run automatically on push and pull requests.

### GitHub Actions - All Workflows Passing

#### GitHub Actions Overview 

<img width="1903" height="791" alt="GitHub Actions Overview" src="https://github.com/user-attachments/assets/40fc0f72-f4be-481c-857a-96c7db6419b3" />

*Both Terraform and Ansible workflows passing validation.*

### Terraform Workflow Details

<img width="1902" height="698" alt="Terraform Workflow Details" src="https://github.com/user-attachments/assets/cf880ffa-2d9b-4cce-b79f-8e4cfc72987b" />

<img width="1904" height="796" alt="Terraform Workflow Details" src="https://github.com/user-attachments/assets/8ce4356b-9c4e-4b09-be55-b07dfdbea61a" />

*Format check, validation, plan generation with artifact upload.*

### Ansible Workflow Details

<img width="1902" height="614" alt="Ansible Workflow Details" src="https://github.com/user-attachments/assets/27e676a0-857e-4f3c-ad17-e8e5902f16b6" />

<img width="1904" height="548" alt="Ansible Workflow Details" src="https://github.com/user-attachments/assets/a3c88830-6fa1-416d-ba65-63be5002e609" />

*Ansible-lint and syntax validation passing.*

### Health Check Response

<img width="1608" height="701" alt="Health Check Response" src="https://github.com/user-attachments/assets/dbe938d1-dd95-4b10-88c3-9404e98d33c6" />

*curl http://localhost:8080/healthz returns expected JSON.*

### Running Containers

<img width="1608" height="1040" alt="Running Containers" src="https://github.com/user-attachments/assets/8e6c8a7e-db92-4e40-b266-a038ff0c6159" />

<img width="1608" height="313" alt="Running Containers" src="https://github.com/user-attachments/assets/76672eff-5901-4232-bb95-0d72d6f577d2" />

*Both nginx and php-fpm containers running with correct ports.*

---

## Useful Links

- Full task description: [INSTRUCTIONS.md](./INSTRUCTIONS.md)
- Solution rationale: [Decisions.md](./Decisions.md)

---

## Environment Details

**Tested on**:
- Ubuntu 24.04 Desktop
- AMD Ryzen 6-core, 16GB RAM
- Docker 24.0+, Terraform 1.6.0+, Ansible 2.9+

**Repository**: https://github.com/vladfreishmidt/sysadmin-infra-homework