import click
from password_generator import PasswordGenerator  

pwo = PasswordGenerator()

# Default values
DEFAULT_LENGTH = 15 # min length
DEFAULT_UPPERS = 2 # min upper case letters
DEFAULT_LOWERS = 3 # min lower case letters
DEFAULT_NUMBERS = 2 # min numbers
DEFAULT_SPECIALS = 2 # min special letters

@click.command()
@click.option("-n", "--length", type=int, default=DEFAULT_LENGTH, prompt=f'Password length', help='The length of the pasword.')
@click.option("-u", "--uppers", type=int, default=DEFAULT_UPPERS, prompt=f'Uppercase letters', help='The amount of uppercase letters.')
@click.option("-l", "--lowers", type=int, default=DEFAULT_LOWERS, prompt=f'Lowercase letters', help='The amount of lowercase letters.')
@click.option("-k", "--numbers", type=int, default=DEFAULT_NUMBERS, prompt=f'Numbers', help='The amount of numerical characters.')
@click.option("-s", "--specials", type=int, default=DEFAULT_SPECIALS, prompt=f'Special characters', help='The amount of special characters.')
def pwgen(length, uppers, lowers, numbers, specials):
    # All properties are optional
    pwo.minlen = length # min length
    pwo.maxlen = length # max length
    pwo.minuchars = uppers # min upper case letters
    pwo.minlchars = lowers # min lower case letters
    pwo.minnumbers = numbers # min numbers
    pwo.minschars = specials # min special letters
    password = pwo.generate()
    click.echo(password)

if __name__ == '__main__':
    pwgen()