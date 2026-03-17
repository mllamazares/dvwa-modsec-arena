# 🧱 DVWA + ModSecurity WAF Arena

Quickly set up a local environment with [DVWA (Damn Vulnerable Web App)](https://github.com/digininja/DVWA) protected by [ModSecurity WAF](https://github.com/coreruleset/modsecurity-crs-docker) running the [OWASP Core Rule Set](https://coreruleset.org/).

Two endpoints are provided so you can compare behavior with and without the WAF:

| Endpoint | Port | WAF |
|---|---|---|
| `http://localhost:7979` | 7979 | ModSecurity CRS |
| `http://localhost:7978` | 7978 | None |

Authentication is disabled — no login required.

## Setup

1.  **Clone the repo:**
    ```bash
    git clone https://github.com/mllamazares/dvwa-modsec-arena.git
    cd dvwa-modsec-arena
    ```

2.  **Start the environment:**
    ```bash
    PARANOIA=1 ANOMALY_INBOUND=5 ANOMALY_OUTBOUND=6 docker-compose up
    ```

3.  **Access the application:**
    - With WAF: `http://localhost:7979`
    - Without WAF: `http://localhost:7978`

## Testing

### Standard query (should pass on both endpoints)
```bash
curl -I http://127.0.0.1:7979/login.php
curl -I http://127.0.0.1:7978/login.php
```
Expected: `HTTP/1.1 200 OK`

### Malicious query (blocked by WAF, allowed without WAF)

**SQL Injection:**
```bash
# Through WAF — blocked
curl -I "http://127.0.0.1:7979/vulnerabilities/sqli/?id=1'%20OR%20'1'='1&Submit=Submit"
# Direct — allowed
curl -I "http://127.0.0.1:7978/vulnerabilities/sqli/?id=1'%20OR%20'1'='1&Submit=Submit"
```
Expected: `403 Forbidden` (WAF) vs `200 OK` (direct)

**XSS:**
```bash
# Through WAF — blocked
curl -I "http://127.0.0.1:7979/vulnerabilities/xss_r/?name=<script>alert(1)</script>"
# Direct — allowed
curl -I "http://127.0.0.1:7978/vulnerabilities/xss_r/?name=<script>alert(1)</script>"
```
Expected: `403 Forbidden` (WAF) vs `200 OK` (direct)

## Logs

To view WAF logs (includes triggered rule details):
```bash
docker-compose logs -f waf
```

The ModSecurity audit log is also mounted locally at `./modsec-logs/audit.log` in JSON format.
