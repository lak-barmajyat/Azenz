# AZENZ QML component kit

This library converts the UI component families in the supplied `code.html` into
native Qt Quick components. The HTML is a component specification sheet, so the
conversion provides reusable types and a gallery rather than embedding a web view.

Source references: `stitch_azenz_erp_ventes_interface/code.html` and `DESIGN.md`.
For conflicting values, the HTML's section-specific definitions take precedence:
orange `#F17D24`, navy `#113657`, 28/32/38px buttons, 32/38px inputs, 28/32px grid
rows, 32/36px grid headers, and 224/56px sidebars. Documentation cards and state
matrices become component properties and gallery examples, not separate copies of
every control. `MetricCard` also implements the KPI card described in `DESIGN.md`.

## Preview in Qt Design Studio

1. Open `AzenzKit.qmlproject` at the repository root.
2. Use a Qt 6.8+ desktop kit. Validation here used Qt/PySide6 6.12.0.
3. Open `qml/gallery/KitPreview.ui.qml` for the visual composition, or Run the
   project for interactive controls, menus, calendars, and dialogs.
4. The five gallery tabs cover inputs, navigation, tables, feedback, and foundations.
   The header switches between compact and comfortable density.

The existing `Azenz.qmlproject` also includes these directories and resources; its
application entry remains `qml/App.qml`. The login/database flow is unchanged.

The `qmldir` and `designer/*.metainfo` files register reusable types under
`AZENZ / Controls`, `AZENZ / Components`, and `AZENZ / Layouts`. Add the corresponding
`controls`, `components`, or `layouts` import when using a type. Both projects put
`qml` on the import path. If the library list is cached, reset the QML code model.
This follows Qt's [custom component registration mechanism](https://doc.qt.io/qtdesignstudio/creator-qml-modules-with-plugins.html).

Behavior resides in `.qml` files. The `.ui.qml` files are declarative compositions
for Design Studio: `KitPreview.ui.qml` and `DesktopShell.ui.qml`. Custom controls
can be placed and configured in the visual editor; editing their JavaScript
behavior requires the code editor. A live Qt Design Studio editor session was not
available during validation, so editor-specific drag/drop behavior is not verified.

Run the independent gallery without starting the database:

```powershell
python preview_kit.py
# Or use the isolated validation runtime created for this conversion:
.\.venv-qml\Scripts\python.exe preview_kit.py
```

## Component map

| HTML section | Project folder | QML types and variants |
| --- | --- | --- |
| 01–04, 17: foundations, colors, typography, spacing | `qml/theme` | `Colors`, `Typography`, `Theme` singletons; `Label` in controls; `DensityScope` in layouts |
| 05: buttons | `qml/controls` | `AzenzButton`: primary, secondary, ghost, danger, toolbar, icon; compact, standard, comfortable; `IconButton`; loading/disabled/hover/pressed/focus |
| 06: inputs | `qml/controls` | `AzenzTextField`: text, number, currency, search, password, documentCode; `InputField`: label, required marker, helper/error line; `NumberInput`: range/step controls; readOnly, valid, error, disabled |
| 07: selection | `qml/controls` | `AzenzCheckBox` including partial selection, `AzenzRadioButton`, `AzenzSwitch`, `AzenzComboBox` with optional search and disabled entries, `DateInput`, `DatePicker` |
| 08: navigation | `qml/components` | `Sidebar`, `SidebarGroup`, `SidebarItem`, `CompanyIdentityArea`, `BottomBrandingArea`, `ApplicationMenuBar`, `Breadcrumb` |
| 09: toolbars | `qml/components` | `PageActionToolbar`, `CompactToolbar`, `ToolbarGroup`, `ToolbarSeparator`, `OverflowMenuButton`, `ToolbarUtilityButton` |
| 10: data grids | `qml/components` | `DataGrid`, `DataGridHeader`, `DataGridHeaderCell`, `DataGridRow`, `DataGridCell`, `DataGridSelectionCell`, `DataGridFooter`, `ColumnResizeHandle`; `AzenzScrollBar` in controls |
| 11: menus and overlays | `qml/components` | `ContextMenu`, `ContextMenuItem`, `DropdownMenu`, `DropdownMenuItem`, `Popover`, `MenuSeparator`; `AzenzToolTip` in controls |
| 12: badges | `qml/components` | `Badge`: neutral/info/success/warning/danger, subtle/filled, optional dot; `DocumentTypeBadge`: DV/BC/BL/BR/FA/FR; `ConnectionIndicator`: connected/connecting/disconnected |
| 13: dialogs | `qml/components` | `AzenzDialog`: confirmation/destructive/warning/information/error; small/medium; optional icon, close button, supporting message, configurable actions |
| 14: feedback | `qml/components` | `Toast`, `ToastHost` queue, `InlineBanner`: success/info/warning/error, optional action and close button |
| 15: loading and empty states | `qml/components` | `Skeleton`: table/textBlock/form; `EmptyState`: noData/noResults, configurable copy and action |
| 16: application status and logo | `qml/components` | `StatusBar`, `Logo`: light/dark/symbol/monochrome using the original referenced images |
| Application composition | `qml/layouts` | `DesktopShell.ui.qml`, `Panel`, `DensityScope` |

