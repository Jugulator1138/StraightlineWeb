# Straight-Line Custom Solutions - Portfolio Website Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a mobile-first portfolio website for Straight-Line Custom Solutions with industrial workshop aesthetic, swipe-based navigation, and lead capture forms.

**Architecture:** Static HTML/CSS/JS site with no build step. Mobile-first design with progressive enhancement for desktop. Project data stored in JSON for easy updates. Forms submit to serverless function for email capture.

**Tech Stack:** HTML5, CSS3 (variables, flexbox, grid), Vanilla JavaScript, Cloudflare Pages, Cloudflare Functions (for form handling)

---

## Task 1: Project Setup & Folder Structure

**Files:**
- Create: `D:\claudecode\site\index.html`
- Create: `D:\claudecode\site\css\variables.css`
- Create: `D:\claudecode\site\css\styles.css`
- Create: `D:\claudecode\site\js\main.js`
- Create: `D:\claudecode\site\data\projects.json`
- Create: `D:\claudecode\site\.gitignore`
- Create: `D:\claudecode\site\README.md`

**Step 1: Create folder structure**

```bash
mkdir -p D:/claudecode/site/css D:/claudecode/site/js D:/claudecode/site/images/projects D:/claudecode/site/images/ui D:/claudecode/site/data D:/claudecode/site/functions
```

**Step 2: Create .gitignore**

```gitignore
# Dependencies
node_modules/

# Local data
data/leads.json

# OS files
.DS_Store
Thumbs.db

# Editor
.vscode/
*.swp

# Environment
.env
.env.local
```

**Step 3: Create README.md**

```markdown
# Straight-Line Custom Solutions Website

Portfolio website for forprofessionaluseonly.com

## Local Development

Open `index.html` in browser, or use a local server:

```bash
npx serve site
```

## Deployment

Push to GitHub → Cloudflare Pages auto-deploys.

## Adding Projects

Edit `data/projects.json` and add images to `images/projects/[project-name]/`
```

**Step 4: Initialize git repository**

```bash
cd D:/claudecode/site && git init
```

**Step 5: Verify structure**

Run: `ls -la D:/claudecode/site/`
Expected: Folders and files created

**Step 6: Commit**

```bash
cd D:/claudecode/site && git add -A && git commit -m "chore: initial project structure

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```

---

## Task 2: CSS Variables & Base Reset

**Files:**
- Create: `D:\claudecode\site\css\variables.css`
- Create: `D:\claudecode\site\css\styles.css`

**Step 1: Create CSS variables**

```css
/* variables.css - Design tokens for Straight-Line Custom Solutions */

:root {
  /* Colors */
  --color-primary: #1a1a1a;
  --color-secondary: #2d2d2d;
  --color-accent: #d4a574;
  --color-text: #f5f5f5;
  --color-text-muted: #a0a0a0;
  --color-highlight: #b87333;
  --color-success: #4a7c59;
  --color-error: #8b3a3a;

  /* Typography */
  --font-headline: 'Bebas Neue', 'Arial Black', sans-serif;
  --font-body: 'Inter', 'Segoe UI', sans-serif;
  --font-mono: 'JetBrains Mono', 'Consolas', monospace;

  /* Font sizes - mobile first */
  --text-xs: 0.75rem;
  --text-sm: 0.875rem;
  --text-base: 1rem;
  --text-lg: 1.125rem;
  --text-xl: 1.25rem;
  --text-2xl: 1.5rem;
  --text-3xl: 2rem;
  --text-4xl: 2.5rem;
  --text-5xl: 3rem;

  /* Spacing */
  --space-xs: 0.25rem;
  --space-sm: 0.5rem;
  --space-md: 1rem;
  --space-lg: 1.5rem;
  --space-xl: 2rem;
  --space-2xl: 3rem;
  --space-3xl: 4rem;

  /* Layout */
  --max-width: 1200px;
  --nav-height: 60px;
  --card-radius: 4px;

  /* Transitions */
  --transition-fast: 150ms ease;
  --transition-base: 250ms ease;
  --transition-slow: 400ms ease;

  /* Shadows */
  --shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.3);
  --shadow-md: 0 4px 6px rgba(0, 0, 0, 0.4);
  --shadow-lg: 0 10px 15px rgba(0, 0, 0, 0.5);
}
```

**Step 2: Create base styles**

```css
/* styles.css - Base styles for Straight-Line Custom Solutions */

@import url('variables.css');

/* Google Fonts */
@import url('https://fonts.googleapis.com/css2?family=Bebas+Neue&family=Inter:wght@400;500;600&family=JetBrains+Mono&display=swap');

/* Reset */
*, *::before, *::after {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

html {
  font-size: 16px;
  scroll-behavior: smooth;
  -webkit-tap-highlight-color: transparent;
}

body {
  font-family: var(--font-body);
  font-size: var(--text-base);
  line-height: 1.6;
  color: var(--color-text);
  background-color: var(--color-primary);
  min-height: 100vh;
  overflow-x: hidden;
}

/* Typography */
h1, h2, h3, h4 {
  font-family: var(--font-headline);
  font-weight: 400;
  line-height: 1.2;
  letter-spacing: 0.05em;
  text-transform: uppercase;
}

h1 { font-size: var(--text-4xl); }
h2 { font-size: var(--text-3xl); }
h3 { font-size: var(--text-2xl); }
h4 { font-size: var(--text-xl); }

p { margin-bottom: var(--space-md); }

a {
  color: var(--color-accent);
  text-decoration: none;
  transition: color var(--transition-fast);
}

a:hover {
  color: var(--color-highlight);
}

/* Images */
img {
  max-width: 100%;
  height: auto;
  display: block;
}

/* Buttons */
.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: var(--space-sm) var(--space-lg);
  font-family: var(--font-headline);
  font-size: var(--text-base);
  letter-spacing: 0.1em;
  text-transform: uppercase;
  border: 2px solid var(--color-highlight);
  background: transparent;
  color: var(--color-text);
  cursor: pointer;
  transition: all var(--transition-base);
}

.btn:hover {
  background: var(--color-highlight);
  color: var(--color-primary);
}

.btn--primary {
  background: var(--color-highlight);
  color: var(--color-primary);
}

.btn--primary:hover {
  background: var(--color-accent);
  border-color: var(--color-accent);
}

/* Utility classes */
.container {
  width: 100%;
  max-width: var(--max-width);
  margin: 0 auto;
  padding: 0 var(--space-md);
}

.sr-only {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  border: 0;
}

/* Desktop enhancements */
@media (min-width: 768px) {
  h1 { font-size: var(--text-5xl); }
  h2 { font-size: var(--text-4xl); }

  .container {
    padding: 0 var(--space-xl);
  }
}
```

**Step 3: Verify files created**

Run: `ls D:/claudecode/site/css/`
Expected: `variables.css styles.css`

**Step 4: Commit**

