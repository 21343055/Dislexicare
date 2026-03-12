import os
import tempfile
import re
import numpy as np
import librosa
from tensorflow.keras.preprocessing.sequence import pad_sequences

# ===== SET PATH FFmpeg (OPTIONAL - will use system PATH if not set) =====
# Uncomment dan sesuaikan path jika ffmpeg tidak ada di system PATH
# AudioSegment.converter = r"C:\path\to\ffmpeg.exe"
# AudioSegment.ffprobe  = r"C:\path\to\ffprobe.exe"

N_MFCC = 40
MAX_PAD_LEN = 100
MAX_TEXT_LEN = 100

def calculate_text_similarity(text_reference, text_answer):
    """
    Hitung similarity antara teks referensi dan teks jawaban menggunakan Levenshtein Distance.
    Returns: float 0.0 - 1.0 (semakin tinggi = semakin mirip)
    """
    # Normalisasi: lowercase dan hapus spasi berlebih
    s1 = text_reference.lower().strip()
    s2 = text_answer.lower().strip()
    
    # Hapus multiple spaces
    s1 = re.sub(r'\s+', ' ', s1)
    s2 = re.sub(r'\s+', ' ', s2)
    
    # Hitung Levenshtein Distance
    len1, len2 = len(s1), len(s2)
    
    # Matrix untuk dynamic programming
    matrix = [[0] * (len2 + 1) for _ in range(len1 + 1)]
    
    # Inisialisasi
    for i in range(len1 + 1):
        matrix[i][0] = i
    for j in range(len2 + 1):
        matrix[0][j] = j
    
    # Fill matrix
    for i in range(1, len1 + 1):
        for j in range(1, len2 + 1):
            cost = 0 if s1[i - 1] == s2[j - 1] else 1
            matrix[i][j] = min(
                matrix[i - 1][j] + 1,      # deletion
                matrix[i][j - 1] + 1,      # insertion
                matrix[i - 1][j - 1] + cost  # substitution
            )
    
    distance = matrix[len1][len2]
    max_length = max(len1, len2)
    
    # Hitung similarity (0-1)
    if max_length == 0:
        return 1.0
    
    similarity = 1.0 - (distance / max_length)
    return similarity

def preprocess_text(text, tokenizer):
    seq = tokenizer.texts_to_sequences([text])
    return pad_sequences(seq, maxlen=MAX_TEXT_LEN, padding="post")

def preprocess_audio(audio_bytes):
    """
    Preprocess audio bytes menjadi MFCC features
    SIMPLIFIED - langsung pakai librosa untuk semua format
    """
    wav_path = None
    try:
        print(f"    > Audio size: {len(audio_bytes)} bytes")
        
        # Simpan ke temp file
        with tempfile.NamedTemporaryFile(delete=False, suffix=".tmp") as tmp:
            tmp.write(audio_bytes)
            wav_path = tmp.name
        
        print(f"    > Loading audio...")
        
        # Librosa bisa handle MP3/WAV/M4A langsung (butuh ffmpeg)
        # duration=5 untuk speed up (hanya baca 5 detik pertama)
        y, sr = librosa.load(
            wav_path, 
            sr=16000, 
            mono=True, 
            duration=5.0,  # Hanya load 5 detik pertama
            res_type='kaiser_fast'
        )
        
        print(f"    > Loaded: {len(y)} samples @ {sr}Hz ({len(y)/sr:.1f}s)")
        
        # Extract MFCC
        print(f"    > Extracting MFCC...")
        mfcc = librosa.feature.mfcc(
            y=y, 
            sr=sr, 
            n_mfcc=N_MFCC, 
            n_fft=512,      # Reduced from 1024
            hop_length=256  # Reduced from 512
        )

        # Pad / truncate
        if mfcc.shape[1] < MAX_PAD_LEN:
            mfcc = np.pad(mfcc, ((0, 0), (0, MAX_PAD_LEN - mfcc.shape[1])))
        else:
            mfcc = mfcc[:, :MAX_PAD_LEN]

        # Reshape
        mfcc = mfcc.reshape(1, N_MFCC, MAX_PAD_LEN, 1)

        print(f"    > MFCC shape: {mfcc.shape}")
        
        # Cleanup
        if wav_path and os.path.exists(wav_path):
            try:
                os.remove(wav_path)
            except:
                pass

        return mfcc
        
    except Exception as e:
        print(f"    ❌ Error: {e}")
        if wav_path and os.path.exists(wav_path):
            try:
                os.remove(wav_path)
            except:
                pass
        raise RuntimeError(f"Gagal memproses audio: {str(e)}. Pastikan file audio valid dan ffmpeg terinstall.")

