from fastapi import FastAPI, Request, HTTPException
from fastapi.responses import RedirectResponse, HTMLResponse
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel, HttpUrl
from typing import List, Optional
import asyncio
from .ddb import put_mapping, get_mapping

app = FastAPI()

@app.get("/", response_class=HTMLResponse)
async def root():
    return """
    <!DOCTYPE html>
    <html>
    <head>
        <title>URL Shortener</title>
        <style>
            body {
                font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
                margin: 0;
                padding: 0;
                background-color: #0a0b14;
                color: white;
                min-height: 100vh;
            }
            .container {
                max-width: 800px;
                margin: 40px auto;
                padding: 20px;
            }
            h1 {
                font-size: 2.5em;
                text-align: center;
                margin-bottom: 40px;
                color: white;
            }
            input[type="url"], textarea {
                width: 100%;
                padding: 12px;
                margin: 10px 0;
                border: 1px solid #2a2b3d;
                border-radius: 8px;
                background-color: #151627;
                color: white;
                font-size: 16px;
                transition: all 0.3s ease;
            }
            input[type="url"]:focus, textarea:focus {
                outline: none;
                border-color: #ff6b6b;
                box-shadow: 0 0 0 2px rgba(255,107,107,0.2);
            }
            button {
                background-color: #ff6b6b;
                color: white;
                border: none;
                padding: 12px 24px;
                border-radius: 8px;
                cursor: pointer;
                font-size: 16px;
                font-weight: 600;
                transition: all 0.3s ease;
                width: 100%;
                margin-top: 10px;
            }
            button:hover {
                background-color: #ff5252;
                transform: translateY(-2px);
                box-shadow: 0 4px 12px rgba(255,107,107,0.2);
            }
            .card {
                background-color: #151627;
                padding: 24px;
                border-radius: 12px;
                margin: 20px 0;
                border: 1px solid #2a2b3d;
            }
            #result {
                margin-top: 20px;
                padding: 16px;
                border-radius: 8px;
                transition: all 0.3s ease;
            }
            .success {
                background-color: rgba(46, 213, 115, 0.1);
                color: #2ed573;
                border: 1px solid rgba(46, 213, 115, 0.2);
            }
            .error {
                background-color: rgba(255, 107, 107, 0.1);
                color: #ff6b6b;
                border: 1px solid rgba(255, 107, 107, 0.2);
            }
            .url-list {
                margin-top: 20px;
            }
            .url-item {
                background-color: #1a1b2e;
                padding: 16px;
                margin: 10px 0;
                border-radius: 8px;
                border: 1px solid #2a2b3d;
            }
            .url-item a {
                color: #ff6b6b;
                text-decoration: none;
                font-weight: 500;
            }
            .url-item a:hover {
                text-decoration: underline;
            }
            .section-title {
                font-size: 1.5em;
                color: #ff6b6b;
                margin-bottom: 20px;
                font-weight: 600;
            }
            .stats {
                display: flex;
                justify-content: space-between;
                margin: 40px 0;
            }
            .stat-card {
                background-color: #151627;
                padding: 20px;
                border-radius: 12px;
                text-align: center;
                flex: 1;
                margin: 0 10px;
                border: 1px solid #2a2b3d;
            }
            .stat-number {
                font-size: 24px;
                font-weight: bold;
                color: #ff6b6b;
            }
            .stat-label {
                color: #8890b5;
                font-size: 14px;
                margin-top: 5px;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>Next-Gen URL Shortener</h1>
            
            <!-- Stats Section -->
            <div class="stats">
                <div class="stat-card">
                    <div class="stat-number">500ms</div>
                    <div class="stat-label">Average Speed</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number">99.9%</div>
                    <div class="stat-label">Uptime</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number">Secure</div>
                    <div class="stat-label">HTTPS Protected</div>
                </div>
            </div>

            <!-- Single URL form -->
            <div class="card">
                <div class="section-title">Quick Shorten</div>
                <input type="url" id="url" placeholder="Enter your long URL here..." required>
                <button onclick="shortenUrl()">Create Short URL</button>
            </div>

            <!-- Bulk URLs form -->
            <div class="card">
                <div class="section-title">Bulk Shortening</div>
                <textarea id="bulkUrls" rows="4" 
                    placeholder="Enter multiple URLs, one per line..."></textarea>
                <button onclick="shortenBulk()">Create Multiple Short URLs</button>
            </div>

            <div id="result"></div>
        </div>

        <script>
            async function shortenUrl() {
                const url = document.getElementById('url').value;
                if (!url) {
                    showResult('Please enter a URL', false);
                    return;
                }

                try {
                    const response = await fetch('/shorten', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json',
                        },
                        body: JSON.stringify({ url: url })
                    });

                    const data = await response.json();
                    if (response.ok) {
                        const shortUrl = window.location.origin + '/' + data.short;
                        showResult(`
                            <p>Original URL: ${data.url}</p>
                            <p>Shortened URL: <a href="${shortUrl}" target="_blank">${shortUrl}</a></p>
                        `, true);
                    } else {
                        showResult('Error: ' + data.detail, false);
                    }
                } catch (error) {
                    showResult('Error shortening URL: ' + error, false);
                }
            }

            async function shortenBulk() {
                const urls = document.getElementById('bulkUrls').value
                    .split('\\n')
                    .map(url => url.trim())
                    .filter(url => url);

                if (urls.length === 0) {
                    showResult('Please enter at least one URL', false);
                    return;
                }

                try {
                    const response = await fetch('/bulk-shorten', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json',
                        },
                        body: JSON.stringify({ urls: urls })
                    });

                    const data = await response.json();
                    if (response.ok) {
                        let resultHtml = '<h3>Results:</h3><div class="url-list">';
                        data.results.forEach(result => {
                            const shortUrl = result.short ? window.location.origin + '/' + result.short : null;
                            resultHtml += `
                                <div class="url-item">
                                    <p>Original URL: ${result.url}</p>
                                    ${result.short 
                                        ? `<p>Shortened URL: <a href="${shortUrl}" target="_blank">${shortUrl}</a></p>`
                                        : `<p class="error">Error: ${result.error}</p>`
                                    }
                                </div>
                            `;
                        });
                        resultHtml += '</div>';
                        showResult(resultHtml, true);
                    } else {
                        showResult('Error: ' + data.detail, false);
                    }
                } catch (error) {
                    showResult('Error shortening URLs: ' + error, false);
                }
            }

            function showResult(message, success) {
                const resultDiv = document.getElementById('result');
                resultDiv.innerHTML = message;
                resultDiv.className = success ? 'success' : 'error';
            }
        </script>
    </body>
    </html>
    """

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ---------- Models ----------
class BulkUrlRequest(BaseModel):
    urls: List[HttpUrl]

