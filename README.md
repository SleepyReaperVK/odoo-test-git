# Odoo Custom POS Development

## Overview
A customized Odoo 18.0 Point of Sale system designed specifically for bars, restaurants, and kiosks. This project focuses on creating an efficient, user-friendly POS system with custom features tailored for the hospitality industry.

## Features
- Custom POS interface
- Kitchen order validation
- ESC/POS printer integration
- Custom receipt formatting
- Employee access management
- Menu layout customization
- XZ reporting system
- Dejavoo credit integration
- Restaurant access management
- Custom percentage tip handling

## Tech Stack
- Python: 40.8%
- JavaScript: 40.3%
- SCSS: 2.8%
- HTML: 0.1%
- Docker for deployment
- GitHub Actions for CI/CD

## Prerequisites
- Docker
- Git
- PostgreSQL
- Python 3.10+
- Node.js 16+

## Installation

### Docker Setup
```bash
# Clone the repository
git clone https://github.com/SleepyReaperVK/odoo-test-git
cd odoo-test-git

# Build and run with Docker
docker-compose up -d
```

### Manual Setup
```bash
# Clone the repository
git clone https://github.com/SleepyReaperVK/odoo-test-git
cd odoo-test-git

# Create Python virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Initialize database
./setup.py
```

## Module Structure
```
custom_modules/
├── cr_kitchen_order_validation/
├── cr_pos_custom_receipt/
├── pos_custom_percentage_tip_fixed/
├── pos_dejavoo_zcredit/
├── pos_menu_layout/
└── [other modules...]
```

## Development

### Setting Up Development Environment
1. Fork the repository
2. Create a feature branch
3. Set up local development environment
4. Make your changes
5. Submit a pull request

### Contribution Guidelines
- Follow PEP 8 style guide for Python code
- Use ESLint for JavaScript
- Write meaningful commit messages
- Add tests for new features
- Update documentation as needed

## Testing
```bash
# Run Python tests
pytest

# Run JavaScript tests
npm test
```

# Cloud Deployment

## Overview
This guide covers deploying the Odoo POS system to various cloud environments while maintaining multiple branches for development, staging, and production.

## Cloud Infrastructure Setup

### Prerequisites
- Cloud provider account (AWS, GCP, or Azure)
- Docker and Docker Compose installed on cloud instances
- Domain name (for production)
- SSL certificates
- Access to container registry

### Environment Configuration

#### Development Branch
```bash
# Create development environment variables
cat > .env.development <<EOF
ODOO_HOST=odoo-dev.yourdomain.com
POSTGRES_USER=odoo_dev
POSTGRES_PASSWORD=dev_secure_password
POSTGRES_DB=odoo_dev
ODOO_ADMIN_PASSWORD=admin_dev_password
EOF
```

#### Staging Branch
```bash
# Create staging environment variables
cat > .env.staging <<EOF
ODOO_HOST=odoo-staging.yourdomain.com
POSTGRES_USER=odoo_staging
POSTGRES_PASSWORD=staging_secure_password
POSTGRES_DB=odoo_staging
ODOO_ADMIN_PASSWORD=admin_staging_password
EOF
```

#### Production Branch
```bash
# Create production environment variables
cat > .env.production <<EOF
ODOO_HOST=odoo.yourdomain.com
POSTGRES_USER=odoo_prod
POSTGRES_PASSWORD=prod_secure_password
POSTGRES_DB=odoo_prod
ODOO_ADMIN_PASSWORD=admin_prod_password
EOF
```

## Deployment Steps

### 1. Container Registry Setup
```bash
# Build and tag images for different environments
docker build -t your-registry.com/odoo-pos:dev -f Dockerfile.dev .
docker build -t your-registry.com/odoo-pos:staging -f Dockerfile.staging .
docker build -t your-registry.com/odoo-pos:prod -f Dockerfile.prod .

# Push images to registry
docker push your-registry.com/odoo-pos:dev
docker push your-registry.com/odoo-pos:staging
docker push your-registry.com/odoo-pos:prod
```

