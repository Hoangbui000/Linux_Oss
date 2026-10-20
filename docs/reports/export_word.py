#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Chuyển đổi Báo cáo Markdown sang Microsoft Word (.docx và .doc)
Đảm bảo chuẩn trình bày học thuật: Times New Roman, dãn dòng 1.3, bảng biểu và code block chuyên nghiệp.
"""

import os
import re
import zipfile
import html

def escape_xml(text):
    return (text.replace('&', '&amp;')
                .replace('<', '&lt;')
                .replace('>', '&gt;')
                .replace('"', '&quot;')
                .replace("'", '&apos;'))

def md_inline_to_word_xml(text):
    """Chuyển đổi inline markdown (bold, italic, code) sang các thẻ w:r của Word OpenXML"""
    # Pattern to match bold, italic, code
    tokens = re.split(r'(\*\*.*?\*\*|\*.*?\*|`.*?`)', text)
    runs_xml = []
    for token in tokens:
        if not token:
            continue
        if token.startswith('**') and token.endswith('**') and len(token) >= 4:
            content = escape_xml(token[2:-2])
            runs_xml.append(f'<w:r><w:rPr><w:b/></w:rPr><w:t xml:space="preserve">{content}</w:t></w:r>')
        elif token.startswith('*') and token.endswith('*') and len(token) >= 2:
            content = escape_xml(token[1:-1])
            runs_xml.append(f'<w:r><w:rPr><w:i/></w:rPr><w:t xml:space="preserve">{content}</w:t></w:r>')
        elif token.startswith('`') and token.endswith('`') and len(token) >= 2:
            content = escape_xml(token[1:-1])
            runs_xml.append(f'<w:r><w:rPr><w:rFonts w:ascii="Consolas" w:hAnsi="Consolas"/><w:color w:val="C7254E"/><w:shd w:val="clear" w:color="auto" w:fill="F9F2F4"/></w:rPr><w:t xml:space="preserve"> {content} </w:t></w:r>')
        else:
            # Handle markdown links [text](url) -> just text (url)
            clean_text = re.sub(r'\[(.*?)\]\((.*?)\)', r'\1', token)
            content = escape_xml(clean_text)
            runs_xml.append(f'<w:r><w:t xml:space="preserve">{content}</w:t></w:r>')
    return "".join(runs_xml)

def create_docx(md_path, docx_path):
    with open(md_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    body_xml = []
    in_code_block = False
    code_block_lines = []
    in_table = False
    table_rows = []

    def flush_code_block():
        nonlocal in_code_block, code_block_lines
        if code_block_lines:
            for c_line in code_block_lines:
                escaped = escape_xml(c_line)
                body_xml.append(
                    f'<w:p>'
                    f'<w:pPr>'
                    f'<w:spacing w:before="40" w:after="40" w:line="240" w:lineRule="auto"/>'
                    f'<w:shd w:val="clear" w:color="auto" w:fill="F4F4F6"/>'
                    f'<w:pBdr>'
                    f'<w:left w:val="single" w:sz="18" w:space="8" w:color="003366"/>'
                    f'</w:pBdr>'
                    f'</w:pPr>'
                    f'<w:r>'
                    f'<w:rPr><w:rFonts w:ascii="Consolas" w:hAnsi="Consolas"/><w:sz w:val="19"/><w:color w:val="1A1A1A"/></w:rPr>'
                    f'<w:t xml:space="preserve">{escaped}</w:t>'
                    f'</w:r>'
                    f'</w:p>'
                )
            code_block_lines = []
        in_code_block = False

    def flush_table():
        nonlocal in_table, table_rows
        if table_rows:
            tbl_xml = [
                '<w:tbl>',
                '<w:tblPr>',
                '<w:tblW w:w="5000" w:type="pct"/>',
                '<w:tblBorders>',
                '<w:top w:val="single" w:sz="6" w:space="0" w:color="D1D5DB"/>',
                '<w:left w:val="none"/>',
                '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="D1D5DB"/>',
                '<w:right w:val="none"/>',
                '<w:insideH w:val="single" w:sz="4" w:space="0" w:color="E5E7EB"/>',
                '<w:insideV w:val="none"/>',
                '</w:tblBorders>',
                '</w:tblPr>'
            ]
            for row_idx, r in enumerate(table_rows):
                tbl_xml.append('<w:tr>')
                is_header = (row_idx == 0)
                for cell in r:
                    shading = ' w:fill="1B365D"' if is_header else (' w:fill="F9FAFB"' if row_idx % 2 == 1 else ' w:fill="FFFFFF"')
                    color = ' w:color="FFFFFF"' if is_header else ' w:color="1F2937"'
                    bold = '<w:b/>' if is_header else ''
                    cell_text = escape_xml(cell.strip())
                    tbl_xml.append(
                        f'<w:tc>'
                        f'<w:tcPr>'
                        f'<w:shd w:val="clear" w:color="auto"{shading}/>'
                        f'<w:tcMar><w:top w:w="120" w:type="dxa"/><w:bottom w:w="120" w:type="dxa"/><w:left w:w="150" w:type="dxa"/><w:right w:w="150" w:type="dxa"/></w:tcMar>'
                        f'</w:tcPr>'
                        f'<w:p>'
                        f'<w:pPr><w:spacing w:before="40" w:after="40"/></w:pPr>'
                        f'<w:r><w:rPr>{bold}<w:sz w:val="22"/>{color}</w:rPr><w:t xml:space="preserve">{cell_text}</w:t></w:r>'
                        f'</w:p>'
                        f'</w:tc>'
                    )
                tbl_xml.append('</w:tr>')
            tbl_xml.append('</w:tbl>')
            body_xml.append("".join(tbl_xml))
            table_rows = []
        in_table = False

    for raw_line in lines:
        line = raw_line.rstrip('\r\n')

        # Code block delimiter
        if line.startswith('```'):
            if in_code_block:
                flush_code_block()
            else:
                if in_table:
                    flush_table()
                in_code_block = True
            continue

        if in_code_block:
            code_block_lines.append(line)
            continue

        # Table row
        if line.strip().startswith('|') and line.strip().endswith('|'):
            # Skip separator row like |:---|:---|
            if re.match(r'^[\|\s\-\:]+$', line.strip()):
                continue
            cols = [c.strip() for c in line.strip().split('|')[1:-1]]
            table_rows.append(cols)
            in_table = True
            continue
        elif in_table:
            flush_table()

        # Horizontal rule
        if line.strip() in ['---', '***', '___']:
            body_xml.append(
                '<w:p><w:pPr><w:pBdr><w:bottom w:val="single" w:sz="6" w:space="8" w:color="CBD5E1"/></w:pBdr>'
                '<w:spacing w:before="120" w:after="120"/></w:pPr></w:p>'
            )
            continue

        # Blank line
        if not line.strip():
            continue

        # Heading 1 (# ...)
        if line.startswith('# '):
            title_text = line[2:].strip()
            runs = md_inline_to_word_xml(title_text)
            body_xml.append(
                f'<w:p>'
                f'<w:pPr>'
                f'<w:pStyle w:val="Heading1"/>'
                f'<w:jc w:val="center"/>'
                f'<w:spacing w:before="240" w:after="180"/>'
                f'</w:pPr>'
                f'{runs}'
                f'</w:p>'
            )
            continue

        # Heading 2 (## ...)
        if line.startswith('## '):
            h2_text = line[3:].strip()
            runs = md_inline_to_word_xml(h2_text)
            body_xml.append(
                f'<w:p>'
                f'<w:pPr>'
                f'<w:pStyle w:val="Heading2"/>'
                f'<w:spacing w:before="240" w:after="100"/>'
                f'<w:pBdr><w:bottom w:val="single" w:sz="12" w:space="4" w:color="1B365D"/></w:pBdr>'
                f'</w:pPr>'
                f'{runs}'
                f'</w:p>'
            )
            continue

        # Heading 3 (### ...)
        if line.startswith('### '):
            h3_text = line[4:].strip()
            runs = md_inline_to_word_xml(h3_text)
            body_xml.append(
                f'<w:p>'
                f'<w:pPr>'
                f'<w:pStyle w:val="Heading3"/>'
                f'<w:spacing w:before="180" w:after="60"/>'
                f'</w:pPr>'
                f'{runs}'
                f'</w:p>'
            )
            continue

        # Bullet list item
        if line.strip().startswith('* ') or line.strip().startswith('- '):
            bullet_indent = 360
            if line.startswith('    ') or line.startswith('\t'):
                bullet_indent = 720
            clean_item = re.sub(r'^\s*[\*\-]\s+', '', line)
            runs = md_inline_to_word_xml(clean_item)
            body_xml.append(
                f'<w:p>'
                f'<w:pPr>'
                f'<w:ind w:left="{bullet_indent}" w:hanging="240"/>'
                f'<w:spacing w:before="40" w:after="40" w:line="300" w:lineRule="auto"/>'
                f'</w:pPr>'
                f'<w:r><w:rPr><w:rFonts w:ascii="Symbol" w:hAnsi="Symbol"/><w:color w:val="1B365D"/></w:rPr><w:t> </w:t></w:r>'
                f'{runs}'
                f'</w:p>'
            )
            continue

        # Numbered list item
        num_match = re.match(r'^\s*(\d+)\.\s+(.*)$', line)
        if num_match:
            num = num_match.group(1)
            content = num_match.group(2)
            runs = md_inline_to_word_xml(content)
            body_xml.append(
                f'<w:p>'
                f'<w:pPr>'
                f'<w:ind w:left="400" w:hanging="280"/>'
                f'<w:spacing w:before="40" w:after="40" w:line="300" w:lineRule="auto"/>'
                f'</w:pPr>'
                f'<w:r><w:rPr><w:b/><w:color w:val="1B365D"/></w:rPr><w:t>{num}. </w:t></w:r>'
                f'{runs}'
                f'</w:p>'
            )
            continue

        # Standard paragraph
        runs = md_inline_to_word_xml(line.strip())
        body_xml.append(
            f'<w:p>'
            f'<w:pPr>'
            f'<w:spacing w:before="60" w:after="60" w:line="312" w:lineRule="auto"/>'
            f'<w:jc w:val="both"/>'
            f'</w:pPr>'
            f'{runs}'
            f'</w:p>'
        )

    # Flush remaining
    if in_code_block:
        flush_code_block()
    if in_table:
        flush_table()

    # Section properties (Page Margins: 2cm top/bottom, 2.5cm left/right)
    body_xml.append(
        '<w:sectPr>'
        '<w:pgSz w:w="11906" w:h="16838"/>'  # A4 size
        '<w:pgMar w:top="1134" w:right="1134" w:bottom="1134" w:left="1417" w:header="708" w:footer="708" w:gutter="0"/>'
        '</w:sectPr>'
    )

    doc_xml_str = (
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n'
        '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">\n'
        '<w:body>\n'
        + "".join(body_xml) +
        '\n</w:body>\n'
        '</w:document>'
    )

    content_types_str = (
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n'
        '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">\n'
        '  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>\n'
        '  <Default Extension="xml" ContentType="application/xml"/>\n'
        '  <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>\n'
        '  <Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>\n'
        '</Types>'
    )

    rels_str = (
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n'
        '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">\n'
        '  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>\n'
        '</Relationships>'
    )

    doc_rels_str = (
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n'
        '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">\n'
        '  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>\n'
        '</Relationships>'
    )

    styles_str = (
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n'
        '<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">\n'
        '  <w:docDefaults>\n'
        '    <w:rPrDefault>\n'
        '      <w:rPr>\n'
        '        <w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:cs="Times New Roman"/>\n'
        '        <w:sz w:val="26"/>\n'
        '        <w:szCs w:val="26"/>\n'
        '        <w:color w:val="1F2937"/>\n'
        '      </w:rPr>\n'
        '    </w:rPrDefault>\n'
        '  </w:docDefaults>\n'
        '  <w:style w:type="paragraph" w:styleId="Heading1">\n'
        '    <w:name w:val="heading 1"/>\n'
        '    <w:rPr>\n'
        '      <w:b/><w:sz w:val="34"/><w:color w:val="1B365D"/>\n'
        '    </w:rPr>\n'
        '  </w:style>\n'
        '  <w:style w:type="paragraph" w:styleId="Heading2">\n'
        '    <w:name w:val="heading 2"/>\n'
        '    <w:rPr>\n'
        '      <w:b/><w:sz w:val="28"/><w:color w:val="1B365D"/>\n'
        '    </w:rPr>\n'
        '  </w:style>\n'
        '  <w:style w:type="paragraph" w:styleId="Heading3">\n'
        '    <w:name w:val="heading 3"/>\n'
        '    <w:rPr>\n'
        '      <w:b/><w:sz w:val="26"/><w:color w:val="2C3E50"/>\n'
        '    </w:rPr>\n'
        '  </w:style>\n'
        '</w:styles>'
    )

    with zipfile.ZipFile(docx_path, 'w', zipfile.ZIP_DEFLATED) as z:
        z.writestr('[Content_Types].xml', content_types_str)
        z.writestr('_rels/.rels', rels_str)
        z.writestr('word/_rels/document.xml.rels', doc_rels_str)
        z.writestr('word/styles.xml', styles_str)
        z.writestr('word/document.xml', doc_xml_str)

    print(f"[SUCCESS] Đã tạo file DOCX: {docx_path}")

def create_doc_html(md_path, doc_path):
    """Tạo file .doc dạng Word-HTML tương thích tuyệt đối mọi phiên bản Word từ 2003 đến 365"""
    with open(md_path, 'r', encoding='utf-8') as f:
        md_text = f.read()

    # Chuyển đổi markdown cơ bản sang HTML đẹp
    lines = md_text.splitlines()
    html_lines = []
    in_code = False
    in_table = False
    table_rows = []

    def flush_table_html():
        nonlocal in_table, table_rows
        if table_rows:
            html_lines.append('<table border="1" cellpadding="8" cellspacing="0" style="border-collapse:collapse; width:100%; margin: 15px 0; border: 1px solid #CBD5E1;">')
            for i, r in enumerate(table_rows):
                if i == 0:
                    html_lines.append('<tr style="background-color: #1B365D; color: #FFFFFF; font-weight: bold; text-align: left;">')
                    for c in r:
                        html_lines.append(f'<th>{html.escape(c.strip())}</th>')
                    html_lines.append('</tr>')
                else:
                    bg = '#F8FAFC' if i % 2 == 1 else '#FFFFFF'
                    html_lines.append(f'<tr style="background-color: {bg};">')
                    for c in r:
                        html_lines.append(f'<td>{html.escape(c.strip())}</td>')
                    html_lines.append('</tr>')
            html_lines.append('</table>')
            table_rows = []
        in_table = False

    for line in lines:
        if line.startswith('```'):
            if in_code:
                html_lines.append('</pre>')
                in_code = False
            else:
                if in_table:
                    flush_table_html()
                html_lines.append('<pre style="background: #F1F5F9; border-left: 4px solid #1B365D; padding: 10px 14px; font-family: Consolas, monospace; font-size: 10.5pt; color: #0F172A; white-space: pre-wrap;">')
                in_code = True
            continue

        if in_code:
            html_lines.append(html.escape(line))
            continue

        if line.strip().startswith('|') and line.strip().endswith('|'):
            if re.match(r'^[\|\s\-\:]+$', line.strip()):
                continue
            cols = [c.strip() for c in line.strip().split('|')[1:-1]]
            table_rows.append(cols)
            in_table = True
            continue
        elif in_table:
            flush_table_html()

        if line.strip() in ['---', '***']:
            html_lines.append('<hr style="border: 0; border-top: 1px solid #CBD5E1; margin: 20px 0;"/>')
            continue

        if line.startswith('# '):
            html_lines.append(f'<h1 style="color: #1B365D; text-align: center; font-size: 18pt; margin-top: 24px; margin-bottom: 16px; text-transform: uppercase;">{html.escape(line[2:].strip())}</h1>')
            continue

        if line.startswith('## '):
            html_lines.append(f'<h2 style="color: #1B365D; font-size: 14pt; border-bottom: 2px solid #1B365D; padding-bottom: 4px; margin-top: 20px; margin-bottom: 12px;">{html.escape(line[3:].strip())}</h2>')
            continue

        if line.startswith('### '):
            html_lines.append(f'<h3 style="color: #2C3E50; font-size: 13pt; margin-top: 16px; margin-bottom: 8px;">{html.escape(line[4:].strip())}</h3>')
            continue

        if line.strip().startswith('* ') or line.strip().startswith('- '):
            item_text = line.strip()[2:]
            # formatting bold
            item_text = re.sub(r'\*\*(.*?)\*\*', r'<b>\1</b>', item_text)
            item_text = re.sub(r'`(.*?)`', r'<code style="background:#F1F5F9; color:#C7254E; padding: 2px 4px; border-radius:3px;">\1</code>', item_text)
            item_text = re.sub(r'\[(.*?)\]\((.*?)\)', r'\1', item_text)
            html_lines.append(f'<p style="margin: 4px 0 4px 24px; text-indent: -12px;">• {item_text}</p>')
            continue

        num_match = re.match(r'^\s*(\d+)\.\s+(.*)$', line)
        if num_match:
            item_text = num_match.group(2)
            item_text = re.sub(r'\*\*(.*?)\*\*', r'<b>\1</b>', item_text)
            item_text = re.sub(r'`(.*?)`', r'<code style="background:#F1F5F9; color:#C7254E; padding: 2px 4px; border-radius:3px;">\1</code>', item_text)
            item_text = re.sub(r'\[(.*?)\]\((.*?)\)', r'\1', item_text)
            html_lines.append(f'<p style="margin: 6px 0 6px 24px; text-indent: -18px;"><b>{num_match.group(1)}.</b> {item_text}</p>')
            continue

        if line.strip():
            p_text = line.strip()
            p_text = re.sub(r'\*\*(.*?)\*\*', r'<b>\1</b>', p_text)
            p_text = re.sub(r'`(.*?)`', r'<code style="background:#F1F5F9; color:#C7254E; padding: 2px 4px; border-radius:3px;">\1</code>', p_text)
            p_text = re.sub(r'\[(.*?)\]\((.*?)\)', r'\1', p_text)
            html_lines.append(f'<p style="margin: 6px 0; text-align: justify; line-height: 1.35;">{p_text}</p>')

    if in_table:
        flush_table_html()
    if in_code:
        html_lines.append('</pre>')

    doc_content = f"""<html xmlns:o='urn:schemas-microsoft-com:office:office' xmlns:w='urn:schemas-microsoft-com:office:word' xmlns='http://www.w3.org/TR/REC-html40'>
