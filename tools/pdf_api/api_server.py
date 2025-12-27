from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import sys
from pathlib import Path
import tempfile
import os
import traceback

# Resolve project-root-local parser
CURRENT_DIR = Path(__file__).parent
PROJECT_ROOT = CURRENT_DIR.parents[2] if len(CURRENT_DIR.parents) >= 2 else CURRENT_DIR

# Insert paths so `schedule_parser.py` (or a package) beside this file can be imported
sys.path.insert(0, str(CURRENT_DIR))

try:
    from schedule_parser import ScheduleParser  # type: ignore
except Exception:
    # As a fallback, also try a nested "parser" dir
    parser_dir = CURRENT_DIR / "parser"
    if parser_dir.exists():
        sys.path.insert(0, str(parser_dir))
        try:
            from schedule_parser import ScheduleParser  # type: ignore
        except Exception as e:
            print("ERROR: Could not import schedule_parser from", parser_dir, e)
            ScheduleParser = None  # type: ignore
    else:
        print("WARNING: schedule_parser.py not found. Place it under:")
        print(f" - {CURRENT_DIR}/schedule_parser.py")
        print(f" - or {CURRENT_DIR}/parser/schedule_parser.py")
        ScheduleParser = None  # type: ignore

app = FastAPI()

# CORS for Flutter app (web/desktop/mobile)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root():
    return {"message": "PDF Schedule Parser API is running!", "status": "ok"}

@app.post("/parse-pdf")
async def parse_pdf(file: UploadFile = File(...)):
    if ScheduleParser is None:
        return JSONResponse(status_code=500, content={
            "error": "schedule_parser not available. Place schedule_parser.py next to api_server.py",
            "courses": []
        })

    tmp_path = None
    try:
        # Save upload to a temp file
        with tempfile.NamedTemporaryFile(delete=False, suffix=".pdf") as tmp_file:
            tmp_path = tmp_file.name
            content = await file.read()
            tmp_file.write(content)

        parser = ScheduleParser()
        courses = parser.parse_pdf(tmp_path)

        if not courses:
            return JSONResponse(status_code=400, content={
                "error": "No courses found in the PDF",
                "courses": []
            })

        return {"courses": courses, "count": len(courses)}
    except Exception as e:
        tb = traceback.format_exc()
        # Log server-side for quick diagnosis
        print("\n--- Parse Error ---")
        print(str(e))
        print(tb)
        print("--- End Parse Error ---\n")
        return JSONResponse(status_code=500, content={
            "error": str(e),
            "trace": tb,
            "courses": []
        })
    finally:
        if tmp_path and os.path.exists(tmp_path):
            try:
                os.unlink(tmp_path)
            except Exception:
                pass

@app.get("/health")
async def health():
    return {"status": "healthy"}

if __name__ == "__main__":
    import uvicorn
    print("Starting PDF Parser API server...")
    print("The server will run on http://localhost:8000")
    print("You can access the API docs at http://localhost:8000/docs")
    uvicorn.run(app, host="0.0.0.0", port=8000, log_level="info")


