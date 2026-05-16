import React from 'react';

const Badge = ({ type, text }) => {
  const styles = {
    Nam: 'bg-green-100 text-green-800',
    'Nữ': 'bg-pink-100 text-pink-800',
    default: 'bg-gray-100 text-gray-800'
  };

  const currentStyle = styles[type] || styles.default;

  return (
    <span className={`px-2.5 py-1 text-xs font-medium rounded-full ${currentStyle}`}>
      {text || type}
    </span>
  );
};

export default Badge;
