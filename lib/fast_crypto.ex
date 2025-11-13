defmodule PiviEx.FastCrypto do
  @moduledoc """
  Fast symmetric encryption using AES-256-GCM.
  (from Claude Sonnet).
  """
  
  @aad "AES256GCM"

  @doc """
  Generates a random 256-bit encryption key.
  Returns the key as a binary.
  """
  def generate_key do
    :crypto.strong_rand_bytes(32)
  end

  @doc """
  Encrypts data using AES-256-GCM.
  Returns `{:ok, {iv, ciphertext, tag}}` or `{:error, reason}`.
  """
  def encrypt(plaintext, key) when byte_size(key) == 32 do
    try do
      iv = :crypto.strong_rand_bytes(16)
        
      {ciphertext, tag} = 
        :crypto.crypto_one_time_aead(:aes_256_gcm, 
          key, iv, plaintext, @aad, true)
          
      {:ok, {iv, ciphertext, tag}}
    rescue
      e -> {:error, e}
    end
  end

  def encrypt(_plaintext, _key), do: {:error, :invalid_key_size}

  @doc """
  Decrypts data using AES-256-GCM.
  Returns `{:ok, plaintext}` or `{:error, reason}`.
  """
  def decrypt({iv, ciphertext, tag}, key) when byte_size(key) == 32 do
    try do
      case :crypto.crypto_one_time_aead(:aes_256_gcm, key, iv, ciphertext, @aad, tag, false) do
        :error -> {:error, :decryption_failed}
        plaintext -> {:ok, plaintext}
      end
    rescue
      e -> {:error, e}
    end
  end

  def decrypt(_encrypted, _key), do: {:error, :invalid_key_size}

  @doc """
  Encrypts and returns a single binary for easy storage.
  Format: <<iv::binary-16, tag::binary-16, ciphertext::binary>>
  """
  def encrypt_pack(plaintext, key) do
    with {:ok, {iv, ciphertext, tag}} <- encrypt(plaintext, key) do
      {:ok, iv <> tag <> ciphertext}
    end
  end

  @doc """
  Decrypts from packed binary format.
  """
  def decrypt_unpack(<<iv::binary-16, tag::binary-16, ciphertext::binary>>, key) do
    decrypt({iv, ciphertext, tag}, key)
  end

  def decrypt_unpack(_packed, _key), do: {:error, :invalid_format}
end

