#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Banner
show_banner() {
    clear
    echo -e "${CYAN}"
    echo "   ____  _  _  ____  ____  _  _  ____  _____ "
    echo "  (_  _)( \\/ )(_  _)(_  _)( \\/ )( ___)(  _  )"
    echo "    )(   \\  /   )(   _)(_  \\  /  )__)  )(_)( "
    echo "   (__)  (__)  (__) (____) (__) (____)(_____)"
    echo -e "${NC}"
    echo -e "${YELLOW}          ZIP File Brute Force Tool$
                                            Made by Glitch{NC}"
    echo -e "${YELLOW}           Interactive Version${NC}"
    echo ""
}

# Function to check dependencies
check_dependencies() {
    echo -e "${YELLOW}[*] Checking dependencies...${NC}"
    
    local deps=("python3" "pip3")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            echo -e "${RED}[-] Error: $dep is not installed${NC}"
            exit 1
        fi
    done
    
    # Check if pyzipper is installed
    python3 -c "import pyzipper" 2>/dev/null
    if [ $? -ne 0 ]; then
        echo -e "${YELLOW}[*] Installing pyzipper...${NC}"
        pip3 install pyzipper
        if [ $? -ne 0 ]; then
            echo -e "${RED}[-] Error: Failed to install pyzipper${NC}"
            exit 1
        fi
        echo -e "${GREEN}[+] pyzipper installed successfully${NC}"
    else
        echo -e "${GREEN}[+] pyzipper is already installed${NC}"
    fi
    echo ""
}

# Function to select ZIP file
select_zip_file() {
    while true; do
        echo -e "${CYAN}[?] Select ZIP file:${NC}"
        echo "1. Enter path manually"
        echo "2. Browse current directory"
        echo "3. Exit"
        echo ""
        read -p "Choose option [1-3]: " file_choice

        case $file_choice in
            1)
                echo ""
                read -p "Enter full path to ZIP file: " zip_file
                if [ -f "$zip_file" ]; then
                    ZIP_FILE="$zip_file"
                    echo -e "${GREEN}[+] Selected file: $ZIP_FILE${NC}"
                    break
                else
                    echo -e "${RED}[-] File not found: $zip_file${NC}"
                    echo ""
                fi
                ;;
            2)
                echo ""
                echo -e "${YELLOW}[*] ZIP files in current directory:${NC}"
                ls -la *.zip 2>/dev/null || echo "No ZIP files found in current directory"
                echo ""
                read -p "Enter ZIP filename: " zip_file
                if [ -f "$zip_file" ]; then
                    ZIP_FILE="$zip_file"
                    echo -e "${GREEN}[+] Selected file: $ZIP_FILE${NC}"
                    break
                else
                    echo -e "${RED}[-] File not found: $zip_file${NC}"
                    echo ""
                fi
                ;;
            3)
                echo -e "${YELLOW}[*] Goodbye!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}[-] Invalid option${NC}"
                echo ""
                ;;
        esac
    done
    echo ""
}

# Function to select attack type
select_attack_type() {
    while true; do
        echo -e "${CYAN}[?] Select brute force type:${NC}"
        echo "1. Letters only (a-z, A-Z)"
        echo "2. Numbers only (0-9)"
        echo "3. Both letters and numbers"
        echo "4. Back to main menu"
        echo ""
        read -p "Choose option [1-4]: " attack_choice

        case $attack_choice in
            1)
                BRUTE_TYPE="letters"
                echo -e "${GREEN}[+] Selected: Letters only${NC}"
                break
                ;;
            2)
                BRUTE_TYPE="numbers"
                echo -e "${GREEN}[+] Selected: Numbers only${NC}"
                break
                ;;
            3)
                BRUTE_TYPE="both"
                echo -e "${GREEN}[+] Selected: Letters and numbers${NC}"
                break
                ;;
            4)
                return 1
                ;;
            *)
                echo -e "${RED}[-] Invalid option${NC}"
                echo ""
                ;;
        esac
    done
    echo ""
}

# Function to set max password length
set_max_length() {
    while true; do
        echo -e "${CYAN}[?] Set maximum password length:${NC}"
        read -p "Enter length (1-8, recommended 3-4): " max_len
        
        if [[ "$max_len" =~ ^[1-8]$ ]]; then
            MAX_LENGTH=$max_len
            echo -e "${GREEN}[+] Max length set to: $MAX_LENGTH${NC}"
            break
        else
            echo -e "${RED}[-] Please enter a number between 1 and 8${NC}"
            echo ""
        fi
    done
    echo ""
}

# Function to set output directory
set_output_dir() {
    echo -e "${CYAN}[?] Set output directory:${NC}"
    read -p "Enter directory (default: ./extracted): " output_dir
    OUTPUT_DIR=${output_dir:-"./extracted"}
    mkdir -p "$OUTPUT_DIR"
    echo -e "${GREEN}[+] Output directory: $OUTPUT_DIR${NC}"
    echo ""
}

