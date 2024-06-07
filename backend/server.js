// server.js
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const bodyParser = require('body-parser');
const multer = require('multer');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// MongoDB connection
mongoose.connect("mongodb+srv://root:root@cluster0.lsejrc8.mongodb.net/portfolio.image?retryWrites=true&w=majority&appName=Cluster0")
.then(() => console.log('MongoDB connected'))
.catch(err => console.log(err));

// Schema and Model
const imageSchema = new mongoose.Schema({
    filename: String,
    path: String,
    originalname: String,
    mimetype: String,
    size: Number,
    createdAt: { type: Date, default: Date.now }
});

const Image = mongoose.model('Image', imageSchema);

// Storage setup
const storage = multer.diskStorage({
    destination: './uploads',
    filename: (req, file, cb) => {
        cb(null, file.fieldname + '-' + Date.now() + path.extname(file.originalname));
    }
});

const upload = multer({
    storage: storage,
    limits: { fileSize: 1000000 }, // 1MB
    fileFilter: (req, file, cb) => {
        const filetypes = /jpeg|jpg|png|gif/;
        const extname = filetypes.test(path.extname(file.originalname).toLowerCase());
        const mimetype = filetypes.test(file.mimetype);
        if (mimetype && extname) {
            return cb(null, true);
        } else {
            cb('Error: Images Only!');
        }
    }
});

// Upload route
app.post('/upload', upload.single('photo'), (req, res) => {
    if (req.file == undefined) {
        return res.status(400).json({ msg: 'No file selected!' });
    }
    const newImage = new Image({
        filename: req.file.filename,
        path: req.file.path,
        originalname: req.file.originalname,
        mimetype: req.file.mimetype,
        size: req.file.size
    });
    newImage.save()
        .then(image => res.json(image))
        .catch(err => res.status(400).json({ msg: 'Error saving image', error: err }));
});

// Serve uploaded files
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Start the server
app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
});
