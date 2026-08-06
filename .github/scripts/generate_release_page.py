#!/usr/bin/env python3
"""
Generate the GitHub Pages download page with all releases.
This script fetches all releases from GitHub API and generates a complete HTML page.
"""

import os
import sys
import json
import re
from datetime import datetime

try:
    import requests
except ImportError:
    print("requests module not available, using urllib")
    import urllib.request as urllib2
else:
    urllib2 = None

# GitHub API configuration
OWNER = os.environ.get('GITHUB_REPOSITORY_OWNER', 'owdvertsbot')
REPO = os.environ.get('GITHUB_REPOSITORY_NAME', 'Workout-flutter-app')
GITHUB_TOKEN = os.environ.get('GITHUB_TOKEN', '')
GITHUB_API_URL = f"https://api.github.com/repos/{OWNER}/{REPO}"

def make_request(url):
    """Make an authenticated GitHub API request."""
    headers = {
        'Authorization': f'token {GITHUB_TOKEN}',
        'Accept': 'application/vnd.github.v3+json',
        'User-Agent': 'RPG-Workout-Release-Generator'
    }
    
    if urllib2:
        req = urllib2.Request(url, headers=headers)
        with urllib2.urlopen(req) as response:
            return json.loads(response.read().decode())
    else:
        response = requests.get(url, headers=headers)
        response.raise_for_status()
        return response.json()

def get_releases():
    """Fetch all releases from GitHub API."""
    releases = []
    page = 1
    per_page = 100
    
    while True:
        url = f"{GITHUB_API_URL}/releases?page={page}&per_page={per_page}"
        try:
            page_releases = make_request(url)
            if not page_releases:
                break
            releases.extend(page_releases)
            if len(page_releases) < per_page:
                break
            page += 1
        except Exception as e:
            print(f"Error fetching releases: {e}")
            break
    
    return releases

def get_release_assets(release):
    """Get download URLs for release assets."""
    assets = {}
    for asset in release.get('assets', []):
        name = asset['name']
        if name.endswith('.apk') or name.endswith('.aab'):
            assets[name] = {
                'url': asset['browser_download_url'],
                'size': asset.get('size', 0)
            }
    return assets

def format_file_size(size_bytes):
    """Format file size in human-readable format."""
    for unit in ['B', 'KB', 'MB', 'GB']:
        if size_bytes < 1024:
            return f"{size_bytes:.1f} {unit}"
        size_bytes /= 1024
    return f"{size_bytes:.1f} TB"

