
# Implementação manual do algoritmo Simon para permitir o rastreamento das chaves de rodada (K), X e Y
# Baseado no algoritmo SIMON para chave de 128 bits e bloco de 128 bits

def simon_round(X, Y, K):
    # Funções auxiliares de rotação
    def rotate_left(x, n, bits=64):
        return ((x << n) & ((1 << bits) - 1)) | (x >> (bits - n))

    def rotate_right(x, n, bits=64):
        return (x >> n) | ((x << (bits - n)) & ((1 << bits) - 1))

    # Realizar uma única rodada de Simon
    tmp = X
    X = Y ^ (rotate_left(tmp, 1) & rotate_left(tmp, 8)) ^ rotate_left(tmp, 2) ^ K
    Y = tmp
    return X, Y

def simon_encrypt_manual(key, plaintext):
    # Inicializando as variáveis
    X = (plaintext >> 64) & 0xFFFFFFFFFFFFFFFF
    Y = plaintext & 0xFFFFFFFFFFFFFFFF
    keys = [key]  # Vamos gerar as chaves de rodada manualmente (apenas para uma chave de exemplo)

    # Rodadas de Simon (exemplo de 68 rodadas para Simon128/128)
    for i in range(68):
        K = keys[i % len(keys)]  # Usar a chave inicial (em vez de gerar novas chaves para cada rodada)
        print(f"Rodada {i + 1}: X = {hex(X)}, Y = {hex(Y)}, K = {hex(K)}")
        X, Y = simon_round(X, Y, K)

    # Unir X e Y de volta para gerar o texto cifrado
    ciphertext = (X << 64) | Y
    return ciphertext

# Testando com o caso de teste fornecido
test_key = 0x74636364616e69656c31322f32303234
test_plaintext = 0x74636364616e69656c31322f32303234

ciphertext = simon_encrypt_manual(test_key, test_plaintext)
print(f"Ciphertext final: {hex(ciphertext)}")
