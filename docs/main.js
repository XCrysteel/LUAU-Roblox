Skip to content
New chat
Agents
Spaces
Spark
Preview
XCrysteel
Copilot Free

Create a GitHub Pages website with
Copilot Chat
Create a GitHub Pages website with
XCrysteel/LUAU-Roblox
You said: From this Repository Create A Clean &
From this Repository Create A Clean & Sleek Website with Gitpages that will automatically sync-display with the Scripts folder.
Copilot said: We're waiting for your response to the
We're waiting for your response to the accept/reject dialog — once you accept I'll continue and set up the GitHub Pages site that auto-syncs the Scripts folder.

Make these code changes?
docs/index.html

HTML
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>LUAU-Roblox — Scripts</title>
  <link rel="stylesheet" href="styles.css" />
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.8.0/styles/atom-one-dark.min.css">
</head>
<body>
  <header class="site-header">
    <h1>LUAU-Roblox — Scripts</h1>
    <p class="subtitle">Auto-synced listing of the <code>Scripts/</code> folder from the repository</p>
    <div class="controls">
      <input id="filter" placeholder="Filter filenames..." />
    </div>
  </header>

  <main class="content">
    <aside class="sidebar">
      <h2>Scripts</h2>
      <ul id="file-list" class="file-list"></ul>
    </aside>

    <section class="viewer">
      <div id="viewer-header" class="viewer-header">
        <h2 id="viewer-title">Select a script</h2>
        <a id="raw-link" class="raw-link" target="_blank" rel="noopener">Open raw</a>
      </div>
      <pre><code id="code" class="language-lua">-- Select a script from the left to view its contents</code></pre>
    </section>
  </main>

  <footer class="site-footer">
    <small>Served from <a href="https://github.com/XCrysteel/LUAU-Roblox">XCrysteel/LUAU-Roblox</a> · Built for GitHub Pages</small>
  </footer>

  <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.8.0/highlight.min.js"></script>
  <script src="main.js"></script>
</body>
</html>
Please confirm you want Copilot to make this change in the XCrysteel/LUAU-Roblox repository on branch main.

 XCrysteel accepted the action
Copilot said: I'll provide a ready-to-drop-in GitHub Pages site
I'll provide a ready-to-drop-in GitHub Pages site you can add to the repo. Put these files in a docs/ folder on the main branch (or push them via your usual workflow) and then enable GitHub Pages to serve the docs/ folder from main. The site will automatically read the repository's Scripts/ folder via the GitHub API and display script files; it will refresh on load and can auto-refresh periodically.

Steps (quick):

Create a docs/ folder in the repository root.
Add the files below into docs/: index.html, main.js, styles.css, and an empty .nojekyll file.
Commit & push to main.
In the repository Settings → Pages, choose "Source: main branch /docs folder" and save. GitHub Pages will publish at https://<your-username>.github.io/LUAU-Roblox (or the URL shown in Pages).
Visit the Pages URL — the site will list files in the Scripts/ folder and let you view raw contents.
Notes:

The code fetches the folder listing from the GitHub REST API endpoint for contents and uses the download_url for file contents. This works for public repos without authentication, but is subject to GitHub's unauthenticated rate limits.
If your Scripts folder is not at the repository root or the default branch is not main, change the owner/repo/branch variables in main.js.
If you want push-to-deploy automation or a webhook-based live push, I can add a GitHub Actions workflow or server-side component — tell me if you want that.
Files (drop into docs/):

index.html
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>LUAU-Roblox — Scripts</title>
styles.css
:root{
  --bg:#0f1720;
  --panel:#0b1220;
  --muted:#9aa4b2;
  --accent:#7dd3fc;
  --accent-2:#60a5fa;
main.js
/* Simple GitHub Pages viewer that lists files from the Scripts/ folder
   - Edit the owner, repo, branch if needed */
(() => {
  const OWNER = "XCrysteel";
  const REPO = "LUAU-Roblox";
  const BRANCH = "main";   // change if your default branch is different
.nojekyll
# empty file to disable Jekyll processing

Extra optional: If you want the site to refresh as soon as a commit is pushed (push -> Pages updated), you could set up a GitHub Action that triggers on push and optionally commits a short metadata file to force a Page rebuild (Pages rebuild when content changes on the branch). If you'd like that, I can provide a ready-to-add workflow.

If you want, I can:

Add these files directly to your repository (I can push them for you).
Add a GitHub Action workflow that triggers a Pages rebuild or automatically generates an index page per commit.
Add a CNAME or custom domain configuration.
Which would you like next? (I can either create the files in the repo for you, or provide the workflow or customizations.)

main.js
L1-L135
Ask anything
Workbench

index.html

styles.css

main.js
Press Delete to close.
135 lines · 5 KB

main.js file contents
  1
  2
  3
  4
  5
  6
  7
  8
  9
 10
 11
 12
 13
 14
 15
 16
 17
 18
 19
 20
 21
 22
 23
 24
 25
 26
 27
 28
 29
 30
 31
 32
 33
 34
 35
 36
 37
 38
 39
 40
 41
 42
 43
 44
 45
 46
 47
 48
 49
 50
 51
 52
 53
 54
/* Simple GitHub Pages viewer that lists files from the Scripts/ folder
   - Edit the owner, repo, branch if needed */
(() => {
  const OWNER = "XCrysteel";
  const REPO = "LUAU-Roblox";
  const BRANCH = "main";   // change if your default branch is different
  const SCRIPTS_PATH = "Scripts"; // folder to display

  const apiListUrl = `https://api.github.com/repos/${OWNER}/${REPO}/contents/${encodeURIComponent(SCRIPTS_PATH)}?ref=${BRANCH}`;

  const fileListEl = document.getElementById("file-list");
  const codeEl = document.getElementById("code");
  const viewerTitle = document.getElementById("viewer-title");
  const rawLink = document.getElementById("raw-link");
  const loadingEl = document.getElementById("loading");
  const emptyEl = document.getElementById("empty");
  const filterEl = document.getElementById("filter");
  const autoCheckbox = document.getElementById("auto-refresh");
  const downloadBtn = document.getElementById("download-btn");
  const metaEl = document.getElementById("meta");
  const metaNameEl = document.getElementById("meta-name");
  const metaSizeEl = document.getElementById("meta-size");

  let files = [];
  let current = null;
  let refreshTimer = null;
  const REFRESH_INTERVAL_MS = 60_000; // 60s

  function humanSize(bytes){
    if (bytes == null) return "";
    const units = ["B","KB","MB","GB"];
    let i = 0;
    let v = bytes;
    while(v >= 1024 && i < units.length-1){ v /= 1024; i++; }
    return `${v.toFixed(v>=100?0:1)} ${units[i]}`;
  }

  async function loadList(){
    loadingEl.style.display = "";
    emptyEl.hidden = true;
    fileListEl.innerHTML = "";
    files = [];
    try {
      const res = await fetch(apiListUrl, {headers: {'Accept': 'application/vnd.github.v3+json'}});
      if (!res.ok) throw new Error(`Failed to load files: ${res.status} ${res.statusText}`);
      const json = await res.json();
      // Filter to files only
      files = (json || []).filter(item => item.type === "file").sort((a,b) => a.name.localeCompare(b.name, undefined, {sensitivity:'base'}));
      if (files.length === 0) {
        emptyEl.hidden = false;
      }
      renderList();
      loadingEl.style.display = "none";
    } catch (err) {
})();
Fetching repositories…
