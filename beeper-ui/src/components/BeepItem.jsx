import React from 'react';
import './BeepItem.css';

function BeepItem({ beep, onDelete }) {
  const formatDate = (dateString) => {
    const date = new Date(dateString);
    const now = new Date();
    const diffMs = now - date;
    const diffMins = Math.floor(diffMs / 60000);
    const diffHours = Math.floor(diffMs / 3600000);
    const diffDays = Math.floor(diffMs / 86400000);

    if (diffMins < 1) return 'Just now';
    if (diffMins < 60) return `${diffMins}m ago`;
    if (diffHours < 24) return `${diffHours}h ago`;
    if (diffDays < 7) return `${diffDays}d ago`;
    
    return date.toLocaleDateString();
  };

  const handleDelete = () => {
    if (window.confirm('Are you sure you want to delete this beep?')) {
      onDelete(beep.id);
    }
  };

  return (
    <div className="beep-item">
      <div className="beep-header">
        <div className="beep-author">
          <span className="author-icon">👤</span>
          <span className="author-name">{beep.author || 'Anonymous'}</span>
        </div>
        <div className="beep-meta">
          <span className="beep-time">{formatDate(beep.createdAt)}</span>
          <button className="delete-btn" onClick={handleDelete} title="Delete beep">
            🗑️
          </button>
        </div>
      </div>
      <div className="beep-message">
        {beep.message}
      </div>
    </div>
  );
}

export default BeepItem;
