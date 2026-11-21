# UI patterns for ERP screens

Use these rules when adding or changing a center frame. The shared shell owns the window title bar, menu, sidebar, fixed 44 px page heading, and status bar. A center frame supplies its content and actions; it does not draw another page heading or breadcrumb. Add a page title and path in `modules/shell/ShellView.ui.qml` when adding navigation.

## Visual language

- Reuse `qml/theme/Colors.qml`, `Typography.qml`, and `Theme.qml`. Navy is the navigation and heading color; orange marks the primary action or active destination. Use white surfaces on the light canvas and the existing border tokens. Avoid screen-specific copies of the palette.
- Use the shared `AzenzButton`, `AzenzTextField`, `DataGrid`, and other controls. Keep the existing compact density for tables and toolbars. Let content scroll inside its frame when the window narrows.
- Use the same title size, breadcrumb size, 44 px heading height, and page spacing on every screen. Put feature-specific status or mode information beside its relevant field, not in the shell heading.
- Summary totals use the shared `FinancialTotal` component: **Total HT**, **TVA**, then emphasized **Total TTC**, in that order. Use the pale blue emphasis and navy text of Ventes on Nouveau document too; keep numeric values with two decimals and `MAD`.
- Every data table uses the Ventes header colors: `Colors.navy` background and white text. Listing grids use the compact 32 px header; editable line tables keep their 44 px row and header height. Apply the colors to line-entry tables and payment grids as well as listing grids. Keep body rows on white or canvas surfaces with standard borders; avoid pale headers with low-contrast gray labels.

## Actions and navigation

- Put **Retour** once, in the page footer beside the final action. Keep it secondary. This applies to Ventes, Nouveau document, and Règlements. Do not repeat it in the top toolbar.
- Put creation, selection actions, refresh, print, and export in the page toolbar. The main creation or save action is orange; other actions are secondary. Disable actions that require a selection until a valid row is selected.
- Put **Appliquer** and **Réinitialiser** in the same filter group, immediately after the last filter. Use a small reset icon with a clear tooltip; keep the apply action labelled. Do not separate these controls with totals, unrelated text, or the page toolbar. A document-wide discount has its own Apply action within the discount group.
- The sidebar is the single module navigation surface. The shell heading reflects the destination. A page-specific Retour action leads to that page's parent; it is not a second sidebar.

## Sidebar motion and Réduire

- Collapsing and expanding the sidebar takes 220 ms with `InOutCubic` easing. Text fades during the transition. Respect `Theme.reducedMotion` so the width changes instantly when motion is disabled.
- **UX recommendation, placement not changed yet:** keep Réduire near the top, immediately under the company identity. It affects the entire navigation and should remain discoverable without scrolling. Moving it to the bottom would place it beside branding and farther from the navigation it controls. Review this with the user before relocating it.

## Review checklist

Check the expanded and collapsed sidebar, keyboard focus and tooltips, the smallest supported window, horizontal table scrolling, and the empty, loading, and populated states. Verify that labels, colors, and action placement match the patterns above before adding another screen.
