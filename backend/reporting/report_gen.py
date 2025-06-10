from jinja2 import Environment, FileSystemLoader
import pdfkit

def generate_pdf(report_data, filename="rapport.pdf"):
    env = Environment(loader=FileSystemLoader('backend/reporting/templates'))
    template = env.get_template('nmap_report.html')
    html_out = template.render(report_data)
    pdfkit.from_string(html_out, filename)
    return filename
