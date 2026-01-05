import React from 'react';
import BeepItem from './BeepItem';
import './BeepList.css';

function BeepList({ beeps, onDelete }) {
  if (beeps.length === 0) {
    return (
      <div className="empty-state">
        <div className="empty-icon">🐝</div>
        <h3>No beeps yet</h3>
        <p>Be the first to share something!</p>
      </div>
    );
  }

  return (
    <div className="beep-list">
      <h2>Recent Beeps</h2>
      <div className="beeps-container">
        {beeps.map((beep) => (
          <BeepItem key={beep.id} beep={beep} onDelete={onDelete} />
        ))}
      </div>
    </div>
  );
}

export default BeepList;
