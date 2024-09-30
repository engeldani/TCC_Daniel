from simon import SimonCipher

def simon_encrypt(key, plaintext):
    # Inicializando o Simon com chave de 128 bits
    simon = SimonCipher(key, block_size=128, key_size=128)
    
    # Criptografando o texto
    ciphertext = simon.encrypt(plaintext)
    
    # Convertendo para hexadecimal para comparação
    return hex(ciphertext)

if __name__ == "__main__":
    # Teste com vários valores de chave e texto
    test_cases = [
        (0x74636364616e69656c31322f32303234, 0x74636364616e69656c31322f32303234),
        (0x70726a64616e69656c30362f32303234, 0x70726a64616e69656c30362f32303234)
    ]
    
    for key, plaintext in test_cases:
        ciphertext = simon_encrypt(key, plaintext)
        print(f"Chave: {hex(key)}, Texto: {hex(plaintext)}, Saída Criptografada: {ciphertext}")
