# Design Decisions

## 1. Variables and Default Values

I kept the three variables from the assignment requirements:

- **`project_name`** (default: "test_assignment") - Prevents resource naming conflicts when running multiple deployments
- **`host_port`** (default: 8080) - Standard dev port, easy to change if needed with `-var="host_port=9090"`
- **`app_env`** (default: "test") - Gets passed to PHP so `/healthz` can report which environment it's running in

The defaults work immediately without configuration, but can be customized per deployment. That's the point of variables.

## 2. Connecting Nginx and PHP-FPM

I used different connection methods based on the deployment type:

**Terraform (Docker):** TCP connection via `test_assignment-php-fpm:9000` - This is required for containers since they're separate network namespaces. Docker DNS resolves the container name automatically.

**Ansible (bare-metal):** Unix socket at `/run/php/php8.3-fpm.sock` - Faster and more secure when both services run on the same machine. This is standard for Ubuntu/Debian systems.

Could have used TCP for both, but I chose the optimal method for each scenario.

## 3. Ensuring Idempotency in Ansible

Used Ansible's built-in features:

- **Declarative modules** (`apt`, `service`, `template`) check current state before making changes
- **Handlers** - Services only restart when configs actually change via `notify`
- **Template checksums** - Files only update if content differs

Verified by running the playbook twice - first run installed everything, second run showed `changed=0` across all tasks.

## 4. What /healthz Checks

The health endpoint validates the entire stack in one request:

- PHP-FPM is running and processing requests (502 error if not)
- Nginx successfully proxies to PHP-FPM via FastCGI
- Environment variable propagation works (`APP_ENV` → container → PHP)

Returns: `{"status":"ok","service":"nginx","env":"test"}`

This is a standard pattern for load balancers and monitoring systems. Kept it simple - just validates the Nginx→PHP connection works.

## 5. What I Would Improve

**If I had more time:**
- Add SSL/TLS support (currently HTTP only)
- Break Terraform into reusable modules for multi-environment deployments
- Add proper monitoring (Prometheus/Grafana)
- Write Molecule tests for the Ansible role
- Implement secrets management instead of plaintext env vars

I focused on meeting the requirements cleanly. These improvements would matter for production, but aren't needed for demonstrating the core concepts.