# Function to create Python script
create_python_script() {
    local script_type=$1
    local python_script=$(mktemp)
    
    case $script_type in
        "letters")
            cat > "$python_script" << 'EOF'
import pyzipper
import itertools
import string
import sys

def brute_force_zip(zip_file, extract_to, max_length=4):
    chars = string.ascii_letters  # Only letters

    def try_password(password):
        try:
            with pyzipper.AESZipFile(zip_file) as zf:
                zf.setpassword(password.encode())
                zf.testzip()
                print(f"SUCCESS: Password found: {password}")
                zf.extractall(extract_to)
                return True
        except Exception:
            return False

    print(f"Starting brute force with letters only (max length: {max_length})")
    total_attempts = sum(len(chars) ** length for length in range(1, max_length + 1))
    print(f"Total possible passwords: {total_attempts}")
    print("=" * 50)
    
    attempts = 0
    for length in range(1, max_length + 1):
        print(f"Trying passwords of length {length}...")
        for password_tuple in itertools.product(chars, repeat=length):
            password = ''.join(password_tuple)
            attempts += 1
            if attempts % 1000 == 0:
                print(f"Attempts: {attempts}/{total_attempts}")
            if try_password(password):
                return password
    return None

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python_script zip_file extract_to max_length")
        sys.exit(1)
    
    zip_file = sys.argv[1]
    extract_to = sys.argv[2]
    max_length = int(sys.argv[3])
    
    result = brute_force_zip(zip_file, extract_to, max_length)
    if result:
        print(f"PASSWORD_FOUND:{result}")
    else:
        print("PASSWORD_NOT_FOUND")
EOF
            ;;
        "numbers")
            cat > "$python_script" << 'EOF'
import pyzipper
import itertools
import string
import sys

def brute_force_zip(zip_file, extract_to, max_length=4):
    chars = string.digits  # Only numbers

    def try_password(password):
        try:
            with pyzipper.AESZipFile(zip_file) as zf:
                zf.setpassword(password.encode())
                zf.testzip()
                print(f"SUCCESS: Password found: {password}")
                zf.extractall(extract_to)
                return True
        except Exception:
            return False

    print(f"Starting brute force with numbers only (max length: {max_length})")
    total_attempts = sum(len(chars) ** length for length in range(1, max_length + 1))
    print(f"Total possible passwords: {total_attempts}")
    print("=" * 50)
    
    attempts = 0
    for length in range(1, max_length + 1):
        print(f"Trying passwords of length {length}...")
        for password_tuple in itertools.product(chars, repeat=length):
            password = ''.join(password_tuple)
            attempts += 1
            if attempts % 100 == 0:
                print(f"Attempts: {attempts}/{total_attempts}")
            if try_password(password):
                return password
    return None

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python_script zip_file extract_to max_length")
        sys.exit(1)
    
    zip_file = sys.argv[1]
    extract_to = sys.argv[2]
    max_length = int(sys.argv[3])
    
    result = brute_force_zip(zip_file, extract_to, max_length)
    if result:
        print(f"PASSWORD_FOUND:{result}")
    else:
        print("PASSWORD_NOT_FOUND")
EOF
            ;;
        "both")
            cat > "$python_script" << 'EOF'
import pyzipper
import itertools
import string
import sys

def brute_force_zip(zip_file, extract_to, max_length=4):
    chars = string.ascii_letters + string.digits  # Letters and numbers

    def try_password(password):
        try:
            with pyzipper.AESZipFile(zip_file) as zf:
                zf.setpassword(password.encode())
                zf.testzip()
                print(f"SUCCESS: Password found: {password}")
                zf.extractall(extract_to)
                return True
        except Exception:
            return False

    print(f"Starting brute force with letters and numbers (max length: {max_length})")
    total_attempts = sum(len(chars) ** length for length in range(1, max_length + 1))
    print(f"Total possible passwords: {total_attempts}")
    print("=" * 50)
    
    attempts = 0
    for length in range(1, max_length + 1):
        print(f"Trying passwords of length {length}...")
        for password_tuple in itertools.product(chars, repeat=length):
            password = ''.join(password_tuple)
            attempts += 1
            if attempts % 1000 == 0:
                print(f"Attempts: {attempts}/{total_attempts}")
            if try_password(password):
                return password
    return None

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python_script zip_file extract_to max_length")
        sys.exit(1)
    
    zip_file = sys.argv[1]
    extract_to = sys.argv[2]
    max_length = int(sys.argv[3])
    
    result = brute_force_zip(zip_file, extract_to, max_length)
    if result:
        print(f"PASSWORD_FOUND:{result}")
    else:
        print("PASSWORD_NOT_FOUND")
EOF
            ;;
    esac
    
    echo "$python_script"
}

