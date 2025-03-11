const WaterLevel = require('../models/WaterLevel');

exports.getAllWaterLevels = async (req, res) => {
  try {
    const data = await WaterLevel.find();
    res.json(data);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
