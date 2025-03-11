const mongoose = require('mongoose');

const WaterLevelSchema = new mongoose.Schema({
  level: { type: Number, required: true },
  distance: { type: Number, required: true },
  date: { type: String, required: true },
  time: { type: String, required: true }
}, { collection: 'water_levels' });

// แปลง timestamp ก่อนบันทึกลง MongoDB
WaterLevelSchema.pre('save', function (next) {
  const now = new Date();
  this.date = now.toISOString().split('T')[0]; // YYYY-MM-DD
  this.time = now.toTimeString().split(' ')[0]; // HH:MM:SS
  next();
});

const WaterLevel = mongoose.model('WaterLevel', WaterLevelSchema);

module.exports = WaterLevel;

