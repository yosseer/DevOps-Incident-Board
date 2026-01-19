const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 8080;
// Default backend target — in Kubernetes/Docker stacks this can be 'http://api:8080'
const BACKEND_URL = process.env.BACKEND_URL || 'http://backend:8080';

// Proxy /api requests to backend
app.use('/api', createProxyMiddleware({
  target: BACKEND_URL,
  changeOrigin: true,
  pathRewrite: { '^/api': '/api' },
  onProxyReq: (proxyReq, req, res) => {
    // preserve client IP forwarding headers
    proxyReq.setHeader('X-Forwarded-For', req.ip || req.headers['x-forwarded-for'] || '');
  }
}));

// Serve static files from the UI folder root
app.use(express.static(path.join(__dirname)));

// Fallback to index.html for SPA-style routes
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'index.html'));
});

app.listen(PORT, () => {
  console.log(`Beeper UI server listening on port ${PORT}, proxying /api -> ${BACKEND_URL}`);
});
