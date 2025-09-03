# Personal Website with MkDocs + uv + GitHub Pages

A clean, cheap, and fast way to build and deploy a personal website using **MkDocs (Material theme)**, **uv** for Python env/deps, and **GitHub Pages**.

---

## What you’ll get

- A personal site at **https://<username>.github.io**
- Free hosting via GitHub Pages
- Reproducible Python environment with `uv`
- Automatic deploy on every push to `main`

---

## Prerequisites

- **Git** and a GitHub account
- **uv** installed  
  macOS/Linux:
  ```bash
  curl -LsSf https://astral.sh/uv/install.sh | sh
  exec $SHELL -l
  uv --version
  ```
- *(Optional)* **GitHub CLI** (`gh`) if you want to create the repo from the terminal:
  ```bash
  # macOS with Homebrew
  brew install gh
  gh auth login
  ```

---

## 1) Create the repository

**Option A — with GitHub CLI**
```bash
gh repo create <username>.github.io --public --clone
cd <username>.github.io
```

**Option B — via GitHub UI**
1. Create a new public repo named **`<username>.github.io`**.  
2. Clone it:
   ```bash
   git clone https://github.com/<username>/<username>.github.io.git
   cd <username>.github.io
   ```

---

## 2) Initialize the project with uv

```bash
uv python install 3.12            # pins and installs Python 3.12 locally
uv init                           # creates pyproject.toml, .python-version, .venv, etc.
uv add mkdocs mkdocs-material mkdocs-material-extensions mkdocs-blog-plugin
uv run mkdocs new .               # writes mkdocs.yml and docs/index.md
uv run mkdocs serve               # preview at http://127.0.0.1:8000
uv lock                           # write uv.lock for reproducible CI
```

Good time to do the first commit:

```
git add .
git commit -m "MkDocs + uv setup"
git push
```

> **Note:** Keep **`.python-version`** as **`3.12`** (avoid exact patches like `3.11.0` in CI).

---

## 3) Minimal `mkdocs.yml` (copy & paste)

```yaml
site_name: <Your Name>
site_url: https://<username>.github.io
theme:
  name: material
  features:
    - navigation.tabs
    - search.suggest
    - content.code.copy
  palette:
    - scheme: default
    - scheme: slate
nav:
  - Home: index.md
  - About: about.md
  - Projects: projects.md
  - Blog: blog/index.md
  - Contact: contact.md
plugins:
  - search
  - blog:
      blog_dir: blog
      post_dir: blog/posts
markdown_extensions:
  - admonition
  - attr_list
  - pymdownx.superfences
  - pymdownx.details
```

Create the matching pages (blank is fine to start):
```bash
mkdir -p docs/blog docs/blog/posts
: > docs/about.md
: > docs/projects.md
: > docs/contact.md
: > docs/blog/index.md
```

Preview:
```bash
uv run mkdocs serve
```

---

## 4) GitHub Actions (auto-deploy on push to `main`)

Create the workflow file:

```bash
mkdir -p .github/workflows
```

**`.github/workflows/gh-pages.yml`**
```yaml
name: Deploy MkDocs (uv)
on:
  push:
    branches: [ main ]
permissions:
  contents: write

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      # Install Python (stable & cached)
      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"

      # Install uv
      - uses: astral-sh/setup-uv@v6
        with:
          enable-cache: true

      # Install project deps (from pyproject/uv.lock) or add if first run
      - run: uv sync || uv add mkdocs mkdocs-material mkdocs-material-extensions mkdocs-blog-plugin

      # Build & publish site to gh-pages branch
      - run: uv run mkdocs gh-deploy --force
```

Commit and push:
```bash
git add .github/workflows/gh-pages.yml
git commit -m "Add Pages deploy workflow"
git push
```

---

## 5) Configure GitHub Pages

1. Go to your repo **Settings → Pages**  
2. **Build and deployment → Source:** **Deploy from a branch**  
3. **Branch:** `gh-pages` and **`/(root)`**  
4. **Save**

> This tells Pages to serve the content that the workflow pushes to the `gh-pages` branch.

---

## 6) Verify the deploy

- **Actions tab:** The latest “Deploy MkDocs (uv)” run should be **green**.
- **Branch check:** Open the `gh-pages` branch and confirm files like `index.html`, `sitemap.xml`, `.nojekyll`.
- **Visit your site:**  
  - Fresh view: `https://gerardmartinezcanelles.github.io/?nocache=1`  
  - If the non-parameterized URL shows old content, **hard refresh** (Cmd+Shift+R / Ctrl+F5) or try Incognito (normal CDN/browser caching).

---

## 7) Manual deploy (optional)

You can also publish from your machine at any time:
```bash
uv run mkdocs gh-deploy --force
```

---

## Troubleshooting

- **Action fails with “No interpreter found for Python X.Y.Z”**  
  Ensure your repo’s `.python-version` matches the workflow Python. Prefer **minor pins** like `3.12`.
  ```bash
  echo "3.12" > .python-version
  git add .python-version
  git commit -m "Use Python 3.12 (match CI)"
  git push
  ```

- **Page not updating without `?nocache=1`**  
  It’s caching. Hard refresh, use Incognito, or wait a few minutes. Confirm new files exist on the `gh-pages` branch.

- **No `gh-pages` branch yet**  
  Run a deploy once (via CI or locally) to create it:
  ```bash
  uv run mkdocs gh-deploy --force
  ```

---

## Common commands

```bash
# Start local server
uv run mkdocs serve

# Build site locally (outputs to ./site)
uv run mkdocs build

# Deploy from local machine
uv run mkdocs gh-deploy --force
```
