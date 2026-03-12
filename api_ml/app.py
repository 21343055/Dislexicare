from fastapi import FastAPI, UploadFile, File, Form, Request
from fastapi.middleware.cors import CORSMiddleware
import numpy as np
import tensorflow as tf
import joblib
import time

from utils import preprocess_text, preprocess_audio, calculate_text_similarity

# ======================
# INIT APP
# ======================
app = FastAPI(
    title="DislexiCare API",
    description="API Deteksi Dini Disleksia Anak Pra Sekolah",
    version="1.0"
)

# ======================
# MIDDLEWARE LOGGING
# ======================
@app.middleware("http")
async def log_requests(request: Request, call_next):
    print(f"\n📨 Incoming Request: {request.method} {request.url.path}")
    response = await call_next(request)
    print(f"✅ Response Status: {response.status_code}")
    return response

# ======================
# CORS (untuk PHP / Frontend)
# ======================
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # boleh diperketat nanti
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ======================
# LOAD MODEL & OBJECT
# ======================
model = tf.keras.models.load_model("model_disleksia_gru.keras")
tokenizer = joblib.load("tokenizer.pkl")
label_encoder = joblib.load("encoder_label.pkl")

# ======================
# HELPER DIAGNOSIS
# ======================
def get_prediction_and_category(confidence_disleksia_raw):
    """
    Mengubah raw confidence dari model 
    menjadi label hasil deteksi ("Tidak Disleksia" / "Disleksia") 
    dan kategori ("Aman", "Ringan", "Sedang", "Berat")
    """
    if confidence_disleksia_raw < 50.0:
        prediction = "Tidak Disleksia"
        category = "Aman"
    elif confidence_disleksia_raw < 70.0:
        prediction = "Disleksia"
        category = "Ringan"
    elif confidence_disleksia_raw < 90.0:
        prediction = "Disleksia"
        category = "Sedang"
    else:
        prediction = "Disleksia"
        category = "Berat"
    return prediction, category

# ======================
# ROOT CHECK
# ======================
@app.get("/")
def root():
    return {
        "status": "API aktif",
        "model": "GRU Disleksia",
        "author": "Muhamad Fathur Rahman",
        "timestamp": time.time()
    }

# ======================
# TEST ENDPOINT
# ======================
@app.post("/test")
async def test_endpoint(teks: str = Form(None), teks_soal: str = Form(None)):
    """
    Endpoint test untuk debugging
    """
    print(f"\n🔍 TEST ENDPOINT:")
    print(f"  - teks: {teks}")
    print(f"  - teks_soal: {teks_soal}")
    
    if teks_soal and teks:
        from utils import calculate_text_similarity
        similarity = calculate_text_similarity(teks_soal, teks)
        return {
            "status": "OK",
            "teks_received": teks,
            "teks_soal_received": teks_soal,
            "similarity": f"{similarity * 100:.1f}%"
        }
    
    return {
        "status": "OK",
        "teks_received": teks,
        "teks_soal_received": teks_soal
    }

# ======================
# PREDIKSI TEKS SAJA
# ======================
@app.post("/predict/text")
def predict_text(teks: str = Form(...)):
    x_text = preprocess_text(teks, tokenizer)

    # 🔴 dummy audio (WAJIB)
    x_audio = np.zeros((1, 40, 100, 1))  # SESUAI preprocess_audio

    pred = model.predict([x_text, x_audio], verbose=0)

    # 🆕 SELALU HITUNG CONFIDENCE UNTUK KELAS DISLEKSIA
    try:
        disleksia_index = list(label_encoder.classes_).index("Disleksia")
    except ValueError:
        disleksia_index = list(label_encoder.classes_).index("disleksia")
    
    confidence_disleksia = float(pred[0][disleksia_index]) * 100
    
    # 🎯 TENTUKAN DIAGNOSIS BERDASARKAN KATEGORI CONFIDENCE
    prediction, category = get_prediction_and_category(confidence_disleksia)

    return {
        "input_text": teks,
        "prediction": prediction,
        "confidence_disleksia": category,
        "confidence_raw": round(confidence_disleksia, 2)
    }


# ======================
# PREDIKSI AUDIO SAJA
# ======================
@app.post("/predict/audio")
async def predict_audio(audio: UploadFile = File(...)):
    audio_bytes = await audio.read()
    x_audio = preprocess_audio(audio_bytes)

    # 🔴 dummy text
    x_text = np.zeros((1, 100))  # max_len text

    pred = model.predict([x_text, x_audio], verbose=0)

    # 🆕 SELALU HITUNG CONFIDENCE UNTUK KELAS DISLEKSIA
    try:
        disleksia_index = list(label_encoder.classes_).index("Disleksia")
    except ValueError:
        disleksia_index = list(label_encoder.classes_).index("disleksia")
    
    confidence_disleksia = float(pred[0][disleksia_index]) * 100
    
    # 🎯 TENTUKAN DIAGNOSIS BERDASARKAN KATEGORI CONFIDENCE
    prediction, category = get_prediction_and_category(confidence_disleksia)

    return {
        "filename": audio.filename,
        "prediction": prediction,
        "confidence_disleksia": category,
        "confidence_raw": round(confidence_disleksia, 2)
    }


