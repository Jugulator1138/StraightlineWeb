# Straight-Line Custom Solutions - Portfolio Website Design

**Date:** 2026-02-03
**Status:** Approved
**Domain:** forprofessionaluseonly.com
**Hosting:** Cloudflare Pages
**Email:** admin@forprofessionaluseonly.com

---

## Business Overview

**Company:** Straight-Line Custom Solutions
**Tagline:** "For Professional Use Only"

**Services:**
- Woodworking (furniture, cabinets, specialty desks, speaker enclosures, pro audio furniture)
- Residential remodeling and renovations
- Custom bars, tables, built-in closets, shelving, live edge pieces, doors
- Pool table renovations
- Professional coating and finishing, painting, welding
- Design (SketchUp, Illustrator, decals, vinyl stencils, SVGs)

---

## Brand & Visual Direction

### The Feel
"Workshop floor, not showroom." Visitors sense they've stepped behind the curtain - where the real work happens. Industrial, authentic, professional-grade. "The side the pros use."

### Color Palette
| Role | Color | Hex | Description |
|------|-------|-----|-------------|
| Primary | Deep Charcoal | #1a1a1a | The workshop after hours |
| Secondary | Warm Steel Gray | #2d2d2d | Tool metal, concrete |
| Accent | Amber/Orange | #d4a574 | Sawdust under work lights |
| Text | Off-White | #f5f5f5 | Clean contrast |
| Highlight | Raw Copper | #b87333 | Buttons, links, CTAs |

### Typography
- **Headlines:** Bold industrial sans-serif (Industry, Bebas Neue) - stencil/machine shop feel
- **Body:** Clean readable sans-serif (Inter, Work Sans) - professional, no-nonsense
- **Accent:** Monospace for details/specs - like blueprints or shop drawings

### Textures & Elements
- Subtle concrete or brushed metal backgrounds
- Thin ruled lines like technical drawings
- Photography does the heavy lifting - textures support, don't compete

---

## Site Structure

### Phase 1 Pages
1. **Homepage** - Hero, overview, highlight reel, contact
2. **About** - Positioning statement, skills, philosophy
3. **Contact** - Full contact page (backup to embedded forms)

### Navigation (Sticky)
- Logo (left)
- Work | About | Contact (right)
- Mobile: Hamburger menu, thumb-friendly bottom nav

---

## Mobile-First Portfolio Experience

### Design Priority
Mobile-first, swipe-driven. Content comes at a rhythm - not a wall to parse.

### Mobile Flow

**1. Hero**
- Full-screen signature image
- Logo overlay
- Tagline: "For Professional Use Only"
- Swipe up to enter

**2. Overview Strip**
- Horizontal swipe carousel of category cards
- Categories: Woodworking | Renovations | Audio | Finishing | Design
- Each card: Representative image + category name
- Tap to filter, or keep swiping to browse all

**3. Highlight Reel**
- Quick vertical scroll of mixed best work
- Smaller cards, 2-3 visible at once
- Shows variety at a glance
- "Here's what I do"

**4. Deep Dive (on tap)**
- Full-screen swipe experience for individual project
- Hero shot → Before/after → Detail shots → Brief story/specs
- "Interested?" quick contact option
- Swipe out to return to browsing

### Card Anatomy
```
┌─────────────────────┐
│                     │
│   [Project Image]   │
│                     │
│                     │
├─────────────────────┤
│ PROJECT TITLE       │
│ Brief caption here  │
│         ↑ swipe     │
└─────────────────────┘
```

### Desktop Adaptation
- Grid layout with hover effects
- Same content, different presentation
- Mobile remains primary design target

---

## Contact & Lead Capture

### Tier 1: Quick Contact
- Floating button or bottom nav icon
- Slides up simple form:
  - Name
  - Email
  - Message
- For general inquiries, quick questions

### Tier 2: Project Request
- Available from project pages: "Want something like this?"
- Guided form:
  - Name / Email / Phone (optional)
  - Project type (dropdown)
  - Brief description
  - Budget range (Under $500 / $500-2K / $2K-5K / $5K+ / Not sure)
  - Timeline (ASAP / Few weeks / Few months / Just exploring)
  - Upload reference photos (optional)

### Email Database
- Every submission stored in JSON/CSV
- Fields: name, email, date, source, message summary
- Clean structure for future CRM/Mailchimp export
- Email notification on each submission

### Spam Protection
- Honeypot field (hidden from humans, bots fill it)
- No CAPTCHAs

---

## About Page

### Structure

**1. Opening Statement (2-3 sentences)**
Positioning, not biography. Establishes range and credibility.

**2. Photo**
Action shot in the shop. Not a headshot - working environment.

**3. Skills/Capabilities Grid**
```
Woodworking    │  Renovations    │  Pro Audio
Welding        │  Finishing      │  Design
Cabinets       │  Restorations   │  Custom Builds
```

**4. Philosophy (1-2 lines)**
Approach in a sentence. "Measure twice, cut once. No shortcuts. Built to last."

**5. CTA**
- "See the work" → portfolio
- "Got a project?" → contact form

---

## Technical Implementation

### Tech Stack
- HTML/CSS/JavaScript - No framework
- CSS Variables - Centralized theming
- Vanilla JS - No jQuery, no bloat
- Mobile-first CSS - Base mobile, enhance for desktop

### File Structure
```
/site
  index.html
  about.html
  contact.html
  /css
    styles.css
    variables.css
  /js
    main.js
    forms.js
    swipe.js
  /images
    /projects
    /ui
  /data
    projects.json
    leads.json (gitignored)
```

### Project Data Format (projects.json)
```json
{
  "projects": [
    {
      "id": "kitchen-remodel-2024",
      "title": "Full Kitchen Remodel",
      "category": "renovations",
      "caption": "Complete cabinet and countertop renovation",
      "images": ["hero.jpg", "before.jpg", "after.jpg", "detail-1.jpg"],
      "featured": true
    }
  ]
}
```

### Deployment
- GitHub repository
- Cloudflare Pages auto-deploy on push
- Domain: forprofessionaluseonly.com (already on Cloudflare)

---

## Future Phases (Roadmap)

### Phase 2: Shop & Selling
- Add "Shop" navigation item
- Product cards with pricing
- Built pieces + "Build to Order" options

### Phase 3: Speaker Enclosure Tool
- "Enclosure Builder" page
- Google Form integration
- Customer fills form → You create plans → Sell plans or build

### Phase 4: Paint Guide Tool
- Interactive form for paint projects
- Returns procedure, tips, recommendations
- Lead magnet for traffic and email capture

### Phase 5: Client Portal
- Logged-in client access
- Project status, file uploads, approvals
- Long-term goal

---

## Infrastructure Notes

- **Domain:** forprofessionaluseonly.com via Cloudflare
- **Hosting:** Cloudflare Pages (free tier)
- **Existing:** Piwigo album on Namecheap (separate, not integrated)
- **Email:** admin@forprofessionaluseonly.com

---

## Approved
This design was validated through collaborative brainstorming on 2026-02-03.
