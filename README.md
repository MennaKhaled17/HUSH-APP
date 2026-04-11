<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>HUSH — Block the noise. Answer the call.</title>
<link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700;900&family=DM+Mono:wght@300;400;500&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
<style>
  :root {
    --bg: #0a0a0f;
    --surface: #111118;
    --surface2: #16161f;
    --border: #1e1e2e;
    --gold: #c9a84c;
    --gold-dim: #8a6d2f;
    --gold-glow: rgba(201,168,76,0.12);
    --white: #f0ede6;
    --muted: #6b6880;
    --text: #ccc9be;
    --accent: #7c6af7;
    --danger: #e05c5c;
    --success: #5cb87a;
  }

  * { margin: 0; padding: 0; box-sizing: border-box; }

  body {
    background: var(--bg);
    color: var(--text);
    font-family: 'DM Sans', sans-serif;
    font-weight: 300;
    line-height: 1.7;
    overflow-x: hidden;
  }

  /* ── NOISE TEXTURE OVERLAY ── */
  body::before {
    content: '';
    position: fixed;
    inset: 0;
    background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 256 256' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noise'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noise)' opacity='0.03'/%3E%3C/svg%3E");
    pointer-events: none;
    z-index: 999;
    opacity: 0.4;
  }

  /* ── HERO ── */
  .hero {
    min-height: 100vh;
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    text-align: center;
    padding: 80px 40px;
    position: relative;
    border-bottom: 1px solid var(--border);
    overflow: hidden;
  }

  .hero::before {
    content: '';
    position: absolute;
    width: 600px;
    height: 600px;
    background: radial-gradient(circle, rgba(201,168,76,0.07) 0%, transparent 70%);
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    pointer-events: none;
  }

  .hero-eyebrow {
    font-family: 'DM Mono', monospace;
    font-size: 11px;
    letter-spacing: 0.3em;
    text-transform: uppercase;
    color: var(--gold);
    margin-bottom: 32px;
    opacity: 0;
    animation: fadeUp 0.8s ease forwards 0.2s;
  }

  .hero-title {
    font-family: 'Playfair Display', serif;
    font-size: clamp(72px, 14vw, 140px);
    font-weight: 900;
    color: var(--white);
    letter-spacing: -0.03em;
    line-height: 0.9;
    margin-bottom: 8px;
    opacity: 0;
    animation: fadeUp 0.8s ease forwards 0.4s;
  }

  .hero-title span {
    color: var(--gold);
  }

  .hero-icon {
    font-size: clamp(40px, 6vw, 60px);
    margin-bottom: 16px;
    opacity: 0;
    animation: fadeUp 0.8s ease forwards 0.3s;
  }

  .hero-tagline {
    font-family: 'Playfair Display', serif;
    font-size: clamp(14px, 2.5vw, 20px);
    color: var(--muted);
    font-style: italic;
    margin-top: 24px;
    margin-bottom: 48px;
    opacity: 0;
    animation: fadeUp 0.8s ease forwards 0.6s;
  }

  .hero-tagline strong {
    color: var(--gold);
    font-style: normal;
  }

  .status-badge {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 100px;
    padding: 8px 20px;
    font-family: 'DM Mono', monospace;
    font-size: 11px;
    letter-spacing: 0.15em;
    color: var(--muted);
    opacity: 0;
    animation: fadeUp 0.8s ease forwards 0.8s;
  }

  .status-dot {
    width: 6px;
    height: 6px;
    border-radius: 50%;
    background: var(--gold);
    animation: pulse 2s ease infinite;
  }

  /* ── LAYOUT ── */
  .container {
    max-width: 960px;
    margin: 0 auto;
    padding: 0 40px;
  }

  section {
    padding: 80px 0;
    border-bottom: 1px solid var(--border);
  }

  section:last-child { border-bottom: none; }

  /* ── SECTION HEADERS ── */
  .section-label {
    font-family: 'DM Mono', monospace;
    font-size: 10px;
    letter-spacing: 0.35em;
    text-transform: uppercase;
    color: var(--gold-dim);
    margin-bottom: 16px;
    display: flex;
    align-items: center;
    gap: 12px;
  }

  .section-label::after {
    content: '';
    flex: 1;
    height: 1px;
    background: var(--border);
  }

  .section-title {
    font-family: 'Playfair Display', serif;
    font-size: clamp(28px, 4vw, 42px);
    font-weight: 700;
    color: var(--white);
    line-height: 1.2;
    margin-bottom: 12px;
  }

  .section-subtitle {
    color: var(--muted);
    font-size: 15px;
    max-width: 520px;
    margin-bottom: 48px;
  }

  /* ── FEATURE CARDS ── */
  .feature-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 1px;
    background: var(--border);
    border: 1px solid var(--border);
  }

  .feature-card {
    background: var(--surface);
    padding: 40px;
    position: relative;
    overflow: hidden;
    transition: background 0.3s ease;
  }

  .feature-card:hover {
    background: var(--surface2);
  }

  .feature-card::before {
    content: '';
    position: absolute;
    top: 0; left: 0;
    width: 3px;
    height: 100%;
    background: var(--gold);
    transform: scaleY(0);
    transform-origin: top;
    transition: transform 0.3s ease;
  }

  .feature-card:hover::before {
    transform: scaleY(1);
  }

  .feature-icon {
    font-size: 28px;
    margin-bottom: 20px;
  }

  .feature-title {
    font-family: 'Playfair Display', serif;
    font-size: 20px;
    font-weight: 700;
    color: var(--white);
    margin-bottom: 12px;
  }

  .feature-desc {
    font-size: 14px;
    color: var(--muted);
    line-height: 1.7;
  }

  .feature-list {
    list-style: none;
    margin-top: 16px;
  }

  .feature-list li {
    font-size: 13px;
    color: var(--text);
    padding: 5px 0;
    display: flex;
    align-items: flex-start;
    gap: 10px;
  }

  .feature-list li::before {
    content: '→';
    color: var(--gold);
    font-family: 'DM Mono', monospace;
    font-size: 11px;
    margin-top: 3px;
    flex-shrink: 0;
  }

  /* ── TECH TABLE ── */
  .tech-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
    gap: 1px;
    background: var(--border);
    border: 1px solid var(--border);
  }

  .tech-item {
    background: var(--surface);
    padding: 24px 28px;
    display: flex;
    align-items: center;
    gap: 16px;
    transition: background 0.2s;
  }

  .tech-item:hover { background: var(--surface2); }

  .tech-layer {
    font-family: 'DM Mono', monospace;
    font-size: 10px;
    letter-spacing: 0.1em;
    color: var(--gold-dim);
    text-transform: uppercase;
    min-width: 80px;
  }

  .tech-value {
    font-size: 14px;
    color: var(--white);
    font-weight: 500;
  }

  /* ── CODE BLOCKS ── */
  .code-block {
    background: var(--surface);
    border: 1px solid var(--border);
    padding: 32px;
    font-family: 'DM Mono', monospace;
    font-size: 13px;
    line-height: 1.8;
    color: var(--text);
    overflow-x: auto;
    position: relative;
  }

  .code-block::before {
    content: attr(data-lang);
    position: absolute;
    top: 12px;
    right: 16px;
    font-size: 10px;
    letter-spacing: 0.2em;
    color: var(--gold-dim);
    text-transform: uppercase;
  }

  .code-comment { color: var(--muted); }
  .code-key { color: var(--gold); }
  .code-val { color: #7ec8a0; }
  .code-tag { color: #7c9fcf; }
  .code-attr { color: #c9a84c; }
  .code-str { color: #a8d8a0; }

  /* ── FLOW DIAGRAM ── */
  .flow {
    display: flex;
    flex-direction: column;
    gap: 0;
  }

  .flow-step {
    display: flex;
    align-items: stretch;
    gap: 24px;
  }

  .flow-line {
    display: flex;
    flex-direction: column;
    align-items: center;
    width: 40px;
    flex-shrink: 0;
  }

  .flow-dot {
    width: 12px;
    height: 12px;
    border-radius: 50%;
    background: var(--gold);
    border: 2px solid var(--bg);
    outline: 1px solid var(--gold-dim);
    flex-shrink: 0;
    margin-top: 4px;
  }

  .flow-connector {
    width: 1px;
    flex: 1;
    background: var(--border);
    margin: 4px 0;
    min-height: 32px;
  }

  .flow-content {
    padding: 0 0 32px 0;
    flex: 1;
  }

  .flow-title {
    font-family: 'DM Mono', monospace;
    font-size: 13px;
    color: var(--white);
    margin-bottom: 4px;
  }

  .flow-desc {
    font-size: 13px;
    color: var(--muted);
  }

  .flow-branch {
    margin-left: 24px;
    border-left: 1px solid var(--border);
    padding-left: 24px;
    margin-top: 8px;
  }

  .flow-branch-item {
    font-size: 12px;
    font-family: 'DM Mono', monospace;
    color: var(--muted);
    padding: 6px 0;
    display: flex;
    align-items: center;
    gap: 8px;
  }

  .flow-branch-item::before {
    content: '├─';
    color: var(--border);
  }

  .flow-branch-item:last-child::before {
    content: '└─';
  }

  .flow-branch-item .tag {
    padding: 2px 8px;
    border-radius: 3px;
    font-size: 10px;
  }

  .tag-success { background: rgba(92,184,122,0.1); color: var(--success); }
  .tag-danger { background: rgba(224,92,92,0.1); color: var(--danger); }

  /* ── PHASES ── */
  .phase-list {
    display: flex;
    flex-direction: column;
    gap: 1px;
    background: var(--border);
    border: 1px solid var(--border);
  }

  .phase-item {
    background: var(--surface);
    padding: 24px 32px;
    display: grid;
    grid-template-columns: 48px 1fr auto;
    align-items: center;
    gap: 24px;
    transition: background 0.2s;
  }

  .phase-item:hover { background: var(--surface2); }

  .phase-num {
    font-family: 'Playfair Display', serif;
    font-size: 28px;
    font-weight: 900;
    color: var(--border);
    line-height: 1;
  }

  .phase-item:first-child .phase-num { color: var(--gold); }

  .phase-name {
    font-size: 15px;
    color: var(--white);
    font-weight: 500;
  }

  .phase-desc {
    font-size: 13px;
    color: var(--muted);
    margin-top: 2px;
  }

  .phase-badge {
    font-family: 'DM Mono', monospace;
    font-size: 10px;
    letter-spacing: 0.1em;
    padding: 4px 12px;
    border-radius: 100px;
  }

  .badge-active { background: rgba(201,168,76,0.1); color: var(--gold); border: 1px solid rgba(201,168,76,0.2); }
  .badge-pending { background: transparent; color: var(--muted); border: 1px solid var(--border); }

  /* ── FILE TREE ── */
  .file-tree {
    font-family: 'DM Mono', monospace;
    font-size: 13px;
    line-height: 2;
    color: var(--muted);
  }

  .file-tree .dir { color: var(--white); }
  .file-tree .file-dart { color: #60b8ff; }
  .file-tree .file-kotlin { color: #a98ff3; }
  .file-tree .file-other { color: var(--muted); }
  .file-tree .tree-icon { color: var(--gold-dim); }

  /* ── COMMIT CONVENTION ── */
  .commit-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 24px;
    margin-bottom: 32px;
  }

  .commit-type {
    background: var(--surface);
    border: 1px solid var(--border);
    padding: 20px 24px;
  }

  .commit-type-label {
    font-family: 'DM Mono', monospace;
    font-size: 12px;
    color: var(--gold);
    margin-bottom: 8px;
  }

  .commit-type-desc {
    font-size: 13px;
    color: var(--muted);
  }

  /* ── PERMISSIONS ── */
  .perm-list {
    display: flex;
    flex-direction: column;
    gap: 1px;
    background: var(--border);
    border: 1px solid var(--border);
  }

  .perm-item {
    background: var(--surface);
    padding: 16px 24px;
    font-family: 'DM Mono', monospace;
    font-size: 12px;
    color: var(--gold);
    display: flex;
    align-items: center;
    gap: 16px;
  }

  .perm-item .perm-reason {
    font-size: 12px;
    color: var(--muted);
    font-family: 'DM Sans', sans-serif;
    margin-left: auto;
  }

  /* ── FOOTER ── */
  .footer {
    padding: 60px 0;
    text-align: center;
  }

  .footer-title {
    font-family: 'Playfair Display', serif;
    font-size: 32px;
    font-weight: 700;
    color: var(--white);
    margin-bottom: 8px;
  }

  .footer-sub {
    font-size: 13px;
    color: var(--muted);
    margin-bottom: 32px;
  }

  .footer-meta {
    font-family: 'DM Mono', monospace;
    font-size: 11px;
    color: var(--gold-dim);
    letter-spacing: 0.2em;
  }

  /* ── DIVIDER ── */
  .gold-divider {
    width: 48px;
    height: 2px;
    background: var(--gold);
    margin: 24px 0;
  }

  /* ── ANIMATIONS ── */
  @keyframes fadeUp {
    from { opacity: 0; transform: translateY(20px); }
    to { opacity: 1; transform: translateY(0); }
  }

  @keyframes pulse {
    0%, 100% { opacity: 1; }
    50% { opacity: 0.4; }
  }

  /* ── RESPONSIVE ── */
  @media (max-width: 680px) {
    .feature-grid { grid-template-columns: 1fr; }
    .commit-grid { grid-template-columns: 1fr; }
    .phase-item { grid-template-columns: 40px 1fr; }
    .phase-badge { display: none; }
    .perm-item .perm-reason { display: none; }
    .container { padding: 0 20px; }
    section { padding: 60px 0; }
  }
</style>
</head>
<body>

<!-- ══ HERO ══ -->
<section class="hero">
  <p class="hero-eyebrow">Flutter · Android · Open Source</p>
  <div class="hero-icon">🤫</div>
  <h1 class="hero-title">H<span>U</span>SH</h1>
  <p class="hero-tagline">
    <strong>Block the noise.</strong> Answer the call. <strong>Own your time.</strong>
  </p>
  <div class="status-badge">
    <span class="status-dot"></span>
    Phase 1 — In Active Development · Cairo, Egypt
  </div>
</section>

<!-- ══ WHAT IS HUSH ══ -->
<div class="container">

<section>
  <p class="section-label">Overview</p>
  <h2 class="section-title">What is HUSH?</h2>
  <p class="section-subtitle">
    HUSH is an Android app built with Flutter that combines Islamic prayer enforcement with a professional focus mode. When it's time to pray — everything stops. When it's time to study — everything stops. No exceptions, no distractions.
  </p>

  <div class="feature-grid">
    <div class="feature-card">
      <div class="feature-icon">🕌</div>
      <div class="feature-title">Prayer Mode</div>
      <div class="feature-desc">Automatically enforces prayer time across your entire device — no app can override it.</div>
      <ul class="feature-list">
        <li>Fetches 5 daily prayer times via GPS location</li>
        <li>Plays the azan at each prayer time</li>
        <li>Locks phone with full-screen dialog after 5 min</li>
        <li>Blocks all apps until prayer is confirmed</li>
        <li>Emergency bypass — logged for accountability</li>
      </ul>
    </div>

    <div class="feature-card">
      <div class="feature-icon">🎯</div>
      <div class="feature-title">Focus Mode</div>
      <div class="feature-desc">Deep work sessions enforced at the OS level. Distraction is not optional.</div>
      <ul class="feature-list">
        <li>25 min, 50 min, or custom session durations</li>
        <li>Blocks all non-whitelisted apps during session</li>
        <li>Built-in Pomodoro: 25 study → 5 break → repeat</li>
        <li>Prayer mid-session: pause → pray → resume</li>
        <li>Whitelist specific apps (notes, maps, calls)</li>
      </ul>
    </div>

    <div class="feature-card">
      <div class="feature-icon">📊</div>
      <div class="feature-title">Dashboard</div>
      <div class="feature-desc">A clear view of your spiritual and intellectual discipline over time.</div>
      <ul class="feature-list">
        <li>Next prayer countdown, live</li>
        <li>Active focus session status</li>
        <li>Weekly stats: prayers kept, hours focused</li>
        <li>Streak tracking for consistency</li>
      </ul>
    </div>

    <div class="feature-card">
      <div class="feature-icon">⚡</div>
      <div class="feature-title">Smart Handoff</div>
      <div class="feature-desc">Prayer and focus modes talk to each other. The transition is seamless and automatic.</div>
      <ul class="feature-list">
        <li>Azan interrupts focus → prayer dialog appears</li>
        <li>Confirm prayer → focus session resumes exactly</li>
        <li>Emergency bypass → session pauses, logged</li>
        <li>No manual toggling between modes</li>
      </ul>
    </div>
  </div>
</section>

<!-- ══ HANDOFF FLOW ══ -->
<section>
  <p class="section-label">Architecture</p>
  <h2 class="section-title">Smart Handoff Flow</h2>
  <p class="section-subtitle">How prayer and focus modes coordinate at the system level.</p>

  <div class="flow">
    <div class="flow-step">
      <div class="flow-line">
        <div class="flow-dot"></div>
        <div class="flow-connector"></div>
      </div>
      <div class="flow-content">
        <div class="flow-title">Azan time hits</div>
        <div class="flow-desc">Prayer service detects scheduled time via GPS-synced API</div>
      </div>
    </div>
    <div class="flow-step">
      <div class="flow-line">
        <div class="flow-dot"></div>
        <div class="flow-connector"></div>
      </div>
      <div class="flow-content">
        <div class="flow-title">Audio plays</div>
        <div class="flow-desc">Azan audio begins via foreground service</div>
      </div>
    </div>
    <div class="flow-step">
      <div class="flow-line">
        <div class="flow-dot"></div>
        <div class="flow-connector"></div>
      </div>
      <div class="flow-content">
        <div class="flow-title">5-minute countdown</div>
        <div class="flow-desc">Grace period before full-screen lock is enforced</div>
      </div>
    </div>
    <div class="flow-step">
      <div class="flow-line">
        <div class="flow-dot"></div>
        <div class="flow-connector"></div>
      </div>
      <div class="flow-content">
        <div class="flow-title">Full-screen prayer dialog</div>
        <div class="flow-desc">All apps blocked. Accessibility service takes control.</div>
        <div class="flow-branch">
          <div class="flow-branch-item">
            <span class="tag tag-success">"I Prayed"</span>
            Apps unblock · Focus session resumes if active
          </div>
          <div class="flow-branch-item">
            <span class="tag tag-danger">"Emergency"</span>
            Apps unblock · Bypass logged · Focus paused
          </div>
        </div>
      </div>
    </div>
  </div>
</section>

<!-- ══ TECH STACK ══ -->
<section>
  <p class="section-label">Technology</p>
  <h2 class="section-title">Tech Stack</h2>
  <p class="section-subtitle">Every tool chosen deliberately for Android system-level access and reliability.</p>

  <div class="tech-grid">
    <div class="tech-item"><span class="tech-layer">Framework</span><span class="tech-value">Flutter (Dart)</span></div>
    <div class="tech-item"><span class="tech-layer">Prayer API</span><span class="tech-value">Aladhan API</span></div>
    <div class="tech-item"><span class="tech-layer">App Blocking</span><span class="tech-value">Android Accessibility Service (Kotlin)</span></div>
    <div class="tech-item"><span class="tech-layer">Bridge</span><span class="tech-value">MethodChannel</span></div>
    <div class="tech-item"><span class="tech-layer">Background</span><span class="tech-value">Android Foreground Service</span></div>
    <div class="tech-item"><span class="tech-layer">Audio</span><span class="tech-value">audioplayers</span></div>
    <div class="tech-item"><span class="tech-layer">Notifications</span><span class="tech-value">flutter_local_notifications</span></div>
    <div class="tech-item"><span class="tech-layer">Location</span><span class="tech-value">geolocator</span></div>
    <div class="tech-item"><span class="tech-layer">Storage</span><span class="tech-value">shared_preferences + sqflite</span></div>
    <div class="tech-item"><span class="tech-layer">State</span><span class="tech-value">Provider</span></div>
  </div>
</section>

<!-- ══ PACKAGES ══ -->
<section>
  <p class="section-label">Dependencies</p>
  <h2 class="section-title">Flutter Packages</h2>

  <div class="code-block" data-lang="yaml">
<span class="code-key">dependencies:</span>
  <span class="code-key">flutter:</span>
    <span class="code-key">sdk:</span> <span class="code-val">flutter</span>
  <span class="code-key">http:</span>                         <span class="code-comment"># Prayer times API calls</span>
  <span class="code-key">audioplayers:</span>                  <span class="code-comment"># Azan audio playback</span>
  <span class="code-key">flutter_local_notifications:</span>   <span class="code-comment"># Prayer time alerts</span>
  <span class="code-key">geolocator:</span>                    <span class="code-comment"># GPS-based prayer time calculation</span>
  <span class="code-key">shared_preferences:</span>            <span class="code-comment"># Lightweight local settings</span>
  <span class="code-key">sqflite:</span>                       <span class="code-comment"># Focus session history & stats</span>
  <span class="code-key">provider:</span>                      <span class="code-comment"># App-wide state management</span>
  <span class="code-key">flutter_foreground_task:</span>       <span class="code-comment"># Background service persistence</span>
  </div>
</section>

<!-- ══ PERMISSIONS ══ -->
<section>
  <p class="section-label">Android Manifest</p>
  <h2 class="section-title">Required Permissions</h2>

  <div class="perm-list">
    <div class="perm-item">android.permission.INTERNET <span class="perm-reason">Fetch prayer times from Aladhan API</span></div>
    <div class="perm-item">android.permission.ACCESS_FINE_LOCATION <span class="perm-reason">GPS-based prayer time accuracy</span></div>
    <div class="perm-item">android.permission.FOREGROUND_SERVICE <span class="perm-reason">Keep services alive in background</span></div>
    <div class="perm-item">android.permission.FOREGROUND_SERVICE_SPECIAL_USE <span class="perm-reason">Special foreground service type</span></div>
    <div class="perm-item">android.permission.USE_EXACT_ALARM <span class="perm-reason">Precise azan scheduling</span></div>
    <div class="perm-item">android.permission.BIND_ACCESSIBILITY_SERVICE <span class="perm-reason">OS-level app blocking</span></div>
    <div class="perm-item">android.permission.PACKAGE_USAGE_STATS <span class="perm-reason">Detect which app is in foreground</span></div>
    <div class="perm-item">android.permission.SYSTEM_ALERT_WINDOW <span class="perm-reason">Draw full-screen prayer overlay</span></div>
  </div>
</section>

<!-- ══ PROJECT STRUCTURE ══ -->
<section>
  <p class="section-label">Codebase</p>
  <h2 class="section-title">Project Structure</h2>

  <div class="code-block" data-lang="tree">
<span class="dir tree-icon">hush/</span>
├── <span class="dir">lib/</span>
│   ├── <span class="file-dart">main.dart</span>
│   ├── <span class="dir">screens/</span>
│   │   ├── <span class="file-dart">home_screen.dart</span>
│   │   ├── <span class="file-dart">prayer_screen.dart</span>
│   │   ├── <span class="file-dart">focus_screen.dart</span>
│   │   └── <span class="file-dart">settings_screen.dart</span>
│   ├── <span class="dir">services/</span>
│   │   ├── <span class="file-dart">prayer_service.dart</span>
│   │   ├── <span class="file-dart">blocker_service.dart</span>
│   │   ├── <span class="file-dart">audio_service.dart</span>
│   │   └── <span class="file-dart">focus_service.dart</span>
│   ├── <span class="dir">models/</span>
│   │   ├── <span class="file-dart">prayer_time.dart</span>
│   │   └── <span class="file-dart">focus_session.dart</span>
│   └── <span class="dir">widgets/</span>
│       ├── <span class="file-dart">prayer_dialog.dart</span>
│       ├── <span class="file-dart">countdown_timer.dart</span>
│       └── <span class="file-dart">focus_card.dart</span>
├── <span class="dir">android/app/src/main/kotlin/</span>
│   └── <span class="file-kotlin">HushAccessibilityService.kt</span>
├── <span class="dir">assets/audio/</span>
│   └── <span class="file-other">azan.mp3</span>
└── <span class="file-other">pubspec.yaml</span>
  </div>
</section>

<!-- ══ BUILD PHASES ══ -->
<section>
  <p class="section-label">Roadmap</p>
  <h2 class="section-title">Build Phases</h2>

  <div class="phase-list">
    <div class="phase-item">
      <div class="phase-num">1</div>
      <div>
        <div class="phase-name">Flutter Setup & First Run</div>
        <div class="phase-desc">Project scaffold, dependencies, device connection</div>
      </div>
      <div class="phase-badge badge-active">Active</div>
    </div>
    <div class="phase-item">
      <div class="phase-num">2</div>
      <div>
        <div class="phase-name">Prayer Times Screen</div>
        <div class="phase-desc">Fetch and display 5 daily prayers from Aladhan API</div>
      </div>
      <div class="phase-badge badge-pending">Pending</div>
    </div>
    <div class="phase-item">
      <div class="phase-num">3</div>
      <div>
        <div class="phase-name">Azan Audio & Notifications</div>
        <div class="phase-desc">Schedule and trigger azan with local notifications</div>
      </div>
      <div class="phase-badge badge-pending">Pending</div>
    </div>
    <div class="phase-item">
      <div class="phase-num">4</div>
      <div>
        <div class="phase-name">Full-Screen Prayer Dialog</div>
        <div class="phase-desc">Countdown overlay with confirm and emergency bypass</div>
      </div>
      <div class="phase-badge badge-pending">Pending</div>
    </div>
    <div class="phase-item">
      <div class="phase-num">5</div>
      <div>
        <div class="phase-name">Android Accessibility Service</div>
        <div class="phase-desc">Kotlin-based OS-level app blocker</div>
      </div>
      <div class="phase-badge badge-pending">Pending</div>
    </div>
    <div class="phase-item">
      <div class="phase-num">6</div>
      <div>
        <div class="phase-name">Focus Mode</div>
        <div class="phase-desc">Pomodoro timer, session management, whitelist</div>
      </div>
      <div class="phase-badge badge-pending">Pending</div>
    </div>
    <div class="phase-item">
      <div class="phase-num">7</div>
      <div>
        <div class="phase-name">Dashboard, Stats & Polish</div>
        <div class="phase-desc">Weekly streaks, settings, final design pass</div>
      </div>
      <div class="phase-badge badge-pending">Pending</div>
    </div>
  </div>
</section>

<!-- ══ COMMIT CONVENTION ══ -->
<section>
  <p class="section-label">Git Workflow</p>
  <h2 class="section-title">Commit Convention</h2>
  <p class="section-subtitle">This project follows <a href="https://www.conventionalcommits.org/" style="color:var(--gold);text-decoration:none;">Conventional Commits</a>.</p>

  <div class="code-block" data-lang="format" style="margin-bottom: 24px;">
<span class="code-key">type</span>(<span class="code-val">scope</span>): <span class="code-comment">short description</span>
  </div>

  <div class="commit-grid">
    <div class="commit-type"><div class="commit-type-label">feat</div><div class="commit-type-desc">New feature added</div></div>
    <div class="commit-type"><div class="commit-type-label">fix</div><div class="commit-type-desc">Bug fix</div></div>
    <div class="commit-type"><div class="commit-type-label">refactor</div><div class="commit-type-desc">Code restructure, no behavior change</div></div>
    <div class="commit-type"><div class="commit-type-label">style</div><div class="commit-type-desc">UI/visual changes only</div></div>
    <div class="commit-type"><div class="commit-type-label">chore</div><div class="commit-type-desc">Dependencies, config, tooling</div></div>
    <div class="commit-type"><div class="commit-type-label">docs</div><div class="commit-type-desc">Documentation updates</div></div>
  </div>

  <div class="code-block" data-lang="examples">
<span class="code-comment"># Scopes: prayer · focus · blocker · dialog · audio · settings · home</span>

init: scaffold HUSH Flutter project
feat(prayer): fetch prayer times from aladhan API
feat(blocker): add accessibility service for app blocking
feat(focus): implement pomodoro session timer
fix(dialog): emergency button not dismissing overlay
style(home): redesign dashboard card layout
chore: add geolocator and audioplayers packages
  </div>
</section>

<!-- ══ BRANCH STRATEGY ══ -->
<section>
  <p class="section-label">Version Control</p>
  <h2 class="section-title">Branch Strategy</h2>

  <div class="tech-grid" style="grid-template-columns: 1fr 1fr;">
    <div class="tech-item" style="flex-direction: column; align-items: flex-start; gap: 8px; padding: 28px;">
      <span class="tech-layer">main</span>
      <span class="tech-value">Stable, working code only</span>
      <span style="font-size:12px; color: var(--muted);">Merge only when a full feature is complete and tested</span>
    </div>
    <div class="tech-item" style="flex-direction: column; align-items: flex-start; gap: 8px; padding: 28px;">
      <span class="tech-layer">dev</span>
      <span class="tech-value">Daily work branch</span>
      <span style="font-size:12px; color: var(--muted);">Always work here — never commit directly to main</span>
    </div>
  </div>
</section>

</div>

<!-- ══ FOOTER ══ -->
<div style="border-top: 1px solid var(--border);">
<div class="container">
  <div class="footer">
    <div class="footer-title">🤫 HUSH</div>
    <div class="footer-sub">Block the noise. Answer the call. Own your time.</div>
    <div class="footer-meta">Built by Mena Khaled · Cairo, Egypt · 🚧 Phase 1 in progress</div>
  </div>
</div>
</div>

</body>
</html>
