const mongoose = require('mongoose');

const Schema = mongoose.Schema;

const studentSchema = new Schema({
  studentId: {
    type: String,
    required: true,
  },
  name: {
    type: String,
    required: true,
  },
  dob: {
    type: Date,
    required: true,
  },
  gender: {
    type: String,
    required: true,
  },
  studentClass: {
    type: String,
    required: true,
  },
  major: {
    type: String,
    required: true,
  },
}, { timestamps: true });

const Student = mongoose.model('Student', studentSchema);
module.exports = Student;