# Function to start brute force attack
start_attack() {
    echo -e "${YELLOW}[*] Starting brute force attack...${NC}"
    echo -e "${BLUE}[*] Press Ctrl+C to stop the attack${NC}"
    echo ""
    
    # Create and run the appropriate Python script
    PYTHON_SCRIPT=$(create_python_script "$BRUTE_TYPE")
    
    start_time=$(date +%s)
    
    # Run the Python script
    python3 "$PYTHON_SCRIPT" "$ZIP_FILE" "$OUTPUT_DIR" "$MAX_LENGTH" 2>&1 | while IFS= read -r line; do
        if [[ "$line" == "PASSWORD_FOUND:"* ]]; then
            password="${line#PASSWORD_FOUND:}"
            echo -e "${GREEN}"
            echo "=========================================="
            echo "🎉 PASSWORD FOUND: $password"
            echo "=========================================="
            echo -e "${NC}"
        elif [[ "$line" == "PASSWORD_NOT_FOUND" ]]; then
            echo -e "${RED}"
            echo "=========================================="
            echo "❌ Password not found with current settings"
            echo "Try increasing max length or changing type"
            echo "=========================================="
            echo -e "${NC}"
        elif [[ "$line" == "SUCCESS:"* ]]; then
            echo -e "${GREEN}$line${NC}"
        else
            echo "$line"
        fi
    done
    
    end_time=$(date +%s)
    duration=$((end_time - start_time))
    
    echo ""
    echo -e "${YELLOW}[*] Attack completed in $duration seconds${NC}"
    
    # Clean up
    rm -f "$PYTHON_SCRIPT"
    
    # Check if files were extracted
    if [ "$(ls -A "$OUTPUT_DIR" 2>/dev/null)" ]; then
        echo -e "${GREEN}[+] Files extracted to: $OUTPUT_DIR${NC}"
        echo -e "${GREEN}[+] Contents:${NC}"
        ls -la "$OUTPUT_DIR"
    else
        echo -e "${YELLOW}[!] No files extracted - password not found or extraction failed${NC}"
    fi
    
    echo ""
    read -p "Press Enter to continue..."
}

# Main menu
main_menu() {
    while true; do
        show_banner
        
        echo -e "${CYAN}=== MAIN MENU ===${NC}"
        echo "1. Select ZIP file"
        echo "2. Select attack type"
        echo "3. Set max password length"
        echo "4. Set output directory"
        echo "5. Start attack"
        echo "6. Show current settings"
        echo "7. Exit"
        echo ""
        
        if [ -n "$ZIP_FILE" ]; then
            echo -e "${GREEN}Current file: $ZIP_FILE${NC}"
        else
            echo -e "${RED}No file selected${NC}"
        fi
        
        if [ -n "$BRUTE_TYPE" ]; then
            echo -e "${GREEN}Attack type: $BRUTE_TYPE${NC}"
        else
            echo -e "${RED}No attack type selected${NC}"
        fi
        
        if [ -n "$MAX_LENGTH" ]; then
            echo -e "${GREEN}Max length: $MAX_LENGTH${NC}"
        else
            echo -e "${RED}Max length not set${NC}"
        fi
        
        if [ -n "$OUTPUT_DIR" ]; then
            echo -e "${GREEN}Output dir: $OUTPUT_DIR${NC}"
        else
            echo -e "${RED}Output dir not set${NC}"
        fi
        echo ""
        
        read -p "Choose option [1-7]: " main_choice

        case $main_choice in
            1)
                select_zip_file
                ;;
            2)
                select_attack_type
                ;;
            3)
                set_max_length
                ;;
            4)
                set_output_dir
                ;;
            5)
                if [ -z "$ZIP_FILE" ]; then
                    echo -e "${RED}[-] Please select a ZIP file first${NC}"
                    read -p "Press Enter to continue..."
                elif [ -z "$BRUTE_TYPE" ]; then
                    echo -e "${RED}[-] Please select an attack type first${NC}"
                    read -p "Press Enter to continue..."
                else
                    start_attack
                fi
                ;;
            6)
                echo ""
                echo -e "${CYAN}=== CURRENT SETTINGS ===${NC}"
                echo -e "ZIP File: ${GREEN}${ZIP_FILE:-Not set}${NC}"
                echo -e "Attack Type: ${GREEN}${BRUTE_TYPE:-Not set}${NC}"
                echo -e "Max Length: ${GREEN}${MAX_LENGTH:-Not set}${NC}"
                echo -e "Output Directory: ${GREEN}${OUTPUT_DIR:-Not set}${NC}"
                echo ""
                read -p "Press Enter to continue..."
                ;;
            7)
                echo -e "${YELLOW}[*] Goodbye!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}[-] Invalid option${NC}"
                read -p "Press Enter to continue..."
                ;;
        esac
    done
}

# Initialize default values
ZIP_FILE=""
BRUTE_TYPE=""
MAX_LENGTH=""
OUTPUT_DIR="./extracted"

# Start the application
show_banner
check_dependencies
main_menu
