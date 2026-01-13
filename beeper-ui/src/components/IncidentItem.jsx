import React from 'react';
import './IncidentItem.css';

function IncidentItem({ incident, onDelete, onStatusChange }) {
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
    if (window.confirm('Are you sure you want to delete this incident?')) {
      onDelete(incident.id);
    }
  };

  const handleStatusChange = (e) => {
    const newStatus = e.target.value;
    if (newStatus !== incident.status) {
      onStatusChange(incident.id, newStatus);
    }
  };

  const getSeverityIcon = (severity) => {
    switch (severity) {
      case 'CRITICAL': return '🔴';
      case 'HIGH': return '🟠';
      case 'MEDIUM': return '🟡';
      case 'LOW': return '🟢';
      default: return '⚪';
    }
  };

  const getStatusBadgeClass = (status) => {
    switch (status) {
      case 'OPEN': return 'status-open';
      case 'INVESTIGATING': return 'status-investigating';
      case 'RESOLVED': return 'status-resolved';
      default: return '';
    }
  };

  return (
    <div className={`incident-item severity-${incident.severity.toLowerCase()}`}>
      <div className="incident-header">
        <div className="incident-severity">
          <span className="severity-icon">{getSeverityIcon(incident.severity)}</span>
          <span className="severity-label">{incident.severity}</span>
        </div>
        <div className="incident-actions">
          <select 
            className={`status-badge ${getStatusBadgeClass(incident.status)}`}
            value={incident.status}
            onChange={handleStatusChange}
            title="Change incident status"
          >
            <option value="OPEN">OPEN</option>
            <option value="INVESTIGATING">INVESTIGATING</option>
            <option value="RESOLVED">RESOLVED</option>
          </select>
          <button className="delete-btn" onClick={handleDelete} title="Delete incident">
            🗑️
          </button>
        </div>
      </div>
      
      <div className="incident-title">{incident.title}</div>
      
      {incident.description && (
        <div className="incident-description">{incident.description}</div>
      )}
      
      <div className="incident-footer">
        <div className="incident-author">
          <span className="author-icon">👤</span>
          <span className="author-name">{incident.createdBy || 'Anonymous'}</span>
        </div>
        <span className="incident-time">{formatDate(incident.createdAt)}</span>
      </div>
    </div>
  );
}

export default IncidentItem;
