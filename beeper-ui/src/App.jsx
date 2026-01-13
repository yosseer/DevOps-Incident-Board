import React, { useState, useEffect } from 'react';
import axios from 'axios';
import IncidentForm from './components/IncidentForm';
import IncidentList from './components/IncidentList';
import './App.css';

const API_URL = window.location.hostname === 'localhost' 
  ? 'http://localhost:8080/api/incidents'
  : 'http://beeper-api:8080/api/incidents';

function App() {
  const [incidents, setIncidents] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [success, setSuccess] = useState(null);

  const fetchIncidents = async () => {
    try {
      setLoading(true);
      const response = await axios.get(API_URL);
      setIncidents(response.data);
      setError(null);
    } catch (err) {
      setError('Failed to load incidents. Make sure the API is running.');
      console.error('Error fetching incidents:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchIncidents();
  }, []);

  const handleNewIncident = async (incidentData) => {
    try {
      await axios.post(API_URL, incidentData);
      setSuccess('Incident created successfully! 🎉');
      setError(null);
      setTimeout(() => setSuccess(null), 3000);
      await fetchIncidents();
      return true;
    } catch (err) {
      setError('Failed to create incident. Please try again.');
      setSuccess(null);
      console.error('Error creating incident:', err);
      return false;
    }
  };

  const handleDeleteIncident = async (id) => {
    try {
      await axios.delete(`${API_URL}/${id}`);
      await fetchIncidents();
    } catch (err) {
      setError('Failed to delete incident.');
      console.error('Error deleting incident:', err);
    }
  };

  const handleStatusChange = async (id, newStatus) => {
    try {
      await axios.patch(`${API_URL}/${id}/status`, { status: newStatus });
      await fetchIncidents();
    } catch (err) {
      setError('Failed to update incident status.');
      console.error('Error updating status:', err);
    }
  };

  return (
    <div className="App">
      <header className="App-header">
        <h1>🚨 DevOps Incident Board</h1>
        <p>Track and manage production incidents in real-time</p>
      </header>

      <main className="App-main">
        <IncidentForm onSubmit={handleNewIncident} success={success} error={error} />
        
        {loading ? (
          <div className="loading">Loading incidents...</div>
        ) : (
          <IncidentList 
            incidents={incidents} 
            onDelete={handleDeleteIncident}
            onStatusChange={handleStatusChange}
          />
        )}
      </main>

      <footer className="App-footer">
        <p>Built with React & Spring Boot | DevOps Incident Management System</p>
      </footer>
    </div>
  );
}

export default App;