```bash
cd D:/claudecode/site && git add css/ && git commit -m "feat: add CSS variables and base styles

- Design tokens (colors, typography, spacing)
- CSS reset and base typography
- Button components
- Utility classes

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```

---

## Task 3: HTML Boilerplate & Head

**Files:**
- Create: `D:\claudecode\site\index.html`

**Step 1: Create index.html with head and meta tags**

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover">
  <meta name="description" content="Straight-Line Custom Solutions - Custom woodworking, renovations, pro audio, and professional finishing services. For Professional Use Only.">
  <meta name="theme-color" content="#1a1a1a">

  <!-- Open Graph -->
  <meta property="og:title" content="Straight-Line Custom Solutions">
  <meta property="og:description" content="Custom builds. Precision finishing. From concept to completion.">
  <meta property="og:type" content="website">
  <meta property="og:url" content="https://forprofessionaluseonly.com">

  <title>Straight-Line Custom Solutions | For Professional Use Only</title>

  <!-- Preconnect to Google Fonts -->
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>

  <!-- Styles -->
  <link rel="stylesheet" href="css/styles.css">

  <!-- Favicon placeholder -->
  <link rel="icon" href="data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><text y='.9em' font-size='90'>⚒️</text></svg>">
</head>
<body>
  <!-- Content will be added in subsequent tasks -->

  <script src="js/main.js" defer></script>
</body>
</html>
```

**Step 2: Open in browser to verify**

Run: `start D:/claudecode/site/index.html` (Windows)
Expected: Dark background page loads without errors

**Step 3: Commit**

```bash
cd D:/claudecode/site && git add index.html && git commit -m "feat: add HTML boilerplate with meta tags

- SEO meta description
- Open Graph tags for social sharing
- Theme color for mobile browsers
- Font preconnects for performance

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```

---

## Task 4: Navigation Component

**Files:**
- Modify: `D:\claudecode\site\index.html`
- Modify: `D:\claudecode\site\css\styles.css`
- Modify: `D:\claudecode\site\js\main.js`

**Step 1: Add navigation HTML to index.html (after body tag)**

```html
  <!-- Navigation -->
  <nav class="nav" id="nav">
    <div class="nav__container">
      <a href="/" class="nav__logo">
        <span class="nav__logo-text">Straight-Line</span>
        <span class="nav__logo-sub">Custom Solutions</span>
      </a>

      <button class="nav__toggle" id="nav-toggle" aria-label="Toggle menu" aria-expanded="false">
        <span class="nav__toggle-bar"></span>
        <span class="nav__toggle-bar"></span>
        <span class="nav__toggle-bar"></span>
      </button>

      <ul class="nav__menu" id="nav-menu">
        <li><a href="#work" class="nav__link">Work</a></li>
        <li><a href="about.html" class="nav__link">About</a></li>
        <li><a href="#contact" class="nav__link">Contact</a></li>
      </ul>
    </div>
  </nav>
```

**Step 2: Add navigation CSS to styles.css**

```css
/* Navigation */
.nav {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  height: var(--nav-height);
  background: rgba(26, 26, 26, 0.95);
  backdrop-filter: blur(10px);
  z-index: 1000;
  border-bottom: 1px solid var(--color-secondary);
}

.nav__container {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 100%;
  max-width: var(--max-width);
  margin: 0 auto;
  padding: 0 var(--space-md);
}

.nav__logo {
  display: flex;
  flex-direction: column;
  color: var(--color-text);
  line-height: 1.1;
}

.nav__logo-text {
  font-family: var(--font-headline);
  font-size: var(--text-lg);
  letter-spacing: 0.1em;
  text-transform: uppercase;
}

.nav__logo-sub {
  font-size: var(--text-xs);
  color: var(--color-accent);
  letter-spacing: 0.05em;
}

.nav__toggle {
  display: flex;
  flex-direction: column;
  justify-content: center;
  gap: 5px;
  width: 30px;
  height: 30px;
  background: none;
  border: none;
  cursor: pointer;
  padding: 0;
}

.nav__toggle-bar {
  width: 100%;
  height: 2px;
  background: var(--color-text);
  transition: transform var(--transition-base), opacity var(--transition-base);
}

.nav__toggle[aria-expanded="true"] .nav__toggle-bar:nth-child(1) {
  transform: translateY(7px) rotate(45deg);
}

.nav__toggle[aria-expanded="true"] .nav__toggle-bar:nth-child(2) {
  opacity: 0;
}

.nav__toggle[aria-expanded="true"] .nav__toggle-bar:nth-child(3) {
  transform: translateY(-7px) rotate(-45deg);
}

.nav__menu {
  position: fixed;
  top: var(--nav-height);
  left: 0;
  right: 0;
  bottom: 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: var(--space-xl);
  background: var(--color-primary);
  list-style: none;
  transform: translateX(100%);
  transition: transform var(--transition-base);
}

.nav__menu.is-open {
  transform: translateX(0);
}

.nav__link {
  font-family: var(--font-headline);
  font-size: var(--text-2xl);
  color: var(--color-text);
  letter-spacing: 0.1em;
  text-transform: uppercase;
}

.nav__link:hover {
  color: var(--color-accent);
}

/* Desktop navigation */
@media (min-width: 768px) {
  .nav__toggle {
    display: none;
  }

  .nav__menu {
    position: static;
    flex-direction: row;
    background: transparent;
    transform: none;
    gap: var(--space-xl);
  }

  .nav__link {
    font-size: var(--text-base);
  }
}
```

**Step 3: Add navigation JS to main.js**

```javascript
// main.js - Straight-Line Custom Solutions

(function() {
  'use strict';

  // Navigation toggle
  const navToggle = document.getElementById('nav-toggle');
  const navMenu = document.getElementById('nav-menu');

  if (navToggle && navMenu) {
    navToggle.addEventListener('click', () => {
      const isOpen = navToggle.getAttribute('aria-expanded') === 'true';
      navToggle.setAttribute('aria-expanded', !isOpen);
      navMenu.classList.toggle('is-open');
      document.body.style.overflow = isOpen ? '' : 'hidden';
    });

    // Close menu when clicking a link
    navMenu.querySelectorAll('.nav__link').forEach(link => {
      link.addEventListener('click', () => {
        navToggle.setAttribute('aria-expanded', 'false');
        navMenu.classList.remove('is-open');
        document.body.style.overflow = '';
      });
    });
  }

  // Hide nav on scroll down, show on scroll up
  let lastScroll = 0;
  const nav = document.getElementById('nav');

  window.addEventListener('scroll', () => {
    const currentScroll = window.pageYOffset;

    if (currentScroll <= 0) {
      nav.classList.remove('nav--hidden');
      return;
    }

    if (currentScroll > lastScroll && currentScroll > 100) {
      nav.classList.add('nav--hidden');
    } else {
      nav.classList.remove('nav--hidden');
    }

    lastScroll = currentScroll;
  }, { passive: true });

})();
```

**Step 4: Add nav hidden state to CSS**

```css
.nav--hidden {
  transform: translateY(-100%);
}

