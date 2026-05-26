const path = require('path');
const express = require('express');
const cors = require('cors');
const swaggerUi = require('swagger-ui-express');
const { PORT, assertServerSettings } = require('./config-server-settings');

const openapiPath = path.join(__dirname, '..', 'openapi.yaml');

assertServerSettings();
const adminLoginRoutes = require('./route-admin-login');
const adminDataRoutes = require('./route-admin-data');
const adminReceiptRoutes = require('./route-admin-receipts');
const adminCardRoutes = require('./route-admin-cards');
const adminUserRoutes = require('./route-admin-users');

const app = express();
const adminDir = path.resolve(__dirname, '..', '..', 'web', 'admin');

app.use(cors());
app.use(express.json({ limit: '1mb' }));

app.get('/api/docs/openapi.yaml', (_req, res) => {
  res.type('application/yaml').sendFile(openapiPath);
});
app.use('/api/docs', swaggerUi.serve, swaggerUi.setup(null, {
  swaggerOptions: { url: '/api/docs/openapi.yaml' }
}));

app.use('/api/admin', adminLoginRoutes);
app.use('/api/admin', adminDataRoutes);
app.use('/api/admin', adminReceiptRoutes);
app.use('/api/admin', adminCardRoutes);
app.use('/api/admin', adminUserRoutes);
app.get('/admin/config.local.js', (_req, res) => res.sendStatus(404));
app.use('/admin', express.static(adminDir));
app.get('/', (_req, res) => res.redirect('/admin/'));
app.get('/admin', (_req, res) => res.redirect('/admin/'));

app.listen(PORT, () => {
  console.log(`Admin server running at http://localhost:${PORT}/admin/`);
  console.log(`API docs (Swagger UI) at http://localhost:${PORT}/api/docs`);
});