def generate_release_html(releases, current_version):
    """Generate HTML for the releases list."""
    html_parts = []
    
    for release in releases:
        tag = release['tag_name']
        name = release['name'] or tag
        body = release.get('body', '') or ''
        created_at = release.get('created_at', '')
        is_draft = release.get('draft', False)
        is_prerelease = release.get('prerelease', False)
        
        # Skip draft releases for public page
        if is_draft:
            continue
        
        # Format date
        try:
            date = datetime.fromisoformat(created_at.replace('Z', '+00:00'))
            formatted_date = date.strftime('%B %d, %Y')
        except:
            formatted_date = created_at[:10] if created_at else 'Unknown'
        
        # Get assets
        assets = get_release_assets(release)
        
        # Find release APK
        release_apk = None
        debug_apk = None
        aab_bundle = None
        
        for name, data in assets.items():
            if 'release' in name.lower() and name.endswith('.apk'):
                release_apk = (name, data)
            elif 'debug' in name.lower() and name.endswith('.apk'):
                debug_apk = (name, data)
            elif name.endswith('.aab'):
                aab_bundle = (name, data)
        
        # Determine if this is the current version
        is_current = tag == current_version or tag == f"v{current_version}"
        
        # Build release card HTML
        badge = ''
        if is_current:
            badge = '<span class="release-badge">Latest</span>'
        if is_prerelease:
            badge += ' <span class="prerelease-badge">Pre-release</span>'
        
        html_parts.append(f'''
        <div class="release-card {'current' if is_current else ''}">
          <div class="release-header">
            <h3>{name} {badge}</h3>
            <span class="release-date">{formatted_date}</span>
          </div>
          <div class="release-downloads">
''')
        
        # Add release APK
        if release_apk:
            size = format_file_size(release_apk[1]['size'])
            html_parts.append(f'''
            <a href="{release_apk[1]['url']}" class="download-btn release">
              <div class="btn-icon"><i class="fas fa-rocket"></i></div>
              <div class="btn-content">
                <span class="btn-label">Recommended</span>
                <span class="btn-title">Release APK</span>
                <span class="btn-size">~{size}</span>
              </div>
              <i class="fas fa-download btn-arrow"></i>
            </a>
''')
        
        # Add debug APK
        if debug_apk:
            size = format_file_size(debug_apk[1]['size'])
            html_parts.append(f'''
            <a href="{debug_apk[1]['url']}" class="download-btn">
              <div class="btn-icon"><i class="fas fa-flask"></i></div>
              <div class="btn-content">
                <span class="btn-label">For Developers</span>
                <span class="btn-title">Debug APK</span>
                <span class="btn-size">~{size}</span>
              </div>
              <i class="fas fa-download btn-arrow"></i>
            </a>
''')
        
        # Add AAB
        if aab_bundle:
            size = format_file_size(aab_bundle[1]['size'])
            html_parts.append(f'''
            <a href="{aab_bundle[1]['url']}" class="download-btn">
              <div class="btn-icon"><i class="fab fa-android"></i></div>
              <div class="btn-content">
                <span class="btn-label">For Google Play</span>
                <span class="btn-title">App Bundle</span>
                <span class="btn-size">~{size}</span>
              </div>
              <i class="fas fa-download btn-arrow"></i>
            </a>
''')
        
        html_parts.append('</div>')
        
        # Add release notes if available
        if body and body.strip():
            # Strip markdown formatting for display
            notes = re.sub(r'\[([^\]]+)\]\([^\)]+\)', r'\1', body)
            notes = notes[:300] + '...' if len(notes) > 300 else notes
            html_parts.append(f'''
          <div class="release-notes">
            <details>
              <summary><i class="fas fa-scroll"></i> Release Notes</summary>
              <pre>{notes}</pre>
            </details>
          </div>
''')
        
        html_parts.append('</div>')
    
    return '\n'.join(html_parts)