.nav {
  transition: transform var(--transition-base);
}
```

**Step 5: Test in browser**

Run: Refresh browser, test hamburger menu on mobile viewport
Expected: Menu toggles, links close menu, nav hides on scroll

**Step 6: Commit**

```bash
cd D:/claudecode/site && git add -A && git commit -m "feat: add responsive navigation

- Sticky nav with blur backdrop
- Mobile hamburger menu with animation
- Hide on scroll down, show on scroll up
- Desktop horizontal menu

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```

---

## Task 5: Hero Section

**Files:**
- Modify: `D:\claudecode\site\index.html`
- Modify: `D:\claudecode\site\css\styles.css`

**Step 1: Add hero HTML after nav**

```html
  <!-- Hero -->
  <section class="hero" id="hero">
    <div class="hero__background">
      <!-- Placeholder - replace with actual hero image -->
      <div class="hero__placeholder"></div>
    </div>
    <div class="hero__content">
      <p class="hero__tagline">For Professional Use Only</p>
      <h1 class="hero__title">Straight-Line<br>Custom Solutions</h1>
      <p class="hero__subtitle">Custom builds. Precision finishing. From concept to completion.</p>
      <div class="hero__cta">
        <a href="#work" class="btn btn--primary">See the Work</a>
      </div>
    </div>
    <div class="hero__scroll">
      <span>Scroll</span>
      <div class="hero__scroll-line"></div>
    </div>
  </section>
```

**Step 2: Add hero CSS**

```css
/* Hero Section */
.hero {
  position: relative;
  min-height: 100vh;
  min-height: 100dvh;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  text-align: center;
  padding: var(--space-xl);
  padding-top: calc(var(--nav-height) + var(--space-xl));
}

.hero__background {
  position: absolute;
  inset: 0;
  z-index: -1;
  overflow: hidden;
}

.hero__background::after {
  content: '';
  position: absolute;
  inset: 0;
  background: linear-gradient(
    to bottom,
    rgba(26, 26, 26, 0.7) 0%,
    rgba(26, 26, 26, 0.5) 50%,
    rgba(26, 26, 26, 0.9) 100%
  );
}

.hero__placeholder {
  width: 100%;
  height: 100%;
  background:
    linear-gradient(135deg, var(--color-secondary) 0%, var(--color-primary) 100%),
    repeating-linear-gradient(
      45deg,
      transparent,
      transparent 10px,
      rgba(255,255,255,0.03) 10px,
      rgba(255,255,255,0.03) 20px
    );
}

.hero__content {
  max-width: 600px;
}

.hero__tagline {
  font-family: var(--font-mono);
  font-size: var(--text-sm);
  color: var(--color-accent);
  letter-spacing: 0.2em;
  text-transform: uppercase;
  margin-bottom: var(--space-md);
}

.hero__title {
  font-size: var(--text-4xl);
  margin-bottom: var(--space-lg);
  line-height: 1;
}

.hero__subtitle {
  font-size: var(--text-lg);
  color: var(--color-text-muted);
  margin-bottom: var(--space-xl);
}

.hero__cta {
  margin-top: var(--space-lg);
}

.hero__scroll {
  position: absolute;
  bottom: var(--space-xl);
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--space-sm);
  font-family: var(--font-mono);
  font-size: var(--text-xs);
  color: var(--color-text-muted);
  letter-spacing: 0.1em;
  text-transform: uppercase;
}

.hero__scroll-line {
  width: 1px;
  height: 40px;
  background: linear-gradient(to bottom, var(--color-accent), transparent);
  animation: scrollPulse 2s ease-in-out infinite;
}

@keyframes scrollPulse {
  0%, 100% { opacity: 1; transform: scaleY(1); }
  50% { opacity: 0.5; transform: scaleY(0.8); }
}

/* Desktop hero */
@media (min-width: 768px) {
  .hero__title {
    font-size: var(--text-5xl);
  }

  .hero__tagline {
    font-size: var(--text-base);
  }
}
```

**Step 3: Test in browser**

Run: Refresh browser
Expected: Full-screen hero with title, tagline, CTA button, scroll indicator

**Step 4: Commit**

```bash
cd D:/claudecode/site && git add -A && git commit -m "feat: add hero section

- Full viewport height
- Gradient overlay for text readability
- Scroll indicator animation
- Responsive typography

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```

---

## Task 6: Category Overview Carousel

**Files:**
- Modify: `D:\claudecode\site\index.html`
- Modify: `D:\claudecode\site\css\styles.css`
- Create: `D:\claudecode\site\js\swipe.js`

**Step 1: Add categories HTML after hero**

```html
  <!-- Categories Overview -->
  <section class="categories" id="categories">
    <div class="categories__header">
      <h2 class="categories__title">What I Build</h2>
      <p class="categories__hint">Swipe to explore</p>
    </div>
    <div class="categories__carousel" id="categories-carousel">
      <div class="categories__track">
        <article class="category-card" data-category="woodworking">
          <div class="category-card__image">
            <div class="category-card__placeholder"></div>
          </div>
          <h3 class="category-card__title">Woodworking</h3>
        </article>
        <article class="category-card" data-category="renovations">
          <div class="category-card__image">
            <div class="category-card__placeholder"></div>
          </div>
          <h3 class="category-card__title">Renovations</h3>
        </article>
        <article class="category-card" data-category="audio">
          <div class="category-card__image">
            <div class="category-card__placeholder"></div>
          </div>
          <h3 class="category-card__title">Pro Audio</h3>
        </article>
        <article class="category-card" data-category="finishing">
          <div class="category-card__image">
            <div class="category-card__placeholder"></div>
          </div>
          <h3 class="category-card__title">Finishing</h3>
        </article>
        <article class="category-card" data-category="design">
          <div class="category-card__image">
            <div class="category-card__placeholder"></div>
          </div>
          <h3 class="category-card__title">Design</h3>
        </article>
      </div>
    </div>
  </section>
```

**Step 2: Add categories CSS**

```css
/* Categories Section */
.categories {
  padding: var(--space-3xl) 0;
  overflow: hidden;
}

.categories__header {
  text-align: center;
  margin-bottom: var(--space-xl);
  padding: 0 var(--space-md);
}

.categories__title {
  margin-bottom: var(--space-sm);
}

.categories__hint {
  font-family: var(--font-mono);
  font-size: var(--text-sm);
  color: var(--color-text-muted);
}

.categories__carousel {
  overflow-x: auto;
  overflow-y: hidden;
  scroll-snap-type: x mandatory;
  scrollbar-width: none;
  -ms-overflow-style: none;
  padding: var(--space-md);
}

.categories__carousel::-webkit-scrollbar {
  display: none;
}

.categories__track {
  display: flex;
  gap: var(--space-md);
  padding: 0 calc(50vw - 140px);
}

.category-card {
  flex-shrink: 0;
  width: 250px;
  scroll-snap-align: center;
  cursor: pointer;
  transition: transform var(--transition-base);
}

