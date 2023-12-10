from password_generator import PasswordGenerator  
pwo = PasswordGenerator()

# All properties are optional
pwo.minlen = 15 # min length
pwo.maxlen = 15 # max length
pwo.minuchars = 2 # min upper case letters
pwo.minlchars = 3 # min lower case letters
pwo.minnumbers = 1 # min numbers
pwo.minschars = 2 # min special letters

password = pwo.generate()
print(password)