def generate_html_page(releases, current_version):
    """Generate the complete HTML page."""
    current_version_clean = current_version.lstrip('v')
    releases_html = generate_release_html(releases, current_version)
    
    # Count releases
    public_releases = [r for r in releases if not r.get('draft', False)]
    
    html = f'''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>RPG Workout App - Turn Your Fitness Into an Epic Adventure</title>
  <meta name="description" content="Download the RPG Workout App - Transform your fitness journey with gamification, 1324+ exercises, and daily quests. Available for Android.">
  
  <!-- Google Fonts -->
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=Space+Grotesk:wght@500;700&display=swap" rel="stylesheet">
  
  <!-- Font Awesome -->
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
  
  <style>
    :root {{
      --bg-primary: #0a0a0f;
      --bg-secondary: #12121a;
      --bg-card: rgba(255, 255, 255, 0.03);
      --bg-card-hover: rgba(255, 255, 255, 0.06);
      --accent-primary: #a855f7;
      --accent-secondary: #6366f1;
      --accent-gold: #fbbf24;
      --accent-emerald: #34d399;
      --text-primary: #ffffff;
      --text-secondary: #94a3b8;
      --text-muted: #64748b;
      --border-color: rgba(255, 255, 255, 0.08);
      --glow-purple: rgba(168, 85, 247, 0.4);
      --glow-gold: rgba(251, 191, 36, 0.4);
    }}

    * {{ margin: 0; padding: 0; box-sizing: border-box; }}
    html {{ scroll-behavior: smooth; }}

    body {{
      font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
      background: var(--bg-primary);
      color: var(--text-primary);
      min-height: 100vh;
      line-height: 1.6;
    }}

    .bg-animation {{
      position: fixed;
      top: 0; left: 0;
      width: 100%; height: 100%;
      pointer-events: none;
      z-index: 0;
      overflow: hidden;
    }}

    .bg-animation::before {{
      content: '';
      position: absolute;
      top: -50%; left: -50%;
      width: 200%; height: 200%;
      background: 
        radial-gradient(ellipse at 20% 20%, var(--glow-purple) 0%, transparent 50%),
        radial-gradient(ellipse at 80% 80%, var(--glow-gold) 0%, transparent 50%),
        radial-gradient(ellipse at 50% 50%, rgba(99, 102, 241, 0.2) 0%, transparent 60%);
      animation: bgPulse 15s ease-in-out infinite;
    }}

    @keyframes bgPulse {{
      0%, 100% {{ transform: translate(0, 0) scale(1); opacity: 1; }}
      33% {{ transform: translate(2%, 2%) scale(1.05); opacity: 0.8; }}
      66% {{ transform: translate(-2%, 1%) scale(0.95); opacity: 0.9; }}
    }}

    .grid-overlay {{
      position: fixed;
      top: 0; left: 0;
      width: 100%; height: 100%;
      background-image: 
        linear-gradient(rgba(255, 255, 255, 0.02) 1px, transparent 1px),
        linear-gradient(90deg, rgba(255, 255, 255, 0.02) 1px, transparent 1px);
      background-size: 60px 60px;
      pointer-events: none;
      z-index: 1;
    }}

    .container {{
      position: relative;
      z-index: 10;
      max-width: 900px;
      margin: 0 auto;
      padding: 60px 24px;
    }}

    .hero {{
      text-align: center;
      margin-bottom: 60px;
    }}

    .hero-badge {{
      display: inline-flex;
      align-items: center;
      gap: 8px;
      background: linear-gradient(135deg, var(--accent-primary), var(--accent-secondary));
      padding: 8px 20px;
      border-radius: 100px;
      font-size: 0.875rem;
      font-weight: 600;
      margin-bottom: 32px;
      animation: badgePulse 3s ease-in-out infinite;
    }}

    @keyframes badgePulse {{
      0%, 100% {{ box-shadow: 0 0 20px var(--glow-purple); }}
      50% {{ box-shadow: 0 0 40px var(--glow-purple); }}
    }}

    .hero h1 {{
      font-family: 'Space Grotesk', sans-serif;
      font-size: clamp(2.5rem, 8vw, 4.5rem);
      font-weight: 700;
      line-height: 1.1;
      margin-bottom: 20px;
      background: linear-gradient(135deg, #fff 0%, #e2e8f0 50%, var(--accent-gold) 100%);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
      background-clip: text;
    }}

    .hero h1 span {{
      background: linear-gradient(135deg, var(--accent-gold), #f59e0b);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
      background-clip: text;
    }}

    .hero p {{
      font-size: clamp(1rem, 2.5vw, 1.25rem);
      color: var(--text-secondary);
      max-width: 600px;
      margin: 0 auto 40px;
    }}

    .stats-bar {{
      display: flex;
      justify-content: center;
      gap: 48px;
      flex-wrap: wrap;
      margin-bottom: 60px;
    }}

    .stat {{ text-align: center; }}

    .stat-value {{
      font-family: 'Space Grotesk', sans-serif;
      font-size: 2rem;
      font-weight: 700;
      background: linear-gradient(135deg, var(--accent-gold), var(--accent-primary));
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
      background-clip: text;
    }}

    .stat-label {{
      font-size: 0.875rem;
      color: var(--text-muted);
      margin-top: 4px;
    }}

    .features {{
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
      gap: 24px;
      margin-bottom: 60px;
    }}

    .feature-card {{
      background: var(--bg-card);
      border: 1px solid var(--border-color);
      border-radius: 20px;
      padding: 32px 24px;
      text-align: center;
      transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
    }}

    .feature-card:hover {{
      background: var(--bg-card-hover);
      border-color: rgba(168, 85, 247, 0.3);
      transform: translateY(-8px);
    }}

    .feature-icon {{
      width: 64px; height: 64px;
      margin: 0 auto 20px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 1.75rem;
      background: linear-gradient(135deg, var(--accent-primary), var(--accent-secondary));
      border-radius: 16px;
      box-shadow: 0 8px 32px rgba(168, 85, 247, 0.3);
    }}

    .feature-card h3 {{
      font-size: 1.125rem;
      font-weight: 600;
      margin-bottom: 8px;
    }}

    .feature-card p {{
      font-size: 0.875rem;
      color: var(--text-muted);
    }}

    /* Releases Section */
    .releases-section {{
      margin-bottom: 60px;
    }}

    .releases-header {{
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 32px;
    }}

    .releases-header h2 {{
      font-family: 'Space Grotesk', sans-serif;
      font-size: 1.75rem;
      display: flex;
      align-items: center;
      gap: 12px;
    }}

    .release-count {{
      background: var(--bg-card);
      padding: 4px 12px;
      border-radius: 20px;
      font-size: 0.875rem;
      color: var(--text-muted);
    }}

    .release-card {{
      background: var(--bg-card);
      border: 1px solid var(--border-color);
      border-radius: 16px;
      padding: 24px;
      margin-bottom: 24px;
      transition: all 0.3s;
    }}

    .release-card.current {{
      border-color: var(--accent-primary);
      box-shadow: 0 0 30px rgba(168, 85, 247, 0.15);
    }}

    .release-header {{
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 20px;
    }}

    .release-header h3 {{
      font-size: 1.25rem;
      display: flex;
      align-items: center;
      gap: 12px;
    }}

    .release-badge {{
      background: linear-gradient(135deg, var(--accent-primary), var(--accent-secondary));
      padding: 4px 12px;
      border-radius: 20px;
      font-size: 0.75rem;
      font-weight: 600;
    }}

    .prerelease-badge {{
      background: rgba(251, 191, 36, 0.2);
      color: var(--accent-gold);
      padding: 4px 12px;
      border-radius: 20px;
      font-size: 0.75rem;
      font-weight: 600;
    }}

    .release-date {{
      color: var(--text-muted);
      font-size: 0.875rem;
    }}

    .release-downloads {{
      display: flex;
      flex-direction: column;
      gap: 12px;
    }}

    .download-btn {{
      display: flex;
      align-items: center;
      gap: 16px;
      padding: 16px 20px;
      background: var(--bg-card-hover);
      border: 1px solid var(--border-color);
      border-radius: 12px;
      text-decoration: none;
      color: var(--text-primary);
      transition: all 0.3s;
    }}

    .download-btn:hover {{
      background: rgba(255, 255, 255, 0.08);
      border-color: rgba(168, 85, 247, 0.3);
      transform: translateX(4px);
    }}

    .download-btn.release {{
      background: linear-gradient(135deg, rgba(168, 85, 247, 0.15), rgba(99, 102, 241, 0.15));
      border-color: rgba(168, 85, 247, 0.3);
    }}

    .download-btn.release:hover {{
      background: linear-gradient(135deg, rgba(168, 85, 247, 0.25), rgba(99, 102, 241, 0.25));
    }}

    .btn-icon {{
      width: 48px; height: 48px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 1.25rem;
      background: rgba(255, 255, 255, 0.1);
      border-radius: 12px;
    }}

    .btn-content {{ flex: 1; }}
    .btn-label {{
      display: block;
      font-size: 0.75rem;
      color: var(--text-muted);
      text-transform: uppercase;
      letter-spacing: 0.5px;
      margin-bottom: 2px;
    }}
    .btn-title {{
      display: block;
      font-size: 1rem;
      font-weight: 600;
      margin-bottom: 2px;
    }}
    .btn-size {{
      display: block;
      font-size: 0.875rem;
      color: var(--text-muted);
    }}
    .btn-arrow {{
      color: var(--text-muted);
      transition: transform 0.3s;
    }}
    .download-btn:hover .btn-arrow {{
      transform: translateX(4px);
      color: var(--accent-primary);
    }}

    .release-notes {{
      margin-top: 16px;
      padding-top: 16px;
      border-top: 1px solid var(--border-color);
    }}

    .release-notes summary {{
      cursor: pointer;
      color: var(--text-secondary);
      font-size: 0.875rem;
      display: flex;
      align-items: center;
      gap: 8px;
    }}

    .release-notes summary:hover {{
      color: var(--accent-primary);
    }}

    .release-notes pre {{
      margin-top: 12px;
      padding: 16px;
      background: var(--bg-primary);
      border-radius: 8px;
      font-size: 0.875rem;
      color: var(--text-secondary);
      white-space: pre-wrap;
      overflow-x: auto;
    }}

    .notes {{
      background: rgba(251, 191, 36, 0.1);
      border: 1px solid rgba(251, 191, 36, 0.2);
      border-radius: 16px;
      padding: 24px;
      margin-bottom: 40px;
    }}

    .notes-title {{
      display: flex;
      align-items: center;
      gap: 12px;
      font-weight: 600;
      color: var(--accent-gold);
      margin-bottom: 12px;
    }}

    .notes ul {{
      list-style: none;
      display: flex;
      flex-direction: column;
      gap: 8px;
    }}

    .notes li {{
      display: flex;
      align-items: center;
      gap: 8px;
      font-size: 0.875rem;
      color: var(--text-secondary);
    }}

    .notes li i {{
      color: var(--accent-gold);
      font-size: 0.75rem;
    }}

    .footer {{
      text-align: center;
      padding-top: 40px;
      border-top: 1px solid var(--border-color);
    }}

    .footer-links {{
      display: flex;
      justify-content: center;
      gap: 32px;
      margin-bottom: 24px;
      flex-wrap: wrap;
    }}

    .footer-links a {{
      display: flex;
      align-items: center;
      gap: 8px;
      color: var(--text-secondary);
      text-decoration: none;
      font-size: 0.875rem;
      transition: color 0.3s;
    }}

    .footer-links a:hover {{
      color: var(--accent-primary);
    }}

    .footer-text {{
      font-size: 0.875rem;
      color: var(--text-muted);
    }}

    /* Version Badge for Hero */
    .version-badge {{
      display: inline-flex;
      align-items: center;
      gap: 8px;
      background: var(--bg-card);
      border: 1px solid var(--border-color);
      padding: 8px 16px;
      border-radius: 100px;
      font-size: 0.875rem;
      margin-bottom: 24px;
    }}

    .version-badge i {{
      color: var(--accent-emerald);
    }}

    @media (max-width: 640px) {{
      .container {{ padding: 40px 16px; }}
      .stats-bar {{ gap: 32px; }}
      .download-btn {{ padding: 12px; }}
      .footer-links {{ flex-direction: column; align-items: center; gap: 16px; }}
    }}

    .fade-in {{
      animation: fadeIn 0.8s ease-out forwards;
      opacity: 0;
    }}

    @keyframes fadeIn {{
      from {{ opacity: 0; transform: translateY(20px); }}
      to {{ opacity: 1; transform: translateY(0); }}
    }}
  </style>
</head>
<body>
  <div class="bg-animation"></div>
  <div class="grid-overlay"></div>

  <div class="container">
    <section class="hero fade-in">
      <div class="hero-badge">
        <i class="fas fa-sparkles"></i>
        <span>Download RPG Workout App</span>
      </div>
      <div class="version-badge">
        <i class="fas fa-circle"></i>
        <span>Latest: v{current_version_clean}</span>
      </div>
      <h1><span>&#9883;</span> RPG Workout</h1>
      <p>Transform your fitness journey into an epic adventure. Level up your workouts, complete daily quests, and become the hero of your own story.</p>
    </section>

    <div class="stats-bar fade-in">
      <div class="stat">
        <div class="stat-value">1324+</div>
        <div class="stat-label">Exercises</div>
      </div>
      <div class="stat">
        <div class="stat-value">50+</div>
        <div class="stat-label">Workout Types</div>
      </div>
      <div class="stat">
        <div class="stat-value">{len(public_releases)}</div>
        <div class="stat-label">Releases</div>
      </div>
    </div>

    <section class="features fade-in">
      <div class="feature-card">
        <div class="feature-icon"><i class="fas fa-gamepad"></i></div>
        <h3>RPG Gamification</h3>
        <p>Level up, earn XP, unlock achievements, and progress through an immersive storyline</p>
      </div>
      <div class="feature-card">
        <div class="feature-icon"><i class="fas fa-dumbbell"></i></div>
        <h3>1324+ Exercises</h3>
        <p>Comprehensive exercise library covering cardio, strength, flexibility, and more</p>
      </div>
      <div class="feature-card">
        <div class="feature-icon"><i class="fas fa-calendar-check"></i></div>
        <h3>Daily Quests</h3>
        <p>Stay motivated with daily challenges and quests that keep you coming back</p>
      </div>
    </section>

    <section class="releases-section fade-in">
      <div class="releases-header">
        <h2><i class="fas fa-box-open"></i> All Releases <span class="release-count">{len(public_releases)}</span></h2>
      </div>
      {releases_html}
    </section>

    <section class="notes fade-in">
      <div class="notes-title">
        <i class="fas fa-info-circle"></i>
        <span>Before You Download</span>
      </div>
      <ul>
        <li><i class="fas fa-check"></i> Requires Android 6.0 (Marshmallow) or higher</li>
        <li><i class="fas fa-check"></i> Enable "Install from unknown sources" in your device settings</li>
        <li><i class="fas fa-check"></i> Web version unavailable due to native SQLite dependencies</li>
      </ul>
    </section>

    <footer class="footer fade-in">
      <div class="footer-links">
        <a href="https://github.com/{OWNER}/{REPO}">
          <i class="fab fa-github"></i>
          View on GitHub
        </a>
        <a href="https://github.com/{OWNER}/{REPO}/releases">
          <i class="fas fa-box-open"></i>
          All Releases
        </a>
        <a href="https://github.com/{OWNER}/{REPO}/issues">
          <i class="fas fa-bug"></i>
          Report an Issue
        </a>
      </div>
      <p class="footer-text">Made with <i class="fas fa-heart" style="color: #ef4444;"></i> for fitness enthusiasts everywhere</p>
    </footer>
  </div>
</body>
</html>'''
    
    return html