### 2. Database Management
```bash
# Initialize database with base modules
docker-compose -f docker-compose.prod.yml run --rm odoo initdb

# Install required custom modules
docker-compose -f docker-compose.prod.yml run --rm odoo install-modules
```

### 3. Automatic Module Installation
Create an `auto_install.py` script:
```python
import xmlrpc.client

def install_modules(url, db, username, password):
    common = xmlrpc.client.ServerProxy('{}/xmlrpc/2/common'.format(url))
    uid = common.authenticate(db, username, password, {})
    models = xmlrpc.client.ServerProxy('{}/xmlrpc/2/object'.format(url))
    
    # List of modules to install
    modules = [
        'cr_kitchen_order_validation',
        'cr_pos_custom_receipt',
        'pos_custom_percentage_tip_fixed',
        'pos_dejavoo_zcredit',
        'pos_menu_layout'
    ]
    
    for module in modules:
        models.execute_kw(db, uid, password,
            'ir.module.module', 'button_immediate_install',
            [[models.execute_kw(db, uid, password,
                'ir.module.module', 'search',
                [[['name', '=', module]]])[0]]])

if __name__ == '__main__':
    install_modules('http://localhost:8069', 'odoo_prod', 'admin', 'admin_prod_password')
```

### 5. SSL Configuration
```nginx
# Nginx configuration for SSL
server {
    listen 443 ssl;
    server_name odoo.yourdomain.com;

    ssl_certificate /etc/letsencrypt/live/odoo.yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/odoo.yourdomain.com/privkey.pem;

    location / {
        proxy_pass http://localhost:8069;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### 6. Monitoring Setup
```yaml
# prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'odoo'
    static_configs:
      - targets: ['localhost:9090']
```

### 7. Backup Configuration
```bash
#!/bin/bash
# backup.sh
DATE=$(date +%Y%m%d_%H%M%S)
docker-compose exec db pg_dump -U odoo_prod odoo_prod > backup_${DATE}.sql
aws s3 cp backup_${DATE}.sql s3://your-bucket/backups/
```

## Branch Management

### Development Workflow
```bash
# Create feature branch
git checkout -b feature/new-feature develop

# After development
git checkout develop
git merge --no-ff feature/new-feature
git push origin develop

# Deploy to staging
git checkout staging
git merge --no-ff develop
git push origin staging

# Deploy to production
git checkout main
git merge --no-ff staging
git push origin main
```

## Troubleshooting

### Common Issues
1. Database connection failures
   - Check PostgreSQL container logs
   - Verify environment variables
   - Confirm network configuration

2. Module installation failures
   - Check Odoo logs for dependencies
   - Verify module path in addons
   - Confirm module compatibility

3. Performance issues
   - Monitor resource usage
   - Check worker configuration
   - Optimize queries

### Monitoring
- Set up Prometheus for metrics
- Configure Grafana dashboards
- Enable Odoo logging
- Monitor system resources

## Security Considerations
- Use secure passwords
- Implement IP restrictions
- Regular security updates
- Enable audit logging
- Backup encryption
- SSL/TLS configuration

## Rollback Procedures
```bash
# Revert to previous version
git checkout main^
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml up -d

# Restore database
docker-compose -f docker-compose.prod.yml exec db psql -U odoo_prod odoo_prod < backup_file.sql
```

## Deployment
The project uses GitHub Actions for automated building and deployment. The workflow includes:
- Code checkout
- Docker build setup
- GitHub Container Registry login
- Image building and pushing
- Automated deployment

## CI/CD Pipeline
- Automated testing on push
- Docker image building
- Deployment to staging/production
- Backup creation

## Documentation
- [Odoo Official Documentation](https://www.odoo.com/documentation/18.0/)
- [Developer Tutorials](https://www.odoo.com/documentation/18.0/developer.html)
- [API Reference](https://www.odoo.com/documentation/18.0/reference.html)

## Support
For issues and feature requests, please use the GitHub issue tracker.

## License
This project is licensed under the GNU Lesser General Public License v3.0 - see the LICENSE file for details.

## Contributors
- SleepyReaperVK (Lead Developer)

## Acknowledgments
- Odoo Community
- Contributors to dependent modules
- Testing team members
