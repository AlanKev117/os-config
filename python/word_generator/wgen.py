from random_word import RandomWords

def generate_random_meaningful_word():
    r = RandomWords()
    random_word = r.get_random_word()
    return random_word

if __name__ == "__main__":
    word = generate_random_meaningful_word()
    print(word)