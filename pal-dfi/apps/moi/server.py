from http.server import BaseHTTPRequestHandler, HTTPServer
import json
import os

SERVICE_NAME = "moi"
PORT = int(os.getenv("PORT", "8080"))


class Handler(BaseHTTPRequestHandler):
    def _write_json(self, code, data):
        body = json.dumps(data).encode("utf-8")
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        if self.path == "/health":
            self._write_json(200, {"service": SERVICE_NAME, "status": "ok"})
            return

        if self.path.startswith("/verify-citizen"):
            self._write_json(200, {"service": SERVICE_NAME, "verified": True, "authority": "civil-registry"})
            return

        self._write_json(404, {"error": "not found"})


if __name__ == "__main__":
    server = HTTPServer(("0.0.0.0", PORT), Handler)
    print(f"{SERVICE_NAME} listening on :{PORT}")
    server.serve_forever()
