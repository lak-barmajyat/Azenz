---
name: Fluent Industrial ERP
colors:
  surface: '#f9f9ff'
  surface-dim: '#d3daea'
  surface-bright: '#f9f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f0f3ff'
  surface-container: '#e7eefe'
  surface-container-high: '#e2e8f8'
  surface-container-highest: '#dce2f3'
  on-surface: '#151c27'
  on-surface-variant: '#43474e'
  inverse-surface: '#2a313d'
  inverse-on-surface: '#ebf1ff'
  outline: '#73777f'
  outline-variant: '#c3c7cf'
  surface-tint: '#406184'
  primary: '#00203b'
  on-primary: '#ffffff'
  primary-container: '#113657'
  on-primary-container: '#7f9fc6'
  inverse-primary: '#a9c9f2'
  secondary: '#984700'
  on-secondary: '#ffffff'
  secondary-container: '#fd862d'
  on-secondary-container: '#632c00'
  tertiary: '#00250a'
  on-tertiary: '#ffffff'
  tertiary-container: '#003d16'
  on-tertiary-container: '#2fb257'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#d1e4ff'
  primary-fixed-dim: '#a9c9f2'
  on-primary-fixed: '#001d35'
  on-primary-fixed-variant: '#27496b'
  secondary-fixed: '#ffdbc8'
  secondary-fixed-dim: '#ffb68a'
  on-secondary-fixed: '#321300'
  on-secondary-fixed-variant: '#743500'
  tertiary-fixed: '#7ffc97'
  tertiary-fixed-dim: '#62df7d'
  on-tertiary-fixed: '#002109'
  on-tertiary-fixed-variant: '#005320'
  background: '#f9f9ff'
  on-background: '#151c27'
  surface-variant: '#dce2f3'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
    letterSpacing: -0.02em
  display-md:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '700'
    lineHeight: 28px
    letterSpacing: -0.015em
  headline-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Inter
    fontSize: 15px
    fontWeight: '600'
    lineHeight: 20px
  body-lg:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-md:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
  body-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
  label-lg:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '600'
    lineHeight: 18px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 14px
    letterSpacing: 0.02em
  data-mono:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  gutter: 12px
  margin: 16px
  space-xs: 4px
  space-sm: 8px
  space-md: 12px
  space-lg: 16px
  space-xl: 24px
---

## Brand & Style
This design system is engineered for modern Windows desktop enterprise resource planning (ERP). Built for high-frequency business operators, financial controllers, inventory managers, and supply chain analysts, the interface emphasizes extreme clarity, rapid scanability, and dense operational ergonomics.

The aesthetic synthesizes modern enterprise desktop paradigms with the crisp geometry of modern Windows Fluent software. The visual tone is grounded, authoritative, and responsive: dark navy anchors structure and hierarchy, pure white surfaces isolate core data tasks, and a vivid, energetic orange accent drives call-to-actions, workflow focus, and state validations. The interface feels indestructible, precise, and fast—stripping away decorative distraction in favor of tabular throughput and tactile keyboard-first efficiency.

## Colors
The palette balances deep naval structure with energetic workflow accelerators and functional status indicators:

- **Structural Anchor (`#113657`)**: The primary deep navy represents stability and structure. It serves as the background for global navigation sidebars, top application chrome, primary table headers, and high-level visual containers.
- **Accent & Interaction (`#F17D24`)**: Vibrant industrial orange serves strictly as an operational catalyst. It drives primary action buttons, active navigation selections, active row highlights, progress flags, and critical interactive indicators.
- **Canvas Base (`#F8FAFC`)**: A cool, slightly blue-tinted light neutral reduces eye strain across long desktop shifts, acting as the foundation workspace background underneath floating surfaces.
- **Surfaces (`#FFFFFF`)**: Pure white data cards, data grids, modal dialogs, and text input fields to ensure maximum contrast against typography and numerical metrics.
- **Text Primary (`#1F2937`)**: High-contrast, charcoal-slate for table content, data rows, form labels, and section headings.
- **Text Secondary (`#6B7280`)**: Muted cool gray for table metadata, column units, currency suffixes, and input field placeholders.
- **Structural Outlines (`#E5E7EB`)**: A subtle border gray defining dense 1px grid cells, panel separators, and input boundaries without visual clutter.
- **System Semantic States**:
  - **Success (`#16A34A`)**: Paid invoices, connected services, active stock items, and positive delta values.
  - **Danger / Destructive (`#DC2626`)**: Critical alerts, cancellation prompts, stock depletion warnings, and irreversible deletions.
  - **Warning (`#F59E0B`)**: Pending approvals, draft invoices, and items awaiting clearance.

## Typography
Typography is tuned for compact, data-first enterprise desktop screens. Inter provides high x-height, clear numeric legibility, and geometric clarity across complex multilingual layouts (including right-to-left and Latin pairings).

- **Data Tables & Numeric Values**: All monetary values, tracking numbers, stock quantities, and invoice IDs utilize tabular figures (`font-feature-settings: "tnum" 1`) to ensure perfect vertical alignment across columns.
- **Hierarchy Scale**:
  - `display-lg` (24px bold): Primary window / module titles and aggregate balance metrics.
  - `display-md` (20px bold): View headers and top KPI card aggregates.
  - `headline-lg` (18px semibold): Section headings, modal titles, and master panel identifiers.
  - `body-md` (13px regular): Standard desktop reading text, grid row descriptions, and form inputs.
  - `label-sm` (11px medium): Column headers, badges, status chips, and metadata hints.

## Layout & Spacing
This design system operates on a high-density 4px base scale designed for high-resolution desktop displays (1080p, 1440p, 4K monitors):

