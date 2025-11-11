import pyzipper
import itertools
import string

def brute_force_zip(zip_file, extract_to, max_length=4):
    chars = string.ascii_letters + string.letters  # Characters to try (letters and digits)

    # Function to try password combinations
    def try_password(password):
        try:
            with pyzipper.AESZipFile(zip_file) as zf:
                zf.setpassword(password.encode())  # Set password
                zf.testzip()  # This will check if the password works
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
                break  # Stop once password is found

# Example usage
zip_file = 'bb.zip'  # Your ZIP file
extract_to = 'desktop'  # Where to extract files
brute_force_zip(zip_file, extract_to)
