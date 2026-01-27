#!/usr/bin/env python3
"""
Script alternativo para gerar chaves EdDSA usando Python
Use este script se o Sparkle tools não estiver disponível
"""

import os
import sys
from pathlib import Path

try:
    from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PrivateKey
    from cryptography.hazmat.primitives import serialization
except ImportError:
    print("❌ Erro: Biblioteca 'cryptography' não encontrada.")
    print("")
    print("Para instalar:")
    print("  pip install cryptography")
    sys.exit(1)

def generate_ed25519_keys():
    """Gera par de chaves EdDSA (Ed25519)"""
    # Gerar chave privada
    private_key = Ed25519PrivateKey.generate()
    
    # Obter chave pública
    public_key = private_key.public_key()
    
    # Serializar chave privada (formato PEM)
    private_pem = private_key.private_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PrivateFormat.PKCS8,
        encryption_algorithm=serialization.NoEncryption()
    )
    
    # Serializar chave pública (formato raw para Sparkle)
    public_bytes = public_key.public_bytes(
        encoding=serialization.Encoding.Raw,
        format=serialization.PublicFormat.Raw
    )
    
    return private_pem, public_bytes

def main():
    script_dir = Path(__file__).parent
    project_dir = script_dir.parent
    keys_dir = project_dir / "keys"
    
    print("🔑 Gerando chaves EdDSA para Sparkle (usando Python)...")
    print("")
    
    # Criar diretório de chaves
    keys_dir.mkdir(exist_ok=True)
    
    private_key_path = keys_dir / "eddsa_private_key.pem"
    public_key_path = keys_dir / "eddsa_public_key.pem"
    
    # Verificar se já existe
    if private_key_path.exists():
        print(f"⚠️  Chave privada já existe em {private_key_path}")
        response = input("Deseja sobrescrever? (s/N): ")
        if response.lower() != 's':
            print("Operação cancelada.")
            return
    
    # Gerar chaves
    print("Gerando chaves...")
    private_pem, public_bytes = generate_ed25519_keys()
    
    # Salvar chave privada
    with open(private_key_path, 'wb') as f:
        f.write(private_pem)
    os.chmod(private_key_path, 0o600)  # Permissões restritas
    
    # Salvar chave pública (formato base64 para Sparkle)
    import base64
    public_base64 = base64.b64encode(public_bytes).decode('ascii')
    
    with open(public_key_path, 'w') as f:
        f.write(public_base64)
    
    print("")
    print("✅ Chaves geradas com sucesso!")
    print("")
    print("📋 Chave pública (adicione ao Info.plist como SUPublicEDKey):")
    print("---")
    print(public_base64)
    print("---")
    print("")
    print("⚠️  IMPORTANTE:")
    print(f"   - Chave privada: {private_key_path} (NUNCA commitar no git!)")
    print(f"   - Chave pública: {public_key_path} (pode ser commitada)")
    print("")
    print("A chave privada já está no .gitignore e não será commitada.")
    print("")
    print("📝 Próximo passo:")
    print("   Adicione a chave pública acima ao project.pbxproj como:")
    print('   INFOPLIST_KEY_SUPublicEDKey = "' + public_base64 + '";')

if __name__ == "__main__":
    main()
