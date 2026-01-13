// Mock Backend API for Incident Board Testing
const express = require('express');
const cors = require('cors');
const app = express();
const PORT = 8080;

app.use(cors());
app.use(express.json());

// In-memory storage
let incidents = [
  {
    id: 1,
    title: "Production Database Connection Timeout",
    description: "Users unable to access application due to database connectivity issues",
    severity: "CRITICAL",
    status: "INVESTIGATING",
    createdAt: new Date(Date.now() - 300000).toISOString(),
    createdBy: "Mohamed Ben Ali"
  },
  {
    id: 2,
    title: "API Response Times Increased",
    description: "Average response time increased by 200ms across all endpoints",
    severity: "HIGH",
    status: "OPEN",
    createdAt: new Date(Date.now() - 3600000).toISOString(),
    createdBy: "Fatma Bouazizi"
  },
  {
    id: 3,
    title: "Memory Usage Spike on Server 3",
    description: "Memory utilization reached 85% on production server",
    severity: "MEDIUM",
    status: "RESOLVED",
    createdAt: new Date(Date.now() - 7200000).toISOString(),
    createdBy: "Ahmed Trabelsi",
    resolutionComment: "Restarted application pods and cleared memory cache",
    resolvedBy: "Youssef Hammami",
    resolvedAt: new Date(Date.now() - 3600000).toISOString()
  },
  {
    id: 4,
    title: "Minor UI Alignment Issue",
    description: "Button slightly misaligned on mobile devices",
    severity: "LOW",
    status: "OPEN",
    createdAt: new Date(Date.now() - 10800000).toISOString(),
    createdBy: "Amira Chaabane"
  },
  {
    id: 5,
    title: "SSL Certificate Expiry Warning",
    description: "Certificate expires in 7 days for api.example.com",
    severity: "HIGH",
    status: "RESOLVED",
    createdAt: new Date(Date.now() - 14400000).toISOString(),
    createdBy: "Khalil Mansouri",
    resolutionComment: "Renewed certificate and updated load balancer",
    resolvedBy: "Nour El Houda",
    resolvedAt: new Date(Date.now() - 10800000).toISOString()
  },
  {
    id: 6,
    title: "Disk Space Running Low on DB Server",
    description: "Only 15% disk space remaining",
    severity: "MEDIUM",
    status: "RESOLVED",
    createdAt: new Date(Date.now() - 18000000).toISOString(),
    createdBy: "Rania Belhadj",
    resolutionComment: "Cleaned old logs and archived data",
    resolvedBy: "Youssef Hammami",
    resolvedAt: new Date(Date.now() - 14400000).toISOString()
  },
  {
    id: 7,
    title: "Failed Deployment to Staging",
    description: "CI/CD pipeline failed at integration test stage",
    severity: "MEDIUM",
    status: "RESOLVED",
    createdAt: new Date(Date.now() - 21600000).toISOString(),
    createdBy: "Amine Jebali",
    resolutionComment: "Fixed failing test and redeployed",
    resolvedBy: "Sami Khelifi",
    resolvedAt: new Date(Date.now() - 18000000).toISOString()
  },
  {
    id: 8,
    title: "Cache Invalidation Issue",
    description: "Users seeing stale data after updates",
    severity: "HIGH",
    status: "RESOLVED",
    createdAt: new Date(Date.now() - 25200000).toISOString(),
    createdBy: "Mariem Gharbi",
    resolutionComment: "Implemented proper cache busting strategy",
    resolvedBy: "Nour El Houda",
    resolvedAt: new Date(Date.now() - 21600000).toISOString()
  },
  {
    id: 9,
    title: "Network Latency in Tunisia DC",
    description: "High latency detected between Tunis and Sfax data centers",
    severity: "HIGH",
    status: "INVESTIGATING",
    createdAt: new Date(Date.now() - 1800000).toISOString(),
    createdBy: "Houssem Mejri"
  },
  {
    id: 10,
    title: "Authentication Service Down",
    description: "Users cannot login to the platform",
    severity: "CRITICAL",
    status: "OPEN",
    createdAt: new Date(Date.now() - 600000).toISOString(),
    createdBy: "Ines Ben Salah"
  },
  {
    id: 11,
    title: "Backup Job Failed",
    description: "Nightly backup job failed for production database",
    severity: "MEDIUM",
    status: "RESOLVED",
    createdAt: new Date(Date.now() - 28800000).toISOString(),
    createdBy: "Bilel Sassi",
    resolutionComment: "Fixed storage permissions and re-ran backup successfully",
    resolvedBy: "Sami Khelifi",
    resolvedAt: new Date(Date.now() - 25200000).toISOString()
  },
  {
    id: 12,
    title: "Email Notification Delay",
    description: "Email notifications are delayed by 30 minutes",
    severity: "LOW",
    status: "OPEN",
    createdAt: new Date(Date.now() - 5400000).toISOString(),
    createdBy: "Hajer Mahjoub"
  }
];

