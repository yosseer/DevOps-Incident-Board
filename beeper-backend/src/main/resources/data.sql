-- Sample Incidents Data with Tunisian Names
-- This file is automatically executed by Spring Boot on startup

-- Critical Incidents
INSERT INTO incidents (title, description, severity, status, created_by, created_at) VALUES
('Production Database Connection Failure', 'Users unable to access the application due to database connectivity issues. Multiple connection timeouts reported.', 'CRITICAL', 'INVESTIGATING', 'Mohamed Ben Ali', CURRENT_TIMESTAMP - INTERVAL '2' HOUR);

INSERT INTO incidents (title, description, severity, status, created_by, created_at) VALUES
('Payment Gateway Down', 'All payment transactions are failing. E-commerce platform completely affected.', 'CRITICAL', 'OPEN', 'Fatma Bouazizi', CURRENT_TIMESTAMP - INTERVAL '30' MINUTE);

-- High Severity Incidents
INSERT INTO incidents (title, description, severity, status, created_by, created_at) VALUES
('API Response Times Increased by 500%', 'Average response time increased from 200ms to over 1 second across all endpoints. Customer complaints rising.', 'HIGH', 'INVESTIGATING', 'Ahmed Trabelsi', CURRENT_TIMESTAMP - INTERVAL '4' HOUR);

INSERT INTO incidents (title, description, severity, status, created_by, created_at) VALUES
('Email Service Not Sending Notifications', 'Transactional emails including password resets and order confirmations are not being delivered.', 'HIGH', 'OPEN', 'Amira Chaabane', CURRENT_TIMESTAMP - INTERVAL '1' HOUR);

INSERT INTO incidents (title, description, severity, status, created_by, created_at) VALUES
('Load Balancer Health Check Failures', 'Two out of five backend servers failing health checks intermittently.', 'HIGH', 'INVESTIGATING', 'Youssef Hammami', CURRENT_TIMESTAMP - INTERVAL '3' HOUR);

-- Medium Severity Incidents
INSERT INTO incidents (title, description, severity, status, created_by, created_at) VALUES
('Memory Usage Spike on Server 3', 'Memory utilization reached 85% on production server. Performance slightly degraded.', 'MEDIUM', 'RESOLVED', 'Nour Mansouri', CURRENT_TIMESTAMP - INTERVAL '6' HOUR);

INSERT INTO incidents (title, description, severity, status, created_by, created_at, resolved_by, resolved_at, resolution_comment) VALUES
('SSL Certificate Expiring Soon', 'SSL certificate for api.company.com expires in 7 days. Needs renewal.', 'MEDIUM', 'RESOLVED', 'Khalil Jebali', CURRENT_TIMESTAMP - INTERVAL '12' HOUR, 'Sami Belhaj', CURRENT_TIMESTAMP - INTERVAL '8' HOUR, 'Certificate renewed for another 2 years. Auto-renewal configured.');

INSERT INTO incidents (title, description, severity, status, created_by, created_at) VALUES
('Disk Space Warning on Log Server', 'Log server disk usage at 78%. Need to implement log rotation.', 'MEDIUM', 'OPEN', 'Rim Gharbi', CURRENT_TIMESTAMP - INTERVAL '5' HOUR);

INSERT INTO incidents (title, description, severity, status, created_by, created_at, resolved_by, resolved_at, resolution_comment) VALUES
('CDN Cache Invalidation Issues', 'Static assets not updating properly after deployment. Users seeing old versions.', 'MEDIUM', 'RESOLVED', 'Amine Sfaxi', CURRENT_TIMESTAMP - INTERVAL '8' HOUR, 'Youssef Hammami', CURRENT_TIMESTAMP - INTERVAL '6' HOUR, 'Manually purged CDN cache and fixed deployment pipeline to auto-invalidate.');

-- Low Severity Incidents  
INSERT INTO incidents (title, description, severity, status, created_by, created_at) VALUES
('Minor UI Alignment Issue on Mobile', 'Submit button slightly misaligned on iPhone SE screen size.', 'LOW', 'OPEN', 'Ines Mejri', CURRENT_TIMESTAMP - INTERVAL '24' HOUR);

INSERT INTO incidents (title, description, severity, status, created_by, created_at, resolved_by, resolved_at, resolution_comment) VALUES
('Typo in Error Message', 'Error message shows "Somthing went wrong" instead of "Something went wrong".', 'LOW', 'RESOLVED', 'Houssem Dali', CURRENT_TIMESTAMP - INTERVAL '48' HOUR, 'Ines Mejri', CURRENT_TIMESTAMP - INTERVAL '46' HOUR, 'Fixed typo in error messages file and deployed hotfix.');

INSERT INTO incidents (title, description, severity, status, created_by, created_at) VALUES
('Documentation Outdated for v2 API', 'API documentation still references deprecated v1 endpoints.', 'LOW', 'INVESTIGATING', 'Mariem Khelifi', CURRENT_TIMESTAMP - INTERVAL '72' HOUR);

INSERT INTO incidents (title, description, severity, status, created_by, created_at, resolved_by, resolved_at, resolution_comment) VALUES
('Slow Query on Reports Page', 'Reports page taking 5+ seconds to load for large date ranges.', 'MEDIUM', 'RESOLVED', 'Anis Belhadj', CURRENT_TIMESTAMP - INTERVAL '10' HOUR, 'Ahmed Trabelsi', CURRENT_TIMESTAMP - INTERVAL '7' HOUR, 'Added database index on created_at column. Query now runs in under 500ms.');

INSERT INTO incidents (title, description, severity, status, created_by, created_at, resolved_by, resolved_at, resolution_comment) VALUES
('Redis Cache Eviction Rate High', 'Cache hit ratio dropped to 65%. Memory pressure causing frequent evictions.', 'HIGH', 'RESOLVED', 'Sofiene Ayari', CURRENT_TIMESTAMP - INTERVAL '15' HOUR, 'Mohamed Ben Ali', CURRENT_TIMESTAMP - INTERVAL '12' HOUR, 'Increased Redis memory allocation and optimized cache TTL settings.');
