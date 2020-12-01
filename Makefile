serve:
	uvicorn \
		--reload \
		--host 0.0.0.0 \
		--port 8089 \
		dashboard:app
