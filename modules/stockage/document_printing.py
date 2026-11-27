"""Simple A4 PDF rendering for stock documents."""

from __future__ import annotations

from datetime import date, datetime
from decimal import Decimal
from pathlib import Path
from typing import Any
from xml.sax.saxutils import escape

from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_RIGHT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import mm
from reportlab.platypus import PageBreak, Paragraph, SimpleDocTemplate, Spacer, Table, TableStyle

NAVY = colors.HexColor("#12304A")
LIGHT = colors.HexColor("#EEF2F5")
TEXT_MUTED = colors.HexColor("#5F6B76")


def _quantity(value: Any) -> str:
    formatted = f"{Decimal(str(value or 0)):.4f}".rstrip("0").rstrip(".")
    return formatted.replace(".", ",")


def _date(value: Any) -> str:
    if isinstance(value, datetime):
        value = value.date()
    if isinstance(value, date):
        return value.strftime("%d/%m/%Y")
    try:
        return date.fromisoformat(str(value)).strftime("%d/%m/%Y")
    except ValueError:
        return str(value)


def _text(value: Any) -> str:
    return escape(str(value or ""))


def _footer(canvas: Any, document: Any) -> None:
    canvas.saveState()
    width, _ = A4
    canvas.setStrokeColor(colors.HexColor("#D5DCE2"))
    canvas.line(18 * mm, 13 * mm, width - 18 * mm, 13 * mm)
    canvas.setFillColor(TEXT_MUTED)
    canvas.setFont("Helvetica", 8)
    canvas.drawString(18 * mm, 8 * mm, "AZENZ")
    canvas.drawRightString(width - 18 * mm, 8 * mm, f"Page {document.page}")
    canvas.restoreState()


def render_stock_documents(destination: Path, documents: list[dict[str, Any]]) -> Path:
    """Render one or more stock documents into a single printable PDF."""
    if not documents:
        raise ValueError("At least one document is required")
    destination.parent.mkdir(parents=True, exist_ok=True)
    pdf = SimpleDocTemplate(
        str(destination),
        pagesize=A4,
        rightMargin=18 * mm,
        leftMargin=18 * mm,
        topMargin=16 * mm,
        bottomMargin=20 * mm,
        title="Documents de stock",
        author="Azenz",
    )
    styles = getSampleStyleSheet()
    title_style = ParagraphStyle(
        "DocumentTitle",
        parent=styles["Title"],
        fontName="Helvetica-Bold",
        fontSize=18,
        leading=22,
        textColor=NAVY,
        spaceAfter=3 * mm,
    )
    label_style = ParagraphStyle(
        "Label",
        parent=styles["Normal"],
        fontName="Helvetica-Bold",
        fontSize=8,
        leading=10,
        textColor=TEXT_MUTED,
    )
    value_style = ParagraphStyle("Value", parent=styles["Normal"], fontSize=9, leading=12)
    cell_style = ParagraphStyle("Cell", parent=value_style, fontSize=8, leading=10)
    right_style = ParagraphStyle("RightCell", parent=cell_style, alignment=TA_RIGHT)
    header_style = ParagraphStyle(
        "HeaderCell",
        parent=cell_style,
        fontName="Helvetica-Bold",
        textColor=colors.white,
        alignment=TA_CENTER,
    )
    story: list[Any] = []

    for index, stock_document in enumerate(documents):
        if index:
            story.append(PageBreak())
        story.append(Paragraph(_text(stock_document["documentType"]), title_style))
        story.append(
            Table(
                [
                    [
                        Paragraph("DOCUMENT", label_style),
                        Paragraph("DATE", label_style),
                        Paragraph("STATUT", label_style),
                    ],
                    [
                        Paragraph(_text(stock_document["documentCode"]), value_style),
                        Paragraph(_date(stock_document["date"]), value_style),
                        Paragraph(_text(stock_document["status"]), value_style),
                    ],
                ],
                colWidths=[65 * mm, 45 * mm, 64 * mm],
                style=TableStyle(
                    [
                        ("BOX", (0, 0), (-1, -1), 0.5, colors.HexColor("#D5DCE2")),
                        ("INNERGRID", (0, 0), (-1, -1), 0.25, colors.HexColor("#E4E9ED")),
                        ("VALIGN", (0, 0), (-1, -1), "TOP"),
                        ("LEFTPADDING", (0, 0), (-1, -1), 7),
                        ("RIGHTPADDING", (0, 0), (-1, -1), 7),
                        ("TOPPADDING", (0, 0), (-1, -1), 5),
                        ("BOTTOMPADDING", (0, 0), (-1, -1), 5),
                    ]
                ),
            )
        )
        if stock_document["comment"]:
            story.append(Spacer(1, 3 * mm))
            story.append(Paragraph(_text(stock_document["comment"]), value_style))
        story.append(Spacer(1, 6 * mm))
        rows = [
            [
                Paragraph("Référence", header_style),
                Paragraph("Désignation", header_style),
                Paragraph("Quantité", header_style),
                Paragraph("Commentaire", header_style),
            ]
        ]
        for line in stock_document["lines"]:
            rows.append(
                [
                    Paragraph(_text(line["reference"]), cell_style),
                    Paragraph(_text(line["description"]), cell_style),
                    Paragraph(_quantity(line["quantity"]), right_style),
                    Paragraph(_text(line["comment"]), cell_style),
                ]
            )
        story.append(
            Table(
                rows,
                repeatRows=1,
                colWidths=[28 * mm, 70 * mm, 22 * mm, 54 * mm],
                style=TableStyle(
                    [
                        ("BACKGROUND", (0, 0), (-1, 0), NAVY),
                        ("GRID", (0, 0), (-1, -1), 0.35, colors.HexColor("#D5DCE2")),
                        ("ROWBACKGROUNDS", (0, 1), (-1, -1), [colors.white, LIGHT]),
                        ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
                        ("LEFTPADDING", (0, 0), (-1, -1), 4),
                        ("RIGHTPADDING", (0, 0), (-1, -1), 4),
                        ("TOPPADDING", (0, 0), (-1, -1), 5),
                        ("BOTTOMPADDING", (0, 0), (-1, -1), 5),
                    ]
                ),
            )
        )

    pdf.build(story, onFirstPage=_footer, onLaterPages=_footer)
    return destination
