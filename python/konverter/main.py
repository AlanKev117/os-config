import io
import os
from fastapi import FastAPI, UploadFile, Request, Form
from fastapi.responses import HTMLResponse, StreamingResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from PIL import Image
import pillow_avif
from pillow_heif import register_heif_opener
import fitz
from typing import Annotated

app = FastAPI()

app.mount("/static", StaticFiles(directory="static"), name="static")
templates = Jinja2Templates(directory="templates")

register_heif_opener()

@app.get("/", response_class=HTMLResponse)
async def read_root(request: Request):
    return templates.TemplateResponse("index.html", {"request": request})

@app.post("/convert/")
async def convert_file(file: Annotated[UploadFile, Form()], output_format: Annotated[str, Form()]):
    # Lee el contenido del archivo subido en memoria
    contents = await file.read()
    output_buffer = io.BytesIO()

    # Determina si el archivo de entrada es un PDF
    is_input_pdf = file.content_type == "application/pdf" or file.filename.lower().endswith(".pdf")
    
    # --- LÓGICA DE CONVERSIÓN ---

    if is_input_pdf:
        # Escenario 1: PDF a IMAGEN
        if output_format.lower() != 'pdf':
            pdf_doc = fitz.open(stream=contents, filetype="pdf")
            # Convierte solo la primera página del PDF
            page = pdf_doc.load_page(0)
            pix = page.get_pixmap(dpi=300)
            img = Image.frombytes("RGB", [pix.width, pix.height], pix.samples)
            img.save(output_buffer, format=output_format.upper())
        # Escenario 2: PDF a PDF (devuelve el original)
        else:
            output_buffer.write(contents)
    else:
        # Abre el archivo como una imagen
        img = Image.open(io.BytesIO(contents))
        
        # Escenario 3: IMAGEN a PDF
        if output_format.lower() == 'pdf':
            # El formato PDF no soporta transparencia, convierte a RGB
            if img.mode == 'RGBA':
                img = img.convert('RGB')
            img.save(output_buffer, format="PDF")
        # Escenario 4: IMAGEN a IMAGEN (lógica original)
        else:
            # Caso especial para JPG
            if output_format.lower() == 'jpeg' and img.mode == 'RGBA':
                img = img.convert('RGB')
            img.save(output_buffer, format=output_format.upper())

    output_buffer.seek(0)
    
    # --- PREPARACIÓN DE LA RESPUESTA ---

    # Construye el nuevo nombre de archivo
    filename_without_ext, _ = os.path.splitext(file.filename)
    new_filename = f"{filename_without_ext}.{output_format.lower()}"
    
    # Determina el tipo de medio (MIME type)
    media_type = f"application/{output_format.lower()}" if output_format.lower() == 'pdf' else f"image/{output_format.lower()}"
    
    return StreamingResponse(output_buffer, media_type=media_type, headers={
        "Content-Disposition": f"attachment; filename=\"{new_filename}\""
    })