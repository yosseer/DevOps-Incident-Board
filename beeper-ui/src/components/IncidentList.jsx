import React from 'react';
import IncidentItem from './IncidentItem';
import './IncidentList.css';

function IncidentList({ incidents, onDelete, onStatusChange }) {
  if (incidents.length === 0) {
    return (
      <div className="empty-state">
        <div className="empty-icon">✅</div>
        <h3>No active incidents</h3>
        <p>All systems operational!</p>
      </div>
    );
  }

  // Separate critical incidents
  const criticalIncidents = incidents.filter(inc => inc.severity === 'CRITICAL');
  const otherIncidents = incidents.filter(inc => inc.severity !== 'CRITICAL');

  return (
    <div className="incident-list">
      <div className="incident-stats">
        <div className="stat">
          <span className="stat-value">{incidents.length}</span>
          <span className="stat-label">Total Incidents</span>
        </div>
        <div className="stat critical">
          <span className="stat-value">{criticalIncidents.length}</span>
          <span className="stat-label">Critical</span>
        </div>
        <div className="stat open">
          <span className="stat-value">{incidents.filter(i => i.status === 'OPEN').length}</span>
          <span className="stat-label">Open</span>
        </div>
        <div className="stat resolved">
          <span className="stat-value">{incidents.filter(i => i.status === 'RESOLVED').length}</span>
          <span className="stat-label">Resolved</span>
        </div>
      </div>

      {criticalIncidents.length > 0 && (
        <div className="critical-section">
          <h2 className="section-title critical">🔴 Critical Incidents</h2>
          <div className="incidents-container">
            {criticalIncidents.map((incident) => (
              <IncidentItem 
                key={incident.id} 
                incident={incident} 
                onDelete={onDelete}
                onStatusChange={onStatusChange}
              />
            ))}
          </div>
        </div>
      )}

      {otherIncidents.length > 0 && (
        <div className="other-section">
          <h2 className="section-title">📋 All Incidents</h2>
          <div className="incidents-container">
            {otherIncidents.map((incident) => (
              <IncidentItem 
                key={incident.id} 
                incident={incident} 
                onDelete={onDelete}
                onStatusChange={onStatusChange}
              />
            ))}
          </div>
        </div>
      )}
    </div>
  );
}

export default IncidentList;