- **Workspace Topology**:
  - **Left Rail / Sidebar**: Fixed 220px default width (collapsible to 56px icon-only rail). Uses `#113657` dark background for permanent visual orientation.
  - **Top Utility Bar**: Fixed 44px height for global search, user profile, notifications, and branch/fiscal period switcher.
  - **Canvas Area**: Fluid multi-pane workspace with 16px peripheral padding (`margin`).
- **Dense Data Grids**: Grid rows maintain compact row heights (32px for dense mode, 40px for standard mode) to ensure 20+ rows remain visible above the fold without scrolling.
- **Component Intervals**: 4px between adjacent micro-controls (e.g., table action buttons, icon buttons), 8px between standard inputs and labels, 12px for standard form gaps, and 16px to 24px container padding.

## Elevation & Depth
Depth in this system is defined by crisp, structured surface tiers and subtle Windows Fluent-inspired borders, avoiding heavy, unfocused shadows:

- **Level 0 (Base Canvas)**: Background `#F8FAFC`, flat, 0px offset.
- **Level 1 (Card & Data Containers)**: Background `#FFFFFF`, bordered by 1px solid `#E5E7EB`. Subtle ambient drop shadow: `0 1px 2px rgba(17, 54, 87, 0.04)`.
- **Level 2 (Dropdowns, Menus & Tooltips)**: Background `#FFFFFF`, 1px solid `#E5E7EB`, floating shadow: `0 4px 12px rgba(17, 54, 87, 0.08)`.
- **Level 3 (Modal Dialogs & Command Palettes)**: Centered overlay over a 30% `#113657` scrim, elevated with `0 12px 28px rgba(17, 54, 87, 0.16)` and 1px border `#E5E7EB`.
- **Level 4 (Toasts & Notifications)**: Persistent top-right positioning with high-contrast framing: `0 8px 20px rgba(17, 54, 87, 0.12)`.

## Shapes
To preserve an authentic, compact enterprise desktop feel, shapes utilize soft 4px-6px radii:

- **Inputs, Buttons, and Selects**: 4px (`roundedness: 1`), keeping controls compact, stackable, and space-efficient.
- **Cards and Panels**: 6px corner radius for structural framing without feeling bubbly.
- **Badges and Status Indicators**: Rounded pills (9999px) for categorical pills (`مدفوعة`, `معلقة`) to clearly differentiate static status markers from interactive rectangular controls.
- **Modals and Popovers**: 6px corner radius with razor-sharp 1px border definition.

## Components

### Buttons
- **Primary**: Background `#F17D24`, text `#FFFFFF`, font-weight 600, height 32px (compact) or 36px (standard), padding 0 12px, border-radius 4px. Hover state shifts to `#DE6E1B`. Active state `#C75E12`. Focus ring: 2px offset with 2px solid `#F17D24`.
- **Secondary / Ghost**: Background `#FFFFFF`, border 1px solid `#E5E7EB`, text `#1F2937`. Hover: background `#F8FAFC`, border `#D1D5DB`.
- **Destructive**: Background `#FEF2F2`, border 1px solid `#FCA5A5`, text `#DC2626`. Hover: background `#DC2626`, text `#FFFFFF`.
- **Dark Structural**: Background `#113657`, text `#FFFFFF`. Hover: `#1A4B75`.

### Form Inputs & Search Fields
- **Container**: Height 32px, background `#FFFFFF`, border 1px solid `#E5E7EB`, border-radius 4px, padding 0 10px, typography `body-md` (13px).
- **Focus**: Border color `#F17D24`, box-shadow `0 0 0 1px #F17D24`.
- **Search Variant**: Integrated leading magnifying icon (14px, `#6B7280`), trailing keyboard shortcut hint (`Ctrl + K` badge, `#F3F4F6`, border `#E5E7EB`).

### Data Tables (Core ERP Grid)
- **Header**: Height 34px, background `#F8FAFC` or `#F1F5F9`, border-bottom 2px solid `#E2E8F0`, typography `label-sm` (11px, bold, uppercase, text `#6B7280`).
- **Rows**: Alternating or clean white background, border-bottom 1px solid `#F1F5F9`, height 36px, hover background `#FFF7ED` (subtle orange tint) or `#F8FAFC`.
- **Numeric Cells**: Right-aligned, Inter tabular numbers with bold currency suffix.
- **Selection**: Active row selected state features a 3px vertical accent border of `#F17D24` on the leading cell edge.

### Status Badges & Chips
- **Success (e.g. Paid / Connecté)**: Background `#DCFCE7`, text `#15803D`, 1px solid `#BBF7D0`, 20px height, rounded-full, with leading 6px circular dot `#16A34A`.
- **Warning / Pending (e.g. En attente)**: Background `#FEF3C7`, text `#B45309`, 1px solid `#FDE68A`, with leading 6px circular dot `#D97706`.
- **Danger (e.g. Annulé / Erreur)**: Background `#FEE2E2`, text `#B91C1C`, 1px solid `#FECACA`, with leading 6px circular dot `#DC2626`.

### KPI Metric Cards
- **Structure**: Background `#FFFFFF`, border 1px solid `#E5E7EB`, padding 12px 16px, border-radius 6px.
- **Top Row**: Metric label (12px, `#6B7280`) paired with subtle tinted icon container (28px × 28px, rounded 4px).
- **Metric Row**: 20px bold figure (`#1F2937`) accompanied by inline percentage trend tag (e.g., green `+12%` indicator with directional arrow).

### Desktop Navigation Rail
- **Background**: Solid `#113657`.
- **Nav Items**: Height 36px, horizontal padding 12px, border-radius 4px, text `#CBD5E1`.
- **Active Nav Item**: Background `#1C476E` with vibrant `#F17D24` leading accent marker (or solid `#F17D24` fill when prominent), text `#FFFFFF`, icon colored `#FFFFFF`.