# 🧱 DVWA + ModSecurity WAF Arena

Quickly set up a local environment with [DVWA (Damn Vulnerable Web App)](https://github.com/digininja/DVWA) protected by [ModSecurity WAF](https://github.com/coreruleset/modsecurity-crs-docker) running the [OWASP Core Rule Set](https://coreruleset.org/).

## Setup

1.  **Clone the repo:**
    ```bash
    git clone https://github.com/mllamazares/dvwa-modsec-arena.git
    cd dvwa-modsec-arena
    ```

2.  **Start the environment:**
    ```bash
    PARANOIA=2 ANOMALY_INBOUND=5 ANOMALY_OUTBOUND=6 docker-compose up
    ```

3.  **Access the application:**
    Open your browser and navigate to `http://localhost:8080`.
    
    Default credentials: `admin` / `password`.

## Testing

### Standard query (should pass)
```bash
curl -I http://127.0.0.1:8080/login.php
```
Expected: `HTTP/1.1 200 OK`

### Malicious query (should be blocked)

**SQL Injection:**
```bash
curl -I "http://127.0.0.1:8080/vulnerabilities/sqli/?id=1'%20OR%20'1'='1&Submit=Submit"
```
Expected: `HTTP/1.1 403 Forbidden`

**XSS:**
```bash
curl -I "http://127.0.0.1:8080/vulnerabilities/xss_r/?name=<script>alert(1)</script>"
```
Expected: `HTTP/1.1 403 Forbidden`

## Logs
To view WAF logs:
```bash
docker-compose logs -f waf
```