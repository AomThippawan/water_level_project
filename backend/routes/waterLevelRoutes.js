const express = require('express');
const router = express.Router();
const waterLevelController = require('../controllers/waterLevelController');

router.get('/', waterLevelController.getAllWaterLevels);

module.exports = router;
