const express = require('express');
const router = express.Router();
const { getRules } = require('../controllers/rulesController');

router.get('/', getRules);

module.exports = router;