## Basic usage

```qml
import QtQuick
import QtQuick.Layouts
import controls 1.0
import components 1.0
import layouts 1.0

DensityScope {
    width: 600
    height: 320
    density: "comfortable"

    ColumnLayout {
        anchors.fill: parent
        InputField {
            label: "Raison sociale"
            required: true
            placeholderText: "Saisir un client"
            Layout.fillWidth: true
        }
        AzenzButton {
            text: "Enregistrer"
            iconName: "save"
            onClicked: console.log("Save requested")
        }
    }
}
```

Use directory imports such as `import "../../qml/controls"` from an existing
module, or the named imports above with `qml` on the engine's import path.
`main.py` already adds that path. Native controls explicitly use the Basic style,
so their custom styling does not depend on the host's Windows control style.

### Density, typography, and RTL

Controls bind their `density` to the nearest parent that declares it, falling back
to `Theme.density`. Wrap a screen in `DensityScope` or declare a `density` property
on its root. Explicit `size` overrides button size. The sidebar, badges, menu rows,
and application status bar keep their specified fixed dimensions.

Inter and Noto Sans Arabic are local fonts. `Label.arabic: true` selects the Arabic
font; `Label.tabular: true` enables tabular digits. `DesktopShell` exposes layout
mirroring through `Theme.rightToLeft`; full per-screen translation and RTL content
arrangement remain the application's responsibility. Dates and financial fields
use French formatting and Latin digits, as in the supplied examples.

### Inputs and selection

`AzenzTextField` exposes `inputType`, `validationState`, `prefix`, `suffix`,
`leadingIcon`, `trailingIcon`, `readOnly`, `clearable`, and `shortcutEnabled`.
Enable `shortcutEnabled` on only the active screen's search field for Ctrl+K.
`InputField.field` exposes the underlying field for validators and other options.
Passwords have an eye toggle; read-only text remains selectable.

`NumberInput` has `value`, `minimum`, `maximum`, `stepSize`, and `decimals`.
`DateInput` has `value`, `hasValue`, `minimumDate`, and `maximumDate`; invalid
calendar dates are rejected, including non-leap-year February 29. `DatePicker`
supports day arrows, PageUp/PageDown, Enter, Escape, and F3 for today. Its separate
selected, today, and focus indicators follow the HTML's distinction.

`AzenzComboBox.model` accepts strings or `{text, value, enabled}` objects in a JS
array. Set `searchable: true` for long lists. `activated(index)` reports user
selection; `currentText` and `currentValue` expose the selected entry. Filtered
keyboard navigation skips disabled entries.

### Data grid contract

