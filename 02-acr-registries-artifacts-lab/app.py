from http.server import HTTPServer, BaseHTTPRequestHandler
import json

class SimpleInferenceHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.end_headers()
        
        response = {
            "service": "AI Inference API",
            "model_version": "v1.0.0",
            "status": "ready"
        }
        self.wfile.write(json.dumps(response).encode('utf-8'))

if __name__ == '__main__':
    server = HTTPServer(('0.0.0.0', 8080), SimpleInferenceHandler)
    print("AI Model server running on port 8080...")
    server.serve_forever()
