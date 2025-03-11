require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const waterLevelRoutes = require('./routes/waterLevelRoutes');

const app = express();
const PORT = process.env.PORT || 3035;
const MONGO_URI = process.env.MONGO_URI;

app.use(cors());
app.use(express.json());

app.use('/api/waterlevels', waterLevelRoutes);

mongoose.connect(MONGO_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true
}).then(() => {
  console.log('MongoDB Connected');
}).catch(err => {
  console.error('Error connecting to MongoDB:', err);
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on 0.0.0.0:${PORT}`);
});