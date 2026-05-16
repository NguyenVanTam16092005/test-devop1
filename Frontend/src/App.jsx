import React from 'react';
import StudentManagement from './Pages/StudentManagement';
import { ToastProvider } from './Components/common/ToastNotification';

function App() {
  return (
    <ToastProvider>
      <StudentManagement />
    </ToastProvider>
  );
}

export default App;
