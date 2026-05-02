const express = require('express');
const router = express.Router();
const { getMyStats } = require('../controllers/statsController');

router.get('/my', getMyStats);

module.exports = router;
