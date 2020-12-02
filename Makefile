PORT := 8089
WORKERS := 4

serve:
	uvicorn \
		--reload \
		--host 0.0.0.0 \
		--port $(PORT) \
		--workers $(WORKERS) \
		dashboard:app
