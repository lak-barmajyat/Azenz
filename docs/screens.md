# Login and sales screens

The two supplied HTML screens are implemented with the existing QML component kit:

| Reference | Visual form | Interactive screen |
| --- | --- | --- |
| `code2.html`: Connexion | `modules/login/LoginView.ui.qml` | `modules/login/Login.qml` |
| `code.html`: Ventes | `modules/ventes/liste_ventes/SalesView.ui.qml` | `modules/ventes/liste_ventes/Sales.qml` |

Open **AzenzScreens.qmlproject** in Qt Design Studio. The main visual form previews
sales; running the project starts with login. The `.ui.qml` files contain the
visual compositions, while their `.qml` wrappers handle interactions. The original
component gallery remains available through `AzenzKit.qmlproject`.

To run independently of the database:

```powershell
.\.venv-qml\Scripts\python.exe preview_screens.py
.\.venv-qml\Scripts\python.exe preview_screens.py --sales
.\.venv-qml\Scripts\python.exe run_sales.py
```

`run_sales.py` opens the interactive sales window directly. The calendar buttons
work in this runtime. Qt Design Studio's form-editing canvas is for editing the
design; use **Run App** (Ctrl+R) to test interactions in the application, or
**Live Preview** (Alt+P) to run the active QML file. A separate Live Preview window
should support interactions too; a nonworking button there is not expected merely
because it is a preview.

The standalone preview explicitly labels itself as a preview. Any **nonempty**
username/password opens its sales screen without verification. Password text is
cleared on completion and is never written to storage or logs. In this preview,
confirmed deletion changes only the sample array in memory; F5 restores it.
Other business commands display the requested action without pretending to save,
print, or export a real document.

The production entry, `qml/App.qml`, does **not** use this preview authentication
behavior. It starts with login and reports that authentication is unavailable
until a backend is connected. `main.py` retains its existing database bootstrap.

## Implemented interactions

- Login: required-field validation, Enter navigation/submission, password eye
  toggle, loading/error states, forgot-password help, and French/English/Arabic
  interface text. Arabic labels mirror while credential input controls retain
  consistent icon placement.
- Window chrome: dragging, double-click maximize/restore, minimize, close, and a
  bottom-right resize grip in the window entry points.
- Sales: collapsible sidebar/groups, system menus, document code and type filters,
  date range validation, reset, sorting, column resizing, continuous scrolling,
  checkbox and keyboard selection, selection-aware toolbar, context menu, and
  destructive confirmation with Cancel initially focused.
- Totals and counts reflect the filtered array. The HTML contains 15 actual rows,
  despite its placeholder footer saying 50/2,438. Those 15 rows sum to
  **216,100.00 MAD HT**, **43,220.00 MAD TVA**, and **259,320.00 MAD TTC**.
  Filters initially show all records instead of presenting the HTML's inconsistent
  prefilled filters with unrelated rows.
- Screen styles use the kit with optional dark menu/header colors, currency cell
  suffixes, and login control corner radii. Existing defaults are preserved.

The HTML screenshots were used as layout references. The fonts and AZENZ logo
variants already bundled in the project are reused; no runtime network access is
needed. Local SVG icons and simple geometric decoration replace web icon fonts and
blur effects. Production company, username, connection state and rows are exposed
as properties; the preview does not fabricate live connection latency.

## Backend integration

`Login.loginRequested(username, password, language)` is emitted after local input
validation. Complete the request with
`Login.completeAuthentication(success, message)`. Success emits
`authenticated(username)`; failure displays the backend's error message.
No credential repository or password-reset service was present in the project.

The production entry creates `LoginModel`, which calls the SQLAlchemy repository
and uses `@with_session()` for session lifecycle. It sets
`authenticationAvailable = true` after bootstrap. Supply `salesRecords` (the
grid's array contract), set `connected` from the real connection state, and handle
`salesActionRequested(action, records)` and `navigationRequested(page)`. Records require unique stable IDs and numeric
`ht`, `vat`, and `ttc` fields; see `SalesSample.js` for the shape.

The sales screen exposes `actionRequested(action, records)` for new/open/edit/
duplicate/delete/print/export/refresh and menu commands. Only a confirmed delete
emits the delete command. Context menus target the pointed record independently of
checkbox selection. `filtersChanged(filters)` can be used to request backend data;
local filtering and totals are already provided. Other ERP modules and the document
editor are outside these two supplied screens.

## Verification

```powershell
.\.venv-qml\Scripts\python.exe tests/validate_screens.py
.\.venv-qml\Scripts\python.exe tests/validate_qml.py
.\.venv-qml\Scripts\python.exe tests/test_qml_interactions.py
```

`validate_screens.py` renders both screens and smaller-window/Arabic variants into
`build/screens-preview`, exercises their interactions, and verifies that production
login refuses unverified credentials. Tests run offscreen with Qt 6.12.0 and fail
on runtime warnings. Qt Design Studio editor drag/drop itself has not been tested.
