import React, { useState } from 'react';
import './BeepForm.css';

function BeepForm({ onSubmit, success, error }) {
  const [message, setMessage] = useState('');
  const [author, setAuthor] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const [localError, setLocalError] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!message.trim()) {
      setLocalError('Please enter a message');
      return;
    }

    setSubmitting(true);
    setLocalError('');
    try {
      const result = await onSubmit({
        message: message.trim(),
        author: author.trim() || 'Anonymous'
      });
      if (result) {
        setMessage('');
        setAuthor('');
      }
    } catch (err) {
      console.error('Error submitting beep:', err);
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="beep-form-container">
      <h2>Create a New Beep</h2>
      <form onSubmit={handleSubmit} className="beep-form">
        <div className="form-group">
          <label htmlFor="author">Your Name (optional)</label>
          <input
            type="text"
            id="author"
            value={author}
            onChange={(e) => setAuthor(e.target.value)}
            placeholder="Anonymous"
            maxLength="50"
            disabled={submitting}
            aria-label="Your name (optional)"
          />
          <span className="helper-text">Leave blank to post as Anonymous</span>
        </div>

        <div className="form-group">
          <label htmlFor="message">Your Message *</label>
          <textarea
            id="message"
            value={message}
            onChange={(e) => {
              setMessage(e.target.value);
              if (localError) setLocalError('');
            }}
            placeholder="What's on your mind?"
            maxLength="280"
            rows="4"
            required
            disabled={submitting}
            aria-label="Your message (required)"
            aria-describedby="char-count"
            className={localError ? 'error-input' : ''}
          />
          <div id="char-count" className="char-count">{message.length}/280 characters</div>
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
          disabled={submitting || !message.trim()}
          aria-label={submitting ? 'Posting beep, please wait' : 'Post your beep'}
        >
          {submitting ? '⏳ Posting...' : '🐝 Post Beep'}
        </button>
      </form>
    </div>
  );
}

export default BeepForm;
