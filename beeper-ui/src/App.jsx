import React, { useState, useEffect } from 'react';
import axios from 'axios';
import BeepForm from './components/BeepForm';
import BeepList from './components/BeepList';
import './App.css';

const API_URL = window.location.hostname === 'localhost' 
  ? 'http://localhost:8080/api/beeps'
  : 'http://beeper-api:8080/api/beeps';

function App() {
  const [beeps, setBeeps] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [success, setSuccess] = useState(null);

  const fetchBeeps = async () => {
    try {
      setLoading(true);
      const response = await axios.get(API_URL);
      setBeeps(response.data);
      setError(null);
    } catch (err) {
      setError('Failed to load beeps. Make sure the API is running.');
      console.error('Error fetching beeps:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchBeeps();
  }, []);

  const handleNewBeep = async (beepData) => {
    try {
      await axios.post(API_URL, beepData);
      setSuccess('Beep posted successfully! 🎉');
      setError(null);
      setTimeout(() => setSuccess(null), 3000);
      await fetchBeeps();
      return true;
    } catch (err) {
      setError('Failed to create beep. Please try again.');
      setSuccess(null);
      console.error('Error creating beep:', err);
      return false;
    }
  };

  const handleDeleteBeep = async (id) => {
    try {
      await axios.delete(`${API_URL}/${id}`);
      await fetchBeeps();
    } catch (err) {
      setError('Failed to delete beep.');
      console.error('Error deleting beep:', err);
    }
  };

  return (
    <div className="App">
      <header className="App-header">
        <h1>🐝 Beeper</h1>
        <p>Share your thoughts with the world</p>
      </header>

      <main className="App-main">
        <BeepForm onSubmit={handleNewBeep} success={success} error={error} />
        
        {loading ? (
          <div className="loading">Loading beeps...</div>
        ) : (
          <BeepList beeps={beeps} onDelete={handleDeleteBeep} />
        )}
      </main>

      <footer className="App-footer">
        <p>Built with React & Spring Boot | DO188 Comprehensive Review</p>
      </footer>
    </div>
  );
}

export default App;
