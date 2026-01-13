import React, { useState } from 'react';
import './IncidentForm.css';

function IncidentForm({ onSubmit, success, error }) {
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [severity, setSeverity] = useState('MEDIUM');
  const [createdBy, setCreatedBy] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const [localError, setLocalError] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!title.trim()) {
      setLocalError('Please enter an incident title');
      return;
    }

    setSubmitting(true);
    setLocalError('');
    try {
      const result = await onSubmit({
        title: title.trim(),
        description: description.trim(),
        severity: severity,
        createdBy: createdBy.trim() || 'Anonymous'
      });
      if (result) {
        setTitle('');
        setDescription('');
        setSeverity('MEDIUM');
        setCreatedBy('');
      }
    } catch (err) {
      console.error('Error submitting incident:', err);
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="incident-form-container">
      <h2>🚨 Report New Incident</h2>
      <form onSubmit={handleSubmit} className="incident-form">
        <div className="form-group">
          <label htmlFor="createdBy">Reporter Name (optional)</label>
          <input
            type="text"
            id="createdBy"
            value={createdBy}
            onChange={(e) => setCreatedBy(e.target.value)}
            placeholder="Anonymous"
            maxLength="50"
            disabled={submitting}
            aria-label="Reporter name (optional)"
          />
          <span className="helper-text">Leave blank to report as Anonymous</span>
        </div>

        <div className="form-group">
          <label htmlFor="severity">Severity Level *</label>
          <select
            id="severity"
            value={severity}
            onChange={(e) => setSeverity(e.target.value)}
            disabled={submitting}
            className={`severity-select severity-${severity.toLowerCase()}`}
            aria-label="Severity level (required)"
          >
            <option value="LOW">🟢 LOW - Minor issue, no immediate impact</option>
            <option value="MEDIUM">🟡 MEDIUM - Service degradation</option>
            <option value="HIGH">🟠 HIGH - Significant impact</option>
            <option value="CRITICAL">🔴 CRITICAL - Service down</option>
          </select>
        </div>

        <div className="form-group">
          <label htmlFor="title">Incident Title *</label>
          <input
            type="text"
            id="title"
            value={title}
            onChange={(e) => {
              setTitle(e.target.value);
              if (localError) setLocalError('');
            }}
            placeholder="e.g., Database connection timeout"
            maxLength="200"
            required
            disabled={submitting}
            aria-label="Incident title (required)"
            className={localError ? 'error-input' : ''}
          />
          <span className="char-count">{title.length}/200 characters</span>
        </div>

        <div className="form-group">
          <label htmlFor="description">Description (optional)</label>
          <textarea
            id="description"
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            placeholder="Provide additional details about the incident..."
            maxLength="1000"
            rows="4"
            disabled={submitting}
            aria-label="Incident description (optional)"
            aria-describedby="desc-char-count"
          />
          <div id="desc-char-count" className="char-count">{description.length}/1000 characters</div>
        </div>

        {localError && (
          <div className="form-error" role="alert" aria-live="polite">
            {localError}
          </div>
        )}
        
        {error && (
          <div className="form-error" role="alert" aria-live="polite">
            {error}
          </div>
        )}
        
        {success && (
          <div className="form-success" role="alert" aria-live="polite">
            {success}
          </div>
        )}

        <button 
          type="submit" 
          className="submit-btn" 
          disabled={submitting || !title.trim()}
          aria-label={submitting ? 'Creating incident, please wait' : 'Create incident'}
        >
          {submitting ? '⏳ Creating...' : '🚨 Create Incident'}
        </button>
      </form>
    </div>
  );
}

export default IncidentForm;
