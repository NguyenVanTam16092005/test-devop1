const router = require('express').Router();
const Student = require('../models/student');

// GET /api/students
router.route('/').get((req, res) => {
  Student.find()
    .then((students) => res.json(students))
    .catch((err) => res.status(400).json('Error: ' + err.message));
});

// POST /api/students
router.route('/').post((req, res) => {
  const { studentId, name, dob, gender, studentClass, major } = req.body;

  const newStudent = new Student({
    studentId, name, dob, gender, studentClass, major
  });

  newStudent.save()
    .then((student) => res.status(201).json(student))
    .catch((err) => res.status(400).json('Error: ' + err.message));
});

// PUT /api/students/:id
router.route('/:id').put(async (req, res) => {
  const { studentId, name, dob, gender, studentClass, major } = req.body;

  try {
    const updatedStudent = await Student.findByIdAndUpdate(req.params.id, {
      studentId, name, dob, gender, studentClass, major
    }, { new: true });
    res.json(updatedStudent);
  } catch (err) {
    res.status(400).json('Error: ' + err.message);
  }
});

// DELETE /api/students/:id
router.route('/:id').delete(async (req, res) => {
  try {
    await Student.findByIdAndDelete(req.params.id);
    res.json({ message: 'Student deleted.' });
  } catch (err) {
    res.status(400).json('Error: ' + err.message);
  }
});

// GET /api/students/:id
router.route('/:id').get(async (req, res) => {
  try {
    const student = await Student.findById(req.params.id);
    res.json(student);
  } catch (err) {
    res.status(400).json('Error: ' + err.message);
  }
});

module.exports = router;