.category-card:hover {
  transform: translateY(-4px);
}

.category-card__image {
  aspect-ratio: 4/3;
  overflow: hidden;
  border-radius: var(--card-radius);
  margin-bottom: var(--space-sm);
  border: 1px solid var(--color-secondary);
}

.category-card__placeholder {
  width: 100%;
  height: 100%;
  background: linear-gradient(135deg, var(--color-secondary), var(--color-primary));
}

.category-card__title {
  font-size: var(--text-lg);
  text-align: center;
  color: var(--color-text);
}

/* Desktop categories */
@media (min-width: 768px) {
  .categories__hint {
    display: none;
  }

  .categories__track {
    justify-content: center;
    padding: 0 var(--space-xl);
    flex-wrap: wrap;
  }

  .category-card {
    width: 200px;
  }
}
```

**Step 3: Test in browser**

Run: Refresh browser, test horizontal scroll on mobile
Expected: Horizontally scrolling category cards with snap behavior

**Step 4: Commit**

```bash
cd D:/claudecode/site && git add -A && git commit -m "feat: add category overview carousel

- Horizontal scroll with snap
- Touch-friendly swipe navigation
- Responsive grid on desktop
- Category cards with hover effect

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```

---

## Task 7: Project Highlight Grid

**Files:**
- Modify: `D:\claudecode\site\index.html`
- Modify: `D:\claudecode\site\css\styles.css`
- Create: `D:\claudecode\site\data\projects.json`

**Step 1: Create projects.json with sample data**

```json
{
  "projects": [
    {
      "id": "kitchen-remodel",
      "title": "Full Kitchen Remodel",
      "category": "renovations",
      "caption": "Complete cabinet and countertop renovation",
      "images": ["hero.jpg"],
      "featured": true
    },
    {
      "id": "custom-desk",
      "title": "Executive Desk",
      "category": "woodworking",
      "caption": "Walnut and steel custom build",
      "images": ["hero.jpg"],
      "featured": true
    },
    {
      "id": "subwoofer-enclosure",
      "title": "Car Audio Enclosure",
      "category": "audio",
      "caption": "Ported enclosure built to spec",
      "images": ["hero.jpg"],
      "featured": true
    },
    {
      "id": "live-edge-table",
      "title": "Live Edge Coffee Table",
      "category": "woodworking",
      "caption": "Maple slab with epoxy river",
      "images": ["hero.jpg"],
      "featured": true
    },
    {
      "id": "custom-bar",
      "title": "Home Bar Build",
      "category": "renovations",
      "caption": "Full custom bar with storage",
      "images": ["hero.jpg"],
      "featured": true
    },
    {
      "id": "cabinet-refinish",
      "title": "Cabinet Refinishing",
      "category": "finishing",
      "caption": "Professional spray finish",
      "images": ["hero.jpg"],
      "featured": true
    },
    {
      "id": "utility-trailer",
      "title": "Custom Utility Trailer",
      "category": "woodworking",
      "caption": "Welded frame with wood deck",
      "images": ["hero.jpg"],
      "featured": true
    },
    {
      "id": "closet-system",
      "title": "Built-In Closet",
      "category": "renovations",
      "caption": "Custom organization system",
      "images": ["hero.jpg"],
      "featured": true
    }
  ]
}
```

**Step 2: Add projects grid HTML after categories**

```html
  <!-- Work / Projects Grid -->
  <section class="work" id="work">
    <div class="container">
      <h2 class="work__title">Recent Work</h2>
      <div class="work__grid" id="work-grid">
        <!-- Projects loaded dynamically, fallback static content -->
        <article class="project-card" data-project="kitchen-remodel">
          <div class="project-card__image">
            <div class="project-card__placeholder"></div>
          </div>
          <div class="project-card__info">
            <span class="project-card__category">Renovations</span>
            <h3 class="project-card__title">Full Kitchen Remodel</h3>
            <p class="project-card__caption">Complete cabinet and countertop renovation</p>
          </div>
        </article>
        <article class="project-card" data-project="custom-desk">
          <div class="project-card__image">
            <div class="project-card__placeholder"></div>
          </div>
          <div class="project-card__info">
            <span class="project-card__category">Woodworking</span>
            <h3 class="project-card__title">Executive Desk</h3>
            <p class="project-card__caption">Walnut and steel custom build</p>
          </div>
        </article>
        <article class="project-card" data-project="subwoofer-enclosure">
          <div class="project-card__image">
            <div class="project-card__placeholder"></div>
          </div>
          <div class="project-card__info">
            <span class="project-card__category">Pro Audio</span>
            <h3 class="project-card__title">Car Audio Enclosure</h3>
            <p class="project-card__caption">Ported enclosure built to spec</p>
          </div>
        </article>
        <article class="project-card" data-project="live-edge-table">
          <div class="project-card__image">
            <div class="project-card__placeholder"></div>
          </div>
          <div class="project-card__info">
            <span class="project-card__category">Woodworking</span>
            <h3 class="project-card__title">Live Edge Coffee Table</h3>
            <p class="project-card__caption">Maple slab with epoxy river</p>
          </div>
        </article>
        <article class="project-card" data-project="custom-bar">
          <div class="project-card__image">
            <div class="project-card__placeholder"></div>
          </div>
          <div class="project-card__info">
            <span class="project-card__category">Renovations</span>
            <h3 class="project-card__title">Home Bar Build</h3>
            <p class="project-card__caption">Full custom bar with storage</p>
          </div>
        </article>
        <article class="project-card" data-project="cabinet-refinish">
          <div class="project-card__image">
            <div class="project-card__placeholder"></div>
          </div>
          <div class="project-card__info">
            <span class="project-card__category">Finishing</span>
            <h3 class="project-card__title">Cabinet Refinishing</h3>
            <p class="project-card__caption">Professional spray finish</p>
          </div>
        </article>
      </div>
    </div>
  </section>
```

**Step 3: Add projects grid CSS**

```css
/* Work / Projects Section */
.work {
  padding: var(--space-3xl) 0;
  background: var(--color-secondary);
}

.work__title {
  text-align: center;
  margin-bottom: var(--space-2xl);
}

.work__grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: var(--space-lg);
}

.project-card {
  position: relative;
  cursor: pointer;
  overflow: hidden;
  border-radius: var(--card-radius);
  background: var(--color-primary);
  transition: transform var(--transition-base), box-shadow var(--transition-base);
}

.project-card:hover {
  transform: translateY(-4px);
  box-shadow: var(--shadow-lg);
}

.project-card__image {
  aspect-ratio: 16/10;
  overflow: hidden;
}

.project-card__placeholder {
  width: 100%;
  height: 100%;
  background: linear-gradient(135deg, var(--color-secondary), var(--color-primary));
}

.project-card__info {
  padding: var(--space-md);
}