<head>
<meta charset='utf-8'>
<title>Báo Cáo Tiến Độ Đồ Án - Tuần 01</title>
<!--[if gte mso 9]>
<xml>
<w:WordDocument>
<w:View>Print</w:View>
<w:Zoom>100</w:Zoom>
<w:DoNotOptimizeForBrowser/>
</w:WordDocument>
</xml>
<![endif]-->
<style>
body {{
    font-family: 'Times New Roman', Times, serif;
    font-size: 13pt;
    line-height: 1.35;
    color: #1F2937;
    margin: 40px;
}}
p, li {{
    font-size: 13pt;
}}
</style>
</head>
<body>
{"".join(html_lines)}
</body>
</html>"""

    with open(doc_path, 'w', encoding='utf-8') as f:
        f.write(doc_content)
    print(f"[SUCCESS] Đã tạo file DOC: {doc_path}")

if __name__ == '__main__':
    base_dir = os.path.dirname(os.path.abspath(__file__))
    reports = ['BAO_CAO_TUAN_1', 'BAO_CAO_TUAN_2', 'BAO_CAO_TUAN_3', 'TONG_QUAN_TIEN_DO']

    for r in reports:
        md_file = os.path.join(base_dir, f'{r}.md')
        docx_file = os.path.join(base_dir, f'{r}.docx')
        doc_file = os.path.join(base_dir, f'{r}.doc')
        if os.path.exists(md_file):
            create_docx(md_file, docx_file)
            create_doc_html(md_file, doc_file)

