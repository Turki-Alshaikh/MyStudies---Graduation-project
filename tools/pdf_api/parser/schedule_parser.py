import pdfplumber
import json
import re
from typing import List, Dict, Any, Optional


class ScheduleParser:
    def __init__(self):
        # Column indices based on the actual table structure
        self.COURSE_CODE_INDEX = 0
        self.COURSE_NAME_INDEX = 1
        self.CR_INDEX = 2  # Credits
        self.CT_INDEX = 3  # Contact Hours
        self.ACTIVITY_INDEX = 6
        self.SEC_INDEX = 4
        self.STAFF_INDEX = 14
        self.BUILDING_INDEX = 12
        self.ROOM_INDEX = 13
        
        # Schedule day indices (Sun, Mon, Tue, Wed, Thu)
        self.DAY_INDICES = {
            'Sun': 7,
            'Mon': 8,
            'Tue': 9,
            'Wed': 10,
            'Thu': 11
        }
        
        # Day order for processing
        self.DAY_ORDER = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu']

    def clean_text(self, text: str) -> str:
        """Clean and normalize text by removing extra spaces and newlines."""
        if not text:
            return ""
        return re.sub(r'\s+', ' ', str(text).strip())

    def is_valid_course_row(self, row: List[str]) -> bool:
        """Check if a row contains valid course data."""
        if not row or len(row) < 15:
            return False
        
        course_code = self.clean_text(row[self.COURSE_CODE_INDEX])
        
        # Skip empty course codes and total rows
        if not course_code or course_code.lower() == "total":
            return False
        
        return True

    def extract_periods(self, period_text: str) -> List[str]:
        """Extract individual periods from a period string."""
        if not period_text:
            return []
        
        # Clean the text and split by comma
        cleaned = self.clean_text(period_text)
        if not cleaned:
            return []
        
        # Split by comma and clean each period
        periods = [p.strip() for p in cleaned.split(',') if p.strip()]
        return periods

    def handle_blackboard(self, building: str, room: str) -> tuple:
        """Handle Blackboard building/room special case."""
        if building and "blackboard" in building.lower():
            return "Blackboard", "Blackboard"
        return building, room

    def extract_schedule(self, row: List[str]) -> List[Dict[str, str]]:
        """Extract schedule information from a table row."""
        schedule = []
        
        for day in self.DAY_ORDER:
            day_index = self.DAY_INDICES[day]
            if day_index < len(row):
                period_text = row[day_index]
                periods = self.extract_periods(period_text)
                
                for period in periods:
                    schedule.append({
                        "day": day,
                        "period": period
                    })
        
        return schedule

    def parse_course_row(self, row: List[str]) -> Optional[Dict[str, Any]]:
        """Parse a single course row into a structured object."""
        if not self.is_valid_course_row(row):
            return None
        
        try:
            # Extract basic course information
            course_code = self.clean_text(row[self.COURSE_CODE_INDEX])
            course_name = self.clean_text(row[self.COURSE_NAME_INDEX])
            cr = self.clean_text(row[self.CR_INDEX])  # Credits
            ct = self.clean_text(row[self.CT_INDEX])  # Contact Hours
            activity = self.clean_text(row[self.ACTIVITY_INDEX])
            sec = self.clean_text(row[self.SEC_INDEX])
            staff = self.clean_text(row[self.STAFF_INDEX])
            building = self.clean_text(row[self.BUILDING_INDEX])
            room = self.clean_text(row[self.ROOM_INDEX])
            
            # Handle Blackboard special case
            building, room = self.handle_blackboard(building, room)
            
            # Extract schedule
            schedule = self.extract_schedule(row)
            
            # Validate required fields (building and room can be empty for some courses)
            if not all([course_code, course_name, activity, sec, staff]):
                return None
            
            # Handle empty building/room by setting defaults
            if not building or building.strip() == "":
                building = "TBD"  # To Be Determined
            if not room or room.strip() == "" or room.strip() == ",":
                room = "TBD"  # To Be Determined
            
            return {
                "course_code": course_code,
                "course_name": course_name,
                "credits": cr if cr else "0",
                "contact_hours": ct if ct else "0",
                "activity": activity,
                "sec": sec,
                "staff": staff,
                "building": building,
                "room": room,
                "schedule": schedule
            }
            
        except (IndexError, TypeError) as e:
            print(f"Error parsing row: {e}")
            return None

    def find_table_header(self, table: List[List[str]]) -> Optional[int]:
        """Find the header row index that contains 'Course Code'."""
        for i, row in enumerate(table):
            if row and len(row) > 0:
                first_cell = self.clean_text(row[0])
                if first_cell == "Course Code":
                    return i
        return None

    def find_split_header(self, table: List[List[str]]) -> Optional[int]:
        """Find the header row index for split header structure."""
        for i, row in enumerate(table):
            if row and len(row) > 0:
                first_cell = self.clean_text(row[0])
                if first_cell == "Course Code":
                    # Check if next row has the sub-headers
                    if i + 1 < len(table) and table[i + 1]:
                        next_row = table[i + 1]
                        if len(next_row) > 4 and self.clean_text(next_row[4]) == "Sec":
                            return i
        return None

    def find_any_header(self, table: List[List[str]]) -> Optional[int]:
        """Find any header row that contains course-related information."""
        for i, row in enumerate(table):
            if row and len(row) > 0:
                first_cell = self.clean_text(row[0])
                if first_cell == "Course Code":
                    return i
                # Also check for course codes in the first column
                elif first_cell.startswith("CS "):
                    # This might be a data row, but let's check if it's actually a header
                    if i > 0 and table[i-1]:
                        prev_row = table[i-1]
                        if prev_row and len(prev_row) > 0:
                            prev_first = self.clean_text(prev_row[0])
                            if prev_first == "Course Code":
                                return i - 1
        return None

    def extract_courses_from_table(self, table: List[List[str]]) -> List[Dict[str, Any]]:
        """Extract course information from a table."""
        courses = []
        
        # Find the header row (try multiple approaches)
        header_index = self.find_table_header(table)
        if header_index is None:
            header_index = self.find_split_header(table)
            if header_index is not None:
                # For split header, skip the second header row
                header_index += 1
        
        if header_index is None:
            header_index = self.find_any_header(table)
        
        if header_index is None:
            print("Could not find table header with 'Course Code'")
            return courses
        
        # Process rows after the header
        for row in table[header_index + 1:]:
            course = self.parse_course_row(row)
            if course:
                courses.append(course)
        
        return courses

    def parse_pdf(self, pdf_path: str) -> List[Dict[str, Any]]:
        """Parse a PDF file and extract course schedule information."""
        all_courses = []
        
        try:
            with pdfplumber.open(pdf_path) as pdf:
                for page_num, page in enumerate(pdf.pages):
                    print(f"Processing page {page_num + 1}")
                    
                    # Extract tables from the page
                    tables = page.extract_tables()
                    
                    for table_num, table in enumerate(tables):
                        if not table:
                            continue
                        
                        print(f"  Processing table {table_num + 1} on page {page_num + 1}")
                        
                        # Extract courses from this table
                        courses = self.extract_courses_from_table(table)
                        all_courses.extend(courses)
                        
                        print(f"    Found {len(courses)} courses in table {table_num + 1}")
        
        except Exception as e:
            print(f"Error processing PDF {pdf_path}: {e}")
            return []
        
        print(f"Total courses extracted: {len(all_courses)}")
        return all_courses

    def save_to_json(self, courses: List[Dict[str, Any]], output_path: str):
        """Save extracted courses to a JSON file."""
        try:
            with open(output_path, 'w', encoding='utf-8') as f:
                json.dump(courses, f, indent=2, ensure_ascii=False)
            print(f"Successfully saved {len(courses)} courses to {output_path}")
        except Exception as e:
            print(f"Error saving to JSON: {e}")

    def parse_and_save(self, pdf_path: str, output_path: str):
        """Parse PDF and save results to JSON file."""
        courses = self.parse_pdf(pdf_path)
        if courses:
            self.save_to_json(courses, output_path)
        else:
            print("No courses found in the PDF")


def main():
    """Main function to demonstrate usage."""
    parser = ScheduleParser()
    
    # Example usage
    pdf_path = "/Users/asim/Downloads/Schedule.pdf"  # Replace with your PDF file path
    output_path = "schedule_output.json"
    
    print("PDF Schedule Parser")
    print("=" * 50)
    
    # Parse the PDF and save to JSON
    courses = parser.parse_pdf(pdf_path)
    if courses:
        parser.save_to_json(courses, output_path)
        print("\nSample extracted course:")
        print(json.dumps(courses[0], indent=2, ensure_ascii=False))
    else:
        print("No courses found in the PDF")


if __name__ == "__main__":
    main()