.project-card__category {
  font-family: var(--font-mono);
  font-size: var(--text-xs);
  color: var(--color-accent);
  text-transform: uppercase;
  letter-spacing: 0.1em;
}

.project-card__title {
  font-size: var(--text-lg);
  margin: var(--space-xs) 0;
}

.project-card__caption {
  font-size: var(--text-sm);
  color: var(--color-text-muted);
  margin: 0;
}

/* Desktop grid */
@media (min-width: 640px) {
  .work__grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (min-width: 1024px) {
  .work__grid {
    grid-template-columns: repeat(3, 1fr);
  }
}
```

**Step 4: Test in browser**

Run: Refresh browser
Expected: Responsive grid of project cards

**Step 5: Commit**

```bash
cd D:/claudecode/site && git add -A && git commit -m "feat: add project highlight grid

- Responsive grid layout (1/2/3 columns)
- Project cards with hover effects
- Sample project data structure
- Category labels

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```

---

## Task 8: Project Detail Modal

**Files:**
- Modify: `D:\claudecode\site\index.html`
- Modify: `D:\claudecode\site\css\styles.css`
- Modify: `D:\claudecode\site\js\main.js`

**Step 1: Add modal HTML before closing body tag**

```html
  <!-- Project Modal -->
  <div class="modal" id="project-modal" aria-hidden="true">
    <div class="modal__backdrop"></div>
    <div class="modal__container">
      <button class="modal__close" aria-label="Close modal">&times;</button>
      <div class="modal__content">
        <div class="modal__gallery" id="modal-gallery">
          <!-- Images injected dynamically -->
        </div>
        <div class="modal__info">
          <span class="modal__category" id="modal-category">Category</span>
          <h2 class="modal__title" id="modal-title">Project Title</h2>
          <p class="modal__description" id="modal-description">Project description goes here.</p>
          <a href="#contact" class="btn btn--primary modal__cta">Interested in something like this?</a>
        </div>
      </div>
      <div class="modal__nav">
        <button class="modal__nav-btn modal__nav-btn--prev" aria-label="Previous image">&#8592;</button>
        <span class="modal__nav-count"><span id="modal-current">1</span> / <span id="modal-total">1</span></span>
        <button class="modal__nav-btn modal__nav-btn--next" aria-label="Next image">&#8594;</button>
      </div>
    </div>
  </div>
```

**Step 2: Add modal CSS**

```css
/* Modal */
.modal {
  position: fixed;
  inset: 0;
  z-index: 2000;
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  visibility: hidden;
  transition: opacity var(--transition-base), visibility var(--transition-base);
}

.modal[aria-hidden="false"] {
  opacity: 1;
  visibility: visible;
}

.modal__backdrop {
  position: absolute;
  inset: 0;
  background: rgba(0, 0, 0, 0.9);
}

.modal__container {
  position: relative;
  width: 100%;
  height: 100%;
  max-width: 1000px;
  max-height: 90vh;
  display: flex;
  flex-direction: column;
  background: var(--color-primary);
  overflow: hidden;
}

.modal__close {
  position: absolute;
  top: var(--space-md);
  right: var(--space-md);
  z-index: 10;
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--color-secondary);
  border: none;
  border-radius: 50%;
  color: var(--color-text);
  font-size: var(--text-2xl);
  cursor: pointer;
  transition: background var(--transition-fast);
}

.modal__close:hover {
  background: var(--color-highlight);
}

.modal__content {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.modal__gallery {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--color-secondary);
  overflow: hidden;
}

.modal__gallery img {
  max-width: 100%;
  max-height: 100%;
  object-fit: contain;
}

.modal__info {
  padding: var(--space-lg);
}

.modal__category {
  font-family: var(--font-mono);
  font-size: var(--text-xs);
  color: var(--color-accent);
  text-transform: uppercase;
  letter-spacing: 0.1em;
}

.modal__title {
  font-size: var(--text-2xl);
  margin: var(--space-xs) 0 var(--space-sm);
}

.modal__description {
  color: var(--color-text-muted);
  margin-bottom: var(--space-lg);
}

.modal__cta {
  width: 100%;
}

.modal__nav {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: var(--space-lg);
  padding: var(--space-md);
  background: var(--color-secondary);
}

.modal__nav-btn {
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: transparent;
  border: 1px solid var(--color-text-muted);
  color: var(--color-text);
  font-size: var(--text-lg);
  cursor: pointer;
  transition: all var(--transition-fast);
}

.modal__nav-btn:hover {
  border-color: var(--color-accent);
  color: var(--color-accent);
}

.modal__nav-count {
  font-family: var(--font-mono);
  font-size: var(--text-sm);
  color: var(--color-text-muted);
}

/* Desktop modal */
@media (min-width: 768px) {
  .modal__container {
    width: 90%;
    height: auto;
    max-height: 90vh;
    border-radius: var(--card-radius);
  }

  .modal__content {
    flex-direction: row;
  }

  .modal__gallery {
    flex: 2;
    min-height: 400px;
  }

  .modal__info {
    flex: 1;
    max-width: 350px;
    display: flex;
    flex-direction: column;
    justify-content: center;
  }

  .modal__cta {
    width: auto;
  }
}
```

**Step 3: Add modal JS to main.js**

```javascript
  // Project Modal
  const modal = document.getElementById('project-modal');
  const modalGallery = document.getElementById('modal-gallery');
  const modalCategory = document.getElementById('modal-category');
  const modalTitle = document.getElementById('modal-title');
  const modalDescription = document.getElementById('modal-description');
  const modalClose = modal?.querySelector('.modal__close');
  const modalBackdrop = modal?.querySelector('.modal__backdrop');
  const modalCurrent = document.getElementById('modal-current');
  const modalTotal = document.getElementById('modal-total');
  const modalPrev = modal?.querySelector('.modal__nav-btn--prev');
  const modalNext = modal?.querySelector('.modal__nav-btn--next');

  let currentImageIndex = 0;
  let currentImages = [];

  function openModal(projectCard) {
    const category = projectCard.querySelector('.project-card__category')?.textContent || '';
    const title = projectCard.querySelector('.project-card__title')?.textContent || '';
    const caption = projectCard.querySelector('.project-card__caption')?.textContent || '';

    modalCategory.textContent = category;
    modalTitle.textContent = title;
    modalDescription.textContent = caption;

    // Placeholder image for now
    currentImages = ['placeholder'];
    currentImageIndex = 0;
    updateGallery();

    modal.setAttribute('aria-hidden', 'false');
    document.body.style.overflow = 'hidden';
  }

  function closeModal() {
    modal.setAttribute('aria-hidden', 'true');
    document.body.style.overflow = '';
  }

  function updateGallery() {
    modalGallery.innerHTML = '<div class="project-card__placeholder" style="width:100%;height:300px;"></div>';
    modalCurrent.textContent = currentImageIndex + 1;
    modalTotal.textContent = currentImages.length;
  }

  function nextImage() {
    currentImageIndex = (currentImageIndex + 1) % currentImages.length;
    updateGallery();
  }

  function prevImage() {
    currentImageIndex = (currentImageIndex - 1 + currentImages.length) % currentImages.length;
    updateGallery();
  }

  // Event listeners
  document.querySelectorAll('.project-card').forEach(card => {
    card.addEventListener('click', () => openModal(card));
  });

  modalClose?.addEventListener('click', closeModal);
  modalBackdrop?.addEventListener('click', closeModal);
  modalPrev?.addEventListener('click', prevImage);
  modalNext?.addEventListener('click', nextImage);

  // Keyboard navigation
  document.addEventListener('keydown', (e) => {
    if (modal?.getAttribute('aria-hidden') === 'false') {
      if (e.key === 'Escape') closeModal();
      if (e.key === 'ArrowLeft') prevImage();
      if (e.key === 'ArrowRight') nextImage();
    }
  });