def main():
    """Main function to generate the download page."""
    # Get current version from environment or git tag
    current_version = os.environ.get('RELEASE_VERSION', '')
    
    if not current_version:
        # Try to get from git tag
        try:
            if urllib2:
                req = urllib2.Request(
                    f"{GITHUB_API_URL}/releases/latest",
                    headers={'Authorization': f'token {GITHUB_TOKEN}', 'Accept': 'application/vnd.github.v3+json'}
                )
                with urllib2.urlopen(req) as response:
                    latest = json.loads(response.read().decode())
                    current_version = latest.get('tag_name', '')
            else:
                response = requests.get(
                    f"{GITHUB_API_URL}/releases/latest",
                    headers={'Authorization': f'token {GITHUB_TOKEN}', 'Accept': 'application/vnd.github.v3+json'}
                )
                latest = response.json()
                current_version = latest.get('tag_name', '')
        except Exception as e:
            print(f"Could not fetch latest release: {e}")
            current_version = os.environ.get('GITHUB_REF_NAME', 'v1.0.0')
    
    print(f"Generating download page for version: {current_version}")
    
    # Fetch releases
    print("Fetching releases from GitHub...")
    releases = get_releases()
    print(f"Found {len(releases)} releases")
    
    # Generate HTML
    print("Generating HTML page...")
    html = generate_html_page(releases, current_version)
    
    # Write to docs/index.html
    output_path = os.environ.get('OUTPUT_PATH', 'docs/index.html')
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(html)
    
    print(f"Successfully generated {output_path}")
    
    # Also output to stdout for debugging
    print(f"Generated {len(html)} bytes of HTML")
    return 0

if __name__ == '__main__':
    sys.exit(main())