let nextId = 13;

// Health check
app.get('/api/incidents/health', (req, res) => {
  res.send('OK');
});

// Get all incidents
app.get('/api/incidents', (req, res) => {
  const sorted = [...incidents].sort((a, b) => 
    new Date(b.createdAt) - new Date(a.createdAt)
  );
  res.json(sorted);
});

// Get single incident
app.get('/api/incidents/:id', (req, res) => {
  const incident = incidents.find(i => i.id === parseInt(req.params.id));
  if (incident) {
    res.json(incident);
  } else {
    res.status(404).json({ error: 'Incident not found' });
  }
});

// Create incident
app.post('/api/incidents', (req, res) => {
  const newIncident = {
    id: nextId++,
    title: req.body.title,
    description: req.body.description || '',
    severity: req.body.severity || 'MEDIUM',
    status: req.body.status || 'OPEN',
    createdAt: new Date().toISOString(),
    createdBy: req.body.createdBy || 'Anonymous'
  };
  
  incidents.push(newIncident);
  console.log(`Created incident: ${newIncident.title}`);
  res.status(201).json(newIncident);
});

// Update incident status
app.patch('/api/incidents/:id/status', (req, res) => {
  console.log('PATCH request received:', req.body);
  const incident = incidents.find(i => i.id === parseInt(req.params.id));
  if (incident) {
    incident.status = req.body.status;
    
    // Handle resolution fields
    if (req.body.status === 'RESOLVED') {
      incident.resolutionComment = req.body.resolutionComment || null;
      incident.resolvedBy = req.body.resolvedBy || null;
      incident.resolvedAt = req.body.resolvedAt || new Date().toISOString();
      console.log(`Resolved by: ${incident.resolvedBy}`);
    } else {
      // Clear resolution fields if reopening
      incident.resolutionComment = null;
      incident.resolvedBy = null;
      incident.resolvedAt = null;
    }
    
    console.log(`Updated incident ${incident.id}:`, incident);
    res.json(incident);
  } else {
    res.status(404).json({ error: 'Incident not found' });
  }
});

// Delete incident
app.delete('/api/incidents/:id', (req, res) => {
  const index = incidents.findIndex(i => i.id === parseInt(req.params.id));
  if (index !== -1) {
    const deleted = incidents.splice(index, 1)[0];
    console.log(`Deleted incident: ${deleted.title}`);
    res.status(204).send();
  } else {
    res.status(404).json({ error: 'Incident not found' });
  }
});

app.listen(PORT, () => {
  console.log('');
  console.log('========================================');
  console.log('  Mock Incident API Server');
  console.log('========================================');
  console.log('');
  console.log(`Server running on http://localhost:${PORT}`);
  console.log(`API endpoint: http://localhost:${PORT}/api/incidents`);
  console.log(`Health check: http://localhost:${PORT}/api/incidents/health`);
  console.log('');
  console.log(`Currently loaded with ${incidents.length} sample incidents`);
  console.log('');
  console.log('Press Ctrl+C to stop');
  console.log('========================================');
  console.log('');
});