```

**Step 4: Test in browser**

Run: Refresh browser, click a project card
Expected: Modal opens with project info, close on X/backdrop/Escape

**Step 5: Commit**

```bash
cd D:/claudecode/site && git add -A && git commit -m "feat: add project detail modal

- Full-screen mobile, contained desktop
- Image gallery navigation
- Keyboard controls (Escape, arrows)
- CTA to contact form

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```

---

## Task 9: Contact Section & Quick Form

**Files:**
- Modify: `D:\claudecode\site\index.html`
- Modify: `D:\claudecode\site\css\styles.css`
- Create: `D:\claudecode\site\js\forms.js`

**Step 1: Add contact section HTML after work section**

```html
  <!-- Contact Section -->
  <section class="contact" id="contact">
    <div class="container">
      <h2 class="contact__title">Got a Project?</h2>
      <p class="contact__subtitle">Let's talk about what you need built.</p>

      <form class="contact-form" id="contact-form">
        <div class="form-group">
          <label for="name" class="form-label">Name</label>
          <input type="text" id="name" name="name" class="form-input" required>
        </div>
        <div class="form-group">
          <label for="email" class="form-label">Email</label>
          <input type="email" id="email" name="email" class="form-input" required>
        </div>
        <div class="form-group">
          <label for="message" class="form-label">Message</label>
          <textarea id="message" name="message" class="form-input form-textarea" rows="4" required></textarea>
        </div>
        <!-- Honeypot -->
        <div class="form-group" style="position:absolute;left:-9999px;" aria-hidden="true">
          <label for="website">Website</label>
          <input type="text" id="website" name="website" tabindex="-1" autocomplete="off">
        </div>
        <button type="submit" class="btn btn--primary contact-form__submit">Send Message</button>
      </form>

      <div class="contact__direct">
        <p>Or reach out directly:</p>
        <a href="mailto:admin@forprofessionaluseonly.com" class="contact__email">admin@forprofessionaluseonly.com</a>
      </div>
    </div>
  </section>
```

**Step 2: Add contact CSS**

```css
/* Contact Section */
.contact {
  padding: var(--space-3xl) 0;
  text-align: center;
}

.contact__title {
  margin-bottom: var(--space-sm);
}

.contact__subtitle {
  color: var(--color-text-muted);
  margin-bottom: var(--space-2xl);
}

.contact-form {
  max-width: 500px;
  margin: 0 auto var(--space-2xl);
  text-align: left;
}

.form-group {
  margin-bottom: var(--space-lg);
}

.form-label {
  display: block;
  font-family: var(--font-mono);
  font-size: var(--text-sm);
  color: var(--color-text-muted);
  text-transform: uppercase;
  letter-spacing: 0.05em;
  margin-bottom: var(--space-xs);
}

.form-input {
  width: 100%;
  padding: var(--space-sm) var(--space-md);
  font-family: var(--font-body);
  font-size: var(--text-base);
  color: var(--color-text);
  background: var(--color-secondary);
  border: 1px solid var(--color-secondary);
  border-radius: var(--card-radius);
  transition: border-color var(--transition-fast);
}

.form-input:focus {
  outline: none;
  border-color: var(--color-accent);
}

.form-textarea {
  resize: vertical;
  min-height: 120px;
}

.contact-form__submit {
  width: 100%;
}

.contact__direct {
  color: var(--color-text-muted);
}

.contact__email {
  font-family: var(--font-mono);
  font-size: var(--text-lg);
}
```

**Step 3: Create forms.js**

```javascript
// forms.js - Form handling for Straight-Line Custom Solutions

(function() {
  'use strict';

  const contactForm = document.getElementById('contact-form');

  if (contactForm) {
    contactForm.addEventListener('submit', async (e) => {
      e.preventDefault();

      const formData = new FormData(contactForm);

      // Check honeypot
      if (formData.get('website')) {
        console.log('Bot detected');
        return;
      }

      const data = {
        name: formData.get('name'),
        email: formData.get('email'),
        message: formData.get('message'),
        source: 'contact',
        timestamp: new Date().toISOString()
      };

      const submitBtn = contactForm.querySelector('button[type="submit"]');
      const originalText = submitBtn.textContent;
      submitBtn.textContent = 'Sending...';
      submitBtn.disabled = true;

      try {
        // For now, log to console. Later: send to Cloudflare Function
        console.log('Form submission:', data);

        // Simulate success
        submitBtn.textContent = 'Sent!';
        contactForm.reset();

        setTimeout(() => {
          submitBtn.textContent = originalText;
          submitBtn.disabled = false;
        }, 2000);

      } catch (error) {
        console.error('Form error:', error);
        submitBtn.textContent = 'Error - Try Again';
        submitBtn.disabled = false;
      }
    });
  }

})();
```

**Step 4: Add forms.js to index.html**

Add before closing body tag:
```html
  <script src="js/forms.js" defer></script>
```

**Step 5: Test in browser**

Run: Refresh browser, fill and submit form
Expected: Form validates, shows "Sending..." then "Sent!", resets

**Step 6: Commit**

```bash
cd D:/claudecode/site && git add -A && git commit -m "feat: add contact section and form

- Quick contact form with validation
- Honeypot spam protection
- Loading states on submit
- Direct email link fallback

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```

---

## Task 10: Footer

**Files:**
- Modify: `D:\claudecode\site\index.html`
- Modify: `D:\claudecode\site\css\styles.css`

**Step 1: Add footer HTML before modal**

```html
  <!-- Footer -->
  <footer class="footer">
    <div class="container">
      <div class="footer__brand">
        <span class="footer__logo">Straight-Line Custom Solutions</span>
        <span class="footer__tagline">For Professional Use Only</span>
      </div>
      <nav class="footer__nav">
        <a href="#work">Work</a>
        <a href="about.html">About</a>
        <a href="#contact">Contact</a>
      </nav>
      <p class="footer__copy">&copy; 2026 Straight-Line Custom Solutions. All rights reserved.</p>
    </div>
  </footer>