`DataGrid.rows` is a JS array of records, each with a **unique stable `id`** (or the
field named by `idRole`). Do not use duplicate or missing IDs. Set `enabled: false`
on a record to disable it; a business label such as "Annulé" does not disable it.
Replace the array after backend updates so QML can observe changes. Adapt Python
models to this contract or add a QAbstractItemModel adapter for server-scale use.

`columns` is an array of `{key, title, width, type, alignment, sortable, editable}`.
The nine cell types are `text`, `code`, `date`, `int`, `dec`, `currency`, `status`,
`checkbox`, and `bool`. Financial columns should receive numeric values. Date
sorting accepts JS dates, `dd/MM/yyyy` strings, or ISO dates. For a status cell,
`record.statusVariant` determines its semantic badge color.

The row renderer is virtualized; sorting/filtering operate on the supplied array.
Headers stay fixed while rows scroll, and column resize handles control widths.
Selection is stored by ID and survives sorting. A plain click or arrow key moves
focus; Space or the checkbox changes selection. Ctrl-click toggles a record;
Shift-click selects a range when `multiSelection` is enabled. Editable cells
enter edit mode on double-click; Enter emits `cellEdited`, Escape cancels. Commit
that signal in your screen/backend and replace the relevant records.

`rowActivated(record)` is emitted on Enter; its business meaning is supplied by the
screen. `contextMenuRequested(record, x, y)` targets the pointed/focused record,
independently from checked selections. Use `menu.popup(grid, x, y)` to place a
`ContextMenu`. `selectedIds` and `selectionCount` drive the action toolbar.

`viewState` is `default`, `loading`, `empty`, or `error`. Headers remain visible.
`retryRequested()` lets the screen retry. Set `totalCount` and handle
`loadMoreRequested()` to append another backend batch on reaching the end; the kit
does not query databases. Empty/loading/error illustrations are generic.

### Commands, dialogs, and feedback

`PageActionToolbar` emits `actionTriggered(action)` for `new`, `edit`, `delete`,
`duplicate`, `print`, `export`, `refresh`, `columns`, and `secondary`.
`actionAvailability` overrides its example selection-based availability. File
exports, print operations, persistence, permissions, and other business logic
must be connected by each screen. Menu `shortcutText` labels are display hints;
register actual shortcuts at screen scope to avoid duplicate global bindings.

`AzenzDialog` emits the standard `accepted()`/`rejected()` signals. Destructive
dialogs initially focus Cancel, Tab cycles within the dialog, and closing restores
focus to the trigger. Information dialogs may hide Cancel. Override button text
and messages for the workflow.

`ToastHost.show(title, message, variant, actionText)` returns a notification ID.
It shows at most four at a time and queues additional messages. Dismiss an ID with
`dismiss(id)` and handle `actionTriggered(id)`. Success/info notifications default
to five seconds; warnings, errors, and actionable notices persist. Hover pauses
automatic dismissal. Inline banners stay until their owner or close button hides
them. Skeleton animation is off by default and respects `Theme.reducedMotion`.

## Assets and verification

`resources/fonts` contains the two fonts and their OFL licenses. The four logo
images are the exact URLs referenced by the source HTML. `resources/kit-assets.json`
records their source URLs and hashes. Icons use local inline SVG geometry exposed
by `Icons.paths`; these are functional equivalents of the HTML's Material Symbols,
not the original Material Symbols font. Shadows/backdrop blur are reduced to crisp
Qt borders and overlay scrims to avoid a Qt Quick Effects dependency.

```powershell
.\.venv-qml\Scripts\python.exe tests/validate_qml.py --render
.\.venv-qml\Scripts\python.exe tests/test_qml_interactions.py
```

The first script instantiates all component types and renders every gallery tab,
failing on Qt warnings/errors; screenshots go to `build/qml-preview`. The second
uses real Qt keyboard and pointer input to check density inheritance, invalid and
leap dates, numeric bounds, searchable selection, numeric/date sorting, selection
identity, disabled rows, context targets, resize dragging, Ctrl/Shift selection,
modal focus/cancel behavior, calendar navigation, and the toast queue. These checks
run without a database. The existing backend tests and application startup are
outside this UI conversion.
