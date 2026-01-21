package com.redhat.training.beeper;

import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;

@RestController
@CrossOrigin(origins = "*")
public class WelcomeController {

    @GetMapping(value = "/", produces = MediaType.TEXT_HTML_VALUE)
    public String welcomeHtml() {
        String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
        
        StringBuilder html = new StringBuilder();
        html.append("<!DOCTYPE html>");
        html.append("<html lang=\"en\">");
        html.append("<head>");
        html.append("<meta charset=\"UTF-8\">");
        html.append("<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">");
        html.append("<title>DevOps Incident Board API</title>");
        html.append("<style>");
        html.append("* { margin: 0; padding: 0; box-sizing: border-box; }");
        html.append("body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; ");
        html.append("background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); ");
        html.append("min-height: 100vh; display: flex; justify-content: center; align-items: center; color: white; }");
        html.append(".container { text-align: center; padding: 40px; background: rgba(255,255,255,0.1); ");
        html.append("border-radius: 20px; backdrop-filter: blur(10px); box-shadow: 0 8px 32px rgba(0,0,0,0.3); max-width: 600px; }");
        html.append(".celebration { font-size: 80px; margin-bottom: 20px; animation: bounce 1s infinite; }");
        html.append("@keyframes bounce { 0%, 100% { transform: translateY(0); } 50% { transform: translateY(-20px); } }");
        html.append("h1 { font-size: 2.5em; margin-bottom: 10px; text-shadow: 2px 2px 4px rgba(0,0,0,0.3); }");
        html.append(".subtitle { font-size: 1.2em; opacity: 0.9; margin-bottom: 30px; }");
        html.append(".status { background: #4CAF50; padding: 10px 30px; border-radius: 50px; display: inline-block; font-weight: bold; margin-bottom: 20px; }");
        html.append(".info { background: rgba(0,0,0,0.2); padding: 20px; border-radius: 10px; margin-top: 20px; }");
        html.append(".info p { margin: 10px 0; font-size: 0.95em; }");
        html.append(".endpoints { text-align: left; margin-top: 20px; }");
        html.append(".endpoints h3 { margin-bottom: 10px; }");
        html.append(".endpoints ul { list-style: none; }");
        html.append(".endpoints li { padding: 5px 0; font-family: monospace; }");
        html.append(".endpoints a { color: #FFD700; text-decoration: none; }");
        html.append(".endpoints a:hover { text-decoration: underline; }");
        html.append(".footer { margin-top: 30px; font-size: 0.85em; opacity: 0.8; }");
        html.append(".flag { font-size: 40px; }");
        html.append("</style>");
        html.append("</head>");
        html.append("<body>");
        html.append("<div class=\"container\">");
        html.append("<div class=\"celebration\">&#127881;&#128640;&#127882;</div>");
        html.append("<h1>DevOps Incident Board API</h1>");
        html.append("<p class=\"subtitle\">Successfully Deployed on Red Hat OpenShift!</p>");
        html.append("<div class=\"status\">&#10004; RUNNING</div>");
        html.append("<div class=\"info\">");
        html.append("<p><strong>Version:</strong> 1.0.0</p>");
        html.append("<p><strong>Platform:</strong> Red Hat OpenShift Container Platform</p>");
        html.append("<p><strong>Runtime:</strong> Spring Boot 2.7.18 + Java 21</p>");
        html.append("<p><strong>Database:</strong> H2 (Embedded)</p>");
        html.append("<p><strong>Timestamp:</strong> ").append(timestamp).append("</p>");
        html.append("</div>");
        html.append("<div class=\"endpoints\">");
        html.append("<h3>&#128225; API Endpoints:</h3>");
        html.append("<ul>");
        html.append("<li>GET <a href=\"/api/incidents\">/api/incidents</a> - List all incidents</li>");
        html.append("<li>POST /api/incidents - Create new incident</li>");
        html.append("<li>GET /api/incidents/{id} - Get incident by ID</li>");
        html.append("<li>PATCH /api/incidents/{id}/status - Update status</li>");
        html.append("<li>DELETE /api/incidents/{id} - Delete incident</li>");
        html.append("<li>GET <a href=\"/actuator/health\">/actuator/health</a> - Health check</li>");
        html.append("</ul>");
        html.append("</div>");
        html.append("<div class=\"footer\">");
        html.append("<p class=\"flag\">&#127481;&#127475;</p>");
        html.append("<p>Built with love by Yosser Fhal | Tunisia</p>");
        html.append("<p>Deployed on OpenShift | Powered by Red Hat</p>");
        html.append("</div>");
        html.append("</div>");
        html.append("</body>");
        html.append("</html>");
        
        return html.toString();
    }

    @GetMapping(value = "/api", produces = MediaType.APPLICATION_JSON_VALUE)
    public Map<String, Object> apiInfo() {
        Map<String, Object> info = new HashMap<>();
        info.put("name", "DevOps Incident Board API");
        info.put("version", "1.0.0");
        info.put("status", "running");
        info.put("platform", "Red Hat OpenShift");
        info.put("message", "Congratulations! The API is successfully deployed!");
        info.put("timestamp", LocalDateTime.now().toString());
        
        Map<String, String> endpoints = new HashMap<>();
        endpoints.put("incidents", "/api/incidents");
        endpoints.put("beeps", "/api/beeps");
        endpoints.put("health", "/actuator/health");
        info.put("endpoints", endpoints);
        
        return info;
    }
}
