import itertools
import string
import pyzipper

# Adjust the character set to include digits and numbers
chars = string.digits + string.digits  # Letters (both uppercase and lowercase) + digits

def brute_force_zip(zip_file, extract_to, max_length=3):
    # Function to try password combinations
    def try_password(password):
        try:
            with pyzipper.AESZipFile(zip_file) as zf:
                zf.setpassword(password.encode())  # Set password
                zf.testzip()  # Test the password to see if it's correct
                print(f"Password found: {password}")
                zf.extractall(extract_to)  # Extract files to the specified directory
                return True
        except RuntimeError:
            return False

    # Brute-force all possible password combinations of the given length
    for length in range(1, max_length + 1):
        for password_tuple in itertools.product(chars, repeat=length):
            password = ''.join(password_tuple)
            print(f"Trying password: {password}")
            if try_password(password):
                break  # Stop once the correct password is found

# Example usage
zip_file = 'adv.zip'  # Your ZIP file
extract_to = 'Desktop'  # Where to extract files
brute_force_zip(zip_file, extract_to)

    
