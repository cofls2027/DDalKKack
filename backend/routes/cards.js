const express = require('express');
const router = express.Router();
const { getCards } = require('../controllers/cardsController');

router.get('/', getCards);

module.exports = router;