class UrlResult(BaseModel):
    url: str
    short: Optional[str] = None
    error: Optional[str] = None

class BulkUrlResponse(BaseModel):
    results: List[UrlResult]

# ---------- Health ----------
@app.get("/healthz")
def health():
    import time
    return {"status": "testing push ", "ts": int(time.time())}

# ---------- Single shorten ----------
@app.post("/shorten")
async def shorten(req: Request):
    body = await req.json()
    url = body.get("url")
    if not url:
        raise HTTPException(status_code=400, detail="url required")

    # run blocking DDB write off the event loop
    short = await asyncio.to_thread(put_mapping, str(url))
    return {"short": short, "url": url}

# ---------- Bulk shorten ----------
@app.post("/bulk-shorten", response_model=BulkUrlResponse)
async def bulk_shorten(payload: BulkUrlRequest):
    if not payload.urls:
        raise HTTPException(status_code=400, detail="No URLs provided")
    if len(payload.urls) > 100:
        raise HTTPException(status_code=413, detail="Too many URLs. Maximum is 100")

    async def process_url(u: HttpUrl) -> UrlResult:
        try:
            short_id = await asyncio.to_thread(put_mapping, str(u))
            return UrlResult(url=str(u), short=short_id)
        except Exception as e:
            return UrlResult(url=str(u), error=str(e))

    results = await asyncio.gather(*(process_url(u) for u in payload.urls))
    return BulkUrlResponse(results=results)

# ---------- Resolve ----------
@app.get("/{short_id}")
def resolve(short_id: str):
    item = get_mapping(short_id)
    if not item:
        raise HTTPException(status_code=404, detail="not found")
    return RedirectResponse(item["url"])