# ======================
# PREDIKSI GABUNGAN
# ======================
@app.post("/predict/multimodal")
async def predict_multimodal(
    teks: str = Form(...),
    audio: UploadFile = File(...),
    teks_soal: str = Form(None)  # 🆕 Teks referensi (opsional)
):
    try:
        start_total = time.time()
        print(f"\n{'='*60}")
        print(f"🎯 REQUEST MASUK - predict/multimodal")
        print(f"{'='*60}")
        print(f"  - Teks: '{teks}'")
        print(f"  - Teks Soal: '{teks_soal}'")
        print(f"  - Audio filename: {audio.filename}")
        print(f"  - Audio content_type: {audio.content_type}")
        
        # Read audio bytes
        audio_bytes = await audio.read()
        audio_size_mb = len(audio_bytes) / (1024 * 1024)
        print(f"  - Audio size: {len(audio_bytes)} bytes ({audio_size_mb:.2f} MB)")
        
        # ⚠️ VALIDASI UKURAN FILE (max 10MB)
        if len(audio_bytes) > 10 * 1024 * 1024:
            print(f"  ❌ File terlalu besar!")
            return {
                "error": "File audio terlalu besar",
                "detail": f"Ukuran maksimal 10MB, file Anda {audio_size_mb:.2f}MB"
            }

        # 🆕 ANALISIS KESALAHAN PENULISAN (jika ada teks_soal)
        text_similarity = 1.0
        confidence_disleksia = 0.0
        writing_error_detected = False
        
        if teks_soal and teks_soal.strip():
            start_time = time.time()
            text_similarity = calculate_text_similarity(teks_soal, teks)
            print(f"  - Text Similarity: {text_similarity * 100:.1f}% ({(time.time()-start_time)*1000:.0f}ms)")
            print(f"  - Referensi: '{teks_soal}'")
            print(f"  - Jawaban: '{teks}'")
            
            # 🔥 RULE SANGAT KETAT: 
            # Jika similarity < 95% (ada kesalahan), LANGSUNG DISLEKSIA!
            if text_similarity < 0.95:
                writing_error_detected = True
                error_rate = 1.0 - text_similarity
                
                # Hitung confidence berdasarkan error rate
                # Semakin besar error, semakin tinggi confidence
                confidence_disleksia = 70.0 + (error_rate * 30.0)
                confidence_disleksia = min(confidence_disleksia, 95.0)
                
                prediction, category = get_prediction_and_category(confidence_disleksia)
                
                print(f"  - ⚠️ KESALAHAN PENULISAN TERDETEKSI!")
                print(f"  - Error rate: {error_rate * 100:.1f}%")
                print(f"  - 🎯 DIAGNOSIS: {prediction} (rule-based)")
                print(f"  - Kategori: {category}")
                print(f"  - ⏱️ Total waktu: {(time.time()-start_total)*1000:.0f}ms")
                print(f"{'='*60}\n")
                
                return {
                    "prediction": prediction,
                    "confidence_disleksia": category,
                    "confidence_raw": round(confidence_disleksia, 2),
                    "method": "rule-based",
                    "text_similarity": round(text_similarity * 100, 2),
                    "reason": f"Kesalahan penulisan terdeteksi (similarity {text_similarity * 100:.1f}%)"
                }
            else:
                print(f"  - ✅ Penulisan hampir sempurna (similarity > 95%)")
        else:
            print(f"  - ⚠️ WARNING: Teks soal TIDAK ada! Hanya menggunakan ML model.")

        # 🆕 PREDIKSI ML (hanya jika tidak ada error penulisan signifikan)
        # Preprocess text
        start_time = time.time()
        x_text = preprocess_text(teks, tokenizer)
        print(f"  - Text preprocessing: {x_text.shape} ({(time.time()-start_time)*1000:.0f}ms)")
        
        # Preprocess audio
        start_time = time.time()
        x_audio = preprocess_audio(audio_bytes)
        print(f"  - Audio preprocessing: {x_audio.shape} ({(time.time()-start_time)*1000:.0f}ms)")

        # Predict dengan ML
        start_time = time.time()
        pred = model.predict([x_text, x_audio], verbose=0)
        print(f"  - Model prediction: ({(time.time()-start_time)*1000:.0f}ms)")
        
        # 🆕 SELALU HITUNG CONFIDENCE UNTUK KELAS DISLEKSIA
        try:
            disleksia_index = list(label_encoder.classes_).index("Disleksia")
        except ValueError:
            disleksia_index = list(label_encoder.classes_).index("disleksia")
        
        confidence_disleksia_ml = float(pred[0][disleksia_index]) * 100
        print(f"  - ML Confidence Disleksia (raw): {confidence_disleksia_ml:.2f}%")
        
        # Gunakan ML confidence
        confidence_disleksia = confidence_disleksia_ml
        
        # 🎯 TENTUKAN DIAGNOSIS BERDASARKAN KATEGORI CONFIDENCE
        prediction, category = get_prediction_and_category(confidence_disleksia)
        
        print(f"  - 🎯 DIAGNOSIS FINAL: {prediction} (confidence: {category})")
        print(f"  - ⏱️ Total waktu: {(time.time()-start_total)*1000:.0f}ms")
        print(f"{'='*60}\n")

        return {
            "prediction": prediction,
            "confidence_disleksia": category,
            "confidence_raw": round(confidence_disleksia, 2),
            "method": "ml-model",
            "text_similarity": round(text_similarity * 100, 2) if teks_soal else None
        }
    except Exception as e:
        print(f"\n❌ ERROR di predict_multimodal: {e}")
        import traceback
        traceback.print_exc()
        print(f"{'='*60}\n")
        return {
            "error": str(e),
            "detail": "Terjadi kesalahan saat memproses data"
        }