```

**Step 2: Add footer CSS**

```css
/* Footer */
.footer {
  padding: var(--space-2xl) 0;
  background: var(--color-secondary);
  border-top: 1px solid rgba(255, 255, 255, 0.1);
  text-align: center;
}

.footer__brand {
  margin-bottom: var(--space-lg);
}

.footer__logo {
  display: block;
  font-family: var(--font-headline);
  font-size: var(--text-xl);
  letter-spacing: 0.1em;
  text-transform: uppercase;
}

.footer__tagline {
  font-family: var(--font-mono);
  font-size: var(--text-sm);
  color: var(--color-accent);
}

.footer__nav {
  display: flex;
  justify-content: center;
  gap: var(--space-xl);
  margin-bottom: var(--space-lg);
}

.footer__nav a {
  font-family: var(--font-mono);
  font-size: var(--text-sm);
  color: var(--color-text-muted);
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.footer__nav a:hover {
  color: var(--color-accent);
}

.footer__copy {
  font-size: var(--text-sm);
  color: var(--color-text-muted);
  margin: 0;
}
```

**Step 3: Test in browser**

Run: Refresh browser, scroll to bottom
Expected: Footer with brand, nav links, copyright

**Step 4: Commit**

```bash
cd D:/claudecode/site && git add -A && git commit -m "feat: add footer

- Brand and tagline
- Navigation links
- Copyright notice

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```

---

## Task 11: About Page

**Files:**
- Create: `D:\claudecode\site\about.html`
- Modify: `D:\claudecode\site\css\styles.css`

**Step 1: Create about.html**

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover">
  <meta name="description" content="About Straight-Line Custom Solutions - Custom woodworking, renovations, and professional finishing.">
  <meta name="theme-color" content="#1a1a1a">

  <title>About | Straight-Line Custom Solutions</title>

  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link rel="stylesheet" href="css/styles.css">
  <link rel="icon" href="data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><text y='.9em' font-size='90'>⚒️</text></svg>">
</head>
<body>
  <!-- Navigation -->
  <nav class="nav" id="nav">
    <div class="nav__container">
      <a href="/" class="nav__logo">
        <span class="nav__logo-text">Straight-Line</span>
        <span class="nav__logo-sub">Custom Solutions</span>
      </a>
      <button class="nav__toggle" id="nav-toggle" aria-label="Toggle menu" aria-expanded="false">
        <span class="nav__toggle-bar"></span>
        <span class="nav__toggle-bar"></span>
        <span class="nav__toggle-bar"></span>
      </button>
      <ul class="nav__menu" id="nav-menu">
        <li><a href="/#work" class="nav__link">Work</a></li>
        <li><a href="about.html" class="nav__link">About</a></li>
        <li><a href="/#contact" class="nav__link">Contact</a></li>
      </ul>
    </div>
  </nav>

  <!-- About Hero -->
  <section class="about-hero">
    <div class="container">
      <h1 class="about-hero__title">The Builder</h1>
    </div>
  </section>

  <!-- About Content -->
  <section class="about-content">
    <div class="container">
      <div class="about-content__grid">
        <div class="about-content__photo">
          <div class="about-content__placeholder"></div>
        </div>
        <div class="about-content__text">
          <p class="about-content__intro">
            I've spent years solving problems with my hands. From framing walls to finishing furniture,
            welding steel to designing in SketchUp—if it needs built right, I build it.
          </p>
          <p>
            Every project starts with understanding what you actually need, not what's easiest to build.
            I work directly with clients from concept to completion, handling design, materials,
            construction, and finishing under one roof.
          </p>
          <p class="about-content__philosophy">
            Measure twice, cut once. No shortcuts. Built to last.
          </p>
        </div>
      </div>
    </div>
  </section>

  <!-- Skills Grid -->
  <section class="skills">
    <div class="container">
      <h2 class="skills__title">Capabilities</h2>
      <div class="skills__grid">
        <div class="skill-item">
          <h3 class="skill-item__title">Woodworking</h3>
          <p class="skill-item__desc">Furniture, cabinets, specialty builds</p>
        </div>
        <div class="skill-item">
          <h3 class="skill-item__title">Renovations</h3>
          <p class="skill-item__desc">Kitchens, bathrooms, custom spaces</p>
        </div>
        <div class="skill-item">
          <h3 class="skill-item__title">Pro Audio</h3>
          <p class="skill-item__desc">Enclosures, studio furniture</p>
        </div>
        <div class="skill-item">
          <h3 class="skill-item__title">Welding</h3>
          <p class="skill-item__desc">Steel frames, custom metalwork</p>
        </div>
        <div class="skill-item">
          <h3 class="skill-item__title">Finishing</h3>
          <p class="skill-item__desc">Professional coating, refinishing</p>
        </div>
        <div class="skill-item">
          <h3 class="skill-item__title">Design</h3>
          <p class="skill-item__desc">SketchUp, Illustrator, blueprints</p>
        </div>
      </div>
    </div>
  </section>

  <!-- CTA -->
  <section class="about-cta">
    <div class="container">
      <h2 class="about-cta__title">Ready to Build?</h2>
      <div class="about-cta__buttons">
        <a href="/#work" class="btn">See the Work</a>
        <a href="/#contact" class="btn btn--primary">Start a Project</a>
      </div>
    </div>
  </section>

  <!-- Footer -->
  <footer class="footer">
    <div class="container">
      <div class="footer__brand">
        <span class="footer__logo">Straight-Line Custom Solutions</span>
        <span class="footer__tagline">For Professional Use Only</span>
      </div>
      <nav class="footer__nav">
        <a href="/#work">Work</a>
        <a href="about.html">About</a>
        <a href="/#contact">Contact</a>
      </nav>
      <p class="footer__copy">&copy; 2026 Straight-Line Custom Solutions. All rights reserved.</p>
    </div>
  </footer>

  <script src="js/main.js" defer></script>
</body>
</html>
```

**Step 2: Add about page CSS**

```css
/* About Page */
.about-hero {
  padding: calc(var(--nav-height) + var(--space-3xl)) 0 var(--space-2xl);
  text-align: center;
}

.about-hero__title {
  font-size: var(--text-4xl);
}

.about-content {
  padding: var(--space-2xl) 0;
}

.about-content__grid {
  display: grid;
  gap: var(--space-2xl);
}

.about-content__photo {
  aspect-ratio: 4/3;
  overflow: hidden;
  border-radius: var(--card-radius);
}

.about-content__placeholder {
  width: 100%;
  height: 100%;
  background: linear-gradient(135deg, var(--color-secondary), var(--color-primary));
}

.about-content__intro {
  font-size: var(--text-lg);
  color: var(--color-text);
}

.about-content__philosophy {
  font-family: var(--font-mono);
  color: var(--color-accent);
  font-style: italic;
}

.skills {
  padding: var(--space-3xl) 0;
  background: var(--color-secondary);
}

.skills__title {
  text-align: center;
  margin-bottom: var(--space-2xl);
}

.skills__grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: var(--space-lg);
}

.skill-item {
  padding: var(--space-lg);
  background: var(--color-primary);
  border-radius: var(--card-radius);
  border-left: 3px solid var(--color-accent);
}

.skill-item__title {
  font-size: var(--text-lg);
  margin-bottom: var(--space-xs);
}

.skill-item__desc {
  font-size: var(--text-sm);
  color: var(--color-text-muted);
  margin: 0;
}

.about-cta {
  padding: var(--space-3xl) 0;
  text-align: center;
}

.about-cta__title {
  margin-bottom: var(--space-xl);
}

.about-cta__buttons {
  display: flex;
  flex-direction: column;
  gap: var(--space-md);
  max-width: 300px;
  margin: 0 auto;
}

/* Desktop about */
@media (min-width: 768px) {
  .about-hero__title {
    font-size: var(--text-5xl);
  }

  .about-content__grid {
    grid-template-columns: 1fr 1fr;
    align-items: center;
  }

  .skills__grid {
    grid-template-columns: repeat(3, 1fr);
  }

  .about-cta__buttons {
    flex-direction: row;
    max-width: none;
    justify-content: center;
  }
}
```

**Step 3: Test in browser**

Run: Open `D:/claudecode/site/about.html` in browser
Expected: About page with photo placeholder, bio, skills grid, CTAs

**Step 4: Commit**

```bash
cd D:/claudecode/site && git add -A && git commit -m "feat: add about page

- Hero section
- Photo and bio content
- Skills/capabilities grid
- CTA section

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```

---

## Task 12: Cloudflare Pages Deployment Setup

**Files:**
- Create: `D:\claudecode\site\functions\submit-form.js`
- Modify: `D:\claudecode\site\js\forms.js`

**Step 1: Create Cloudflare Function for form handling**

```javascript
// functions/submit-form.js - Cloudflare Pages Function

export async function onRequestPost(context) {
  try {
    const formData = await context.request.json();

    // Validate honeypot
    if (formData.website) {
      return new Response(JSON.stringify({ error: 'Invalid submission' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' }
      });
    }

    // Validate required fields
    if (!formData.name || !formData.email || !formData.message) {
      return new Response(JSON.stringify({ error: 'Missing required fields' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' }
      });
    }

    // Log submission (in production, send to email service or database)
    console.log('Form submission:', {
      name: formData.name,
      email: formData.email,
      message: formData.message,
      source: formData.source,
      timestamp: formData.timestamp
    });

    // TODO: Integrate with email service (Mailgun, SendGrid, etc.)
    // TODO: Store in KV or D1 database

    return new Response(JSON.stringify({ success: true }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' }
    });

  } catch (error) {
    return new Response(JSON.stringify({ error: 'Server error' }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    });
  }
}
```

**Step 2: Update forms.js to call the function**

Replace the try block in forms.js with:

```javascript
      try {
        const response = await fetch('/submit-form', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(data)
        });

        if (response.ok) {
          submitBtn.textContent = 'Sent!';
          contactForm.reset();
        } else {
          throw new Error('Submission failed');
        }

        setTimeout(() => {
          submitBtn.textContent = originalText;
          submitBtn.disabled = false;
        }, 2000);

      } catch (error) {
        console.error('Form error:', error);
        submitBtn.textContent = 'Error - Try Again';
        setTimeout(() => {
          submitBtn.textContent = originalText;
          submitBtn.disabled = false;
        }, 2000);
      }
```

**Step 3: Create GitHub repository and push**

```bash
cd D:/claudecode/site
git remote add origin https://github.com/YOUR_USERNAME/straightline-portfolio.git
git branch -M main
git push -u origin main
```

**Step 4: Connect to Cloudflare Pages**

1. Go to Cloudflare Dashboard → Pages
2. Click "Create a project" → "Connect to Git"
3. Select your GitHub repository
4. Build settings:
   - Build command: (leave empty)
   - Build output directory: /
5. Deploy

**Step 5: Configure custom domain**

1. In Cloudflare Pages project → Custom domains
2. Add `forprofessionaluseonly.com`
3. Cloudflare auto-configures DNS since domain is already there

**Step 6: Commit**

```bash
cd D:/claudecode/site && git add -A && git commit -m "feat: add Cloudflare Pages deployment

- Serverless function for form handling
- Updated form JS to use API endpoint
- Ready for Cloudflare Pages deployment

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```

---

## Task 13: Final Polish & Testing

**Files:**
- All files

**Step 1: Add smooth scroll offset for fixed nav**

Add to styles.css:

```css
/* Smooth scroll offset for fixed nav */
html {
  scroll-padding-top: calc(var(--nav-height) + var(--space-md));
}
```

**Step 2: Add loading state for images**

Add to styles.css:

```css
/* Image loading states */
img {
  opacity: 0;
  transition: opacity var(--transition-base);
}

img.loaded {
  opacity: 1;
}
```

Add to main.js:

```javascript
  // Image loading
  document.querySelectorAll('img').forEach(img => {
    if (img.complete) {
      img.classList.add('loaded');
    } else {
      img.addEventListener('load', () => img.classList.add('loaded'));
    }
  });
```

**Step 3: Test checklist**

- [ ] Mobile: Navigation toggle works
- [ ] Mobile: Category carousel swipes
- [ ] Mobile: Project cards tap to open modal
- [ ] Mobile: Contact form submits
- [ ] Desktop: Navigation links work
- [ ] Desktop: Project grid hovers
- [ ] Desktop: Modal keyboard navigation (Escape, arrows)
- [ ] About page loads correctly
- [ ] All links navigate correctly
- [ ] No console errors

**Step 4: Final commit**

```bash
cd D:/claudecode/site && git add -A && git commit -m "chore: final polish and testing

- Smooth scroll offset for fixed nav
- Image loading transitions
- Testing complete

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```

**Step 5: Push to deploy**

```bash
git push
```

---

## Next Steps (Post-Launch)

After the portfolio is live:

1. **Add real images** - Replace placeholders with your project photos
2. **Update content** - Customize bio text, project descriptions
3. **Set up email notifications** - Integrate form with email service
4. **Phase 2: Shop** - Add product listings and ordering
5. **Phase 3: Tools** - Implement speaker enclosure and paint guide apps

---

## Summary

| Task | Description | Files |
|------|-------------|-------|
| 1 | Project setup | folder structure, .gitignore, README |
| 2 | CSS variables & reset | variables.css, styles.css |
| 3 | HTML boilerplate | index.html |
| 4 | Navigation | nav HTML/CSS/JS |
| 5 | Hero section | hero HTML/CSS |
| 6 | Category carousel | categories HTML/CSS |
| 7 | Project grid | work section, projects.json |
| 8 | Project modal | modal HTML/CSS/JS |
| 9 | Contact form | form HTML/CSS/JS |
| 10 | Footer | footer HTML/CSS |
| 11 | About page | about.html |
| 12 | Deployment | Cloudflare function, deploy |
| 13 | Final polish | testing, cleanup |
