# DevOps Incident Board - Architecture

## System Architecture Diagram

### Standalone Testing Mode
```

                         USER BROWSER                             
                    file:///incident-board.html                   

                              HTTP REST API
                             

                      MOCK API SERVER                             
    
                Express.js Server (Port 8080)                 
    - GET /api/incidents                                       
    - POST /api/incidents                                      
    - PATCH /api/incidents/:id/status                          
    - DELETE /api/incidents/:id                                
    
     File: mock-api-server.js                                     
     Port: 8080                                                   

```

### Production Mode (Containerized)
```

                         USER BROWSER                             
                    http://localhost:8080                         

                              HTTP
                             

                      BEEPER UI CONTAINER                         
    
                Nginx Web Server (Port 8080)                  
    - Serves incident-board.html + CSS                        
    - Proxies /api/* requests to backend                      
    
     Image: beeper-ui:v1                                          
     Network: beeper-frontend                                     

                              HTTP /api/*
                              DNS: beeper-api

                     BEEPER API CONTAINER                         
    
          Spring Boot Application (Port 8080)                 
    - REST API endpoints                                      
    - Business logic                                          
    - JPA/Hibernate ORM                                       
    
     Image: beeper-api:v1                                         
     Networks: beeper-frontend + beeper-backend                   
     Environment: DB_HOST=beeper-db                               

                              JDBC
                              DNS: beeper-db

                   POSTGRESQL DB CONTAINER                        
    
           PostgreSQL 13 Database (Port 5432)                 
    - Database: beeper                                        
    - Table: incidents                                        
    
     Network: beeper-backend                                      
     Volume: beeper-data  /var/lib/pgsql/data                   

```

## Component Breakdown

### Frontend (incident-board.html)
```

                     incident-board.html                          
   
    SUMMARY STATISTICS                                         
    [Total] [Critical] [High] [Medium] [Low]                  
   
     
    ACTIVE INCIDENTS     RESOLVED INCIDENTS                  
    - Status dropdown     - Resolver name                    
    - Color coding        - Resolution comments              
    - Resolve button      - 24h countdown timer              
      - Delete/Reopen buttons            
     
    NEW INCIDENT FORM                                          
    - Severity select                                          
    - Title input                                              
    - Description                                              
                                            
   
    ANALYTICS DASHBOARD                                        
    [Incidents Over Time Chart] [Employee of Month Trophy]    
    [Resolution Leaderboard Chart]                            
   

```

## Data Flow Diagram

### Creating a New Incident
```
1. User fills form in browser
         
         
2. JavaScript sends POST /api/incidents
         
         
3. Mock API receives request, adds to array
         
         
4. Response returns new incident with ID
         
         
5. UI updates incident list and statistics
```

### Resolving an Incident
```
1. User clicks status dropdown, selects "Resolved"
         
         
2. Resolution modal opens (resolver name required)
         
         
3. User enters name and optional comment
         
         
4. PATCH /api/incidents/:id/status sent
         
         
5. API updates incident with resolvedBy, resolutionComment, resolvedAt
         
         
6. UI moves incident to Resolved section
         
         
7. Analytics charts update (Employee of Month recalculated)
```

## Technology Stack

| Layer | Technology | Purpose |
|-------|------------|---------|
| Frontend | HTML5, CSS3, JS | Dashboard UI |
| Charts | Chart.js v4 | Analytics visualization |
| Fonts | Google Fonts (Roboto) | Typography |
| API (Dev) | Express.js | Mock backend |
| API (Prod) | Spring Boot | Production backend |
| Database | PostgreSQL | Persistent storage |
| Containers | Podman/Docker | Deployment |

## File Structure

```
Cloud_Project/
 beeper-ui/
    incident-board.html    # Main dashboard
    incident-board.css     # Complete styling
    nginx.conf             # Production config
    Containerfile          # Docker build

 beeper-backend/
    src/main/java/...      # Java source
    pom.xml                # Maven config
    Containerfile          # Docker build

 mock-api-server.js         # Express mock API
 README.md                  # Project docs
 deploy.sh                  # Deployment script
```
