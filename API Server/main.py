import json
import uvicorn
from fastapi import FastAPI, HTTPException, Depends, Security
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from pydantic import BaseModel
from llama_cpp import Llama

app = FastAPI()
security = HTTPBearer()

# Load valid keys from JSON
def load_api_keys():
    try:
        with open("api_keys.json", "r") as f:
            return json.load(f)
    except FileNotFoundError:
        return []

VALID_KEYS = load_api_keys()

# Dependency to check the token
def get_current_user(auth: HTTPAuthorizationCredentials = Security(security)):
    if auth.credentials not in VALID_KEYS:
        raise HTTPException(status_code=403, detail="Invalid or missing API Key")
    return auth.credentials


# --- MODEL LOADER ---
def load_model():
    return Llama(
        model_path="./Gemmasutra-Mini-2B-v1-IQ3_M.gguf",
        n_ctx=512,
        verbose=False
    )

llm = load_model()


class ChatRequest(BaseModel):
    message: str


@app.post("/")
async def chat(request: ChatRequest, token: str = Depends(get_current_user)):
    prompt = f"User: {request.message}\nAssistant:"

    output = llm(
        prompt,
        max_tokens=64,
        stop=["User:", "\n"],
        echo=False
    )

    response_text = output["choices"][0]["text"].strip()

    return {
        "result": True,
        "message": f"{response_text}"
    }


# --- RESET ENDPOINT ---
@app.post("/reset/")
async def reset_context(token: str = Depends(get_current_user)):
    global llm
    llm = load_model()

    return {
        "result": True,
        "message": "Model context reset successfully"
    }


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8010)
